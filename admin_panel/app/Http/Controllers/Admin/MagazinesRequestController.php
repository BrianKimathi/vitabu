<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\User;
use App\Models\Common;
use App\Models\Language;
use App\Models\Magazine;
use Illuminate\Http\Request;
use Exception;

class MagazinesRequestController extends Controller
{
    private $folder = "magazines";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $params['data'] = [];
            $params['author'] = User::where('is_author', 1)->where('status', 1)->latest()->get();
            $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
            $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

            if ($request->ajax()) {

                $data = Magazine::with('author', 'category', 'language')->orderBy('id', 'desc')->where('status', 0)->latest()->get();

                $this->common->imageNameToUrl($data, 'portrait_img', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $approvedLabel = __('label.approve');
                        $rejectedLabel = __('label.reject');
                        $btn = "<button type='button' class='show-btn mr-2' id='$row->id' onclick='change_status($row->id, 1)'>$approvedLabel</button>";
                        $btn .= "<button type='button' class='hide-btn' id='$row->id' onclick='change_status($row->id, 0)'>$rejectedLabel</button>";
                        return $btn;
                    })
                    ->rawColumns(['action'])
                    ->make(true);
            }
            return view('admin.magazines_request.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show(Request $request)
    {
        try {
            $id = $request->id;
            $status = $request->status;
            $data = Magazine::where('id', $id)->first();
            if ($data && $status == 1) {
                $data->status = 1;
                $title = $data['title'];
                $data->save();

                $author = User::where('id', $data->author_id)->first();
                if ($author) {
                    $mail = $this->common->BasicNotiConfiguration('content-status-change');
                    if ($mail['status'] == 1 && $mail['send_mail'] == 1) {
                        $this->common->Send_Mail(8, $author['email'], 1, $title, 0, "", "", "", "", 3);
                    }
                    if ($mail['status'] == 1 && $mail['send_notification'] == 1) {
                        $this->common->SaveNotification(1, 8, $author['id'], 3, 0, 0, 0, "", $author['device_type'], $author['device_token'], 1, $title);
                    }
                }
                return response()->json(['status' => 200, 'success' => __('label.magazine_approved')]);
            } elseif ($data && $status == 0) {
                $title = $data['title'];
                $data->delete();

                $author = User::where('id', $data->author_id)->first();
                if ($author) {
                    $mail = $this->common->BasicNotiConfiguration('content-status-change');
                    if ($mail['status'] == 1 && $mail['send_mail'] == 1) {
                        $this->common->Send_Mail(8, $author['email'], 0, $title, 0, "", "", "", "", 3);
                    }
                    if ($mail['status'] == 1 && $mail['send_notification'] == 1) {
                        $this->common->SaveNotification(1, 8, $author['id'], 3, 0, 0, 0, "", $author['device_type'], $author['device_token'], 0, $title);
                    }
                }
                return response()->json(['status' => 200, 'success' => __('label.magazine_rejected')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_found')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
