<?php

namespace App\Http\Controllers\Author;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Common;
use Illuminate\Http\Request;
use Exception;

class CategoryController extends Controller
{
    private $folder = "category";
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

                $query = Category::where('status', 1);
                $input_search = $request['input_search'];
                if ($input_search != null) {
                    $query = Category::where('name', 'LIKE', "%{$input_search}%");
                }
                $data = $query->orderby('sort_order', 'asc')->latest()->get();

                $this->common->imageNameToUrl($data, 'image', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->rawColumns(['status'])
                    ->make(true);
            }
            return view('author.category.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
