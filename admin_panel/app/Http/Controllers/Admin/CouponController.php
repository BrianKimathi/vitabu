<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class CouponController extends Controller
{
    private $folder = "coupon";
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
                if (!empty($input_search)) {
                    $data = Coupon::where('name', 'LIKE', "%{$input_search}%")->latest()->get();
                } else {
                    $data = Coupon::latest()->get();
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {

                        $coupon_delete = __('label.delete_coupon');

                        $delete = '<form onsubmit="return confirm(\'' . $coupon_delete . '\');" method="POST" action="' . route('admin.coupon.destroy', [$row->id]) . '">
                        <input type="hidden" name="_token" value="' . csrf_token() . '">
                        <input type="hidden" name="_method" value="DELETE">
                        <button type="submit" class="edit-delete-btn" title=' . __('label.delete') . '><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center">';
                        $btn .= '<a class="edit-delete-btn edit_coupon mr-4" title=' . __('label.edit') . ' data-toggle="modal" href="#EditModel" 
                                data-id="' . $row->id . '" 
                                data-name="' . $row->name . '" 
                                data-start_date="' . $row->start_date . '" 
                                data-end_date="' . $row->end_date . '" 
                                data-amount_type="' . $row->amount_type . '" 
                                data-price="' . $row->price . '" 
                                data-use_limit="' . $row->use_limit . '"
                                data-is_use="' . $row->is_use . '" >';

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
                                    <label for="checkbox' . $row->id . '" ></label>
                                      <span class="toggle-text"
                                        data-on="' . __('label.active') . '"
                                        data-off="' . __('label.expire') . '"></span>
                                    </div>';
                    })
                    ->addColumn('start_date', function ($row) {
                        return date('d M Y', strtotime($row->start_date));
                    })
                    ->addColumn('end_date', function ($row) {
                        return date('d M Y', strtotime($row->end_date));
                    })
                    ->rawColumns(['action', 'status'])
                    ->make(true);
            }
            return view('admin.coupon.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function create()
    {
        try {
            $params['data'] = [];
            return view('admin.coupon.add', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|min:2',
                'amount_type' => 'required',
                'price' => 'required',
                'use_limit' => 'required',
                'is_use' => 'required',
                'start_date' => 'required|date',
                'end_date' => 'required|date',
                'image' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }
            $start_date = date('Y-m-d', strtotime($request->start_date));
            $end_date = date('Y-m-d', strtotime($request->end_date));
  
            if ($start_date < date('Y-m-d')) {
                return response()->json(['status' => 400, 'errors' => __('label.start_date_must_be_today_or_future')]);
            }

            if ($end_date <= $start_date) {
                return response()->json(['status' => 400, 'errors' => __('label.end_date_must_be_greator_than_start_date')]);
            }

            $amount_type = $request->amount_type;
            $price = $request->price;

            if ($amount_type == 1 && $price > 100) {
                return response()->json(['status' => 400, 'errors' => __('label.price_must_be_less_than_or_equal_to_100')]);
            }

            $requestData['id'] = $request->id;
            $requestData['coupon_code'] = $this->common->couponCode();
            $requestData['name'] = $request->name;
            $requestData['amount_type'] = $amount_type;
            $requestData['price'] = $price;
            $requestData['use_limit'] = $request->use_limit;
            $requestData['is_use'] = $request->is_use;
            $requestData['start_date'] = $start_date;
            $requestData['end_date'] = $end_date;

            $data = Coupon::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data['id'])) {
                return response()->json(['status' => 200, 'success' => __('label.success_add_coupon')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_add_coupon')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function edit($id)
    {
        try {

            $params['data'] = Coupon::where('id', $id)->first();
            if ($params['data'] != null) {
                $this->common->imageNameToUrl(array($params['data']), 'image', $this->folder);

                return view('admin.coupon.edit', $params);
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
                'name' => 'required|min:2',
                'amount_type' => 'required',
                'price' => 'required',
                'use_limit' => 'required',
                'is_use' => 'required',
                'start_date' => 'required|date',
                'end_date' => 'required|date',
                'image' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(['status' => 400, 'errors' => $errs]);
            }

            $amount_type = $request->amount_type;
            $price = $request->price;

            if ($amount_type == 1 && $price > 100) {
                return response()->json(['status' => 400, 'errors' => __('label.price_must_be_less_than_or_equal_to_100')]);
            }

            $requestData = $request->all();
            $start_date = date('Y-m-d', strtotime($request->start_date));
            $end_date = date('Y-m-d', strtotime($request->end_date));

            if ($end_date <= $start_date) {
                return response()->json(['status' => 400, 'errors' => __('label.end_date_must_be_greator_than_start_date')]);
            }

            $data = Coupon::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($data->id)) {
                return response()->json(['status' => 200, 'success' => __('label.success_edit_coupon')]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.error_edit_coupon')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            $data = Coupon::where('id', $id)->first();
            if (isset($data)) {
                $this->common->deleteImageToFolder($this->folder, $data['image']);
                $data->delete();
            }
            return redirect()->route('admin.coupon.index')->with('success', __('label.coupon_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function show($id)
    {
        try {

            $data = Coupon::where('id', $id)->first();
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
