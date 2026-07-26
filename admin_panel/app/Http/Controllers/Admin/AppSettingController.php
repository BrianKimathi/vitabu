<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\General_Setting;
use App\Models\Onboarding_Screen;
use App\Models\Smtp;
use App\Models\Social_Link;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class AppSettingController extends Controller
{
    private $folder = "setting";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $params['result'] = Setting_Data();
            if ($params['result']) {

                $params['result']['app_logo'] = $this->common->getImage($this->folder, $params['result']['app_logo']);
                $params['result']['company_logo'] = $this->common->getImage($this->folder, $params['result']['company_logo']);

                $params['social_link'] = Social_Link::get();
                $this->common->imageNameToUrl($params['social_link'], 'image', $this->folder);

                $params['onboarding_screen'] = Onboarding_Screen::get();
                $this->common->imageNameToUrl($params['onboarding_screen'], 'image', $this->folder);

                $params['smtp'] = Smtp::latest()->first();

                return view('admin.app_setting.index', $params);
            } else {
                return view('errors.404');
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function app(Request $request)
    {
        try {

            $data = $request->all();
            $data['app_name'] = isset($data['app_name']) ? $data['app_name'] : '';
            $data['app_version'] = isset($data['app_version']) ? $data['app_version'] : '';
            $data['email'] = isset($data['email']) ? $data['email'] : '';
            $data['author'] = isset($data['author']) ? $data['author'] : '';
            $data['contact'] = isset($data['contact']) ? $data['contact'] : '';
            $data['website'] = isset($data['website']) ? $data['website'] : '';
            $data['app_description'] = isset($data['app_description']) ? $data['app_description'] : '';
            $data['address'] = isset($data['address']) ? $data['address'] : '';
            $data['sms_api_url'] = isset($data['sms_api_url']) ? $data['sms_api_url'] : '';
            $data['sms_api_key'] = isset($data['sms_api_key']) ? $data['sms_api_key'] : '';
            $data['sms_partner_id'] = isset($data['sms_partner_id']) ? $data['sms_partner_id'] : '';
            $data['sms_shortcode'] = isset($data['sms_shortcode']) ? $data['sms_shortcode'] : '';

            if (isset($data['app_logo'])) {
                $files = $data['app_logo'];
                $data['app_logo'] = $this->common->saveImage($files, $this->folder, 'logo_');
                $this->common->deleteImageToFolder($this->folder, basename($data['old_app_logo']));
            }

            if (isset($data['company_logo'])) {
                $files = $data['company_logo'];
                $data['company_logo'] = $this->common->saveImage($files, $this->folder, 'company_logo_');
                $this->common->deleteImageToFolder($this->folder, basename($data['old_company_logo']));
            }

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                } else {
                    General_Setting::create([
                        'key' => $key,
                        'value' => $value,
                    ]);
                }
            }

            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function currency(Request $request)
    {
        try {

            $data = $request->all();
            $data["currency"] = isset($data['currency']) ? strtoupper($data['currency']) : '';
            $data["currency_code"] = isset($data['currency_code']) ? $data['currency_code'] : '';

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function screenshot(Request $request)
    {
        try {

            $data = $request->all();
            $data["screenshot"] = isset($data['screenshot']) ? $data['screenshot'] : '';

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function vap_id_key(Request $request)
    {
        try {

            $data = $request->all();
            $data["vap_id_key"] = isset($data['vap_id_key']) ? $data['vap_id_key'] : '';

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function reading_time(Request $request)
    {
        try {
            $validator = Validator::make(
                $request->all(),
                [
                    'min_time' => 'gte:0',
                    'max_time' => 'gte:0',
                ]
            );

            if ($validator->fails()) {
                return response()->json(['status' => 400, 'errors' => $validator->errors()->all()]);
            }

            $data = $request->all();
            $data["min_time"] = isset($data['min_time']) ? strtoupper($data['min_time']) : '';
            $data["max_time"] = isset($data['max_time']) ? $data['max_time'] : '';

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function smtp(Request $request)
    {
        try {

            $validator = Validator::make($request->all(), [
                'status' => 'required',
                'host' => 'required',
                'port' => 'required',
                'protocol' => 'required',
                'user' => 'required',
                'pass' => 'required',
                'from_name' => 'required',
                'from_email' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            if (isset($request['id']) && $request['id'] != null && $request['id'] != "") {

                $smtp = Smtp::where('id', $request['id'])->first();
                if (isset($smtp->id)) {
                    $smtp['protocol'] = $request['protocol'];
                    $smtp['host'] = $request['host'];
                    $smtp['port'] = $request['port'];
                    $smtp['user'] = $request['user'];
                    $smtp['pass'] = $request['pass'];
                    $smtp['from_name'] = $request['from_name'];
                    $smtp['from_email'] = $request['from_email'];
                    $smtp['status'] = $request['status'];
                    if ($smtp->save()) {
                        return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
                    } else {
                        return response()->json(['status' => 400, 'errors' => __('label.data_not_updated')]);
                    }
                }
            } else {

                $insert = new Smtp();
                $insert['protocol'] = $request['protocol'];
                $insert['host'] = $request['host'];
                $insert['port'] = $request['port'];
                $insert['user'] = $request['user'];
                $insert['pass'] = $request['pass'];
                $insert['from_name'] = $request['from_name'];
                $insert['from_email'] = $request['from_email'];
                $insert['status'] = $request['status'];
                if ($insert->save()) {
                    return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
                } else {
                    return response()->json(['status' => 400, 'errors' => __('label.data_not_updated')]);
                }
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function testsmtp(Request $request)
    {
        try {
            $validator = Validator::make(
                $request->all(),
                [
                    'email' => 'required',
                ]
            );
            if ($validator->fails()) {
                return response()->json(['status' => 400, 'errors' => $validator->errors()->all()]);
            }
            $this->common->Send_Mail(10, $request->email, 0, "", 0, "", "", "", "", 0, "");
            return response()->json(['status' => 200, 'success' => __('label.mail_sent')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function commission(Request $request)
    {
        try {
            $validator = Validator::make(
                $request->all(),
                [
                    'commission' => 'numeric|lte:100'
                ]
            );

            if ($validator->fails()) {
                return response()->json(['status' => 400, 'errors' => $validator->errors()->all()]);
            }
            $data = $request->all();
            $data['commission'] = isset($data['commission']) ? $data['commission'] : '';
            $data['active_commission'] = $data['commission'];

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function sociallink(Request $request)
    {
        try {

            $arr_name = $request['name'];
            $arr_url = $request['url'];
            $arr_img = $request->file('image');
            $arr_old_image = $request['old_image'];

            // Save New All Link
            $not_delete_img = array();
            $not_delete_ids = array();

            for ($i = 0; $i < count($arr_name); $i++) {

                if (!empty($arr_name[$i]) && !empty($arr_url[$i])) {

                    if (!empty($arr_img[$i])) {

                        $insert = new Social_Link();
                        $insert->name = $arr_name[$i];
                        $insert->url = $arr_url[$i];
                        $insert->image = $this->common->saveImage($arr_img[$i], $this->folder, 'soc_link_');
                        $insert->save();

                        $this->common->deleteImageToFolder($this->folder, $arr_old_image[$i]);
                    } else {
                        if (!empty($arr_old_image[$i])) {

                            $insert = new Social_Link();
                            $insert->name = $arr_name[$i];
                            $insert->url = $arr_url[$i];
                            $insert->image = $arr_old_image[$i];
                            $insert->save();
                            $not_delete_img[] = $arr_old_image[$i];
                        }
                    }
                    $not_delete_ids[] = $insert->id;
                }
            }

            // Delete Old All Link 
            $all_old_link = Social_Link::whereNotIn('id', $not_delete_ids)->get();
            for ($i = 0; $i < count($all_old_link); $i++) {

                if (!in_array($all_old_link[$i]['image'], $not_delete_img)) {

                    $this->common->deleteImageToFolder($this->folder, $all_old_link[$i]['image']);
                }

                $all_old_link[$i]->delete();
            }

            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function onboardingscreen(Request $request)
    {
        try {

            $arr_title = $request['title'];
            $arr_description = $request['description'];
            $arr_img = $request->file('image');
            $arr_old_image = $request['old_image'];

            // Save New All Link
            $not_delete_img = array();
            $not_delete_ids = array();

            for ($i = 0; $i < count($arr_title); $i++) {

                if (!empty($arr_title[$i]) && !empty($arr_description[$i])) {

                    if (!empty($arr_img[$i])) {
                        $insert = new Onboarding_Screen();
                        $insert->title = $arr_title[$i];
                        $insert->description = $arr_description[$i];
                        $insert->image = $this->common->saveImage($arr_img[$i], $this->folder, 'on_board_');
                        $insert->save();

                        $this->common->deleteImageToFolder($this->folder, $arr_old_image[$i]);
                    } else {
                        if (!empty($arr_old_image[$i])) {

                            $insert = new Onboarding_Screen();
                            $insert->title = $arr_title[$i];
                            $insert->description = $arr_description[$i];
                            $insert->image = $arr_old_image[$i];
                            $insert->save();
                            $not_delete_img[] = $arr_old_image[$i];
                        }
                    }
                    $not_delete_ids[] = $insert->id ?? 0;
                }
            }

            // Delete Old Data
            $all_old_data = Onboarding_Screen::whereNotIn('id', $not_delete_ids)->get();
            for ($i = 0; $i < count($all_old_data); $i++) {

                if (!in_array($all_old_data[$i]['image'], $not_delete_img)) {

                    $this->common->deleteImageToFolder($this->folder, $all_old_data[$i]['image']);
                }
                $all_old_data[$i]->delete();
            }

            return response()->json(['status' => 200, 'success' => __('label.setting_save_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
