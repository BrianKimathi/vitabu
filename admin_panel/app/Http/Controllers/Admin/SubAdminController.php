<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Common;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Exception;

class SubAdminController extends Controller
{
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
                // Return all sub-admins except the current logged-in user
                $data = Admin::where('id', '!=', auth()->guard('admin')->id())->orderBy('id', 'desc')->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('role', function ($row) {
                        return ucfirst($row->role ?? 'admin');
                    })
                    ->addColumn('action', function ($row) {
                        $deleteLabel = __('label.delete');
                        $confirmMsg = "Are you sure you want to delete this sub-admin?";
                        
                        $delete = '<form onsubmit="return confirm(\'' . $confirmMsg . '\');" method="POST" action="' . route('admin.subadmin.destroy', [$row->id]) . '">
                        <input type="hidden" name="_token" value="' . csrf_token() . '">
                        <input type="hidden" name="_method" value="DELETE">
                        <button type="submit" class="edit-delete-btn" title=' . $deleteLabel . '><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-center">';
                        $btn .= '<a href="' . route('admin.subadmin.edit', [$row->id]) . '" class="edit-delete-btn mr-4" title=' . __('label.edit') . '>';
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
                    ->rawColumns(['action', 'status'])
                    ->make(true);
            }
            return view('admin.sub_admin.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function create()
    {
        try {
            return view('admin.sub_admin.add');
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_name' => 'required|min:2|unique:tbl_admin,user_name',
                'email' => 'required|email|unique:tbl_admin,email',
                'password' => 'required|min:4',
                'role' => 'required|in:admin,editor,accounts',
            ]);
            if ($validator->fails()) {
                return response()->json(['status' => 400, 'errors' => $validator->errors()->all()]);
            }

            $admin = new Admin();
            $admin->user_name = $request->user_name;
            $admin->email = $request->email;
            $admin->password = Hash::make($request->password);
            $admin->role = $request->role;
            $admin->status = 1;
            
            if ($admin->save()) {
                return response()->json(['status' => 200, 'success' => "Sub-Admin added successfully!"]);
            } else {
                return response()->json(['status' => 400, 'errors' => "Failed to add Sub-Admin."]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function edit($id)
    {
        try {
            $data = Admin::find($id);
            if ($data) {
                return view('admin.sub_admin.edit', compact('data'));
            } else {
                return redirect()->back()->with('error', __('label.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_name' => 'required|min:2|unique:tbl_admin,user_name,' . $id,
                'email' => 'required|email|unique:tbl_admin,email,' . $id,
                'role' => 'required|in:admin,editor,accounts',
            ]);
            if ($validator->fails()) {
                return response()->json(['status' => 400, 'errors' => $validator->errors()->all()]);
            }

            $admin = Admin::find($id);
            if ($admin) {
                $admin->user_name = $request->user_name;
                $admin->email = $request->email;
                $admin->role = $request->role;
                if ($request->filled('password')) {
                    $admin->password = Hash::make($request->password);
                }
                $admin->save();
                return response()->json(['status' => 200, 'success' => "Sub-Admin updated successfully!"]);
            } else {
                return response()->json(['status' => 400, 'errors' => "Sub-Admin not found."]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function destroy($id)
    {
        try {
            $admin = Admin::find($id);
            if ($admin) {
                $admin->delete();
                return redirect()->route('admin.subadmin.index')->with('success', "Sub-Admin deleted successfully!");
            }
            return redirect()->route('admin.subadmin.index')->with('error', "Sub-Admin not found.");
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function show($id)
    {
        try {
            $admin = Admin::find($id);
            if ($admin) {
                $admin->status = $admin->status === 1 ? 0 : 1;
                $admin->save();
                return response()->json(['status' => 200, 'success' => __('label.status_changed'), 'status_code' => $admin->status]);
            } else {
                return response()->json(['status' => 400, 'errors' => __('label.data_not_found')]);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
