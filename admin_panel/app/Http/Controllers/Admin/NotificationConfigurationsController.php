<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Notification_Configuration;
use Illuminate\Http\Request;
use Exception;

class NotificationConfigurationsController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $getstatus = Notification_Configuration::latest()->first();
            $params['main_status'] = $getstatus['status'];

            if ($request->ajax()) {

                $data = Notification_Configuration::latest()->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->make(true);
            }
            return view('admin.notification_configuration.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {

            $entries = $request->input('entries');
            $type = $request->type;
            $status = $request->status;

            if ($type == "all") {

                if ($status == 1) {
                    Notification_Configuration::query()->update(['status' => 1]);
                } elseif ($status == 0) {
                    Notification_Configuration::query()->update(['status' => 0, 'send_mail' => 0, 'send_notification' => 0]);
                }
            } else {
                foreach ($entries as $entry) {

                    $id = $entry['id'];
                    $array = [
                        'send_notification' => $entry['notification'],
                        'send_mail' => $entry['email'],
                    ];
                    Notification_Configuration::where('id', $id)->update($array);
                }
            }

            return response()->json(['status' => 200, 'success' => __('label.configuration_update')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
