<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Author_Payout;
use App\Models\Common;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;


class SubscriptionPayoutController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {
            $params['author'] = User::where('is_author', 1)->latest()->get();
            $start_year = 2000;
            $current_year = now()->year;
            $params['years'] = range($start_year, $current_year);
            $params['current_month'] = now()->month;
            $params['current_year'] = $current_year;

            $params['months'] = [
                1 => __('label.jan'),
                2 => __('label.feb'),
                3 => __('label.mar'),
                4 => __('label.apr'),
                5 => __('label.may'),
                6 => __('label.jun'),
                7 => __('label.jul'),
                8 => __('label.aug'),
                9 => __('label.sep'),
                10 => __('label.oct'),
                11 => __('label.nov'),
                12 => __('label.dec'),
            ];

            if ($request->ajax()) {

                $input_status = $request['input_status'];
                $input_author_id = $request['input_author_id'];
                $input_month = $request['input_month'];
                $input_year = $request['input_year'];

                $query = Author_Payout::query();
                if ($input_author_id != "0") {
                    $query->where('author_id', $input_author_id);
                }
                if ($input_status != "all") {
                    $query->where('status', $input_status);
                }
                if (isset($input_month) && $input_month != "") {
                    $query->where('payout_month', $input_month);
                }
                if (isset($input_year) && $input_year != "") {
                    $query->where('payout_year', $input_year);
                }
                $data = $query->with('author')->orderBy('status', 'asc')->latest()->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('date', function ($row) {
                        $date = date("d M Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->addColumn('status', function ($row) {

                        $pendingLabel = __('label.pending');
                        $paidLabel = __('label.paid');
                        $holdLabel = __('label.hold');
                        $payout_period = date('M', mktime(0, 0, 0, $row->payout_month, 1)) . " " . $row->payout_year;

                        $pendingStatus = $row->status == 0 ? "selected" : "";
                        $paidStatus = $row->status == 1 ? "selected" : "";
                        $holdStatus = $row->status == 2 ? "selected" : "";

                        $status = "<select class='form-control status-change' id='" . $row->id . "' data-earnings=" . $row->author_payable_amount . " data-payout_period='" . $payout_period . "'>
                        <option value='0' " . $pendingStatus . " >" . $pendingLabel . "</option>
                        <option value='1'  " . $paidStatus . " >" . $paidLabel . "</option>
                        <option value='2'  " . $holdStatus . " >" . $holdLabel . "</option>
                        </select>";
                        return $status;
                    })
                    ->addColumn('action', function ($row) {
                        $total_earnings = ($row->author_payable_amount ?? 0) +  ($row->content_earnings ?? 0);
                        $delete = ' <form onsubmit="return confirm(\'' . __('label.delete_subscription_payout_msg') . '\');" method="POST"  action="' . route('admin.subscription_payout.destroy', [$row->id]) . '">
                    <input type="hidden" name="_token" value="' . csrf_token() . '">
                    <input type="hidden" name="_method" value="DELETE">
                    <button type="submit" class="edit-delete-btn" style="outline: none;" title="Delete"><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center">';
                        $btn .= '<a class="edit-delete-btn view_details mr-4" data-toggle="modal" href="#detailsModal" data-id="' . $row->id . '" data-name="' . $row->author?->first_name . '" data-earnings="' . $total_earnings . '" data-bank_name="' . $row->author?->bank_name . '" data-bank_holder_name="' . $row->author?->bank_holder_name . '" data-account_no="' . $row->author?->account_no . '" data-ifsc_code="' . $row->author?->ifsc_code . '" title="' . __('label.view_details') . '">';
                        $btn .= '<i class="fa-solid fa-eye fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= $delete;
                        $btn .= '</a></div>';
                        return $btn;
                    })
                    ->addColumn('total_read_time', function ($row) {
                        return seconds_to_hm($row->total_read_time);
                    })
                    ->addColumn('payout_period', function ($row) {
                        return date('M', mktime(0, 0, 0, $row->payout_month, 1)) . " " . $row->payout_year;
                    })
                    ->rawColumns(['status', 'action'])
                    ->make(true);
            }
            return view('admin.subscription_payout.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show(Request $request)
    {
        try {
            $id = $request->id ?? 0;
            $status = $request->status ?? 0;

            $data = Author_Payout::where('id', $id)->first();
            if (isset($data)) {

                $data->status = $status;
                $data->save();
                if ($data['status'] == 1) {

                    $payout_date = date('d M Y', strtotime($data['created_at']));
                    $payout_period = date('M', mktime(0, 0, 0, $data['payout_month'], 1)) . " " . $data['payout_year'];
                    $total_earnings = $data['author_payable_amount'] + $data['content_earnings'];

                    $author = User::where('is_author', 1)->where('id', $data['author_id'])->first();
                    if ($author) {
                        $account_last_four = substr($author['account_no'], -4);
                        $title = "Subscription Payout Credited";
                        $message = "Your subscription payout of " . Currency_Code() . $total_earnings .
                            " for the period " . $payout_period .
                            " has been successfully credited to your bank account (A/C No. XXXX" . $account_last_four . ").";

                        $check = $this->common->BasicNotiConfiguration('subscription-status-change');
                        if ($check['status'] == 1 && $check['send_notification'] == 1) {
                            $this->common->send_user_push_notification($author['device_type'], $author['device_token'], $title, $message);
                        }

                        if ($check['status'] == 1 && $check['send_mail'] == 1) {
                            $this->common->Send_Mail(12, $author['email'], 0, "", $total_earnings, $author['first_name'], $author['last_name'], "", $payout_date, 0, "", $payout_period, $data['author_payable_amount'], $data['content_earnings']);
                        }
                    }
                }

                return response()->json(['status' => 200, 'success' => __('label.status_changed'), 'status_code' => $data->status]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_found')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {
            $data = Author_Payout::where('id', $id)->first();
            if (isset($data)) {
                $data->delete();
            }
            return redirect()->back()->with('success', __('label.subscription_payout_delete'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
