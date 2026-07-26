<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\Common;
use App\Models\Content_Transaction;
use App\Models\Magazine;
use App\Models\Novel;
use Exception;
use Illuminate\Http\Request;

class SalesReportController extends Controller
{
    public $common;
    private $folder_novel = "novels";
    private $folder_audiobook = "audio_books";
    private $folder_magazine = "magazines";


    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            // User Statistice
            $audiobook_sales_year = [];
            $novel_sales_year = [];
            $magazine_sales_year = [];
            $audiobook_sales_month = [];
            $novel_sales_month = [];
            $magazine_sales_month = [];
            $audiobook_sales_week = [];
            $novel_sales_week = [];
            $magazine_sales_week = [];
            $audiobook_sales_today = [];
            $novel_sales_today = [];
            $magazine_sales_today = [];

            for ($i = 1; $i < 13; $i++) {
                $Sum1 = Content_Transaction::where('content_type', 1)->whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->where('status', 1)->count();
                $Sum2 = Content_Transaction::where('content_type', 2)->whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->where('status', 1)->count();
                $Sum3 = Content_Transaction::where('content_type', 3)->whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->where('status', 1)->count();
                $audiobook_sales_year['sum'][] = (int) $Sum1;
                $novel_sales_year['sum'][] = (int) $Sum2;
                $magazine_sales_year['sum'][] = (int) $Sum3;
                $audiobook_sales_year['month'][] = date('M', mktime(0, 0, 0, $i, 1));
            }

            $d = cal_days_in_month(CAL_GREGORIAN, date('m'), date('Y'));
            for ($i = 1; $i <= $d; $i++) {
                $Sum1 = Content_Transaction::where('content_type', 1)->whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->whereDay('created_at', $i)->where('status', 1)->count();
                $Sum2 = Content_Transaction::where('content_type', 2)->whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->whereDay('created_at', $i)->where('status', 1)->count();
                $Sum3 = Content_Transaction::where('content_type', 3)->whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->whereDay('created_at', $i)->where('status', 1)->count();
                $audiobook_sales_month['sum'][] = (int) $Sum1;
                $novel_sales_month['sum'][] = (int) $Sum2;
                $magazine_sales_month['sum'][] = (int) $Sum3;
                $audiobook_sales_month['day'][] = $i;
            }

            $start_of_week = now()->startOfWeek();
            $end_of_week = now()->endOfWeek();
            for ($date = $start_of_week->copy(); $date <= $end_of_week; $date->addDay()) {
                $Sum1 = Content_Transaction::where('content_type', 1)->whereDate('created_at', $date)->where('status', 1)->count();
                $Sum2 = Content_Transaction::where('content_type', 2)->whereDate('created_at', $date)->where('status', 1)->count();
                $Sum3 = Content_Transaction::where('content_type', 3)->whereDate('created_at', $date)->where('status', 1)->count();
                $audiobook_sales_week['sum'][] = (int) $Sum1;
                $novel_sales_week['sum'][] = (int) $Sum2;
                $magazine_sales_week['sum'][] = (int) $Sum3;
                $audiobook_sales_week['dates'][] = $date->format('Y-m-d');
            }

            $start_of_today = now()->today();
            $end_of_today = now()->today()->endOfDay();
            for ($hour = $start_of_today; $hour <= $end_of_today; $hour->addHour()) {
                $next_hour = $hour->copy()->addHour();
                $Sum1 = Content_Transaction::where('content_type', 1)->whereBetween('created_at', [$hour, $next_hour])->where('status', 1)->count();
                $Sum2 = Content_Transaction::where('content_type', 2)->whereBetween('created_at', [$hour, $next_hour])->where('status', 1)->count();
                $Sum3 = Content_Transaction::where('content_type', 3)->whereBetween('created_at', [$hour, $next_hour])->where('status', 1)->count();
                $audiobook_sales_today['sum'][] = (int) $Sum1;
                $novel_sales_today['sum'][] = (int) $Sum2;
                $magazine_sales_today['sum'][] = (int) $Sum3;
                $audiobook_sales_today['time'][] = $hour->format('H:00');
            }

