<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Magazine;
use App\Models\Content_Transaction;
use App\Models\Coupon;
use App\Models\Tax;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class SalesMagazinesController extends Controller
{
    public  $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $params['user'] = User::where('is_author', 0)->latest()->get();
            $params['author'] = User::where('is_author', 1)->latest()->get();
            $params['magazines'] = Magazine::latest()->get();

            // Year
            $params['year_sum'] = Content_Transaction::where('content_type', 3)->where('status', 1)->whereYear('created_at', date('Y'))
                ->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();
            // Month
            $params['month_sum'] = Content_Transaction::where('content_type', 3)->where('status', 1)->whereMonth('created_at', date('m'))
                ->whereYear('created_at', date('Y'))->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();
            // Today
            $params['today_sum'] = Content_Transaction::where('content_type', 3)->where('status', 1)->whereDate('created_at', date('Y-m-d'))
                ->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();

            if ($request->ajax()) {

                $input_user = $request['input_user'];
                $input_author = $request['input_author'];
                $input_magazine = $request['input_magazine'];

                $query = Content_Transaction::where('content_type', 3);
                if ($input_user != 0) {
                    $query->where('user_id', $input_user);
                }
                if ($input_author != 0) {
                    $query->where('author_id', $input_author);
                }
                if ($input_magazine != 0) {
                    $query->where('content_id', $input_magazine);
                }
                $data = $query->with('user', 'author', 'magazine')->orderBy('id', 'desc')->latest()->get();

                foreach ($data as $transaction) {
                    $coupon_code = $transaction['coupon_code'];
                    $price = 0;
                    if (!empty($coupon_code)) {
                        if ($transaction['content_id'] != 0) {
                            $price = Magazine::where('id', $transaction['content_id'])->value('price');
                        }
                        $coupon = Coupon::where('coupon_code', $coupon_code)->first();
                        if ($coupon) {
                            $transaction['coupon_discount'] = $coupon['amount_type'] == 1 ?  (round(($price * $coupon['price']) / 100, 2)) : $coupon['price'];
                        }
                    }
                    if (!empty($transaction['tax'])) {
                        $tax = json_decode($transaction['tax'], true);
                        $transaction['taxes'] = $tax;
                    }
                    if ($transaction->magazine) {
                        $transaction['original_price'] = $transaction->magazine->price;
                        $transaction['title'] = $transaction->magazine->title;
                    } else {
                        $transaction['original_price'] = 0;
                        $transaction['title'] = '';
                    }
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {

                        $transaction_delete = __('label.delete_transaction');

                        $delete = '<form onsubmit="return confirm(\'' . $transaction_delete . '\');" method="POST" action="' . route('admin.salesaudiobooks.destroy', [$row->id]) . '">
                            <input type="hidden" name="_token" value="' . csrf_token() . '">
                            <input type="hidden" name="_method" value="DELETE">
                            <button type="submit" class="edit-delete-btn" title=' . __('label.delete') . '><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center">';
                        $btn .= '<button type="button" class="mr-4 edit-delete-btn download-invoice-btn" title=' . __('label.download') . '><i class="fa-solid fa-download fa-xl"></i></button>';
                        $btn .= $delete;
                        $btn .= '</div>';
                        return $btn;
                    })
                    ->addColumn('status', function ($row) {

                        if ($row->status == 0) {
                            $buttonClass = 'upcoming-btn';
                            $statusLabel = __('label.processing');
                        } elseif ($row->status == 1) {
                            $buttonClass = 'show-btn';
                            $statusLabel = __('label.success');
                        } else {
                            $buttonClass = 'hide-btn';
                            $statusLabel = __('label.fail');
                        }

                        return "<button type='button' class='$buttonClass'>$statusLabel</button>";
                    })
                    ->addColumn('date', function ($row) {
                        $date = date("d M Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->rawColumns(['action', 'status'])
                    ->make(true);
            }

            return view('admin.sales_magazines.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function create()
    {
        try {
            $params['users'] = User::where('is_author', 0)->where('status', 1)->get();
            $params['authors'] = User::where('is_author', 1)->where('status', 1)->get();
            $params['magazines'] = Magazine::where('status', 1)->get();

            return view('admin.sales_magazines.add', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required',
                    'author_id' => 'required',
                    'magazine_id' => 'required',
                ]
            );
            if ($validator->fails()) {
                $err = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $err]);
            }

            $requestData = $request->all();

            $Magazine = Magazine::where('id', $request->magazine_id)->first();
            $price = $Magazine['price'];

            $discount_price = 0;
            $coupon_code = $request->coupon_code ?? '';
            if (!empty($coupon_code)) {
                $result = $this->common->checkCoupon($coupon_code, $request->user_id, $price);

                if (!$result['success']) {
                    return response()->json(['status' => 400, 'errors' => $result['message']]);
                }

                $discount_price = $result['discount'];
            }

            $price = max($price - $discount_price, 0);

            $taxes = Tax::select('id', 'name', 'percentage')->where('status', 1)->get();
            $total_tax = 0;
            foreach ($taxes as $tax) {
                $tax_amount = ($price * $tax['percentage']) / 100;
                $tax['amount'] = $tax_amount;
                $total_tax += $tax_amount;
            }

            $final_price = $price + $total_tax;
            $splits = $this->common->calculateContentTransactionSplits($final_price, $total_tax);

            $requestData['content_id'] = $request->magazine_id;
            $requestData['coupon_code'] = $coupon_code;
            $requestData['sub_content_id'] = 0;
            $requestData['content_type'] = 3;
            $requestData['tax'] = json_encode($taxes);
            $requestData['total_tax'] = $total_tax;
            $requestData['price'] = $final_price;
            $requestData['commission'] = $splits['commission'];
            $requestData['author_earning'] = $splits['author_earning'];
            $existing = !empty($requestData['id'])
                ? Content_Transaction::find($requestData['id'])
                : null;
            $requestData['transaction_id'] = $requestData['transaction_id']
                ?? ($existing->transaction_id ?? $this->common->generateTransactionId());
            $requestData['payment_method'] = '';
            $requestData['status'] = $existing && (int) $existing->status === 1 ? 1 : 0;

            unset($requestData['magazine_id']);
            $transaction = Content_Transaction::updateOrCreate(
                ['id' => $requestData['id'] ?? null],
                $requestData
            );
            if ((int) $transaction->status === 0) {
                $this->common->confirmContentTransaction($transaction->fresh());
            }

            return response()->json(['status' => 200, 'success' => __('label.transaction_save')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_magazine(Request $request)
    {
        try {
            $id = $request->id;
            $data = Magazine::where('author_id', $id)->where('status', 1)->get();
            return response()->json(['status' => 200, 'success' => __('label.data_get_successfully'), 'result' => $data]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            Content_Transaction::where('id', $id)->delete();
            return redirect()->route('admin.salesmagazines.index')->with('success', __('label.transaction_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
