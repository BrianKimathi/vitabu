<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Author_Request;
use App\Models\Common;
use App\Models\Payment_Option;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class AuthorRequestController extends Controller
{
    private $folder_user = "user";
    private $folder_kyc = "kyc_docs";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {
            $params['data'] = [];
            if ($request->ajax()) {

                $data = Author_Request::where('status', 0)->with('user')->orderBy('id', 'desc')->latest()->get();
                foreach ($data as $req) {

                    if ($req['user'] != null) {
                        $req['image'] = $this->common->getImage($this->folder_user, $req['user']['image']);
                    } else {
                        $req['image'] = asset('assets/imgs/default.png');
                    }

                    // Resolve KYC image URLs
                    $req['id_front_url'] = $this->common->getImage($this->folder_kyc, $req['id_front'] ?? '');
                    $req['id_back_url'] = $this->common->getImage($this->folder_kyc, $req['id_back'] ?? '');
                    $req['selfie_url'] = $this->common->getImage($this->folder_kyc, $req['selfie'] ?? '');
                    $req['otp_verified_text'] = ($req['is_otp_verified'] ?? 0) == 1 ? 'Verified' : 'Pending';
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('role', function ($row) {
                        return ucfirst($row->role ?? 'author');
                    })
                    ->addColumn('otp_verified_text', function ($row) {
                        $badge = ($row->is_otp_verified ?? 0) == 1
                            ? '<span class="badge" style="background:#E8F5E9;color:#2E7D32;font-size:11px;font-weight:600;padding:3px 10px;border-radius:6px;">Verified</span>'
                            : '<span class="badge" style="background:#FFF8E5;color:#F5A623;font-size:11px;font-weight:600;padding:3px 10px;border-radius:6px;">Pending</span>';
                        return $badge;
                    })
                    ->addColumn('kyc_docs', function ($row) {
                        $html = '<div style="display:flex;gap:4px;justify-content:center;">';
                        if (!empty($row->id_front_url)) {
                            $html .= "<a href='{$row->id_front_url}' target='_blank' class='btn btn-sm' style='background:#EEF0FF;color:#4E45B8;font-size:11px;font-weight:600;padding:2px 8px;border-radius:6px;'>ID-F</a>";
                        }
                        if (!empty($row->id_back_url)) {
                            $html .= "<a href='{$row->id_back_url}' target='_blank' class='btn btn-sm' style='background:#FFF0EE;color:#E54B4B;font-size:11px;font-weight:600;padding:2px 8px;border-radius:6px;'>ID-B</a>";
                        }
                        if (!empty($row->selfie_url)) {
                            $html .= "<a href='{$row->selfie_url}' target='_blank' class='btn btn-sm' style='background:#FFF8E5;color:#F5A623;font-size:11px;font-weight:600;padding:2px 8px;border-radius:6px;'>Selfie</a>";
                        }
                        $html .= !empty($row->id_front_url) || !empty($row->id_back_url) || !empty($row->selfie_url)
                            ? ''
                            : '<span style="font-size:12px;color:#9CA3AF;">—</span>';
                        $html .= '</div>';
                        return $html;
                    })
                    ->addColumn('action', function ($row) {
                        $detailUrl = route('admin.authorrequest.detail', $row->id);
                        $btn = "<a href='{$detailUrl}' class='btn btn-sm mb-1' style='background:#EEF0FF;color:#4E45B8;font-weight:600;padding:4px 12px;border-radius:8px;margin-right:4px;'>
                                    <i class='fa-solid fa-eye mr-1'></i> View
                                </a>";
                        $btn .= "<button type='button' class='btn btn-sm mb-1' style='background:#E8F5E9;color:#2E7D32;font-weight:600;padding:4px 12px;border-radius:8px;margin-right:4px;border:none;' id='$row->id' onclick='change_status($row->id, 1)'>
                                    <i class='fa-solid fa-check mr-1'></i> Approve
                                </button>";
                        $btn .= "<button type='button' class='btn btn-sm mb-1' style='background:#FFF0EE;color:#E54B4B;font-weight:600;padding:4px 12px;border-radius:8px;border:none;' id='$row->id' onclick='change_status($row->id, 0)'>
                                    <i class='fa-solid fa-xmark mr-1'></i> Reject
                                </button>";
                        return $btn;
                    })
                    ->addColumn('date', function ($row) {
                        return date("Y-m-d", strtotime($row->created_at));
                    })
                    ->rawColumns(['action', 'kyc_docs', 'otp_verified_text'])
                    ->make(true);
            }
            return view('admin.author_request.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show(Request $request)
    {
        try {

            $id = $request['id'];
            $status = $request['status'];

            $data = Author_Request::where('id', $id)->first();
            if ($data && $status == 1) {

                $user =  User::where('id', $data['user_id'])->first();
                if (!$user) {
                    return response()->json(['status' => 400, 'errors' => __('label.user_not_found')]);
                }

                $role = $data['role'] ?? 'author';

                // Use subaccount_code if already created during registration, otherwise create now
                $subaccountCode = $data['subaccount_code'] ?? '';
                if (empty($subaccountCode) && ($data['payment_method'] ?? 'bank') === 'bank') {
                    $subaccountCode = $this->createPaystackSubaccount($user, $data);
                }

                $user->update([
                    'is_author' => 1,
                    'is_publisher' => $role === 'publisher' ? 1 : 0,
                    'payment_method' => $data['payment_method'] ?? 'bank',
                    'mpesa_phone' => $data['mpesa_phone'] ?? '',
                    'bank_name' => (($data['payment_method'] ?? 'bank') === 'bank') ? ($data['bank_name'] ?? '') : '',
                    'bank_code' => (($data['payment_method'] ?? 'bank') === 'bank') ? ($data['bank_code'] ?? '') : '',
                    'bank_holder_name' => (($data['payment_method'] ?? 'bank') === 'bank') ? ($data['bank_holder_name'] ?? '') : '',
                    'account_no' => (($data['payment_method'] ?? 'bank') === 'bank') ? ($data['account_no'] ?? '') : '',
                    'ifsc_code' => (($data['payment_method'] ?? 'bank') === 'bank') ? ($data['ifsc_code'] ?? '') : '',
                    'id_front' => $data['id_front'] ?? null,
                    'id_back' => $data['id_back'] ?? null,
                    'selfie' => $data['selfie'] ?? null,
                    'subaccount_code' => $subaccountCode,
                ]);

                $data->delete();

                $mailResult = $this->sendAuthorStatusEmail($user['email'], 1, $user['first_name'] ?? '', $user['last_name'] ?? '');
                Log::info('admin.author_request.approve.mail', [
                    'user_id' => $user['id'],
                    'email' => $user['email'],
                    'result' => is_bool($mailResult) ? ($mailResult ? 'sent' : 'failed') : 'unknown',
                ]);
                $status = $this->resolveAuthorRequestStatusConfig();
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $this->common->SaveNotification(1, 3, $user['id'], 0, 0, 0, 0, "", $user['device_type'], $user['device_token'], 1, "");
                }
            } elseif ($data && $status == 0) {
                $role = $data['role'] ?? 'author';
                User::where('id', $data['user_id'])->update([
                    'is_author' => 0,
                    'is_publisher' => 0,
                ]);
                $data->delete();

                $user = User::where('id', $data['user_id'])->first();
                $mailResult = $this->sendAuthorStatusEmail($user['email'], 0, $user['first_name'] ?? '', $user['last_name'] ?? '');
                Log::info('admin.author_request.reject.mail', [
                    'user_id' => $user['id'],
                    'email' => $user['email'],
                    'result' => is_bool($mailResult) ? ($mailResult ? 'sent' : 'failed') : 'unknown',
                ]);
                $status = $this->resolveAuthorRequestStatusConfig();
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $this->common->SaveNotification(1, 3, $user['id'], 0, 0, 0, 0, "", $user['device_type'], $user['device_token'], 0, "");
                }
            }

            return response()->json(['status' => 200, 'success' => __('label.request_update')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ---------------------------------------------------------------
    //  Detail Page — View full author request in a clean page
    // ---------------------------------------------------------------
    public function detail($id)
    {
        try {
            $params['request'] = Author_Request::with('user')->where('id', $id)->firstOrFail();
            $params['request']['user_image'] = $this->common->getImage($this->folder_user, $params['request']['user']['image'] ?? '');
            $params['request']['id_front_url'] = $this->common->getImage($this->folder_kyc, $params['request']['id_front'] ?? '');
            $params['request']['id_back_url'] = $this->common->getImage($this->folder_kyc, $params['request']['id_back'] ?? '');
            $params['request']['selfie_url'] = $this->common->getImage($this->folder_kyc, $params['request']['selfie'] ?? '');

            return view('admin.author_request.view', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    private function createPaystackSubaccount($user, $requestData): string
    {
        try {
            $paystack = Payment_Option::where('name', 'paystack')->first();
            $secret = trim((string) ($paystack->key_2 ?? ''));
            if ($secret === '') return '';

            $businessName = trim(($user['first_name'] ?? '') . ' ' . ($user['last_name'] ?? ''));
            if ($businessName === '') {
                $businessName = $user['user_name'] ?? ('author_' . ($user['id'] ?? ''));
            }

            $response = Http::withToken($secret)->post('https://api.paystack.co/subaccount', [
                'business_name' => $businessName,
                'settlement_bank' => (string) ($requestData['bank_code'] ?? ''),
                'account_number' => (string) ($requestData['account_no'] ?? ''),
                'percentage_charge' => 0,
                'description' => 'Vitabu author payout subaccount',
                'primary_contact_email' => $user['email'] ?? '',
            ]);

            if (!$response->ok()) return '';
            $payload = $response->json();
            return $payload['data']['subaccount_code'] ?? '';
        } catch (\Throwable $e) {
            return '';
        }
    }

    private function resolveAuthorRequestStatusConfig()
    {
        // Backward compatibility: some databases use "auther", others "author".
        $config = $this->common->BasicNotiConfiguration('auther-request-status-change');
        if (!$config) {
            $config = $this->common->BasicNotiConfiguration('author-request-status-change');
        }
        if (!$config) {
            Log::warning('admin.author_request.config_missing', [
                'expected_types' => ['auther-request-status-change', 'author-request-status-change'],
            ]);
            // Safe default: allow mail/notification when config row is missing.
            return ['status' => 1, 'send_mail' => 1, 'send_notification' => 1];
        }
        return $config;
    }

    private function sendAuthorStatusEmail(string $email, int $requestStatus, string $firstName, string $lastName): bool
    {
        try {
            $sent = $this->common->Send_Mail(4, $email, $requestStatus, "", 0, $firstName, $lastName, "", "");
            if ($sent === true) return true;
        } catch (\Throwable $e) {
            Log::warning('admin.author_request.send_mail.common_failed', ['error' => $e->getMessage()]);
        }

        try {
            // Hard fallback path (same template family as common mail type 4).
            $this->common->SetSmtpConfig();
            $details = [
                'title' => App_Name() . " - Author Request Status",
            ];
            $view = $requestStatus === 1 ? 'mail.author_request_yes' : 'mail.author_request_no';
            Mail::send($view, ['details' => $details], function ($message) use ($email, $details) {
                $message->to($email)->subject($details['title']);
            });
            return true;
        } catch (\Throwable $e) {
            Log::error('admin.author_request.send_mail.fallback_failed', ['error' => $e->getMessage()]);
            return false;
        }
    }
}
