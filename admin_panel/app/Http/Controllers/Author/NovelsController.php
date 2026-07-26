<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\Bookmark;
use App\Models\Category;
use App\Models\Common;
use App\Models\Content_Transaction;
use App\Models\Content_View;
use App\Models\Language;
use App\Models\Novel;
use App\Models\Novel_Chapter;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class NovelsController extends Controller
{
    private $folder = "novels";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $author = Author_Data();
            $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
            $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

            if ($request->ajax()) {

                $input_search = $request['input_search'];
                $input_category = $request['input_category'];
                $input_language = $request['input_language'];
                $input_access_type = $request['input_access_type'];

                $query = Novel::where('author_id', $author['id'])->withCount('chapters');
                if (!empty($input_search)) {
                    $query->where('title', 'LIKE', "%{$input_search}%");
                }
                if ($input_category != 0) {
                    $query->where('category_id', $input_category);
                }
                if ($input_language != 0) {
                    $query->where('language_id', $input_language);
                }
                if (isset($input_status)) {
                    $query->where('status', $input_status);
                }
                if ($input_access_type != "all") {
                    $query->where('access_type', $input_access_type);
                }
                $data = $query->with('category', 'language')->orderBy('id', 'desc')->latest()->get();

                $this->common->imageNameToUrl($data, 'portrait_img', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {

                        $novel_delete = __('label.delete_novel');
                        $btn = '<div class="d-flex justify-content-center" style="gap:6px;">';
                        $btn .= '<a href="' . route('author.novels.edit', [$row->id]) . '" class="btn btn-sm" style="background:#EEF0FF;color:#4E45B8;font-weight:600;padding:4px 10px;border-radius:6px;font-size:12px;border:none;">
                                    <i class="fa-solid fa-pen mr-1"></i> ' . __('label.edit') . '
                                </a>';
                        $btn .= '<form onsubmit="return confirm(\'' . $novel_delete . '\');" method="POST" action="' . route('author.novels.destroy', [$row->id]) . '" style="display:inline;">
                                    <input type="hidden" name="_token" value="' . csrf_token() . '">
                                    <input type="hidden" name="_method" value="DELETE">
                                    <button type="submit" class="btn btn-sm" style="background:#FFF0EE;color:#E54B4B;font-weight:600;padding:4px 10px;border-radius:6px;font-size:12px;border:none;">
                                        <i class="fa-solid fa-trash mr-1"></i> ' . __('label.delete') . '
                                    </button>
                                </form>';
                        $btn .= '<a href="' . route('author.novels.chapters.index', $row->id) . '" class="btn btn-sm" style="background:#FFF8E5;color:#F5A623;font-weight:600;padding:4px 10px;border-radius:6px;font-size:12px;border:none;">
                                    <i class="fa-solid fa-list mr-1"></i> ' . __('label.chapters') . '
                                </a>';
                        $btn .= '</div>';
                        return $btn;
                    })
                    ->addColumn('chapter', function ($row) {
                        $chaptersLabel = __('label.chapters');
                        return "<a href='" . route('author.novels.chapters.index', $row->id) . "' class='btn btn-sm' style='background:#EEF0FF;color:#4E45B8;font-weight:600;padding:4px 12px;border-radius:6px;font-size:12px;border:none;'><i class='fa-solid fa-list mr-1'></i> $chaptersLabel — $row->chapters_count</a>";
                    })
                    ->addColumn('status', function ($row) {
                        $statusLabel = __('label.show');
                        $bg = '#E8F5E9';
                        $color = '#2E7D32';
                        if ($row->status == 0) {
                            $statusLabel = __('label.under_review');
                            $bg = '#FFF8E5';
                            $color = '#F5A623';
                        } elseif ($row->status == 2) {
                            $statusLabel = __('label.hide');
                            $bg = '#FFF0EE';
                            $color = '#E54B4B';
                        }
                        return "<span class='badge' style='background:{$bg};color:{$color};font-size:12px;font-weight:600;padding:4px 12px;border-radius:6px;'>{$statusLabel}</span>";
                    })
                    ->rawColumns(['action', 'chapter', 'status'])
                    ->make(true);
            }
            return view('author.novels.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function create()
    {
        try {

            $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
            $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

            return view('author.novels.add', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $rules = [
                'category_id' => 'required',
                'language_id' => 'required',
                'title' => 'required|min:2',
                'access_type' => 'required',
                'portrait_img' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
                'landscape_img' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
            ];
            if ($request['access_type'] == 1) {
                $rules['price'] = 'required|numeric|min:1';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $author = Author_Data();

            $requestData = $request->all();
            if (isset($requestData['isbn'])) {
                $requestData['bsnb'] = $requestData['isbn'];
            }
            $requestData['author_id'] = $author['id'];
            $requestData['total_read'] = 0;
            $requestData['status'] = 0;
            $requestData['description'] = $request['description'] ?? '';
            $files1 = $requestData['portrait_img'];
            $requestData['portrait_img'] = $this->common->saveImage($files1, $this->folder, 'port_');
            $files2 = $requestData['landscape_img'];
            $requestData['landscape_img'] = $this->common->saveImage($files2, $this->folder, 'land_');
            if ($requestData['access_type'] == 1) {
                $requestData['price'] = $request['price'];
            } else {
                $requestData['price'] = 0;
            }
            $requestData['author_split_amount'] = $request['author_split_amount'] ?? null;
            $requestData['author_split_percentage'] = $request['author_split_percentage'] ?? null;
            if ($requestData['author_split_amount'] === '') $requestData['author_split_amount'] = null;
            if ($requestData['author_split_percentage'] === '') $requestData['author_split_percentage'] = null;
            if (isset($requestData['full_novel']) && $requestData['full_novel'] != null) {
                $requestData['full_novel'] = $request['full_novel'];
            } else {
                $requestData['full_novel'] = "";
            }
            $data = Novel::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {

                // Notification Send
                $status = $this->common->BasicNotiConfiguration('upload-new-content');
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $imageURL = $this->common->getImage($this->folder, $data['portrait_img']);
                    $this->common->SaveNotification(0, 4, 0, 0, 0, 0, 0, $imageURL, "",  "", 0, $data['title']);
                }

                return response()->json(['status' => 200, 'success' => __('label.success_add_novel')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_novel')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function edit($id)
    {
        try {

            $params['data'] = Novel::where('id', $id)->first();
            if ($params['data'] != null) {

                $params['data']['portrait_img'] = $this->common->getImage($this->folder, $params['data']['portrait_img']);
                $params['data']['landscape_img'] = $this->common->getImage($this->folder, $params['data']['landscape_img']);
                $params['data']['full_novel'] = $this->common->getFile($this->folder, $params['data']['full_novel']);

                $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
                $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

                return view('author.novels.edit', $params);
            } else {
                return redirect()->back()->with('error', __('label.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function update(Request $request)
    {
        try {
            $rules = [
                'category_id' => 'required',
                'language_id' => 'required',
                'title' => 'required|min:2',
                'access_type' => 'required',
                'portrait_img' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
                'landscape_img' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
            ];
            if ($request['access_type'] == 1) {
                $rules['price'] = 'required|numeric|min:1';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $author = Author_Data();

            $requestData = $request->all();
            if (isset($requestData['isbn'])) {
                $requestData['bsnb'] = $requestData['isbn'];
            }
            $requestData['author_id'] = $author['id'];
            $requestData['description'] = $request['description'] ?? '';
            if ($requestData['access_type'] == 1) {
                $requestData['price'] = $request['price'];
            } else {
                $requestData['price'] = 0;
            }
            $requestData['author_split_amount'] = $request['author_split_amount'] ?? null;
            $requestData['author_split_percentage'] = $request['author_split_percentage'] ?? null;
            if ($requestData['author_split_amount'] === '') $requestData['author_split_amount'] = null;
            if ($requestData['author_split_percentage'] === '') $requestData['author_split_percentage'] = null;
            if (isset($requestData['portrait_img'])) {
                $files1 = $requestData['portrait_img'];
                $requestData['portrait_img'] = $this->common->saveImage($files1, $this->folder, 'port_');

                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_portrait_img']));
            }
            if (isset($requestData['landscape_img'])) {
                $files2 = $requestData['landscape_img'];
                $requestData['landscape_img'] = $this->common->saveImage($files2, $this->folder, 'land_');

                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_landscape_img']));
            }
            if (isset($requestData['full_novel'])) {
                $requestData['full_novel'] = $request['full_novel'];
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_full_novel']));
            } else {
                unset($requestData['full_novel']);
            }
            unset($requestData['old_portrait_img'], $requestData['old_landscape_img'], $requestData['old_full_novel']);

            $data = Novel::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_novel')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_novel')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            $data = Novel::where('id', $id)->first();
            if (isset($data)) {

                Bookmark::where('content_type', 2)->where('content_id', $id)->delete();
                Content_View::where('content_type', 2)->where('content_id', $id)->delete();
                Review::where('content_type', 2)->where('content_id', $id)->delete();
                Content_Transaction::where('content_type', 2)->where('content_id', $id)->update(['status' => 0]);

                $this->common->deleteImageToFolder($this->folder, $data['portrait_img']);
                $this->common->deleteImageToFolder($this->folder, $data['landscape_img']);
                $this->common->deleteImageToFolder($this->folder, $data['full_novel']);
                $data->delete();

                $chapter_data = Novel_Chapter::where('novel_id', $id)->get();
                foreach ($chapter_data as $chapter) {

                    $this->common->deleteImageToFolder($this->folder, $chapter['image']);
                    if ($chapter['chapter_type'] = 1) {
                        $this->common->deleteImageToFolder($this->folder, $chapter['chapter']);
                    }
                    $chapter->delete();
                }
            }
            return redirect()->route('author.novels.index')->with('success', __('label.novel_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    // Chapter
    public function ChapterIndex(Request $request, $id)
    {
        try {

            $params['data'] = [];
            $params['novel_id'] = $id;

            $input_search = $request['input_search'];
            if ($input_search != null && isset($input_search)) {
                $params['data'] = Novel_Chapter::where('novel_id', $id)->where('title', 'LIKE', "%{$input_search}%")->orderBy('sort_order', 'asc')->latest()->paginate(15);
            } else {
                $params['data'] = Novel_Chapter::where('novel_id', $id)->orderBy('sort_order', 'asc')->latest()->paginate(15);
            }

            $this->common->imageNameToUrl($params['data'], 'image', $this->folder);

            // Sort Order
            $params['sort_order'] = Novel_Chapter::where('novel_id', $id)->orderBy('sort_order', 'asc')->latest()->get();

            return view('author.novels.ch_index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ChapterAdd($novel_id)
    {
        try {

            $params['novel_id'] = $novel_id;
            return view('author.novels.ch_add', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ChapterSave(Request $request)
    {
        try {
            $rules = [
                'novel_id' => 'required',
                'title' => 'required|min:2',
                'is_chapter_paid' => 'required',
                'chapter_type' => 'required',
                'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
            ];
            if ($request['is_chapter_paid'] == 1) {
                $rules['price'] = 'required|numeric|min:1';
            }
            if ($request['chapter_type'] == 1) {
                $rules['chapter'] = 'required';
            } else {
                $rules['chapter_url'] = 'required';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            $requestData['description'] = $request['description'] ?? '';
            $file = $requestData['image'];
            $requestData['image'] = $this->common->saveImage($file, $this->folder, 'chap_');
            if ($requestData['chapter_type'] == 1) {
                $requestData['chapter'] = $request['chapter'];
            } else {
                $requestData['chapter'] = $request['chapter_url'];
            }
            unset($requestData['chapter_url']);
            if ($requestData['is_chapter_paid'] == 1) {
                $requestData['price'] = $request['price'];
            } else {
                $requestData['price'] = 0;
            }
            $requestData['total_read'] = 0;
            $requestData['sort_order'] = 0;
            $requestData['status'] = 1;

            $data = Novel_Chapter::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_add_chapter')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_chapter')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ChapterSortOrder(Request $request)
    {
        try {

            $ids = $request['ids'];
            if (isset($ids) && $ids != null && $ids != "") {

                $id_array = explode(',', $ids);
                for ($i = 0; $i < count($id_array); $i++) {
                    Novel_Chapter::where('id', $id_array[$i])->update(['sort_order' => $i + 1]);
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.data_edit_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ChapterEdit($novel_id, $id)
    {
        try {
            $params['novel_id'] = $novel_id;
            $params['data'] = Novel_Chapter::where('id', $id)->first();
            if ($params['data'] != null) {

                $this->common->imageNameToUrl(array($params['data']), 'image', $this->folder);
                if ($params['data']['chapter_type'] == 1) {
                    $this->common->fileNameToUrl(array($params['data']), 'chapter', $this->folder);
                }

                return view('author.novels.ch_edit', $params);
            } else {
                return redirect()->back()->with('error', __('label.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ChapterUpdate(Request $request)
    {
        try {
            $rules = [
                'novel_id' => 'required',
                'title' => 'required|min:2',
                'is_chapter_paid' => 'required',
                'chapter_type' => 'required',
                'image' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
            ];
            if ($request['is_chapter_paid'] == 1) {
                $rules['price'] = 'required|numeric|min:1';
            }
            if ($request['chapter_type'] == 2) {
                $rules['chapter_url'] = 'required';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            $requestData['description'] = $request['description'] ?? '';
            if ($requestData['is_chapter_paid'] == 1) {
                $requestData['price'] = $request['price'];
            } else {
                $requestData['price'] = 0;
            }
            if (isset($requestData['image'])) {
                $file = $requestData['image'];
                $requestData['image'] = $this->common->saveImage($file, $this->folder, 'chap_');
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_image']));
            }
            if ($requestData['chapter_type'] == 1) {

                if (isset($requestData['chapter']) && !empty($request['chapter'])) {
                    $requestData['chapter'] = $request['chapter'];
                    $this->common->deleteImageToFolder($this->folder, basename($requestData['old_chapter']));
                } else {
                    $requestData['chapter'] = basename($requestData['old_chapter']);
                }
            } else {
                $requestData['chapter'] = $request['chapter_url'];
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_chapter']));
            }
            unset($requestData['old_image'], $requestData['chapter_url'], $requestData['old_chapter']);

            $data = Novel_Chapter::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_chapter')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_chapter')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ChapterDelete(Request $request, $novel_id, $id)
    {
        try {
            $data = Novel_Chapter::where('id', $id)->first();
            if (isset($data)) {

                Content_View::where('content_type', 2)->where('content_id', $novel_id)->where('sub_content_id', $id)->delete();
                Content_Transaction::where('content_type', 2)->where('content_id', $novel_id)->where('sub_content_id', $id)->update(['status' => 0]);

                $this->common->deleteImageToFolder($this->folder, $data['image']);
                if ($data['chapter_type'] = 1) {
                    $this->common->deleteImageToFolder($this->folder, $data['chapter']);
                }
                $data->delete();
            }
            return redirect()->route('author.novels.chapters.index', ['id' => $novel_id])->with('success', __('label.chapter_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