            $audiobook = Content_Transaction::where('content_type', 1)->where('status', 1)->count();
            $novel = Content_Transaction::where('content_type', 2)->where('status', 1)->count();
            $magazine = Content_Transaction::where('content_type', 3)->where('status', 1)->count();

            $total_sales['sum'] = [$audiobook, $novel, $magazine];
            $total_sales['name'] = [__('label.audiobook'), __('label.novel'), __('label.magazine')];

            $params['audiobook_sales_year'] = json_encode($audiobook_sales_year);
            $params['novel_sales_year'] = json_encode($novel_sales_year);
            $params['magazine_sales_year'] = json_encode($magazine_sales_year);
            $params['audiobook_sales_month'] = json_encode($audiobook_sales_month);
            $params['novel_sales_month'] = json_encode($novel_sales_month);
            $params['magazine_sales_month'] = json_encode($magazine_sales_month);
            $params['audiobook_sales_week'] = json_encode($audiobook_sales_week);
            $params['novel_sales_week'] = json_encode($novel_sales_week);
            $params['magazine_sales_week'] = json_encode($magazine_sales_week);
            $params['audiobook_sales_today'] = json_encode($audiobook_sales_today);
            $params['novel_sales_today'] = json_encode($novel_sales_today);
            $params['magazine_sales_today'] = json_encode($magazine_sales_today);
            $params['total_sales'] = json_encode($total_sales);

            return view('admin.sales_report.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_novel(Request $request)
    {
        try {
            if ($request->ajax()) {
                $input_search = $request['input_search'];

                $query = Novel::withCount(['content_transaction'])->where('status', 1);
                if (!empty($input_search)) {
                    $query->where('title', 'LIKE', "%{$input_search}%");
                }
                $data = $query->with('author', 'category', 'language')->orderBy('content_transaction_count', 'desc')->take(5)->get();

                $this->common->imageNameToUrl($data, 'portrait_img', $this->folder_novel);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('total_sales', function ($row) {
                        return $row->content_transaction_count ?? 0;
                    })
                    ->addColumn('total_commission', function ($row) {
                        $commission = Content_Transaction::where('content_id', $row->id)->sum('commission');
                        return $commission;
                    })
                    ->addColumn('total_author_earning', function ($row) {
                        $author_earning = Content_Transaction::where('content_id', $row->id)->sum('author_earning');
                        return $author_earning;
                    })
                    ->make(true);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_audiobook(Request $request)
    {
        try {
            if ($request->ajax()) {
                $input_search = $request['input_search'];

                $query = AudioBook::withCount(['content_transaction'])->where('status', 1);
                if (!empty($input_search)) {
                    $query->where('title', 'LIKE', "%{$input_search}%");
                }
                $data = $query->with('author', 'category', 'language')->orderBy('content_transaction_count', 'desc')->take(5)->get();

                $this->common->imageNameToUrl($data, 'portrait_img', $this->folder_audiobook);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('total_sales', function ($row) {
                        return $row->content_transaction_count ?? 0;
                    })
                    ->addColumn('total_commission', function ($row) {
                        $commission = Content_Transaction::where('content_id', $row->id)->sum('commission');
                        return $commission;
                    })
                    ->addColumn('total_author_earning', function ($row) {
                        $author_earning = Content_Transaction::where('content_id', $row->id)->sum('author_earning');
                        return $author_earning;
                    })
                    ->make(true);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_magazine(Request $request)
    {
        try {
            if ($request->ajax()) {
                $input_search = $request['input_search'];

                $query = Magazine::withCount(['content_transaction'])->where('status', 1);
                if (!empty($input_search)) {
                    $query->where('title', 'LIKE', "%{$input_search}%");
                }
                $data = $query->with('author', 'category', 'language')->orderBy('content_transaction_count', 'desc')->take(5)->get();

                $this->common->imageNameToUrl($data, 'portrait_img', $this->folder_magazine);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('total_sales', function ($row) {
                        return $row->content_transaction_count ?? 0;
                    })
                    ->addColumn('total_commission', function ($row) {
                        $commission = Content_Transaction::where('content_id', $row->id)->sum('commission');
                        return $commission;
                    })
                    ->addColumn('total_author_earning', function ($row) {
                        $author_earning = Content_Transaction::where('content_id', $row->id)->sum('author_earning');
                        return $author_earning;
                    })
                    ->make(true);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
