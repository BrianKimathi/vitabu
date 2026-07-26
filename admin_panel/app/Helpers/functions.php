<?php

use App\Models\General_Setting;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Storage;

function Setting_Data()
{
    $setting = General_Setting::get();
    $data = [];
    foreach ($setting as $value) {
        $data[$value->key] = $value->value;
    }
    return $data;
}
function Tab_Icon()
{
    $setting_data = Setting_Data();
    $app_logo = $setting_data['app_logo'];
    $folder = "setting";

    if ($app_logo != "" && $folder != "") {

        $img_base_url = Config::get('app.image_url');

        if (Storage::disk('public')->exists($folder . '/' . $app_logo)) {
            $app_logo = $img_base_url . $folder . '/' . $app_logo;
        } else {
            $app_logo = "";
        }
    } else {
        $app_logo = "";
    }
    return $app_logo;
}
function App_Name()
{
    $setting_data = Setting_Data();
    $app_name = $setting_data['app_name'];

    if (isset($app_name) && $app_name != "") {
        return $app_name;
    } else {
        return env('APP_NAME');
    }
}
function String_Cut($string, $len)
{
    if (strlen($string) > $len) {
        $string = mb_substr(strip_tags($string), 0, $len, 'utf-8') . '...';
    }
    return $string;
}
function Login_Image()
{
    $Setting_Data = Setting_Data();

    $appName = Config::get('app.image_url');
    $login_page_img = $Setting_Data['panel_login_page_bg_image'];
    $folder = "setting";

    if ($login_page_img != "" && Storage::disk('public')->exists($folder . '/' . $login_page_img)) {
        $login_page_img = $appName . $folder . '/' . $login_page_img;
    } else {
        $login_page_img = asset('assets/imgs/login.webp');
    }
    return $login_page_img;
}
function Admin_Data()
{
    if (Auth::guard('admin')->check()) {
        return Auth::guard('admin')->user();
    }
    return redirect()->route('admin.logout')->send();
}
function Currency_Code()
{
    $data = Setting_Data();
    return $data['currency_code'];
}
function Currency_Symbol()
{
    $data = Setting_Data();
    return $data['currency'] ?? '$';
}
function No_Format($num)
{
    if ($num > 1000) {
        $x = round($num);
        $x_number_format = number_format($x);
        $x_array = explode(',', $x_number_format);
        $x_parts = array('K', 'M', 'B', 'T');
        $x_count_parts = count($x_array) - 1;
        $x_display = $x;
        $x_display = $x_array[0] . ((int) $x_array[1][0] !== 0 ? '.' . $x_array[1][0] : '');
        $x_display .= $x_parts[$x_count_parts - 1];

        return $x_display;
    }
    return $num;
}
function Author_Data()
{
    if (Auth::guard('author')->user()) {
        return Auth::guard('author')->user();
    } else {
        return redirect()->route('author.logout');
    }
}
// Access & Installation
function Demo_Mode()
{
    if (env('DEMO_MODE') == 'ON') {
        return 0;
    } else {
        return 1;
    }
}
function Demo_Domain()
{
    $domain = request()->getHost();
    if ($domain == base64_decode('bG9jYWxob3N0') || $domain == base64_decode('ZGV2LmRpdmluZXRlY2hzLmNvbQ==') || $domain == base64_decode('c3RhZy5kaXZpbmV0ZWNocy5jb20=') || $domain == base64_decode('ZHRlYm9vay5kaXZpbmV0ZWNocy5jb20=')) {
        return 1;
    } else {
        return 0;
    }
}
function Item_Code()
{
    return base64_decode('NTQ3OTk0MTE=');
}
function Set_Environment_Value($envKey, $envValue)
{
    $envFile = app()->environmentFilePath();
    $str = file_get_contents($envFile);

    $oldValue = env($envKey);

    if (strpos($str, $envKey) !== false) {
        $str = str_replace("{$envKey}={$oldValue}", "{$envKey}={$envValue}", $str);
    } else {
        $str .= "{$envKey}={$envValue}\n";
    }

    $fp = fopen($envFile, 'w');
    fwrite($fp, $str);
    fclose($fp);
    return $envValue;
}
function seconds_to_hm($time)
{
    $hours   = floor($time / 3600);
    $minutes = floor(($time % 3600) / 60);
    $seconds = $time % 60;
    $hours = $hours < 10 ? "0" . $hours : $hours;
    $minutes = $minutes < 10 ? "0" . $minutes : $minutes;
    $seconds = $seconds < 10 ? "0" . $seconds : $seconds;

    return $hours . ":" . $minutes . ":" . $seconds;
}
