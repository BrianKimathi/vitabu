<?php

namespace App\Http\Controllers\Author;

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
            $author = Author_Data();
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
                $input_month = $request['input_month'];
                $input_year = $request['input_year'];

                $query = Author_Payout::where('author_id', $author['id']);
                if ($input_status != "all") {
                    $query->where('status', $input_status);
                }
                if (isset($input_month) && $input_month != "") {
                    $query->where('payout_month', $input_month);
                }
                if (isset($input_year) && $input_year != "") {
                    $query->where('payout_year', $input_year);
                }
                $data = $query->orderBy('status', 'asc')->latest()->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('date', function ($row) {
                        $date = date("Y-m-d", strtotime($row->created_at));
                        return $date;
                    })
                    ->addColumn('status', function ($row) {

                        $pendingLabel = __('label.pending');
                        $paidLabel = __('label.paid');
                        $holdLabel = __('label.hold');

                        $pendingStatus = $row->status == 0 ? "selected" : "";
                        $paidStatus = $row->status == 1 ? "selected" : "";
                        $holdStatus = $row->status == 2 ? "selected" : "";

                        $status = "<select class='form-control status-change' id='" . $row->id . "' disabled>
                        <option value='0' " . $pendingStatus . " >" . $pendingLabel . "</option>
                        <option value='1'  " . $paidStatus . " >" . $paidLabel . "</option>
                        <option value='2'  " . $holdStatus . " >" . $holdLabel . "</option>
                        </select>";
                        return $status;
                    })
                    ->addColumn('total_read_time', function ($row) {
                        return seconds_to_hm($row->total_read_time);
                    })
                    ->addColumn('payout_period', function ($row) {
                        return date('M', mktime(0, 0, 0, $row->payout_month, 1)) . " " . $row->payout_year;
                    })
                    ->rawColumns(['status'])
                    ->make(true);
            }
            return view('author.subscription_payout.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
