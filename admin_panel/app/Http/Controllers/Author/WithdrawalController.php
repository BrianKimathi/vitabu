<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\Withdrawal_Request;
use App\Models\Common;
use App\Models\Payment_Option;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;

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

            $author = User::where('id', Author_Data()['id'])->first();
            $params['authorData'] = $author;
            $params['paystackBanks'] = $this->getPaystackBanks();

            if ($request->ajax()) {

                $data = Withdrawal_Request::where('author_id', $author['id'])->orderBy('status', 'asc')->orderBy('id', 'desc')->latest()->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('date', function ($row) {
                        $date = date("Y-m-d", strtotime($row->created_at));
                        return $date;
                    })
                    ->addColumn('action', function ($row) {
                        if ($row->status == 0) {
                            $showLabel = __('label.pending');
                            return "<button type='button' class='hide-btn'>$showLabel</button>";
                        } else if ($row->status == 1) {
                            $hideLabel = __('label.completed');
                            return "<button type='button' class='show-btn'>$hideLabel</button>";
                        } else {
                            return "-";
                        }
                    })
                    ->rawColumns(['action'])
                    ->make(true);
            }
            return view('author.withdrawal.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'price' => 'required|numeric|min:1',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $author = User::where('id', Author_Data()['id'])->first();
            if (!$author) {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_updated')]);
            }
            if ($author['wallet_amount'] < $request['price']) {
                return response()->json(['status' => 400, 'errors' => __('label.insufficient_balance')]);
            }

            [$paymentType, $paymentDetail] = $this->buildPayoutSummary($author);
            if (empty($paymentType) || empty($paymentDetail)) {
                return response()->json([
                    'status' => 400,
                    'errors' => 'Please update your payout details first (Bank or Mpesa) before requesting withdrawal.'
                ]);
            }

            $insert = new Withdrawal_Request();
            $insert['author_id'] = $author['id'];
            $insert['price'] = $request['price'];
            $insert['payment_type'] = $paymentType;
            $insert['payment_detail'] = $paymentDetail;
            $insert['status'] = 0;
            if ($insert->save()) {

                User::where('id', $author['id'])->decrement('wallet_amount', $request['price']);

                // Notification Sent
                $user = User::where('id', $author['id'])->first();
                $status = $this->common->BasicNotiConfiguration('add-withdrawal-request');
                if ($status['status'] == 1 && $status['send_mail'] == 1) {
                    $this->common->Send_Mail(6, $user['email'], 0, "", 0, $user['first_name'], $user['last_name'], "", "");
                }
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $this->common->SaveNotification(0, 5, $user['id'], 0, 0, 0, 0, "", $user['device_type'], $user['device_token'], 0, "");
                }

                return response()->json(['status' => 200, 'success' => __('label.success_add_withdrawal_request')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_withdrawal_request')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function updatePayoutDetails(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'payment_method' => 'required|in:bank,mpesa',
                'mpesa_phone' => 'required_if:payment_method,mpesa',
                'bank_code' => 'required_if:payment_method,bank',
                'bank_name' => 'required_if:payment_method,bank',
                'bank_holder_name' => 'required_if:payment_method,bank',
                'account_no' => 'required_if:payment_method,bank',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $author = User::where('id', Author_Data()['id'])->first();
            if (!$author) {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_updated')]);
            }

            $paymentMethod = $request['payment_method'];
            if ($paymentMethod === 'mpesa') {
                $author->payment_method = 'mpesa';
                $author->mpesa_phone = preg_replace('/\D+/', '', (string) $request['mpesa_phone']);
                $author->bank_name = '';
                $author->bank_code = '';
                $author->bank_holder_name = '';
                $author->account_no = '';
                $author->ifsc_code = '';
            } else {
                $author->payment_method = 'bank';
                $author->bank_code = (string) $request['bank_code'];
                $author->bank_name = (string) $request['bank_name'];
                $author->bank_holder_name = (string) $request['bank_holder_name'];
                $author->account_no = (string) $request['account_no'];
                $author->ifsc_code = (string) ($request['ifsc_code'] ?? '');
                $author->mpesa_phone = '';
            }
            $author->save();

            return response()->json(['status' => 200, 'success' => 'Payout details updated successfully.']);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    private function buildPayoutSummary(User $author): array
    {
        $method = strtolower((string) ($author->payment_method ?? ''));
        if ($method === 'mpesa') {
            $phone = trim((string) ($author->mpesa_phone ?? ''));
            if ($phone === '') return ['', ''];
            return ['Mpesa', 'Mpesa Phone: ' . $phone];
        }

        if ($method === 'bank') {
            $bankName = trim((string) ($author->bank_name ?? ''));
            $holder = trim((string) ($author->bank_holder_name ?? ''));
            $account = trim((string) ($author->account_no ?? ''));
            if ($bankName === '' || $holder === '' || $account === '') return ['', ''];
            $detail = "Bank: {$bankName}; Holder: {$holder}; A/C: {$account}";
            return ['Bank', $detail];
        }

        return ['', ''];
    }

    private function getPaystackBanks(): array
    {
        try {
            $paystack = Payment_Option::where('name', 'paystack')->first();
            $secret = trim((string) ($paystack->key_2 ?? ''));
            if ($secret === '') return [];

            $response = Http::withToken($secret)->get('https://api.paystack.co/bank', [
                'country' => 'kenya',
                'perPage' => 100,
            ]);
            if (!$response->ok()) return [];

            $banks = $response->json('data') ?? [];
            return array_values(array_filter($banks, function ($bank) {
                return isset($bank['active']) ? (bool) $bank['active'] : true;
            }));
        } catch (\Throwable $e) {
            return [];
        }
    }
}
