<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Content_Transaction;
use App\Models\Withdrawal_Request;
use Exception;
use Illuminate\Http\Request;

class FinanceReportController extends Controller
{
    public $common;


    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            // Commission Statistice
            $commission_year = [];
            $commission_month = [];
            $commission_week = [];
            $commission_today = [];
            $tax_array = [];

            $temp_labels = [];

            for ($i = 1; $i <= 12; $i++) {
                $commission_sum = Content_Transaction::whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->where('status', 1)->sum('commission');
                $commission_year['sum'][] = (int) $commission_sum;
                $commission_year['month'][] = date('M', mktime(0, 0, 0, $i, 1));

                $month_name = date('M', mktime(0, 0, 0, $i, 1));
                $tax_array['months'][] = $month_name;

                $transactions = Content_Transaction::select('tax')->whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->where('status', 1)->get();

                $month_taxes = [];

                foreach ($transactions as $transaction) {
                    $json_array = json_decode($transaction->tax, true);
                    if (!is_array($json_array)) continue;

                    foreach ($json_array as $tax) {
                        $name = $tax['name'] ?? '';
                        $amount = $tax['amount'] ?? 0;

                        if (!isset($month_taxes[$name])) {
                            $month_taxes[$name] = 0;
                        }
                        $month_taxes[$name] += $amount;

                        if (!in_array($name, $temp_labels)) {
                            $temp_labels[] = $name;
                        }
                    }
                }

                $tax_array['series'][] = $month_taxes;
            }

            $final_series = [];
            foreach ($temp_labels as $label) {
                $data = [];
                foreach ($tax_array['series'] as $month_data) {
                    $data[] = $month_data[$label] ?? 0;
                }
                $final_series[] = [
                    'name' => $label,
                    'data' => $data,
                ];
            }

            $tax_array['series'] = $final_series;

            $d = cal_days_in_month(CAL_GREGORIAN, date('m'), date('Y'));
            for ($i = 1; $i <= $d; $i++) {
                $commission_sum = Content_Transaction::whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->whereDay('created_at', $i)->where('status', 1)->sum('commission');
                $commission_month['sum'][] = (int)$commission_sum;
                $commission_month['day'][] = $i;
            }

            $start_of_week = now()->startOfWeek();
            $end_of_week = now()->endOfWeek();
            for ($date = $start_of_week->copy(); $date < $end_of_week; $date->addDay()) {
                $commission_sum = Content_Transaction::whereDate('created_at', $date)->where('status', 1)->sum('commission');
                $commission_week['sum'][] = (int)$commission_sum;
                $commission_week['dates'][] = $date->format('d-m-Y');
            }

            $start_of_today = now()->today();
            $end_of_today = now()->today()->endOfDay();
            for ($hour = $start_of_today; $hour < $end_of_today; $hour->addHour()) {
                $next_hour = $hour->copy()->addHour();
                $commission_sum = Content_Transaction::whereBetween('created_at', [$hour, $next_hour])->where('status', 1)->sum('commission');
                $commission_today['sum'][] = $commission_sum;
                $commission_today['hour'][] = $hour->format('H:00');
            }

            $params['commission_year'] = json_encode($commission_year);
            $params['commission_month'] = json_encode($commission_month);
            $params['commission_week'] = json_encode($commission_week);
            $params['commission_today'] = json_encode($commission_today);
            $params['tax_array'] = json_encode($tax_array);

            $params['CommissionCount'] = Content_Transaction::where('status', 1)->sum('commission');
            $params['TaxCount'] = Content_Transaction::where('status', 1)->sum('total_tax');
            $params['WithdrawelCount'] = Withdrawal_Request::where('status', 0)->count();

            return view('admin.finance_report.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_withdrawels(Request $request)
    {
        try {
            if ($request->ajax()) {
                $input_search = $request['input_search'];

                $query = Withdrawal_Request::query();

                if (!empty($input_search)) {
                    $query->whereHas('author', function ($q) use ($input_search) {
                        $q->where('first_name', 'LIKE', "%{$input_search}%");
                    });
                }
                $data = $query->with('author')->orderBy('status', 'asc')->latest()->take(5)->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('date', function ($row) {
                        $date = date("Y-m-d", strtotime($row->created_at));
                        return $date;
                    })

                    ->addColumn('status', function ($row) {
                        if ($row->status == 0) {
                            $showLabel = __('label.pending');
                            return "<button type='button' class='hide-btn'>$showLabel</button>";
                        } else if ($row->status == 1) {
                            $hideLabel = __('label.completed');
                            return "<button type='button' class='show-btn'>$hideLabel</button>";
                        } else {
                            return "-";
                        }
                    })
                    ->rawColumns(['status'])
                    ->make(true);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
