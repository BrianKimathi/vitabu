<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Withdrawal_Request;
use App\Models\Common;
use App\Models\Payment_Option;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class WithdrawalController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {
            $params['author'] = User::where('is_author', 1)->latest()->get();

            if ($request->ajax()) {

                $input_status = $request['input_status'];
                $input_author_id = $request['input_author_id'];

                $query = Withdrawal_Request::query();
                if ($input_author_id != "0") {
                    $query->where('author_id', $input_author_id);
                }
                if ($input_status != "all") {
                    $query->where('status', $input_status);
                }
                $data = $query->with('author')->orderBy('status', 'asc')->latest()->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('date', function ($row) {
                        $date = date("d M Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->addColumn('action', function ($row) {

                        $pendingLabel = __('label.pending');
                        $completedLabel = __('label.completed');

                        $pendingStatus = $row->status == 0 ? "selected" : "";
                        $completedStatus = $row->status == 1 ? "selected" : "";

                        $status = "<select class='form-control status-change' id='" . $row->id . "'>
                        <option value='0' " . $pendingStatus . " >" . $pendingLabel . "</option>
                        <option value='1'  " . $completedStatus . " >" . $completedLabel . "</option>
                        </select>";
                        return $status;
                    })
                    ->rawColumns(['action'])
                    ->make(true);
            }
            return view('admin.withdrawal.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show($id)
    {
        try {

            $data = Withdrawal_Request::where('id', $id)->first();
            if (isset($data)) {
                $oldStatus = (int) $data->status;
                $nextStatus = $data->status === 1 ? 0 : 1;
                if ($oldStatus === 0 && (int) $nextStatus === 1) {
                    $transferResult = $this->sendPaystackTransfer($data);
                    if (!$transferResult['success']) {
                        $this->persistPayoutAudit($data, [
                            'payout_status' => 'failed',
                            'payout_gateway' => $transferResult['gateway'] ?? 'paystack',
                            'payout_reference' => $transferResult['reference'] ?? '',
                            'payout_response' => $transferResult['response'] ?? '',
                            'payout_error' => $transferResult['error'] ?? 'Unknown payout failure',
                        ]);
                        return response()->json(['status' => 400, 'errors' => __('label.data_not_updated') . ' (' . ($transferResult['error'] ?? 'Paystack transfer failed') . ')']);
                    }
                    $this->persistPayoutAudit($data, [
                        'payout_status' => 'success',
                        'payout_gateway' => $transferResult['gateway'] ?? 'paystack',
                        'payout_reference' => $transferResult['reference'] ?? '',
                        'payout_response' => $transferResult['response'] ?? '',
                        'payout_error' => '',
                    ]);
                }
                $data->status = $nextStatus;
                $data->save();

                // If moved from completed -> pending, rollback wallet for safety.
                if ($oldStatus === 1 && (int) $data->status === 0) {
                    // Prevent double-credit if toggled repeatedly.
                    if ((float) $data['price'] > 0) {
                        User::where('id', $data['author_id'])->increment('wallet_amount', (float) $data['price']);
                    }
                    $this->persistPayoutAudit($data, [
                        'payout_status' => 'reverted',
                        'payout_gateway' => 'admin',
                        'payout_reference' => '',
                        'payout_response' => 'Withdrawal moved back to pending by admin; wallet re-credited.',
                        'payout_error' => '',
                    ]);
                }

                // Notification & Mail Sent
                $user = User::where('id', $data['author_id'])->first();
                $status = $this->common->BasicNotiConfiguration('withdrawal-request-status-chagne');
                if ($status['status'] == 1 && $status['send_mail'] == 1) {
                    $this->common->Send_Mail(7, $user['email'], $data->status, "", 0, $user['first_name'], $user['last_name'], "", "", "");
                }
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $this->common->SaveNotification(0, 6, $user['id'], 0, 0, 0, 0, "", $user['device_type'], $user['device_token'], 0, "");
                }

                return response()->json(['status' => 200, 'success' => __('label.status_changed'), 'status_code' => $data->status]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_found')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    private function sendPaystackTransfer(Withdrawal_Request $withdrawal): array
    {
        try {
            $user = User::where('id', $withdrawal->author_id)->first();
            if (!$user) {
                return [
                    'success' => false,
                    'gateway' => 'paystack',
                    'reference' => '',
                    'response' => '',
                    'error' => 'User not found for withdrawal.',
                ];
            }
            if (($user->payment_method ?? 'bank') !== 'bank') {
                // Mpesa/manual payout can be completed by admin outside Paystack.
                return [
                    'success' => true,
                    'gateway' => 'manual',
                    'reference' => 'manual-' . $withdrawal->id . '-' . now()->timestamp,
                    'response' => 'Manual payout path selected by payment method.',
                    'error' => '',
                ];
            }
            if (empty($user->bank_code) || empty($user->account_no)) {
                return [
                    'success' => false,
                    'gateway' => 'paystack',
                    'reference' => '',
                    'response' => '',
                    'error' => 'Missing bank_code/account_no on user profile.',
                ];
            }

            $paystack = Payment_Option::where('name', 'paystack')->first();
            $secret = trim((string) ($paystack->key_2 ?? ''));
            if ($secret === '') {
                return [
                    'success' => false,
                    'gateway' => 'paystack',
                    'reference' => '',
                    'response' => '',
                    'error' => 'Paystack secret key is missing.',
                ];
            }

            $recipientResponse = Http::withToken($secret)
                ->post('https://api.paystack.co/transferrecipient', [
                    'type' => 'nuban',
                    'name' => trim(($user->first_name ?? '') . ' ' . ($user->last_name ?? '')),
                    'account_number' => (string) $user->account_no,
                    'bank_code' => (string) $user->bank_code,
                    'currency' => 'KES',
                ]);

            if (!$recipientResponse->ok()) {
                return [
                    'success' => false,
                    'gateway' => 'paystack',
                    'reference' => '',
                    'response' => (string) $recipientResponse->body(),
                    'error' => 'Failed to create transfer recipient.',
                ];
            }
            $recipientPayload = $recipientResponse->json();
            $recipientCode = $recipientPayload['data']['recipient_code'] ?? '';
            if ($recipientCode === '') {
                return [
                    'success' => false,
                    'gateway' => 'paystack',
                    'reference' => '',
                    'response' => json_encode($recipientPayload),
                    'error' => 'Paystack recipient code missing in response.',
                ];
            }

            $transferResponse = Http::withToken($secret)->post('https://api.paystack.co/transfer', [
                'source' => 'balance',
                'amount' => ((float) $withdrawal->price) * 100,
                'recipient' => $recipientCode,
                'reason' => 'Author/Publisher withdrawal payout',
            ]);
            $transferPayload = $transferResponse->json();
            $reference = $transferPayload['data']['reference'] ?? ($transferPayload['data']['transfer_code'] ?? '');
            return [
                'success' => $transferResponse->ok(),
                'gateway' => 'paystack',
                'reference' => (string) $reference,
                'response' => (string) $transferResponse->body(),
                'error' => $transferResponse->ok() ? '' : 'Paystack transfer request failed.',
            ];
        } catch (\Throwable $e) {
            return [
                'success' => false,
                'gateway' => 'paystack',
                'reference' => '',
                'response' => '',
                'error' => $e->getMessage(),
            ];
        }
    }

    private function persistPayoutAudit(Withdrawal_Request $withdrawal, array $audit): void
    {
        try {
            Log::info('withdrawal.payout_audit', [
                'withdrawal_id' => $withdrawal->id,
                'author_id' => $withdrawal->author_id,
                'amount' => $withdrawal->price,
                'status' => $audit['payout_status'] ?? '',
                'gateway' => $audit['payout_gateway'] ?? '',
                'reference' => $audit['payout_reference'] ?? '',
                'error' => $audit['payout_error'] ?? '',
            ]);

            $table = $withdrawal->getTable();
            $dbPayload = [];
            foreach ($audit as $column => $value) {
                if (Schema::hasColumn($table, $column)) {
                    $dbPayload[$column] = (string) $value;
                }
            }
            if (!empty($dbPayload)) {
                $withdrawal->fill($dbPayload);
                $withdrawal->save();
            }
        } catch (\Throwable $e) {
            Log::error('withdrawal.payout_audit.persist_failed', [
                'withdrawal_id' => $withdrawal->id ?? 0,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
