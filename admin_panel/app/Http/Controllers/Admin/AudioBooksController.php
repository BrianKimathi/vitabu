<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\AudioBook_Episode;
use App\Models\Bookmark;
use App\Models\Category;
use App\Models\User;
use App\Models\Common;
use App\Models\Content_Transaction;
use App\Models\Content_View;
use App\Models\Language;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class AudioBooksController extends Controller
{
    private $folder = "audio_books";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $params['data'] = [];
            $params['author'] = User::where('is_author', 1)->where('status', 1)->latest()->get();
            $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
            $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

            if ($request->ajax()) {

                $input_search = $request['input_search'];
                $input_author = $request['input_author'];
                $input_category = $request['input_category'];
                $input_language = $request['input_language'];
                $input_status = $request['input_status'];
                $input_access_type = $request['input_access_type'];

                $query = AudioBook::where('status', '!=', 0)->withCount('audio_book_episodes');
                if (!empty($input_search)) {
                    $query->where('title', 'LIKE', "%{$input_search}%");
                }
                if ($input_author != 0) {
                    $query->where('author_id', $input_author);
                }
                if ($input_category != 0) {
                    $query->where('category_id', $input_category);
                }
                if ($input_language != 0) {
                    $query->where('language_id', $input_language);
                }
                if ($input_status != 0) {
                    $query->where('status', $input_status);
                }
                if ($input_access_type != "all") {
                    $query->where('access_type', $input_access_type);
                }

                $data = $query->with('author', 'category', 'language')->orderBy('id', 'desc')->latest()->get();

                $this->common->imageNameToUrl($data, 'portrait_img', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {

                        $audiobook_delete = __('label.delete_audio_book');

                        $delete = '<form onsubmit="return confirm(\'' . $audiobook_delete . '\');" method="POST" action="' . route('admin.audiobooks.destroy', [$row->id]) . '">
                            <input type="hidden" name="_token" value="' . csrf_token() . '">
                            <input type="hidden" name="_method" value="DELETE">
                            <button type="submit" class="edit-delete-btn" title=' . __('label.delete') . ' ><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center">';
                        $btn .= '<a href="' . route('admin.audiobooks.edit', [$row->id]) . '" class="edit-delete-btn mr-4" title=' . __('label.edit') . '>';
                        $btn .= '<i class="fa-solid fa-pen-to-square fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= $delete;
                        $btn .= '</a></div>';
                        return $btn;
                    })
                    ->addColumn('episode', function ($row) {
                        $episodesLabel = __('label.episodes');
                        return "<a href='" . route('admin.audiobooks.episodes.index', $row->id) . "' class='btn primary-bg text-white px-2 py-1 font-weight-bold'>$episodesLabel - $row->audio_book_episodes_count</a>";
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
                    ->rawColumns(['action', 'episode', 'status'])
                    ->make(true);
            }
            return view('admin.audio_book.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function create()
    {
        try {

            $params['author'] = User::where('is_author', 1)->where('status', 1)->latest()->get();
            $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
            $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

            return view('admin.audio_book.add', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $rules = [
                'author_id' => 'required',
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

            $requestData = $request->all();
            if (isset($requestData['isbn'])) {
                $requestData['bsnb'] = $requestData['isbn'];
            }
            $requestData['total_played'] = 0;
            $requestData['status'] = 1;
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
            if (isset($requestData['full_audio']) && $requestData['full_audio'] != null) {
                $requestData['full_audio'] = $request['full_audio'];
            } else {
                $requestData['full_audio'] = "";
            }
            $data = AudioBook::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {

                // Notification Send
                $status = $this->common->BasicNotiConfiguration('upload-new-content');
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $imageURL = $this->common->getImage($this->folder, $data['portrait_img']);
                    $this->common->SaveNotification(0, 4, 0, 0, 0, 0, 0, $imageURL, "",  "", 0, $data['title']);
                }

                return response()->json(['status' => 200, 'success' => __('label.success_add_audiobook')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_audiobook')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function edit($id)
    {
        try {

            $params['data'] = AudioBook::where('id', $id)->first();
            if ($params['data'] != null) {

                $params['data']['portrait_img'] = $this->common->getImage($this->folder, $params['data']['portrait_img']);
                $params['data']['landscape_img'] = $this->common->getImage($this->folder, $params['data']['landscape_img']);
                $params['data']['full_audio'] = $this->common->getFile($this->folder, $params['data']['full_audio']);

                $params['author'] = User::where('is_author', 1)->where('status', 1)->latest()->get();
                $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
                $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

                return view('admin.audio_book.edit', $params);
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
                'author_id' => 'required',
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

            $requestData = $request->all();
            if (isset($requestData['isbn'])) {
                $requestData['bsnb'] = $requestData['isbn'];
            }
            $requestData['description'] = $request['description'] ?? '';
            if ($requestData['access_type'] == 1) {
                $requestData['price'] = $request['price'];
            } else {
                $requestData['price'] = 0;
            }
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
            if (isset($requestData['full_audio'])) {
                $requestData['full_audio'] = $request['full_audio'];
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_full_audio']));
            } else {
                unset($requestData['full_audio']);
            }
            unset($requestData['old_portrait_img'], $requestData['old_landscape_img'], $requestData['old_full_audio']);

            $data = AudioBook::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_audiobook')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_audiobook')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            $data = AudioBook::where('id', $id)->first();
            if (isset($data)) {

                Bookmark::where('content_type', 1)->where('content_id', $id)->delete();
                Content_View::where('content_type', 1)->where('content_id', $id)->delete();
                Review::where('content_type', 1)->where('content_id', $id)->delete();
                Content_Transaction::where('content_type', 1)->where('content_id', $id)->update(['status' => 0]);

                $this->common->deleteImageToFolder($this->folder, $data['portrait_img']);
                $this->common->deleteImageToFolder($this->folder, $data['landscape_img']);
                $this->common->deleteImageToFolder($this->folder, $data['full_audio']);
                $data->delete();

                $episode_data = AudioBook_Episode::where('audio_book_id', $id)->get();
                foreach ($episode_data as $episode) {

                    $this->common->deleteImageToFolder($this->folder, $episode['image']);
                    if ($chapter['audio_type'] = 1) {
                        $this->common->deleteImageToFolder($this->folder, $episode['audio']);
                    }
                    $episode->delete();
                }
            }
            return redirect()->route('admin.audiobooks.index')->with('success', __('label.audiobook_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show($id)
    {
        try {

            $data = AudioBook::where('id', $id)->first();
            if (isset($data)) {

                $data->status = $data->status === 1 ? 2 : 1;
                $data->save();
                return response()->json(['status' => 200, 'success' => __('label.status_changed'), 'status_code' => $data->status]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_found')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    // Save Chunk
    public function saveChunkFullAudio()
    {

        @set_time_limit(5 * 60);

        $targetDir = storage_path('/app/public/audio_books');
        $cleanupTargetDir = true; // Remove old files
        $maxFileAge = 5 * 3600; // Temp file age in seconds

        // Create target dir
        if (!file_exists($targetDir)) {
            @mkdir($targetDir);
        }

        // Get a file name
        if (isset($_REQUEST["name"])) {
            $fileName = $_REQUEST["name"];
        } elseif (!empty($_FILES)) {
            $fileName = $_FILES["file"]["name"];
        } else {
            $fileName = uniqid("file_");
        }
        $filePath = $targetDir . DIRECTORY_SEPARATOR . $fileName;

        // Chunk information
        $chunk = isset($_REQUEST["chunk"]) ? intval($_REQUEST["chunk"]) : 0;
        $chunks = isset($_REQUEST["chunks"]) ? intval($_REQUEST["chunks"]) : 0;

        // Remove old temp files
        if ($cleanupTargetDir && is_dir($targetDir) && $dir = opendir($targetDir)) {
            while (($file = readdir($dir)) !== false) {
                $tmpfilePath = $targetDir . DIRECTORY_SEPARATOR . $file;

                // Remove temp file if it is older than the max age and not the current file
                if (preg_match('/\.part$/', $file) && (filemtime($tmpfilePath) < time() - $maxFileAge)) {
                    @unlink($tmpfilePath);
                }
            }
            closedir($dir);
        } else {
            die('{"jsonrpc" : "2.0", "error" : {"code": 100, "message": "Failed to open temp directory."}, "id" : "id"}');
        }

        // Open temp file
        if (!$out = @fopen("{$filePath}.part", $chunks ? "ab" : "wb")) {
            die('{"jsonrpc" : "2.0", "error" : {"code": 102, "message": "Failed to open output stream."}, "id" : "id"}');
        }

        if (!empty($_FILES)) {
            if ($_FILES["file"]["error"] || !is_uploaded_file($_FILES["file"]["tmp_name"])) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 103, "message": "Failed to move uploaded file."}, "id" : "id"}');
            }

            // Read binary input stream and append it to temp file
            if (!$in = @fopen($_FILES["file"]["tmp_name"], "rb")) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 101, "message": "Failed to open input stream."}, "id" : "id"}');
            }
        } else {
            if (!$in = @fopen("php://input", "rb")) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 101, "message": "Failed to open input stream."}, "id" : "id"}');
            }
        }

        while ($buff = fread($in, 4096)) {
            fwrite($out, $buff);
        }

        @fclose($out);
        @fclose($in);

        // Check if file has been uploaded
        if (!$chunks || $chunk == $chunks - 1) {
            // Strip the temp .part suffix off
            rename("{$filePath}.part", $filePath);

            // Generate a new filename based on the current date and time
            $extension = pathinfo($fileName, PATHINFO_EXTENSION); // Get the file extension from the original filename
            $newFileName = 'full_aud' . date('_d_m_Y_H_i_s') . time() . '.' . $extension; // Use the extracted extension
            $newFilePath = $targetDir . DIRECTORY_SEPARATOR . $newFileName;

            // Rename the uploaded file to the new filename
            rename($filePath, $newFilePath);

            // Send the new file name back to the client
            die(json_encode(array('jsonrpc' => '2.0', 'result' => $newFileName, 'id' => 'id')));
        }

        // Return Success JSON-RPC response
        die('{"jsonrpc" : "2.0", "result" : null, "id" : "id"}');
    }
    public function saveChunkEpisode()
    {

        @set_time_limit(5 * 60);

        $targetDir = storage_path('/app/public/audio_books');
        $cleanupTargetDir = true; // Remove old files
        $maxFileAge = 5 * 3600; // Temp file age in seconds

        // Create target dir
        if (!file_exists($targetDir)) {
            @mkdir($targetDir);
        }

        // Get a file name
        if (isset($_REQUEST["name"])) {
            $fileName = $_REQUEST["name"];
        } elseif (!empty($_FILES)) {
            $fileName = $_FILES["file"]["name"];
        } else {
            $fileName = uniqid("file_");
        }
        $filePath = $targetDir . DIRECTORY_SEPARATOR . $fileName;

        // Chunk information
        $chunk = isset($_REQUEST["chunk"]) ? intval($_REQUEST["chunk"]) : 0;
        $chunks = isset($_REQUEST["chunks"]) ? intval($_REQUEST["chunks"]) : 0;

        // Remove old temp files
        if ($cleanupTargetDir && is_dir($targetDir) && $dir = opendir($targetDir)) {
            while (($file = readdir($dir)) !== false) {
                $tmpfilePath = $targetDir . DIRECTORY_SEPARATOR . $file;

                // Remove temp file if it is older than the max age and not the current file
                if (preg_match('/\.part$/', $file) && (filemtime($tmpfilePath) < time() - $maxFileAge)) {
                    @unlink($tmpfilePath);
                }
            }
            closedir($dir);
        } else {
            die('{"jsonrpc" : "2.0", "error" : {"code": 100, "message": "Failed to open temp directory."}, "id" : "id"}');
        }

        // Open temp file
        if (!$out = @fopen("{$filePath}.part", $chunks ? "ab" : "wb")) {
            die('{"jsonrpc" : "2.0", "error" : {"code": 102, "message": "Failed to open output stream."}, "id" : "id"}');
        }

        if (!empty($_FILES)) {
            if ($_FILES["file"]["error"] || !is_uploaded_file($_FILES["file"]["tmp_name"])) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 103, "message": "Failed to move uploaded file."}, "id" : "id"}');
            }

            // Read binary input stream and append it to temp file
            if (!$in = @fopen($_FILES["file"]["tmp_name"], "rb")) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 101, "message": "Failed to open input stream."}, "id" : "id"}');
            }
        } else {
            if (!$in = @fopen("php://input", "rb")) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 101, "message": "Failed to open input stream."}, "id" : "id"}');
            }
        }

        while ($buff = fread($in, 4096)) {
            fwrite($out, $buff);
        }

        @fclose($out);
        @fclose($in);

        // Check if file has been uploaded
        if (!$chunks || $chunk == $chunks - 1) {
            // Strip the temp .part suffix off
            rename("{$filePath}.part", $filePath);

            // Generate a new filename based on the current date and time
            $extension = pathinfo($fileName, PATHINFO_EXTENSION); // Get the file extension from the original filename
            $newFileName = 'ep' . date('_d_m_Y_H_i_s') . time() . '.' . $extension; // Use the extracted extension
            $newFilePath = $targetDir . DIRECTORY_SEPARATOR . $newFileName;

            // Rename the uploaded file to the new filename
            rename($filePath, $newFilePath);

            // Send the new file name back to the client
            die(json_encode(array('jsonrpc' => '2.0', 'result' => $newFileName, 'id' => 'id')));
        }

        // Return Success JSON-RPC response
        die('{"jsonrpc" : "2.0", "result" : null, "id" : "id"}');
    }
    // Episodes
    public function EpisodesIndex(Request $request, $id)
    {
        try {

            $params['data'] = [];
            $params['audio_book_id'] = $id;

            $input_search = $request['input_search'];
            if ($input_search != null && isset($input_search)) {
                $params['data'] = AudioBook_Episode::where('audio_book_id', $id)->where('title', 'LIKE', "%{$input_search}%")->orderBy('sort_order', 'asc')->latest()->paginate(15);
            } else {
                $params['data'] = AudioBook_Episode::where('audio_book_id', $id)->orderBy('sort_order', 'asc')->latest()->paginate(15);
            }

            $this->common->imageNameToUrl($params['data'], 'image', $this->folder);

            // Sort Order
            $params['sort_order'] = AudioBook_Episode::where('audio_book_id', $id)->orderBy('sort_order', 'asc')->latest()->get();

            return view('admin.audio_book.ep_index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function EpisodesAdd($audio_book_id)
    {
        try {

            $params['audio_book_id'] = $audio_book_id;
            return view('admin.audio_book.ep_add', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function EpisodesSave(Request $request)
    {
        try {
            $rules = [
                'audio_book_id' => 'required',
                'title' => 'required|min:2',
                'is_episode_paid' => 'required',
                'audio_type' => 'required',
                'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
            ];
            if ($request['is_episode_paid'] == 1) {
                $rules['price'] = 'required|numeric|min:1';
            }
            if ($request['audio_type'] == 1) {
                $rules['audio'] = 'required';
            } else {
                $rules['audio_url'] = 'required';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            $requestData['description'] = $request['description'] ?? '';
            $file = $requestData['image'];
            $requestData['image'] = $this->common->saveImage($file, $this->folder, 'ep_');
            if ($requestData['audio_type'] == 1) {
                $requestData['audio'] = $request['audio'];
            } else {
                $requestData['audio'] = $request['audio_url'];
            }
            unset($requestData['audio_url']);
            if ($requestData['is_episode_paid'] == 1) {
                $requestData['price'] = $request['price'];
            } else {
                $requestData['price'] = 0;
            }
            $requestData['total_played'] = 0;
            $requestData['sort_order'] = 0;
            $requestData['status'] = 1;

            $data = AudioBook_Episode::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_add_episode')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_episode')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function EpisodesSortOrder(Request $request)
    {
        try {

            $ids = $request['ids'];
            if (isset($ids) && $ids != null && $ids != "") {

                $id_array = explode(',', $ids);
                for ($i = 0; $i < count($id_array); $i++) {
                    AudioBook_Episode::where('id', $id_array[$i])->update(['sort_order' => $i + 1]);
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.data_edit_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function EpisodesEdit($audio_book_id, $id)
    {
        try {
            $params['audio_book_id'] = $audio_book_id;
            $params['data'] = AudioBook_Episode::where('id', $id)->first();
            if ($params['data'] != null) {

                $this->common->imageNameToUrl(array($params['data']), 'image', $this->folder);
                if ($params['data']['audio_type'] == 1) {
                    $this->common->fileNameToUrl(array($params['data']), 'audio', $this->folder);
                }

                return view('admin.audio_book.ep_edit', $params);
            } else {
                return redirect()->back()->with('error', __('label.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function EpisodesUpdate(Request $request)
    {
        try {
            $rules = [
                'audio_book_id' => 'required',
                'title' => 'required|min:2',
                'is_episode_paid' => 'required',
                'audio_type' => 'required',
                'image' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
            ];
            if ($request['is_episode_paid'] == 1) {
                $rules['price'] = 'required|numeric|min:1';
            }
            if ($request['audio_type'] == 2) {
                $rules['audio_url'] = 'required';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            $requestData['description'] = $request['description'] ?? '';
            if ($requestData['is_episode_paid'] == 1) {
                $requestData['price'] = $request['price'];
            } else {
                $requestData['price'] = 0;
            }
            if (isset($requestData['image'])) {
                $file = $requestData['image'];
                $requestData['image'] = $this->common->saveImage($file, $this->folder, 'ep_');
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_image']));
            }
            if ($requestData['audio_type'] == 1) {

                if (isset($requestData['audio']) && !empty($request['audio'])) {
                    $requestData['audio'] = $request['audio'];
                    $this->common->deleteImageToFolder($this->folder, basename($requestData['old_audio']));
                } else {
                    $requestData['audio'] = basename($requestData['old_audio']);
                }
            } else {
                $requestData['audio'] = $request['audio_url'];
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_audio']));
            }
            unset($requestData['old_image'], $requestData['audio_url'], $requestData['old_audio']);

            $data = AudioBook_Episode::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_episode')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_episode')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function EpisodesDelete(Request $request, $audio_book_id, $id)
    {
        try {
            $data = AudioBook_Episode::where('id', $id)->first();
            if (isset($data)) {

                Content_View::where('content_type', 1)->where('content_id', $audio_book_id)->where('sub_content_id', $id)->delete();
                Content_Transaction::where('content_type', 1)->where('content_id', $audio_book_id)->where('sub_content_id', $id)->update(['status' => 0]);

                $this->common->deleteImageToFolder($this->folder, $data['image']);
                if ($data['audio_type'] = 1) {
                    $this->common->deleteImageToFolder($this->folder, $data['audio']);
                }
                $data->delete();
            }
            return redirect()->route('admin.audiobooks.episodes.index', ['id' => $audio_book_id])->with('success', __('label.episode_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
