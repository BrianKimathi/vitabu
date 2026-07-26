<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Plan;
use App\Models\School;
use App\Models\Tax;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Validator;

class TransactionController extends Controller
{
    public $common;

    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {
            $params['data'] = [];

            $params['today'] = Transaction::whereDate('created_at', date('Y-m-d'))->sum('price');
            $params['month'] = Transaction::whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->sum('price');
            $params['year'] = Transaction::whereYear('created_at', date('Y'))->sum('price');

            $input_user_id = $request['input_user_id'];
            $input_plan_id = $request['input_plan_id'];
            $input_type = $request['input_type'];
            $input_start_date = $request['input_start_date'];
            $input_end_date = $request['input_end_date'];
            $input_status = $request['input_status'];
            $setting = Setting_Data();

            if ($request->ajax()) {

                $input_search = $request['input_search'];

                $query = Transaction::with(['plan', 'user']);

                if (!empty($input_search)) {
                    $query->where(function ($q) use ($input_search) {
                        $q->whereHas('user', function ($d) use ($input_search) {
                            $d->where('first_name', 'LIKE', "%{$input_search}%")
                                ->orWhere('last_name', 'LIKE', "%{$input_search}%")
                                ->orWhere('user_name', 'LIKE', "%{$input_search}%");
                        })->orWhereHas('plan', function ($d) use ($input_search) {
                            $d->where('name', 'LIKE', "%{$input_search}%");
                        });
                    });
                }
                if (!empty($input_user_id)) {
                    $query->where('user_id', $input_user_id);
                }
                if (!empty($input_plan_id)) {
                    $query->where('plan_id', $input_plan_id);
                }
                if (!empty($input_type)) {
                    if ($input_type == "today") {
                        $query->whereDay('created_at', date('d'))
                            ->whereMonth('created_at', date('m'))
                            ->whereYear('created_at', date('Y'));
                    } else if ($input_type == "month") {
                        $query->whereMonth('created_at', date('m'))
                            ->whereYear('created_at', date('Y'));
                    } else if ($input_type == "year") {
                        $query->whereYear('created_at', date('Y'));
                    }
                }
                if (isset($input_start_date) && isset($input_end_date)) {
                    $query->whereBetween('created_at', [$input_start_date, $input_end_date]);
                } else if (isset($input_start_date)) {
                    $query->whereDate('created_at', '>=', $input_start_date);
                } else if (isset($input_end_date)) {
                    $query->whereDate('created_at', '<=', $input_end_date);
                }

                if (isset($input_status) && $input_status != "") {
                    $query->where('status', $input_status);
                }

                $data = $query->latest()->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $delete = ' <form onsubmit="return confirm(\'' . __('label.delete_transaction_msg') . '\');" method="POST"  action="' . route('admin.transaction.destroy', [$row->id]) . '">
                    <input type="hidden" name="_token" value="' . csrf_token() . '">
                    <input type="hidden" name="_method" value="DELETE">
                    <button type="submit" class="edit-delete-btn" style="outline: none;" title="Delete"><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';
                        return $delete;
                    })
                    ->addColumn('plan', function ($row) {
                        return $row->plan->name ?? "-";
                    })
                    ->addColumn('buy_date', function ($row) {
                        return date('d M Y H:i', strtotime($row->created_at)) ?? "-";
                    })
                    ->addColumn('starts_at', function ($row) {
                        return date('d M Y H:i', strtotime($row->starts_at)) ?? "-";
                    })
                    ->addColumn('expiry_date', function ($row) {
                        return date('d M Y H:i', strtotime($row->expiry_date)) ?? "-";
                    })
                    ->addColumn('status', function ($row) {

                        if ($row->status == 1) {
                            $buttonClass = 'show-btn';
                            $statusLabel = __('label.active');
                        } elseif ($row->status == 2) {
                            $buttonClass = 'upcoming-btn';
                            $statusLabel = __('label.upcoming');
                        } else {
                            $buttonClass = 'hide-btn';
                            $statusLabel = __('label.expire');
                        }

                        return "<button type='button' id='$row->id' class='$buttonClass'>$statusLabel</button>";
                    })
                    ->rawColumns(['action', 'status', 'price'])
                    ->make(true);
            }
            $params['setting'] = $setting;
            $params['plans'] = Plan::get();
            $params['users'] = User::where('is_author', 0)->get();
            return view('admin.transaction.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function create()
    {
        try {
            $params['data'] = [];
            $params['plans'] = Plan::where('status', 1)->get();
            $params['users'] = User::where('is_author', 0)->where('status', 1)->get();
            return view('admin.transaction.add', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_id' => 'required',
                'plan_id' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }
            $user_id = $request->user_id;
            $plan_id = $request->plan_id;
            $coupon_code = $request->coupon_code ?? '';

            $plan = Plan::where('id', $plan_id)->first();
            $price = $plan->price ?? 0;

            if (!empty($coupon_code)) {
                $result = $this->common->checkCoupon($coupon_code, $user_id, $price);

                if (!$result['success']) {
                    return response()->json(['status' => 400, 'errors' => $result['message']]);
                }

                $discount_price = $result['discount'];
                $price = max($price - $discount_price, 0);
            }

            $taxes = Tax::select('id', 'name', 'percentage')->where('status', 1)->get();
            $total_tax = 0;
            foreach ($taxes as $tax) {
                $tax_amount = floor(($price * $tax['percentage']) / 100);
                $tax['amount'] = $tax_amount;
                $total_tax += $tax_amount;
            }

            $final_price = $price + $total_tax;

            $requestData = $request->all();
            $requestData['coupon_code'] = $coupon_code;
            $requestData['user_id'] = $user_id;
            $requestData['payment_method'] = "";
            $requestData['price'] = $final_price;
            $requestData['total_tax'] = $total_tax;
            $requestData['auto_renew'] = $plan['auto_renew'] ?? 0;
            $requestData['tax'] = json_encode($taxes, true);
            $requestData['transaction_id'] = $this->common->generateTransactionId();

            $plan_days = $this->common->days_calculate($plan->time, $plan->type);
            $transaction = Transaction::where('user_id', $user_id)->whereIn('status', [1, 2])->latest()->first();
            if ($transaction) {
                if ($transaction['status'] == 2) {
                    return response()->json(['status' => 400, 'errors' => __('label.you_already_have_an_upcoming_plan')]);
                }
                $requestData['status'] = 2;
                $requestData['starts_at'] = date('Y-m-d H:i', strtotime($transaction['expiry_date']));
                $requestData['expiry_date'] = date('Y-m-d H:i', strtotime('+' . $plan_days . ' Days', strtotime($requestData['starts_at'])));
                $transaction->update(['auto_renew' => 0]);
            } else {
                $requestData['starts_at'] = date('Y-m-d H:i');
                $requestData['expiry_date'] = date('Y-m-d H:i', strtotime('+' . $plan_days . ' Days', time()));
                $requestData['status'] = 1;
            }

            $transaction_data = Transaction::updateOrCreate(['id' => $requestData['id']], $requestData);

            if (isset($transaction_data->id)) {

                return response()->json(array('status' => 200, 'success' => __('label.transaction_save')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('label.transaction_not_save')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function destroy($id)
    {
        try {
            $data = Transaction::where('id', $id)->first();
            if (isset($data)) {
                $data->delete();
            }
            return redirect()->back()->with('success', __('label.transaction_delete'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
