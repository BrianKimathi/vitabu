<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\Magazine;
use App\Models\Novel;
use App\Models\Review;
use Illuminate\Http\Request;
use Exception;

class ReviewsController extends Controller
{
    public function index(Request $request)
    {
        try {

            $author = Author_Data();
            $params['novel'] = Novel::where('author_id', $author['id'])->latest()->get();
            $params['magazine'] = Magazine::where('author_id', $author['id'])->latest()->get();
            $params['audio_book'] = AudioBook::where('author_id', $author['id'])->latest()->get();

            if ($request->ajax()) {

                $input_novel = $request['input_novel'];
                $input_magazine = $request['input_magazine'];
                $input_audio_book = $request['input_audio_book'];

                $data = [];
                if ($input_novel != 0 || $input_magazine != 0 || $input_audio_book != 0) {
                    $query = Review::query();
                    if ($input_audio_book != 0) {
                        $query->where('content_type', 1)->where('content_id', $input_audio_book);
                    }
                    if ($input_novel != 0) {
                        $query->where('content_type', 2)->where('content_id', $input_novel);
                    }
                    if ($input_magazine != 0) {
                        $query->where('content_type', 3)->where('content_id', $input_magazine);
                    }
                    $data = $query->latest()->with('user', 'audio_book', 'novel', 'magazine')->get();
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('status', function ($row) {
                        if ($row->status == 1) {
                            $showLabel = __('label.show');
                            return "<button type='button' class='show-btn'>$showLabel</button>";
                        } else {
                            $hideLabel = __('label.hide');
                            return "<button type='button' class='hide-btn'>$hideLabel</button>";
                        }
                    })
                    ->addColumn('date', function ($row) {
                        $date = date("d M Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->rawColumns(['status'])
                    ->make(true);
            }
            return view('author.reviews.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
