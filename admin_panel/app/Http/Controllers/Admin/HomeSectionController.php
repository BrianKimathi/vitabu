<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\User;
use App\Models\Common;
use App\Models\Content_Section;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

// Section Type : 0- Home Page, 1- Audiobook, 2- Novel, 3- Magazine
// Content Type : 1- Audiobook, 2- Novel, 3- Magazine, 4- Category, 5- Language, 6- Author

class HomeSectionController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $params['data'] = Content_Section::where('section_type', 0)->orderBy('sort_order', 'asc')->latest()->get();

            $params['author'] = User::where('is_author', 1)->where('status', 1)->latest()->get();
            $params['category'] = Category::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();
            $params['language'] = Language::where('status', 1)->orderBy('sort_order', 'asc')->latest()->get();

            return view('admin.home_section.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $rules = [
                'title' => 'required|min:2',
                'content_type' => 'required',
                'screen_layout' => 'required',
                'view_all' => 'required',
                'no_of_content' => 'required',
                'order_by_upload' => 'required',
            ];
            if ($request['content_type'] == 1 || $request['content_type'] == 2 || $request['content_type'] == 3) {
                $rules['author_id'] = 'required';
                $rules['category_id'] = 'required';
                $rules['language_id'] = 'required';
                $rules['access_type'] = 'required';
                $rules['order_by_view'] = 'required';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            $requestData['section_type'] = 0;
            $requestData['short_title'] = $request['short_title'] ?? '';
            $requestData['sort_order'] = 0;
            $requestData['status'] = 1;
            if ($requestData['content_type'] == 4 || $requestData['content_type'] == 5 || $requestData['content_type'] == 6) {
                $requestData['author_id'] =  0;
                $requestData['category_id'] =  0;
                $requestData['language_id'] =  0;
                $requestData['access_type'] = 0;
                $requestData['order_by_view'] = 0;
            }

            $data = Content_Section::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_add_home_section')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_home_section')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function edit($id, Request $request)
    {
        try {

            $data = Content_Section::where('id', $id)->first();
            return response()->json(['status' => 200, 'success' => __('label.data_get_successfully'), 'data' => $data]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function update(Request $request, $id)
    {
        try {
            $rules = [
                'title' => 'required|min:2',
                'content_type' => 'required',
                'screen_layout' => 'required',
                'view_all' => 'required',
                'no_of_content' => 'required',
                'order_by_upload' => 'required',
            ];
            if ($request['content_type'] == 1 || $request['content_type'] == 2 || $request['content_type'] == 3) {
                $rules['author_id'] = 'required';
                $rules['category_id'] = 'required';
                $rules['language_id'] = 'required';
                $rules['access_type'] = 'required';
                $rules['order_by_view'] = 'required';
            }
            $validator = Validator::make($request->all(), $rules);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $requestData = $request->all();
            $requestData['section_type'] = 0;
            $requestData['short_title'] = $request['short_title'] ?? '';
            if ($requestData['content_type'] == 4 || $requestData['content_type'] == 5 || $requestData['content_type'] == 6) {
                $requestData['author_id'] =  0;
                $requestData['category_id'] =  0;
                $requestData['language_id'] =  0;
                $requestData['access_type'] = 0;
                $requestData['order_by_view'] = 0;
            }

            $data = Content_Section::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_home_section')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_home_section')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show($id)
    {
        try {
            Content_Section::where('id', $id)->delete();
            return response()->json(['status' => 200, 'success' => __('label.home_section_delete')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function changeStatus(Request $request)
    {
        try {

            $data = Content_Section::where('id', $request['id'])->first();
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
    // Sort Order
    public function SortableSave(Request $request)
    {
        try {

            $ids = $request['ids'];
            if (isset($ids) && $ids != null && $ids != "") {

                $id_array = explode(',', $ids);
                for ($i = 0; $i < count($id_array); $i++) {
                    Content_Section::where('id', $id_array[$i])->update(['sort_order' => $i + 1]);
                }
            }
            return response()->json(['status' => 200, 'success' => __('label.data_edit_successfully')]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
