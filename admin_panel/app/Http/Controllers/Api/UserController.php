<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Author_Request;
use App\Models\Category;
use App\Models\Common;
use App\Models\General_Setting;
use App\Models\Login_History;
use App\Models\Payment_Option;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

// Login Type : 1- OTP, 2- Google, 3- Apple, 4- Normal
class UserController extends Controller
{
    private $folder_user = "user";
    private $folder_plan = "plan";
    public $common;
    public $page_limit;
    public function __construct()
    {
        try {
            $this->common = new Common();
            $this->page_limit = env('PAGE_LIMIT');
        } catch (Exception $e) {
            Log::error('api.user_controller.construct_error', ['error' => $e->getMessage()]);
            // Constructors cannot return a response. Let the error bubble or just log it.
        }
    }

    public function register(Request $request)
    {
        try {

            $validation = Validator::make($request->all(), [
                'first_name' => 'required|min:2',
                'last_name' => 'required|min:2',
                'email' => 'required|unique:tbl_user|email',
                'password' => 'required|min:4',
                'mobile_number' => 'required|numeric|unique:tbl_user,mobile_number',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $device_type = (int)$request['device_type'] ?? 0;
            $device_token = $request['device_token'] ?? '';
            $user_name = explode('@', $request['email']);

            $insert = array(
                'is_author' => 0,
                'category_ids' => '',
                'user_name' => $this->common->userName($user_name[0]),
                'first_name' => $request['first_name'],
                'last_name' => $request['last_name'],
                'email' => $request['email'],
                'password' => Hash::make($request['password']),
                'mobile_number' => $request['mobile_number'],
                'image' => '',
                'type' => 4,
                'address' => '',
                'description' => $this->common->user_tag_line(),
                'wallet_amount' => 0,
                'device_type' => $device_type,
                'device_token' => $device_token,
                'bank_name' => "",
                'bank_holder_name' => "",
                'account_no' => "",
                'ifsc_code' => "",
                'status' => 1,
            );
            $user_id = User::insertGetId($insert);
            if (isset($user_id)) {

                $user = User::where('id', $user_id)->first();
                if (isset($user)) {

                    $user['image'] = $this->common->getImage($this->folder_user, $user['image']);

                    $status = $this->common->BasicNotiConfiguration('register');
                    if ($status['status'] == 1 && $status['send_mail'] == 1) {
                        $this->common->Send_Mail(1, $user['email'], 0, "", 0, "", "", "", "");
                    }

                    return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function login(Request $request)
    {
        try {

            if ($request['type'] == 1) {

                $validation = Validator::make($request->all(), [
                    'mobile_number' => 'required',
                ]);
            } elseif ($request['type'] == 2 || $request['type'] == 3) {

                $validation = Validator::make($request->all(), [
                    'email' => 'required',
                ]);
            } elseif ($request->type == 4) {

                $validation = Validator::make($request->all(), [
                    'email' => 'required|email',
                    'password' => 'required|min:4',
                ]);
            } else {

                $validation = Validator::make($request->all(), [
                    'type' => 'required|numeric',
                ]);
            }
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $type = $request['type'];
            $first_name = $request['first_name'] ?? '';
            $last_name = $request['last_name'] ?? '';
            $email = $request['email'] ?? '';
            $password = $request['password'] ?? '';
            $mobile_number = $request['mobile_number'] ?? '';
            $device_type = (int) $request['device_type'] ?? 0;
            $device_token = $request['device_token'] ?? '';
            $image = '';
            if (isset($request['image']) && $request['image'] != null) {
                $file = $request->file('image');
                $image = $this->common->saveImage($file, $this->folder_user, 'user_');
            }

            // OTP
            if ($type == 1) {

                $user = User::where('mobile_number', $mobile_number)->where('type', $type)->latest()->first();
                if ($user) {

                    $user['image'] = $this->common->getImage($this->folder_user, $user['image']);

                    return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                } else {

                    $insert = array(
                        'is_author' => 0,
                        'category_ids' => "",
                        'user_name' => $this->common->userName($mobile_number),
                        'first_name' => $first_name,
                        'last_name' => $last_name,
                        'email' => $email,
                        'password' => $password,
                        'mobile_number' => $mobile_number,
                        'image' => $image,
                        'type' => $type,
                        'address' => "",
                        'description' => $this->common->user_tag_line(),
                        'wallet_amount' => 0,
                        'device_type' => $device_type,
                        'device_token' => $device_token,
                        'bank_name' => "",
                        'bank_holder_name' => "",
                        'account_no' => "",
                        'ifsc_code' => "",
                        'status' => 1,
                    );
                    $user_id = User::insertGetId($insert);

                    if (isset($user_id)) {

                        Login_History::create([
                            'user_id' => $user_id,
                            'login_time' => now(),
                            'logout_time' => '',
                        ]);

                        $user = User::where('id', $user_id)->first();
                        if ($user) {

                            $user['image'] = $this->common->getImage($this->folder_user, $user['image']);

                            return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                        } else {
                            return $this->common->API_Response(400, __('api_msg.data_not_found'));
                        }
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_save'));
                    }
                }
            }

            // Google || Apple
            if ($type == 2 || $type == 3) {

                // Email-first lookup avoids duplicate accounts when login type changes.
                $user = User::where('email', $email)->latest()->first();
                if (isset($user) && $user != null) {
                    $user->update([
                        'type' => $type,
                        'device_type' => $device_type,
                        'device_token' => $device_token,
                        'status' => 1,
                    ]);

                    Login_History::create([
                        'user_id' => $user->id,
                        'login_time' => now(),
                        'logout_time' => '',
                    ]);

                    $user['image'] = $this->common->getImage($this->folder_user, $user['image']);

                    // Send Mail
                    if ($type == 2) {
                        $status = $this->common->BasicNotiConfiguration('login');
                        if ($status['status'] == 1 && $status['send_mail'] == 1) {
                            $this->common->Send_Mail(2, $user['email'], 0, "", 0, "", "", "", "");
                        }
                    }

                    return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                } else {
                    $userNameSeed = $mobile_number;
                    if (empty($userNameSeed)) {
                        $userNameSeed = Str::before($email, '@');
                    }

                    $insert = array(
                        'is_author' => 0,
                        'category_ids' => "",
                        'user_name' => $this->common->userName($userNameSeed),
                        'first_name' => $first_name,
                        'last_name' => $last_name,
                        'email' => $email,
                        'password' => $password,
                        'mobile_number' => $mobile_number,
                        'image' => $image,
                        'type' => $type,
                        'address' => "",
                        'description' => $this->common->user_tag_line(),
                        'wallet_amount' => 0,
                        'device_type' => $device_type,
                        'device_token' => $device_token,
                        'bank_name' => "",
                        'bank_holder_name' => "",
                        'account_no' => "",
                        'ifsc_code' => "",
                        'status' => 1,
                    );
                    $user_id = User::insertGetId($insert);

                    if (isset($user_id)) {

                        Login_History::create([
                            'user_id' => $user_id,
                            'login_time' => now(),
                            'logout_time' => '',
                        ]);

                        $user = User::where('id', $user_id)->first();
                        if ($user) {

                            $user['image'] = $this->common->getImage($this->folder_user, $user['image']);

                            // Send Mail
                            if ($type == 2) {
                                $status = $this->common->BasicNotiConfiguration('login');
                                if ($status['status'] == 1 && $status['send_mail'] == 1) {
                                    $this->common->Send_Mail(2, $user['email'], 0, "", 0, "", "", "", "");
                                }
                            }

                            return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                        } else {
                            return $this->common->API_Response(400, __('api_msg.data_not_found'));
                        }
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_save'));
                    }
                }
            }

            // Normal
            if ($type == 4) {

                $user = User::where('email', $email)->where('type', $type)->latest()->first();
                if ($user) {

                    Login_History::create([
                        'user_id' => $user->id,
                        'login_time' => now(),
                        'logout_time' => '',
                    ]);

                    if (Hash::check($password, $user['password'])) {

                        $user['image'] = $this->common->getImage($this->folder_user, $user['image']);

                        return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                    } else {
                        return $this->common->API_Response(400, __('api_msg.email_pass_wrong'));
                    }
                } else {
                    return $this->common->API_Response(400, __('api_msg.email_pass_wrong'));
                }
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_profile(Request $request)
    {
        try {

            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];

            $user_data = User::where('id', $user_id)->with('author_request')->first();
            if ($user_data) {

                $Ids = explode(',', $user_data['category_ids']);

                $data = Category::select('id', 'name')->whereIn('id', $Ids)->latest()->get();
                if (count($data) > 0) {

                    foreach ($data as $key => $value) {
                        $final_data[] = $value['name'];
                    }

                    $IDs = implode(", ", $final_data);
                    $user_data['category_name'] = $IDs;
                } else {
                    $user_data['category_name'] = "";
                }

                $user_data['image'] = $this->common->getImage($this->folder_user, $user_data['image']);
                $user_data['total_audio_books'] = $this->common->totalAudioBooks($user_data['id']);
                $user_data['total_novels'] = $this->common->totalNovels($user_data['id']);
                $user_data['total_magazines'] = $this->common->totalMagazine($user_data['id']);
                $user_data['is_subscription'] = $this->common->isSubscription($user_data['id']);

                $transaction = Transaction::with('plan')->where('user_id', $user_data['id'])->where('status', 1)->latest()->first();
                if ($transaction && $transaction['plan'] != null) {
                    $user_data['plan_name'] = $transaction['plan']['name'];
                    $user_data['plan_price'] = $transaction['plan']['price'];
                    $user_data['plan_image'] = $this->common->getImage($this->folder_plan, $transaction['plan']['image']);
                } else {
                    $user_data['plan_name'] = "";
                    $user_data['plan_price'] = 0;
                    $user_data['plan_image'] = "";
                }

                unset($user_data['author_request']);

                return $this->common->API_Response(200, __('api_msg.data_retrieved'), array($user_data));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function update_profile(Request $request)
    {
        try {

            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $array = array();

            $data = User::where('id', $user_id)->first();
            if ($data) {

                if (!empty($request['user_name'])) {

                    $check = User::where('user_name', $request['user_name'])->first();
                    if ($check) {
                        if ($check['id'] == $data['id']) {
                            $array['user_name'] = $request['user_name'];
                        } else {
                            return $this->common->API_Response(400, __('api_msg.user_name_exists'));
                        }
                    } else {
                        $array['user_name'] = $request['user_name'];
                    }
                }
                if (!empty($request['first_name'])) {
                    $array['first_name'] = $request['first_name'];
                }
                if (!empty($request['last_name'])) {
                    $array['last_name'] = $request['last_name'];
                }
                if (!empty($request['email'])) {

                    $check = User::where('email', $request['email'])->first();
                    if ($check) {

                        if ($check['id'] == $data['id']) {
                            $array['email'] = $request['email'];
                        } else {
                            return $this->common->API_Response(400, __('api_msg.email_exists'));
                        }
                    } else {
                        $array['email'] = $request['email'];
                    }
                }
                if (!empty($request['password']) && !empty($request['confirm_password'])) {
                    if (strlen($request['password']) < 4) {
                        return $this->common->API_Response(400, __('api_msg.password_must_be_atleast_4_character'));
                    }

                    if ($request['password'] != $request['confirm_password']) {
                        return $this->common->API_Response(400, __('api_msg.password_do_not_match'));
                    }

                    $array['password'] = Hash::make($request['password']);
                }
                if (!empty($request['mobile_number'])) {

                    $check = User::where('mobile_number', $request['mobile_number'])->first();
                    if ($check) {
                        if ($check['id'] == $data['id']) {
                            $array['mobile_number'] = $request['mobile_number'];
                        } else {
                            return $this->common->API_Response(400, __('api_msg.mobile_number_exists'));
                        }
                    } else {
                        $array['mobile_number'] = $request['mobile_number'];
                    }
                }
                if ($request->hasFile('image')) {

                    $image = $request->file('image');
                    $array['image'] = $this->common->saveImage($image, $this->folder_user, 'user_');
                    $this->common->deleteImageToFolder($this->folder_user, $data['image']);
                }
                if (!empty($request['address'])) {
                    $array['address'] = $request['address'];
                }
                if (!empty($request['description'])) {
                    $array['description'] = $request['description'];
                }
                if (!empty($request['category_ids'])) {
                    $array['category_ids'] = $request['category_ids'];
                }
                if (!empty($request['bank_name'])) {
                    $array['bank_name'] = $request['bank_name'];
                }
                if (!empty($request['bank_holder_name'])) {
                    $array['bank_holder_name'] = $request['bank_holder_name'];
                }
                if (!empty($request['account_no'])) {
                    $array['account_no'] = $request['account_no'];
                }
                if (!empty($request['ifsc_code'])) {
                    $array['ifsc_code'] = $request['ifsc_code'];
                }
                User::where('id', $user_id)->update($array);

                $updatedUser = User::where('id', $user_id)->first();
                $updatedUser['image'] = $this->common->getImage($this->folder_user, $updatedUser['image']);

                return $this->common->API_Response(200, __('api_msg.profile_update_successfully'), array($updatedUser));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function add_become_author_request(Request $request)
    {
        try {
            $traceId = 'become_author_' . uniqid();
            Log::info('api.add_become_author_request.start', [
                'trace_id' => $traceId,
                'payload' => [
                    'user_id' => $request['user_id'] ?? null,
                    'mobile_number' => $request['mobile_number'] ?? null,
                    'role' => $request['role'] ?? null,
                    'payment_method' => $request['payment_method'] ?? null,
                    'bank_name' => $request['bank_name'] ?? null,
                    'bank_code' => $request['bank_code'] ?? null,
                    'bank_holder_name' => $request['bank_holder_name'] ?? null,
                    'account_no' => $request['account_no'] ?? null,
                    'ifsc_code' => $request['ifsc_code'] ?? null,
                    'mpesa_phone' => $request['mpesa_phone'] ?? null,
                    'has_id_front' => $request->hasFile('id_front'),
                    'has_id_back' => $request->hasFile('id_back'),
                    'has_selfie' => $request->hasFile('selfie'),
                ],
            ]);

            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'mobile_number' => 'nullable|string',
                'role' => 'required|in:author,publisher',
                'payment_method' => 'required|in:bank,mpesa',
                'bank_name' => 'required_if:payment_method,bank',
                'bank_code' => 'required_if:payment_method,bank',
                'bank_holder_name' => 'required_if:payment_method,bank',
                'account_no' => 'required_if:payment_method,bank',
                'mpesa_phone' => 'required_if:payment_method,mpesa',
                // KYC images (nullable — allowed without files)
                'id_front' => 'nullable|image|mimes:jpeg,png,jpg|max:5120',
                'id_back' => 'nullable|image|mimes:jpeg,png,jpg|max:5120',
                'selfie'  => 'nullable|image|mimes:jpeg,png,jpg|max:5120',
            ]);
            if ($validation->fails()) {
                Log::warning('api.add_become_author_request.validation_failed', [
                    'trace_id' => $traceId,
                    'errors' => $validation->errors()->all(),
                ]);
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $role = $request['role'];
            $payment_method = $request['payment_method'];

            // Bank fields (may be empty strings for mpesa requests)
            $bank_name = $request['bank_name'] ?? '';
            $bank_code = $request['bank_code'] ?? '';
            $bank_holder_name = $request['bank_holder_name'] ?? '';
            $account_no = $request['account_no'] ?? '';
            $ifsc_code = $request['ifsc_code'] ?? '';

            // Mpesa field (may be empty strings for bank requests)
            $mpesa_phone = $request['mpesa_phone'] ?? '';
            $mobile_number = trim((string) ($request['mobile_number'] ?? ''));

            $user = User::find($user_id);
            if (!$user) {
                Log::warning('api.add_become_author_request.user_not_found', [
                    'trace_id' => $traceId,
                    'user_id' => $user_id,
                ]);
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
            // App currently uses `is_author` as "approved contributor",
            // so we block any new requests when it's already enabled.
            if (($user['is_author'] ?? 0) == 1) {
                Log::warning('api.add_become_author_request.already_author', [
                    'trace_id' => $traceId,
                    'user_id' => $user_id,
                ]);
                return $this->common->API_Response(400, __('api_msg.you_are_already_a_author'));
            }

            if (empty($user['mobile_number']) && empty($mobile_number)) {
                return $this->common->API_Response(400, 'Phone number is required for this account.');
            }

            // If user registered via social login without phone, allow phone capture from Become Author form.
            if (empty($user['mobile_number']) && !empty($mobile_number)) {
                $normalizedMobile = preg_replace('/\D+/', '', $mobile_number);
                if (!empty($normalizedMobile)) {
                    $existingPhoneOwner = User::where('mobile_number', $normalizedMobile)
                        ->where('id', '!=', $user_id)
                        ->first();
                    if ($existingPhoneOwner) {
                        return $this->common->API_Response(400, 'This phone number is already used by another account.');
                    }
                    $user->mobile_number = $normalizedMobile;
                    $user->save();
                }
            }

            if ($request->has('password') && !empty($request['password'])) {
                $user->password = Hash::make($request['password']);
                $user->save();
            }

            // ---- KYC: Image Uploads ----
            $folder_kyc = 'kyc_docs';
            $idFrontPath = '';
            $idBackPath = '';
            $selfiePath = '';

            if ($request->hasFile('id_front')) {
                $idFrontPath = $this->common->saveImage($request->file('id_front'), $folder_kyc, 'id_front_');
            }
            if ($request->hasFile('id_back')) {
                $idBackPath = $this->common->saveImage($request->file('id_back'), $folder_kyc, 'id_back_');
            }
            if ($request->hasFile('selfie')) {
                $selfiePath = $this->common->saveImage($request->file('selfie'), $folder_kyc, 'selfie_');
            }

            // ---- OTP Verification Check ----
            $otpVerified = false;
            if (!empty($request['otp_code'])) {
                // Check OTP on user record
                if (
                    $user->otp_code === $request['otp_code']
                    && $user->otp_expiry
                    && now()->lessThan($user->otp_expiry)
                ) {
                    $otpVerified = true;
                    // Clear OTP after successful verification
                    $user->otp_code = null;
                    $user->otp_expiry = null;
                    $user->save();
                } else {
                    return $this->common->API_Response(400, 'Invalid or expired OTP. Please request a new one.');
                }
            }

            $author_request = Author_Request::where('user_id', $user_id)->first();
            if ($author_request) {
                Log::warning('api.add_become_author_request.duplicate_request', [
                    'trace_id' => $traceId,
                    'user_id' => $user_id,
                    'request_id' => $author_request->id,
                    'status' => $author_request->status,
                ]);
                return $this->common->API_Response(400, __('api_msg.you_have_already_sent_the_request'));
            }

            $requiredColumns = [
                'role',
                'payment_method',
                'bank_name',
                'bank_code',
                'bank_holder_name',
                'account_no',
                'ifsc_code',
                'mpesa_phone',
                'status',
                'id_front',
                'id_back',
                'selfie',
                'otp_code',
                'otp_expiry',
                'is_otp_verified',
                'otp_email',
                'otp_phone',
            ];
            $missingColumns = [];
            foreach ($requiredColumns as $column) {
                if (!Schema::hasColumn('tbl_author_request', $column)) {
                    $missingColumns[] = $column;
                }
            }
            if (!empty($missingColumns)) {
                Log::error('api.add_become_author_request.schema_missing_columns', [
                    'trace_id' => $traceId,
                    'missing_columns' => $missingColumns,
                ]);
                return $this->common->API_Response(
                    400,
                    'Author request DB schema is outdated. Missing columns: ' . implode(', ', $missingColumns)
                );
            }

            $insert = new Author_Request();
            $insert['user_id'] = $user_id;
            $insert['role'] = $role;
            $insert['payment_method'] = $payment_method;

            $insert['bank_name'] = $payment_method === 'bank' ? $bank_name : '';
            $insert['bank_code'] = $payment_method === 'bank' ? $bank_code : '';
            $insert['bank_holder_name'] = $payment_method === 'bank' ? $bank_holder_name : '';
            $insert['account_no'] = $payment_method === 'bank' ? $account_no : '';
            $insert['ifsc_code'] = $payment_method === 'bank' ? $ifsc_code : '';

            $insert['mpesa_phone'] = $payment_method === 'mpesa' ? $mpesa_phone : '';

            // Save KYC image paths
            $insert['id_front'] = $idFrontPath;
            $insert['id_back'] = $idBackPath;
            $insert['selfie'] = $selfiePath;

            // OTP verification status
            $insert['is_otp_verified'] = $otpVerified ? 1 : 0;
            $insert['otp_email'] = $user['email'] ?? '';
            $insert['otp_phone'] = $user['mobile_number'] ?? '';

            // ---- Create Paystack subaccount immediately (if bank payment) ----
            if ($payment_method === 'bank' && !empty($bank_code) && !empty($account_no)) {
                try {
                    $subaccountCode = $this->createPaystackSubaccountForRequest($user, $insert);
                    if (!empty($subaccountCode)) {
                        $insert['subaccount_code'] = $subaccountCode;
                        Log::info('api.add_become_author_request.subaccount_created', [
                            'trace_id' => $traceId,
                            'user_id' => $user_id,
                            'subaccount_code' => $subaccountCode,
                        ]);
                    }
                } catch (\Throwable $e) {
                    // Non-fatal: subaccount creation failure shouldn't block the request
                    Log::warning('api.add_become_author_request.subaccount_failed', [
                        'trace_id' => $traceId,
                        'error' => $e->getMessage(),
                    ]);
                }
            }

            $insert['status'] = 0;
            if ($insert->save()) {
                Log::info('api.add_become_author_request.saved', [
                    'trace_id' => $traceId,
                    'request_id' => $insert->id,
                    'user_id' => $user_id,
                    'status' => $insert->status,
                    'otp_verified' => $otpVerified,
                ]);

                $status = $this->common->BasicNotiConfiguration('add-become-auther-request');
                if ($status['status'] == 1 && $status['send_mail'] == 1) {
                    $this->common->Send_Mail(3, $user['email'], 0, "", 0, "", "", "", "");
                }
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $this->common->SaveNotification(1, 2, $user_id, 0, 0, 0, 0, "", $user['device_type'], $user['device_token'], 0, "");
                }
                return $this->common->API_Response(200, __('api_msg.your_request_has_been_sent_successfully_wait_for_admin_to_approve'), []);
            } else {
                Log::error('api.add_become_author_request.save_failed', [
                    'trace_id' => $traceId,
                    'user_id' => $user_id,
                ]);
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            Log::error('api.add_become_author_request.exception', [
                'error' => $e->getMessage(),
                'line' => $e->getLine(),
                'file' => $e->getFile(),
            ]);
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ---------------------------------------------------------------
    //  Send OTP for Author Registration (email + SMS)
    // ---------------------------------------------------------------
    public function send_author_otp(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user = User::find($request['user_id']);
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            // Check user isn't already an author
            if (($user['is_author'] ?? 0) == 1) {
                return $this->common->API_Response(400, __('api_msg.you_are_already_a_author'));
            }

            $email = $user['email'] ?? '';
            $phone = $user['mobile_number'] ?? '';

            if (empty($email) && empty($phone)) {
                return $this->common->API_Response(400, 'No email or phone number found on your profile.');
            }

            // Generate 6-digit OTP
            $otp = (string) random_int(100000, 999999);
            $expiry = now()->addMinutes(5);

            // Store OTP on user record
            $user->otp_code = $otp;
            $user->otp_expiry = $expiry;
            $user->save();

            // Send OTP via email (SMTP configured in admin)
            if (!empty($email)) {
                try {
                    $this->common->Send_Mail(13, $email, 0, "", 0, "", "", "", "", 0, $otp);
                } catch (\Throwable $e) {
                    Log::error('api.send_author_otp.email_failed', [
                        'error' => $e->getMessage(),
                        'email' => $email,
                    ]);
                }
            }

            // Send OTP via SMS (using settings from admin app settings)
            if (!empty($phone)) {
                try {
                    $this->sendOtpSms($phone, $otp);
                } catch (\Throwable $e) {
                    Log::error('api.send_author_otp.sms_failed', [
                        'error' => $e->getMessage(),
                        'phone' => $phone,
                    ]);
                }
            }

            return $this->common->API_Response(200, 'OTP sent successfully to your email and phone.');
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ---------------------------------------------------------------
    //  Verify OTP for Author Registration
    // ---------------------------------------------------------------
    public function verify_author_otp(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'otp' => 'required|string|size:6',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user = User::find($request['user_id']);
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            if (empty($user->otp_code) || empty($user->otp_expiry)) {
                return $this->common->API_Response(400, 'No OTP was requested. Please request one first.');
            }

            if ($user->otp_code !== $request['otp']) {
                return $this->common->API_Response(400, 'Invalid OTP. Please try again.');
            }

            if (now()->greaterThan($user->otp_expiry)) {
                // Clear expired OTP
                $user->otp_code = null;
                $user->otp_expiry = null;
                $user->save();
                return $this->common->API_Response(400, 'OTP has expired. Please request a new one.');
            }

            // Don't clear the OTP here — the final submission (add_become_author_request)
            // will validate and clear it again. This lets the verify step just confirm
            // the code is correct without consuming it.
            return $this->common->API_Response(200, 'OTP verified successfully.');
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ---------------------------------------------------------------
    //  Send OTP via SMS (reuses settings from admin app settings)
    // ---------------------------------------------------------------
    // ---------------------------------------------------------------
    //  Create Paystack subaccount during registration
    // ---------------------------------------------------------------
    private function createPaystackSubaccountForRequest($user, $requestData): string
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

            if (!$response->ok()) {
                Log::warning('api.create_subaccount.http_failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
                return '';
            }
            $payload = $response->json();
            return $payload['data']['subaccount_code'] ?? '';
        } catch (\Throwable $e) {
            Log::error('api.create_subaccount.exception', [
                'error' => $e->getMessage(),
            ]);
            return '';
        }
    }

    private function sendOtpSms(string $phone, string $otp): void
    {
        $settings = General_Setting::pluck('value', 'key')->toArray();
        $apiUrl = trim((string)($settings['sms_api_url'] ?? 'https://api.vaspro.co.ke/v3/BulkSMS/api/create'));
        $apiKey = trim((string)($settings['sms_api_key'] ?? ''));
        $shortcode = trim((string)($settings['sms_shortcode'] ?? 'VasPro'));

        if ($apiKey === '') {
            Log::warning('api.send_otp_sms.missing_api_key', ['phone' => $phone]);
            return;
        }

        // Normalize phone: remove non-digits, prepend 254 if starts with 0
        $rawMobile = preg_replace('/\D+/', '', $phone);
        if (strlen($rawMobile) > 0 && $rawMobile[0] === '0') {
            $rawMobile = '254' . substr($rawMobile, 1);
        } elseif (strlen($rawMobile) === 9 && $rawMobile[0] === '7') {
            $rawMobile = '254' . $rawMobile;
        }

        $message = "Your Vitabu verification OTP is $otp. It expires in 5 minutes.";

        // Try VasPro format first (from logs.txt documentation)
        $payload = [
            'apiKey' => $apiKey,
            'shortCode' => $shortcode,
            'recipient' => $rawMobile,
            'enqueue' => 1,
            'message' => $message,
            'callbackURL' => '',
        ];

        try {
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->post($apiUrl, $payload);

            Log::info('api.send_author_otp.sms_response', [
                'phone' => $rawMobile,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
        } catch (\Throwable $e) {
            Log::error('api.send_author_otp.sms_http_error', [
                'error' => $e->getMessage(),
            ]);
        }
    }
    public function get_author_list(Request $request)
    {
        try {

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = User::where('is_author', 1)->where('status', 1)->orderBy('id', 'desc');

            $total_rows = $data->count();
            $total_page = 50;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->get();
            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_user);
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function forgot_password(Request $request)
    {
        try {
            $validate = Validator::make($request->all(), [
                'email' => 'required',
            ]);

            if ($validate->fails()) {
                return $this->common->API_Response(400, $validate->errors()->first());
            }

            $email = $request->email;

            $user = User::where('email', $email)->first();
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $password = Str::random(6);
            $hash_password = Hash::make($password);

            $user->password = $hash_password;
            $user->save();

            $this->common->Send_Mail(9, $email, 0, "", 0, "", "", "", "", 0, $password);

            return $this->common->API_Response(200, __('api_msg.we_have_sent_a_new_password_to_your_email_please_check_your_inbox'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function get_paystack_banks(Request $request)
    {
        try {
            $country = $request->country ?? 'kenya';
            $secret = $this->getPaystackSecret();
            if (empty($secret)) {
                return $this->common->API_Response(400, 'Paystack is not configured');
            }

            $response = Http::withToken($secret)->get('https://api.paystack.co/bank', [
                'country' => $country,
                'perPage' => 100,
            ]);

            if (!$response->ok()) {
                return $this->common->API_Response(400, 'Failed to fetch banks');
            }

            $payload = $response->json();
            $banks = $payload['data'] ?? [];
            $banks = array_values(array_filter($banks, function ($bank) {
                return isset($bank['active']) ? (bool) $bank['active'] : true;
            }));

            return $this->common->API_Response(200, __('api_msg.data_retrieved'), $banks);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    private function getPaystackSecret(): string
    {
        $paystack = Payment_Option::where('name', 'paystack')->first();
        if (!$paystack) return '';
        return trim((string) ($paystack->key_2 ?? ''));
    }

    public function send_otp_sms(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'mobile_number' => 'required|string',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            Log::info('api.send_otp_sms.init', ['mobile_number' => $request['mobile_number']]);

            $settings = General_Setting::pluck('value', 'key')->toArray();
            $apiUrl = trim((string)($settings['sms_api_url'] ?? 'https://api.vaspro.co.ke/v3/BulkSMS/api/create'));
            $apiKey = trim((string)($settings['sms_api_key'] ?? 'f58a123374422b5c3824ffb83ba01290'));
            $shortcode = trim((string)($settings['sms_shortcode'] ?? 'VasPro'));

            $rawMobile = preg_replace('/\D+/', '', (string)$request['mobile_number']);
            if (str_starts_with($rawMobile, '0')) {
                $rawMobile = '254' . substr($rawMobile, 1);
            } elseif (str_starts_with($rawMobile, '7') && strlen($rawMobile) === 9) {
                $rawMobile = '254' . $rawMobile;
            }

            Log::info('api.send_otp_sms.mobile_parsed', ['original' => $request['mobile_number'], 'parsed' => $rawMobile]);

            if ($rawMobile === '') {
                Log::error('api.send_otp_sms.invalid_mobile');
                return $this->common->API_Response(400, 'Invalid mobile number.');
            }

            $otp = (string) random_int(100000, 999999);
            $message = "Your Vitabu OTP is $otp. It expires in 5 minutes.";
            
            // Handle VasPro API payload structure
            if (str_contains($apiUrl, 'vaspro.co.ke')) {
                $payload = [
                    'apiKey' => $apiKey,
                    'shortCode' => $shortcode,
                    'recipient' => $rawMobile,
                    'enqueue' => 1,
                    'message' => $message,
                    'callbackURL' => 'https://console.vitabu.online/api/sms_callback'
                ];
            } else {
                // CelcomAfrica payload format fallback
                $partnerId = trim((string)($settings['sms_partner_id'] ?? ''));
                $payload = [
                    'apikey' => $apiKey,
                    'partnerID' => $partnerId,
                    'message' => $message,
                    'shortcode' => $shortcode,
                    'mobile' => $rawMobile,
                    'pass_type' => 'plain',
                ];
            }

            Log::info('api.send_otp_sms.request_payload', array_merge($payload, ['apiKey' => '***', 'apikey' => '***']));

            $response = Http::withHeaders(['Content-Type' => 'application/json'])
                            ->post($apiUrl, $payload);

            Log::info('api.send_otp_sms.response', [
                'mobile' => $rawMobile,
                'status' => $response->status(),
                'headers' => $response->headers(),
                'body' => $response->body(),
            ]);

            if (!$response->ok()) {
                return $this->common->API_Response(400, 'Failed to send OTP SMS via VasPro API.');
            }
            return $this->common->API_Response(200, 'OTP sent successfully.', ['otp' => $otp]);
        } catch (\Throwable $e) {
            Log::error('api.send_otp_sms.exception', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->common->API_Response(400, $e->getMessage());
        }
    }
}
