<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\AudioBook_Episode;
use App\Models\Content_Transaction;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Exception;

class SalesAudioBooksController extends Controller
{
    public function index(Request $request)
    {
        try {

            $author = Author_Data();
            $params['audio_books'] = AudioBook::where('author_id', $author['id'])->latest()->get();

            // Year
            $params['year_sum'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 1)->where('status', 1)->whereYear('created_at', date('Y'))
                ->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();
            // Month
            $params['month_sum'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 1)->where('status', 1)->whereMonth('created_at', date('m'))
                ->whereYear('created_at', date('Y'))->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();
            // Today
            $params['today_sum'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 1)->where('status', 1)->whereDate('created_at', date('Y-m-d'))
                ->selectRaw('SUM(commission) as total_commission, SUM(author_earning) as total_author_earning')->first();

            if ($request->ajax()) {

                $input_audio_book = $request['input_audio_book'];

                $query = Content_Transaction::where('author_id', $author['id'])->where('content_type', 1);
                if ($input_audio_book != 0) {
                    $query->where('content_id', $input_audio_book);
                }
                $data = $query->with('user', 'author', 'audio_book', 'episode')->orderBy('id', 'desc')->latest()->get();

                foreach ($data as $transaction) {
                    $coupon_code = $transaction['coupon_code'];
                    $price = 0;

                    if (!empty($coupon_code)) {
                        if ($transaction['sub_content_id'] != 0) {
                            $price = AudioBook_Episode::where('audio_book_id', $transaction['content_id'])->where('id', $transaction['sub_content_id'])->value('price');
                        } else {
                            $price = AudioBook::where('id', $transaction['content_id'])->value('price');
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
                    if ($transaction->episode) {
                        $transaction['original_price'] = $transaction->episode->price;
                        $transaction['title'] = $transaction->audio_book->title . ' - ' . $transaction->episode->title;
                    } else if ($transaction->audio_book) {
                        $transaction['original_price'] = $transaction->audio_book->price;
                        $transaction['title'] = $transaction->audio_book->title;
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
            return view('author.sales_audio_book.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
