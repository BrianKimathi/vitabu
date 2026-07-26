<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\Author_Request;
use App\Models\Common;
use App\Models\Category;
use App\Models\Content_Transaction;
use App\Models\Magazine;
use App\Models\User;
use App\Models\Language;
use App\Models\Novel;
use Exception;

class DashboardController extends Controller
{
    public $common;
    private $folder_category = "category";
    private $folder_author = "user";
    private $folder_langauge = "language";
    private $folder_novels = "novels";
    private $folder_magazines = "magazines";
    private $folder_audio_books = "audio_books";
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            // Card
            $params['UserCount'] = User::where('is_author', 0)->count();
            $params['AuthorCount'] = User::where('is_author', 1)->count();
            $params['AuthorRequestCount'] = Author_Request::where('status', 0)->count();
            $params['NovelRequestCount'] = Novel::where('status', 0)->count();
            $params['MagazineRequestCount'] = Magazine::where('status', 0)->count();
            $params['AudioBookRequestCount'] = AudioBook::where('status', 0)->count();
            $params['CategoryCount'] = Category::count();
            $params['LanguageCount'] = Language::count();
            $params['NovelsCount'] = Novel::count();
            $params['MagazinesCount'] = Magazine::count();
            $params['AudioBooksCount'] = AudioBook::count();
            $params['AudioBooksSalesCount'] = Content_Transaction::where('content_type', 1)->count();
            $params['NovelSalesCount'] = Content_Transaction::where('content_type', 2)->count();
            $params['MagazinesSalesCount'] = Content_Transaction::where('content_type', 3)->count();
            $successfulSales = Content_Transaction::where('status', 1);
            $params['audio_book_earning'] = (clone $successfulSales)->where('content_type', 1)->sum('price');
            $params['novel_earning'] = (clone $successfulSales)->where('content_type', 2)->sum('price');
            $params['magazine_earning'] = (clone $successfulSales)->where('content_type', 3)->sum('price');
            $params['total_earning'] = Content_Transaction::where('status', 1)->sum('price');
            $params['author_earning'] = Content_Transaction::where('status', 1)->sum('author_earning');
            $params['admin_earning'] = Content_Transaction::where('status', 1)->sum('commission');
            $params['ActiveCommissionRate'] = $this->common->getActiveCommissionRate();
            $params['setting_data'] = Setting_Data();

            // User Statistice
            $user_data = [];
            $user_month = [];
            $author_data = [];
            $author_month = [];
            $d = cal_days_in_month(CAL_GREGORIAN, date('m'), date('Y'));
            for ($i = 1; $i < 13; $i++) {
                $Sum = User::where('is_author', 0)->whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->count();
                $Sum1 = User::where('is_author', 1)->whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->count();
                $user_data['sum'][] = (int) $Sum;
                $author_data['sum'][] = (int) $Sum1;
            }
            for ($i = 1; $i <= $d; $i++) {
                $Sum = User::where('is_author', 0)->whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->whereDay('created_at', $i)->count();
                $Sum1 = User::where('is_author', 1)->whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->whereDay('created_at', $i)->count();
                $user_month['sum'][] = (int) $Sum;
                $author_month['sum'][] = (int) $Sum1;
            }
            $params['user_year'] = json_encode($user_data);
            $params['author_year'] = json_encode($author_data);
            $params['user_month'] = json_encode($user_month);
            $params['author_month'] = json_encode($author_month);

            // Most Read Novels & Magazines & Audio Books
            $params['most_read_novels'] = Novel::where('status', 1)->where('total_read', '>', 0)->orderBy('total_read', 'desc')->take(5)->get();
            $params['most_read_magazines'] = Magazine::where('status', 1)->where('total_read', '>', 0)->orderBy('total_read', 'desc')->take(5)->get();
            $params['most_read_audio_books'] = AudioBook::where('status', 1)->where('total_played', '>', 0)->orderBy('total_played', 'desc')->take(5)->get();
            $this->common->imageNameToUrl($params['most_read_novels'], 'portrait_img', $this->folder_novels);
            $this->common->imageNameToUrl($params['most_read_magazines'], 'portrait_img', $this->folder_magazines);
            $this->common->imageNameToUrl($params['most_read_audio_books'], 'portrait_img', $this->folder_audio_books);

            // Best Selling Novels & Magazines & Audio Books
            $params['most_purchased_novels'] = Novel::withCount('content_transaction')->orderBy('content_transaction_count', 'desc')->having('content_transaction_count', '>', 0)->take(5)->get();
            $params['most_purchased_magazines'] = Magazine::withCount('content_transaction')->orderBy('content_transaction_count', 'desc')->having('content_transaction_count', '>', 0)->take(5)->get();
            $params['most_purchased_audio_books'] = AudioBook::withCount('content_transaction')->orderBy('content_transaction_count', 'desc')->having('content_transaction_count', '>', 0)->take(5)->get();
            $this->common->imageNameToUrl($params['most_purchased_novels'], 'portrait_img', $this->folder_novels);
            $this->common->imageNameToUrl($params['most_purchased_magazines'], 'portrait_img', $this->folder_magazines);
            $this->common->imageNameToUrl($params['most_purchased_audio_books'], 'portrait_img', $this->folder_audio_books);

            // Best Category
            $params['best_category'] = Category::orderBy('sort_order', 'asc')->take(8)->get();
            $this->common->imageNameToUrl($params['best_category'], 'image', $this->folder_category);

            // Best Language
            $params['best_language'] = Language::orderBy('sort_order', 'asc')->take(8)->get();
            $this->common->imageNameToUrl($params['best_language'], 'image', $this->folder_langauge);

            // Most Active Authors
            $startOfWeek = now()->startOfWeek();
            $endOfWeek = now()->endOfWeek();

            $params['active_authors'] = User::withCount([
                'novel' => function ($query) use ($startOfWeek, $endOfWeek) {
                    $query->whereBetween('created_at', [$startOfWeek, $endOfWeek]);
                },
                'magazine' => function ($query) use ($startOfWeek, $endOfWeek) {
                    $query->whereBetween('created_at', [$startOfWeek, $endOfWeek]);
                },
                'audio_book' => function ($query) use ($startOfWeek, $endOfWeek) {
                    $query->whereBetween('created_at', [$startOfWeek, $endOfWeek]);
                }
            ])
                ->where('status', 1)
                ->orderByRaw('novel_count + magazine_count + audio_book_count DESC')
                ->take(6)
                ->get();

            $this->common->imageNameToUrl($params['active_authors'], 'image', $this->folder_author);

            return view('admin.dashboard.dashboard', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
