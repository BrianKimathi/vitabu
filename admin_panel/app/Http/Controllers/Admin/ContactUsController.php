<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Contact_Us;
use Illuminate\Http\Request;
use Exception;

class ContactUsController extends Controller
{
    public function index(Request $request)
    {
        try {

            $params['data'] = [];
            if ($request->ajax()) {

                $input_search = $request['input_search'];
                if ($input_search != null && isset($input_search)) {
                    $data = Contact_Us::where(function ($q) use ($input_search) {
                        $q->where('name', 'LIKE', "%{$input_search}%")
                            ->orWhere('email', 'LIKE', "%{$input_search}%")
                            ->orWhereHas('user', function ($d) use ($input_search) {
                                $d->where('first_name', 'LIKE', "%{$input_search}%");
                            });
                    });
                } else {
                    $data = Contact_Us::get();
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $feedback_delete = __('label.feedback_delete');
                        return '<form onsubmit="return confirm(\'' . $feedback_delete . '\');" method="POST" action="' . route('admin.contact_us.destroy', [$row->id]) . '">
                            <input type="hidden" name="_token" value="' . csrf_token() . '">
                            <input type="hidden" name="_method" value="DELETE">
                            <button type="submit" class="edit-delete-btn" title=' . __('label.delete') . ' ><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';
                    })
                    ->addColumn('user_name', function ($row) {
                        return $row->user?->user_name ?? '-';
                    })
                    ->rawColumns(['action'])
                    ->make(true);
            }
            return view('admin.contact_us.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function destroy($id)
    {
        try {

            $data = Contact_Us::where('id', $id)->first();
            if (isset($data)) {
                $data->delete();
            }
            return redirect()->route('admin.contact_us.index')->with('success', __('label.contact_us_delete'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
