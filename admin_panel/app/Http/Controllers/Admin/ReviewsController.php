<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\Magazine;
use App\Models\Novel;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;

class ReviewsController extends Controller
{
    public function index(Request $request)
    {
        try {

            $params['user'] = User::where('is_author', 0)->latest()->get();

            $params['audio_book'] = AudioBook::latest()->get();
            $params['novel'] = Novel::latest()->get();
            $params['magazine'] = Magazine::latest()->get();

            if ($request->ajax()) {

                $input_search = $request['input_search'];
                $input_user = $request['input_user'];
                $input_audio_book = $request['input_audio_book'];
                $input_novel = $request['input_novel'];
                $input_magazine = $request['input_magazine'];

                $query = Review::query();
                if (!empty($input_search)) {
                    $query->where(function ($q) use ($input_search) {
                        $q->where('review', 'LIKE', "%{$input_search}%");
                    });
                }
                if ($input_user != 0) {
                    $query->where('user_id', $input_user);
                }
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

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {

                        $review_delete = __('label.delete_review');

                        $delete = '<form onsubmit="return confirm(\'' . $review_delete . '\');" method="POST" action="' . route('admin.reviews.destroy', [$row->id]) . '">
                            <input type="hidden" name="_token" value="' . csrf_token() . '">
                            <input type="hidden" name="_method" value="DELETE">
                            <button type="submit" class="edit-delete-btn" title=' . __('label.delete') . '><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-around">';
                        $btn .= $delete;
                        $btn .= '</div>';
                        return $btn;
                    })
                    ->addColumn('status', function ($row) {
                        $status = $row->status == 1 ? "checked" : "";
                        return '<div class="switch">
                                    <input class="status-checkbox" id="checkbox' . $row->id . '" data-id="' . $row->id . '" type="checkbox" ' . $status . '>
                                    <label for="checkbox' . $row->id . '"></label>
                                      <span class="toggle-text"
                                        data-on="' . __('label.show') . '"
                                        data-off="' . __('label.hide') . '"></span>
                                    </div>';
                    })
                    ->addColumn('date', function ($row) {
                        $date = date("d M Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->rawColumns(['action', 'status'])
                    ->make(true);
            }
            return view('admin.reviews.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            Review::where('id', $id)->delete();
            return redirect()->route('admin.reviews.index')->with('success', __('label.review_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show($id)
    {
        try {

            $data = Review::where('id', $id)->first();
            if (isset($data)) {

                $data->status = $data->status === 1 ? 0 : 1;
                $data->save();
                return response()->json(['status' => 200, 'success' => __('label.status_changed'), 'status_code' => $data->status]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_found')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
