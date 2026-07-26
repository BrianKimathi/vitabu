<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\Common;
use App\Models\Category;
use App\Models\Magazine;
use App\Models\User;
use App\Models\Novel;
use App\Models\Content_Transaction;
use Exception;

class DashboardController extends Controller
{
    public $common;
    private $folder_category = "category";
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

            $author = Author_Data();

            // Card
            $params['AuthorData'] = User::where('is_author', 1)->where('id', $author['id'])->first();
            $params['NovelsCount'] = Novel::where('author_id', $author['id'])->count();
            $params['MagazinesCount'] = Magazine::where('author_id', $author['id'])->count();
            $params['AudioBooksCount'] = AudioBook::where('author_id', $author['id'])->count();
            
            // Total Earnings (Sales Reports) — net after platform commission
            $params['NovelEarnings'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 2)->where('status', 1)->sum('author_earning');
            $params['MagazineEarnings'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 3)->where('status', 1)->sum('author_earning');
            $params['AudioBookEarnings'] = Content_Transaction::where('author_id', $author['id'])->where('content_type', 1)->where('status', 1)->sum('author_earning');
            $params['TotalEarnings'] = $params['NovelEarnings'] + $params['MagazineEarnings'] + $params['AudioBookEarnings'];
            $params['TotalGrossSales'] = Content_Transaction::where('author_id', $author['id'])->where('status', 1)->sum('price');
            $params['TotalCommissionDeducted'] = Content_Transaction::where('author_id', $author['id'])->where('status', 1)->sum('commission');
            $params['ActiveCommissionRate'] = $this->common->getActiveCommissionRate();
            $params['WalletBalance'] = (float) ($params['AuthorData']['wallet_amount'] ?? 0);

            // Most Read Novels & Magazines & Audio Books
            $params['most_read_novels'] = Novel::where('author_id', $author['id'])->orderBy('total_read', 'desc')->where('total_read', '!=', 0)->where('status', 1)->take(5)->get();
            $params['most_read_magazines'] = Magazine::where('author_id', $author['id'])->orderBy('total_read', 'desc')->where('total_read', '!=', 0)->where('status', 1)->take(5)->get();
            $params['most_read_audio_books'] = AudioBook::where('author_id', $author['id'])->orderBy('total_played', 'desc')->where('total_played', '!=', 0)->where('status', 1)->take(5)->get();
            $this->common->imageNameToUrl($params['most_read_novels'], 'portrait_img', $this->folder_novels);
            $this->common->imageNameToUrl($params['most_read_magazines'], 'portrait_img', $this->folder_magazines);
            $this->common->imageNameToUrl($params['most_read_audio_books'], 'portrait_img', $this->folder_audio_books);

            // Best Category
            $params['best_category'] = Category::orderBy('sort_order', 'asc')->take(8)->get();
            $this->common->imageNameToUrl($params['best_category'], 'image', $this->folder_category);

            return view('author.dashboard.dashboard', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
