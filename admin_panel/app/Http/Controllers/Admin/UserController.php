<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Author_Request;
use App\Models\Bookmark;
use App\Models\Category;
use App\Models\Common;
use App\Models\Content_View;
use App\Models\Notification;
use App\Models\Read_Notification;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Exception;

// Login Type : 1= OTP, 2= Goggle, 3= Apple, 4= Normal
class UserController extends Controller
{
    private $folder = "user";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $params['data'] = [];
            if ($request->ajax()) {

                $input_search = $request['input_search'];
                $input_type = $request['input_type'];
                $input_login_type = $request['input_login_type'];

                $query = User::where('is_author', 0);
                if (!empty($input_search)) {
                    $query->where(function ($q) use ($input_search) {
                        $q->where('user_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")
                            ->orWhere('first_name', 'LIKE', "%{$input_search}%")->orWhere('last_name', 'LIKE', "%{$input_search}%")
                            ->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                    });
                }
                if ($input_login_type != "all") {
                    $query->where('type', $input_login_type);
                }
                if ($input_type == "today") {
                    $query->whereDay('created_at', date('d'))->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'));
                } elseif ($input_type == "month") {
                    $query->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'));
                } elseif ($input_type == "year") {
                    $query->whereYear('created_at', date('Y'));
                }
                $data = $query->latest()->get();

                $this->common->imageNameToUrl($data, 'image', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {

                        $user_delete = __('label.delete_user');

                        $delete = '<form onsubmit="return confirm(\'' . $user_delete . '\');" method="POST" action="' . route('admin.user.destroy', [$row->id]) . '">
                        <input type="hidden" name="_token" value="' . csrf_token() . '">
                        <input type="hidden" name="_method" value="DELETE">
                        <button type="submit" class="edit-delete-btn" title=' . __('label.delete') . '><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center">';
                        $btn .= '<a href="' . route('admin.user.edit', [$row->id]) . '" class="edit-delete-btn mr-4" title=' . __('label.edit') . '>';
                        $btn .= '<i class="fa-solid fa-pen-to-square fa-xl"></i>';
                        $btn .= '</a>';
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
                                        data-on="' . __('label.active') . '"
                                        data-off="' . __('label.inactive') . '"></span>
                                    </div>';
                    })
                    ->addColumn('date', function ($row) {
                        $date = date("d M Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->rawColumns(['action', 'status'])
                    ->make(true);
            }
            return view('admin.user.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function create()
    {
        try {
            $params['data'] = [];
            $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->get();

            return view('admin.user.add', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'first_name' => 'required|min:2',
                'last_name' => 'required|min:2',
                'mobile_number' => 'required|numeric|unique:tbl_user,mobile_number',
                'email' => 'required|unique:tbl_user|email',
                'password' => 'required|min:4',
                'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();

            $requestData['is_author'] = 0;
            if (isset($requestData['category_ids']) && $requestData['category_ids'] != null) {
                $categoryIds = implode(',', $request['category_ids']);
                $requestData['category_ids'] = $categoryIds;
            } else {
                $requestData['category_ids'] = "";
            }
            $user_name = rand(0, 1000);
            $email_array = explode('@', $request->email);
            $requestData['user_name'] = '@' . $email_array[0] . '_' . $user_name;
            $requestData['password'] = Hash::make($request->password);
            $files = $requestData['image'];
            $requestData['image'] = $this->common->saveImage($files, $this->folder, 'user_');
            $requestData['type'] = 4;
            $requestData['address'] = $request['address'] ?? "";
            $requestData['description'] = $request['description'] ?? $this->common->user_tag_line();
            $requestData['wallet_amount'] = 0;
            $requestData['device_type'] = 0;
            $requestData['device_token'] = "";
            $requestData['bank_name'] = "";
            $requestData['bank_holder_name'] = "";
            $requestData['account_no'] = "";
            $requestData['ifsc_code'] = "";
            $requestData['status'] = 1;
            $data = User::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_add_user')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_user')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function edit($id)
    {
        try {

            $params['data'] = User::where('id', $id)->first();
            if ($params['data'] != null) {

                $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->get();
                $this->common->imageNameToUrl(array($params['data']), 'image', $this->folder);

                return view('admin.user.edit', $params);
            } else {
                return redirect()->back()->with('error', __('label.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function update($id, Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'first_name' => 'required|min:2',
                'last_name' => 'required|min:2',
                'mobile_number' => 'required|numeric|unique:tbl_user,mobile_number,' . $id,
                'email' => 'required|email|unique:tbl_user,email,' . $id,
                'image' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            $requestData['is_author'] = 0;
            if (isset($requestData['category_ids']) && $requestData['category_ids'] != null) {
                $categoryIds = implode(',', $request['category_ids']);
                $requestData['category_ids'] = $categoryIds;
            } else {
                $requestData['category_ids'] = "";
            }
            if (isset($request['password']) && $request['password'] != null) {
                $requestData['password'] = Hash::make($request->password);
            } else {
                unset($requestData['password']);
            }
            if (isset($requestData['image'])) {
                $files = $requestData['image'];
                $requestData['image'] = $this->common->saveImage($files, $this->folder, 'user_');

                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_image']));
            }
            unset($requestData['old_image']);
            $requestData['address'] = $request['address'] ?? "";
            $requestData['description'] = $request['description'] ?? "";

            $data = User::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_user')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_user')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            $data = User::where('id', $id)->first();
            if (isset($data)) {

                Author_Request::where('user_id', $id)->delete();
                Bookmark::where('user_id', $id)->delete();
                Content_View::where('user_id', $id)->delete();
                Review::where('user_id', $id)->delete();
                Notification::where('user_id', $id)->delete();
                Read_Notification::where('user_id', $id)->delete();

                $this->common->deleteImageToFolder($this->folder, $data['image']);
                $data->delete();
            }
            return redirect()->route('admin.user.index')->with('success', __('label.user_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show($id)
    {
        try {

            $data = User::where('id', $id)->first();
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
