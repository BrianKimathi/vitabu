<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\Magazine;
use App\Models\Content_Transaction;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Exception;

class SalesMagazinesController extends Controller
{
    public function index(Request $request)
    {
        try {

            $author = Author_Data();
            $params['magazines'] = Magazine::where('author_id', $author['id'])->latest()->get();

            // Year
            $params['year_sum'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 3)->where('status', 1)->whereYear('created_at', date('Y'))
                ->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();
            // Month
            $params['month_sum'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 3)->where('status', 1)->whereMonth('created_at', date('m'))
                ->whereYear('created_at', date('Y'))->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();
            // Today
            $params['today_sum'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 3)->where('status', 1)->whereDate('created_at', date('Y-m-d'))
                ->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();

            if ($request->ajax()) {

                $input_magazine = $request['input_magazine'];

                $query = Content_Transaction::where('author_id', $author['id'])->where('content_type', 3);
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
                    ->addColumn('date', function ($row) {
                        $date = date("d M Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->addColumn('action', function ($row) {
                        return '<button type="button" class="edit-delete-btn download-invoice-btn"><i class="fa-solid fa-download fa-xl"></i></button>';
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
                    ->rawColumns(['action', 'status'])
                    ->make(true);
            }

            return view('author.sales_magazines.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
