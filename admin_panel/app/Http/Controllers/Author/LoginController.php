<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Login_History;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Exception;

class LoginController extends Controller
{
    private $folder = "setting";
    public $common;
    protected $redirectTo = 'author/login';
    public function __construct()
    {
        try {
            $this->middleware('guest', ['except' => 'logout']);
            $this->common = new Common();
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function login(Request $request)
    {
        try {
            Auth()->guard('author')->logout();

            $params['result'] = Setting_Data();
                $params['result']['panel_login_page_bg_image'] = $this->common->getImage($this->folder, $params['result']['panel_login_page_bg_image']);

            return view('author.login.login', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function save_login(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
                'password' => 'required|min:4',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            if (Auth()->guard('author')->attempt(['email' => $requestData['email'], 'password' => $requestData['password'], 'is_author' => 1])) {

                $author = User::select('id')->where('email', $requestData['email'])->where('is_author', 1)->first();
                Login_History::create([
                    'user_id' => $author['id'],
                    'login_time' => now(),
                    'logout_time' => '',
                ]);

                return response()->json(['status' => 200, 'success' => __('label.success_login')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_login')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function logout()
    {
        try {
            $author = Auth()->guard('author')->user();
            $last_login = Login_History::where('user_id', $author->id)->latest()->first();
            if ($last_login) {
                $last_login->update(['logout_time' => now()->toDateTimeString()]);
            }

            Auth()->guard('author')->logout();
            return redirect()->route('author.login')->with('success', __('label.logout_successfully'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // Email-based forgot password for author panel.
    public function forgot_password()
    {
        try {
            return view('author.login.forgot_password');
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function send_forgot_password(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
            ]);

            if ($validator->fails()) {
                return redirect()->back()->with('error', $validator->errors()->first());
            }

            $email = $request->email;
            $author = User::where('email', $email)->where('is_author', 1)->where('status', 1)->first();

            if (!$author) {
                return redirect()->back()->with('error', __('api_msg.data_not_found'));
            }

            // Generate a new password and email it to the author.
            $password = Str::random(6);
            $author->password = Hash::make($password);
            $author->save();

            $this->common->Send_Mail(9, $email, 0, "", 0, "", "", "", "", 0, $password);

            return redirect()->route('author.login')->with(
                'success',
                __('api_msg.we_have_sent_a_new_password_to_your_email_please_check_your_inbox')
            );
        } catch (Exception $e) {
            return redirect()->back()->with('error', $e->getMessage());
        }
    }
}
