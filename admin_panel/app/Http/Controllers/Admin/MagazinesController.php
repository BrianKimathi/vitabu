<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bookmark;
use App\Models\Category;
use App\Models\User;
use App\Models\Common;
use App\Models\Content_Transaction;
use App\Models\Content_View;
use App\Models\Language;
use App\Models\Magazine;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class MagazinesController extends Controller
{
    private $folder = "magazines";
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

                $query = Magazine::where('status', '!=', 0);
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

                        $magazines_delete = __('label.delete_magazines');

                        $delete = '<form onsubmit="return confirm(\'' . $magazines_delete . '\');" method="POST" action="' . route('admin.magazines.destroy', [$row->id]) . '">
                            <input type="hidden" name="_token" value="' . csrf_token() . '">
                            <input type="hidden" name="_method" value="DELETE">
                            <button type="submit" class="edit-delete-btn" title=' . __('label.delete') . '><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center">';
                        $btn .= '<a href="' . route('admin.magazines.edit', [$row->id]) . '" class="edit-delete-btn mr-4" title=' . __('label.edit') . '>';
                        $btn .= '<i class="fa-solid fa-pen-to-square fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= $delete;
                        $btn .= '</a></div>';
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
                    ->rawColumns(['action', 'chapter', 'status'])
                    ->make(true);
            }
            return view('admin.magazines.index', $params);
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

            return view('admin.magazines.add', $params);
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
                'full_magazine' => 'required',
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
            $requestData['total_read'] = 0;
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
            $data = Magazine::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {

                // Notification Send
                $status = $this->common->BasicNotiConfiguration('upload-new-content');
                if ($status['status'] == 1 && $status['send_notification'] == 1) {
                    $imageURL = $this->common->getImage($this->folder, $data['portrait_img']);
                    $this->common->SaveNotification(0, 4, 0, 0, 0, 0, 0, $imageURL, "",  "", 0, $data['title']);
                }

                return response()->json(['status' => 200, 'success' => __('label.success_add_magazines')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_magazines')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function edit($id)
    {
        try {

            $params['data'] = Magazine::where('id', $id)->first();
            if ($params['data'] != null) {

                $params['data']['portrait_img'] = $this->common->getImage($this->folder, $params['data']['portrait_img']);
                $params['data']['landscape_img'] = $this->common->getImage($this->folder, $params['data']['landscape_img']);
                $params['data']['full_magazine'] = $this->common->getFile($this->folder, $params['data']['full_magazine']);

                $params['author'] = User::where('is_author', 1)->where('status', 1)->latest()->get();
                $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
                $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

                return view('admin.magazines.edit', $params);
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
            if (isset($requestData['full_magazine'])) {
                $requestData['full_magazine'] = $request['full_magazine'];
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_full_magazine']));
            } else {
                unset($requestData['full_magazine']);
            }
            unset($requestData['old_portrait_img'], $requestData['old_landscape_img'], $requestData['old_full_magazine']);

            $data = Magazine::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_magazine')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_magazine')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            $data = Magazine::where('id', $id)->first();
            if (isset($data)) {

                Bookmark::where('content_type', 3)->where('content_id', $id)->delete();
                Content_View::where('content_type', 3)->where('content_id', $id)->delete();
                Review::where('content_type', 3)->where('content_id', $id)->delete();
                Content_Transaction::where('content_type', 3)->where('content_id', $id)->update(['status' => 0]);

                $this->common->deleteImageToFolder($this->folder, $data['portrait_img']);
                $this->common->deleteImageToFolder($this->folder, $data['landscape_img']);
                $this->common->deleteImageToFolder($this->folder, $data['full_magazine']);
                $data->delete();
            }
            return redirect()->route('admin.magazines.index')->with('success', __('label.magazines_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show($id)
    {
        try {

            $data = Magazine::where('id', $id)->first();
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
    public function saveChunkMagazines()
    {

        @set_time_limit(5 * 60);

        $targetDir = storage_path('/app/public/magazines');
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
            $newFileName = 'mag' . date('_d_m_Y_H_i_s') . time() . '.' . $extension; // Use the extracted extension
            $newFilePath = $targetDir . DIRECTORY_SEPARATOR . $newFileName;

            // Rename the uploaded file to the new filename
            rename($filePath, $newFilePath);

            // Send the new file name back to the client
            die(json_encode(array('jsonrpc' => '2.0', 'result' => $newFileName, 'id' => 'id')));
        }

        // Return Success JSON-RPC response
        die('{"jsonrpc" : "2.0", "result" : null, "id" : "id"}');
    }
}
