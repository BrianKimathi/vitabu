<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\User;
use Exception;
use Illuminate\Http\Request;

class CustomerReportController extends Controller
{
    public $common;
    public $folder = "user";


    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {
            $active_users_year = [];
            $active_users_month = [];
            $active_users_week = [];
            $active_users_today = [];

            $active_authors_year = [];
            $active_authors_month = [];
            $active_authors_week = [];
            $active_authors_today = [];

            for ($i = 1; $i < 13; $i++) {
                $users = User::whereHas('login_history', function ($q) use ($i) {
                    $q->whereYear('login_time', date('Y'))->whereMonth('login_time', $i);
                })->where('is_author', 0)->where('status', 1)->count();

                $active_users_year['sum'][] = $users;
                $active_users_year['month'][] = date('M', mktime(0, 0, 0, $i, 1));

                $authors = User::whereHas('login_history', function ($q) use ($i) {
                    $q->whereYear('login_time', date('Y'))->whereMonth('login_time', $i);
                })->where('is_author', 1)->where('status', 1)->count();
                $active_authors_year['sum'][] = $authors;
            }

            $d = cal_days_in_month(CAL_GREGORIAN, date('m'), date('Y'));
            for ($i = 1; $i <= $d; $i++) {
                $users = User::whereHas('login_history', function ($q) use ($i) {
                    $q->whereYear('login_time', date('Y'))->whereMonth('login_time', date('m'))->whereDay('login_time', $i);
                })->where('is_author', 0)->where('status', 1)->count();

                $active_users_month['sum'][] = $users;
                $active_users_month['day'][] = $i;

                $authors = User::whereHas('login_history', function ($q) use ($i) {
                    $q->whereYear('login_time', date('Y'))->whereMonth('login_time', date('m'))->whereDay('login_time', $i);
                })->where('is_author', 1)->where('status', 1)->count();

                $active_authors_month['sum'][] = $authors;
            }

            $start_of_week = now()->startOfWeek();
            $end_of_week = now()->endOfWeek();
            for ($date = $start_of_week->copy(); $date < $end_of_week; $date->addDay()) {
                $users = User::whereHas('login_history', function ($q) use ($date) {
                    $q->whereDate('login_time', $date);
                })->where('is_author', 0)->where('status', 1)->count();

                $active_users_week['sum'][] = $users;
                $active_users_week['date'][] = $date->format('d-m-Y');

                $authors = User::whereHas('login_history', function ($q) use ($date) {
                    $q->whereDate('login_time', $date);
                })->where('is_author', 1)->where('status', 1)->count();

                $active_authors_week['sum'][] = $authors;
            }

            $start_of_today = now()->today();
            $end_of_today = now()->today()->endOfDay();
            for ($hour = $start_of_today; $hour < $end_of_today; $hour->addHour()) {
                $next_hour = $hour->copy()->addHour();

                $users = User::whereHas('login_history', function ($q) use ($hour, $next_hour) {
                    $q->whereBetween('login_time', [$hour, $next_hour]);
                })->where('is_author', 0)->where('status', 1)->count();
                $active_users_today['sum'][] = $users;
                $active_users_today['hour'][] = $hour->format('H:00');

                $authors = User::whereHas('login_history', function ($q) use ($hour, $next_hour) {
                    $q->whereBetween('login_time', [$hour, $next_hour]);
                })->where('is_author', 1)->where('status', 1)->count();

                $active_authors_today['sum'][] = $authors;
            }

            $params['active_users_year'] = json_encode($active_users_year);
            $params['active_users_month'] = json_encode($active_users_month);
            $params['active_users_week'] = json_encode($active_users_week);
            $params['active_users_today'] = json_encode($active_users_today);

            $params['active_authors_year'] = json_encode($active_authors_year);
            $params['active_authors_month'] = json_encode($active_authors_month);
            $params['active_authors_week'] = json_encode($active_authors_week);
            $params['active_authors_today'] = json_encode($active_authors_today);

            return view('admin.customer_report.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_user_transactions(Request $request)
    {
        try {
            if ($request->ajax()) {
                $input_search = $request['input_search'];

                $query = User::withCount(['content_transaction'])->where('is_author', 0);

                if (!empty($input_search)) {
                    $query->where('first_name', 'LIKE', "%{$input_search}%");
                }
                $data = $query->orderBy('content_transaction_count', 'desc')->take(5)->get();
                $this->common->imageNameToUrl($data, 'image', $this->folder);
                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('total_transaction', function ($row) {
                        return $row->content_transaction_count ?? 0;
                    })
                    ->make(true);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_authors(Request $request)
    {
        try {
            if ($request->ajax()) {
                $author_search = $request['author_search'];

                $query = User::withCount(['audio_books', 'novels', 'magazines'])->withSum(['content_transactions as total_earnings' => function ($q) {
                    $q->where('status', 1);
                }], 'author_earning')->where('is_author', 1);

                if (!empty($author_search)) {
                    $query->where('first_name', 'LIKE', "%{$author_search}%");
                }
                $data = $query->orderByRaw('audio_books_count + novels_count + magazines_count desc')->take(5)->get();
                $this->common->imageNameToUrl($data, 'image', $this->folder);
                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('total_books', function ($row) {
                        return ($row->audio_books_count + $row->novels_count + $row->magazines_count) ?? 0;
                    })
                    ->addColumn('total_earnings', function ($row) {
                        return $row->total_earnings ?? 0;
                    })
                    ->make(true);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
