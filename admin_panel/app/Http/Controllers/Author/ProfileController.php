<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\User;
use App\Models\Author_Request;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public $common;
    private $folder = "user";
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $params['author'] = Author_Data();
            if (isset($params['author']) && $params['author'] != null) {

                $params['data'] = User::where('id', $params['author']['id'])->first();
                $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->get();

                $this->common->imageNameToUrl(array($params['data']), 'image', $this->folder);

                return view('author.profile.index', $params);
            } else {
                return redirect()->route('author.login')->with('success', __('label.logout_successfully'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'first_name' => 'required|min:2',
                'last_name' => 'required|min:2',
                'mobile_number' => 'required|numeric|unique:tbl_user,mobile_number,' . $request['id'],
                'email' => 'required|email|unique:tbl_user,email,' . $request['id'],
                'image' => 'image|mimes:jpeg,png,jpg,webp|max:2048',
                'bank_name' => 'required',
                'bank_holder_name' => 'required',
                'account_no' => 'required',
                'ifsc_code' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $author = User::where('is_author', 1)->where('id', $request['id'])->first();
            if ($author) {

                $author['first_name'] = $request['first_name'];
                $author['last_name'] = $request['last_name'];
                $author['email'] = $request['email'];
                $author['mobile_number'] = $request['mobile_number'];
                if (isset($request['category_ids']) && $request['category_ids'] != null) {
                    $categoryIds = implode(',', $request['category_ids']);
                    $author['category_ids'] = $categoryIds;
                } else {
                    $request['category_ids'] = "";
                }
                if (isset($request['image'])) {
                    $files = $request['image'];
                    $author['image'] = $this->common->saveImage($files, $this->folder, 'user_');

                    $this->common->deleteImageToFolder($this->folder, basename($request['old_image']));
                }
                $author['description'] = $request['description'] ?? "";
                $author['address'] = $request['address'] ?? "";
                $author['bank_name'] = $request['bank_name'];
                $author['bank_holder_name'] = $request['bank_holder_name'];
                $author['account_no'] = $request['account_no'];
                $author['ifsc_code'] = $request['ifsc_code'];

                if ($request->has('legal_name')) {
                    $author['legal_name'] = $request['legal_name'];
                }
                if ($request->has('national_id_number')) {
                    $author['national_id_number'] = $request['national_id_number'];
                }
                if ($request->has('kra_pin')) {
                    $author['kra_pin'] = $request['kra_pin'];
                }
                if ($request->has('business_name')) {
                    $author['business_name'] = $request['business_name'];
                }
                if ($request->hasFile('business_certificate')) {
                    $author['business_certificate'] = $this->common->saveImage($request->file('business_certificate'), $this->folder, 'biz_cert_');
                }
                if ($request->hasFile('kra_pin_certificate')) {
                    $author['kra_pin_certificate'] = $this->common->saveImage($request->file('kra_pin_certificate'), $this->folder, 'kra_cert_');
                }
                if ($request->has('rep_name')) {
                    $author['rep_name'] = $request['rep_name'];
                }
                if ($request->hasFile('rep_id_upload')) {
                    $author['rep_id_upload'] = $this->common->saveImage($request->file('rep_id_upload'), $this->folder, 'rep_id_');
                }
                $author['rights_declaration'] = $request['rights_declaration'] ? 1 : 0;

                $author->save();

                return response()->json(['status' => 200, 'success' => __('label.data_edit_successfully')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_updated')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ChangePassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'current_password' => 'required',
                'new_password' => 'required|min:4',
                'confirm_password' => 'required|min:4|same:new_password',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $admin = User::where('id', $request['id'])->first();
            if (isset($admin) && $admin != null) {

                if (Hash::check($request['current_password'], $admin['password'])) {

                    $admin['password'] = Hash::make($request['new_password']);
                    if ($admin->save()) {
                        return response()->json(['status' => 200, 'success' => __('label.password_change_successfully')]);
                    }
                } else {
                    return response()->json(['status' => 400, 'errors' => __('label.please_enter_right_current_password')]);
                }
            } else {
                return redirect()->route('author.logout');
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
