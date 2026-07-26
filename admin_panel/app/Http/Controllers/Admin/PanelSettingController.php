<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\General_Setting;
use Illuminate\Http\Request;
use Exception;

class PanelSettingController extends Controller
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
                $params['result']['panel_login_page_bg_image'] = $this->common->getImage($this->folder, $params['result']['panel_login_page_bg_image']);

                return view('admin.panel_setting.index', $params);
            } else {
                return view('errors.404');
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function save(Request $request)
    {
        try {

            $data = $request->all();
            $data['panel_login_page_view'] = isset($data['panel_login_page_view']) ? $data['panel_login_page_view'] : 0;
        

                if (isset($data['panel_login_page_bg_image'])) {
                    $files = $data['panel_login_page_bg_image'];
                    $data['panel_login_page_bg_image'] = $this->common->saveImage($files, $this->folder, 'panel_');
                    $this->common->deleteImageToFolder($this->folder, basename($data['old_panel_login_page_bg_image']));
                }

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
}
