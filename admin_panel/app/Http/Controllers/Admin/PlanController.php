<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Plan;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Exception;
use Illuminate\Support\Facades\Validator;


class PlanController extends Controller
{
    private $folder = "plan";
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

                $query = Plan::withCount([
                    'transaction as transaction_count' => function ($q) {
                        $q->where('status', 1);
                    }
                ]);

                if (!empty($input_search)) {
                    $query->where('name', 'LIKE', "%{$input_search}%");
                }

                $data = $query->latest()->get();

                $this->common->imageNameToUrl($data, 'image', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $delete = ' <form onsubmit="return confirm(\'' . __('label.delete_plan_msg') . '\');" method="POST"  action="' . route('admin.plan.destroy', [$row->id]) . '">
                    <input type="hidden" name="_token" value="' . csrf_token() . '">
                    <input type="hidden" name="_method" value="DELETE">
                    <button type="submit" class="edit-delete-btn" style="outline: none;" title="Delete"><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center" title="Edit">';
                        $btn .= '<a class="edit-delete-btn mr-4" title="Edit" href="' . route('admin.plan.edit', [$row->id]) . '">';
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
                                        data-on="' . __('label.enable') . '"
                                        data-off="' . __('label.disable') . '"></span>
                                    </div>';
                    })
                    ->addColumn('access_type', function ($row) {
                        return $this->common->get_access_type_names($row['access_type']);
                    })
                    ->addColumn('active_subscribers', function ($row) {
                        return $row->transaction_count ?? 0;
                    })
                    ->rawColumns(['action', 'status'])
                    ->make(true);
            }
            $params['setting'] = Setting_Data();

            return view('admin.plan.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function create()
    {
        try {
            $params['data'] = [];

            return view('admin.plan.add', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|min:2',
                'price' => 'required',
                'type' => 'required',
                'time' => 'required',
                'access_type' => 'required',
                'image' => 'required|image|mimes:jpeg,jpg,png,webp|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();
            $requestData['access_type'] = implode(',', $requestData['access_type']);

            if (isset($requestData['image'])) {

                $files = $requestData['image'];
                $requestData['image'] = $this->common->saveImage($files, $this->folder, "plan_");
            }

            $plan_data = Plan::updateOrCreate(['id' => $requestData['id']], $requestData);

            if (isset($plan_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('label.plan_save')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('label.plan_not_save')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function edit($id)
    {
        try {
            $params['data'] = Plan::where('id', $id)->first();

            $this->common->imageNameToUrl(array($params['data']), 'image', $this->folder);

            if ($params['data'] != null) {
                return view('admin.plan.edit', $params);
            } else {
                return redirect()->back()->with('error', __('label.page_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|min:2',
                'price' => 'required',
                'type' => 'required',
                'time' => 'required',
                'access_type' => 'required',
                'image' => 'image|mimes:jpeg,jpg,png,webp|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();
            $requestData['access_type'] = implode(',', $requestData['access_type']);

            if (isset($requestData['image'])) {
                $files = $requestData['image'];
                $requestData['image'] = $this->common->saveImage($files, $this->folder, "plan_");

                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_image']));
            }

            $requestData = Arr::except($requestData, ['old_image']);
            $plan_data = Plan::updateOrCreate(['id' => $requestData['id']], $requestData);

            if (isset($plan_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('label.plan_update')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('label.plan_not_update')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function destroy($id)
    {
        try {
            $data = Plan::where('id', $id)->first();
            if ($data) {
                $this->common->deleteImageToFolder($this->folder, $data['image']);
                $data->delete();
            }
            return redirect()->back()->with('success', __('label.plan_delete'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function change_status(Request $request)
    {
        try {
            $data = Plan::where('id', $request->id)->first();

            if (!$data) {
                return response()->json(['status' => 400, 'errors' => __('label.plan_not_found')]);
            }

            $data->status = $data->status ? 0 : 1;
            $data->save();

            return response()->json(['status' => 200, 'success' => __('label.status_changed'), 'status_code' => $data->status]);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
