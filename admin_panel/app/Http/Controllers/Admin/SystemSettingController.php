<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AudioBook;
use App\Models\AudioBook_Episode;
use App\Models\Author_Payout;
use App\Models\Author_Request;
use App\Models\Bookmark;
use App\Models\Category;
use App\Models\Common;
use App\Models\Contact_Us;
use App\Models\Content_Section;
use App\Models\Content_Transaction;
use App\Models\Content_View;
use App\Models\Coupon;
use App\Models\History;
use App\Models\Language;
use App\Models\Login_History;
use App\Models\Magazine;
use App\Models\Notification;
use App\Models\Novel;
use App\Models\Novel_Chapter;
use App\Models\Onboarding_Screen;
use App\Models\Page;
use App\Models\Plan;
use App\Models\Read_Notification;
use App\Models\Review;
use App\Models\Social_Link;
use App\Models\Tax;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Withdrawal_Request;
use Illuminate\Support\Facades\DB;
use Exception;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\File;

class SystemSettingController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $params['data'] = [];
            return view('admin.system_setting.index', $params);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function ClearData()
    {
        try {

            // Folder Name
            $audio_books = 'public/audio_books';
            $category = 'public/category';
            $database = 'public/database';
            $language = 'public/language';
            $magazines = 'public/magazines';
            $notification = 'public/notification';
            $novels = 'public/novels';
            $setting = 'public/setting';
            $user = 'public/user';
            $plan = 'public/plan';

            // Name Array
            $audio_books_name = [];
            $category_name = [];
            $database_name = [];
            $language_name = [];
            $magazines_name = [];
            $notification_name = [];
            $novels_name = [];
            $setting_name = [];
            $user_name = [];
            $plan_name = [];

            // Get Files
            $audio_books_file = Storage::allFiles($audio_books);
            $category_file = Storage::allFiles($category);
            $database_file = Storage::allFiles($database);
            $language_file = Storage::allFiles($language);
            $magazines_file = Storage::allFiles($magazines);
            $notification_file = Storage::allFiles($notification);
            $novels_file = Storage::allFiles($novels);
            $setting_file = Storage::allFiles($setting);
            $user_file = Storage::allFiles($user);
            $plan_file = Storage::allFiles($plan);

            // Add Name In Array
            foreach ($audio_books_file as $file_name) {
                array_push($audio_books_name, pathinfo($file_name)['basename']);
            }
            foreach ($category_file as $file_name) {
                array_push($category_name, pathinfo($file_name)['basename']);
            }
            foreach ($database_file as $file_name) {
                array_push($database_name, pathinfo($file_name)['basename']);
            }
            foreach ($language_file as $file_name) {
                array_push($language_name, pathinfo($file_name)['basename']);
            }
            foreach ($magazines_file as $file_name) {
                array_push($magazines_name, pathinfo($file_name)['basename']);
            }
            foreach ($notification_file as $file_name) {
                array_push($notification_name, pathinfo($file_name)['basename']);
            }
            foreach ($novels_file as $file_name) {
                array_push($novels_name, pathinfo($file_name)['basename']);
            }
            foreach ($setting_file as $file_name) {
                array_push($setting_name, pathinfo($file_name)['basename']);
            }
            foreach ($user_file as $file_name) {
                array_push($user_name, pathinfo($file_name)['basename']);
            }
            foreach ($plan_file as $file_name) {
                array_push($plan_name, pathinfo($file_name)['basename']);
            }

            // Delete File In Folder
            foreach ($audio_books_name as $key => $value) {

                $file_check = AudioBook::select('id')->where('portrait_img', $value)->orwhere('landscape_img', $value)->orwhere('full_audio', $value)->first();
                $file_check1 = AudioBook_Episode::select('id')->where('image', $value)->orwhere('audio', $value)->first();
                if ($file_check == null && $file_check1) {
                    $this->common->deleteImageToFolder('audio_books', $value);
                }
            }
            foreach ($category_name as $key => $value) {

                $file_check = Category::select('id')->where('image', $value)->first();
                if ($file_check == null) {
                    $this->common->deleteImageToFolder('category', $value);
                }
            }
            foreach ($database_name as $key => $value) {
                $this->common->deleteImageToFolder('database', $value);
            }
            foreach ($language_name as $key => $value) {

                $file_check = Language::select('id')->where('image', $value)->first();
                if ($file_check == null) {
                    $this->common->deleteImageToFolder('language', $value);
                }
            }
            foreach ($magazines_name as $key => $value) {

                $file_check = Magazine::select('id')->where('portrait_img', $value)->orwhere('landscape_img', $value)->orwhere('full_magazine', $value)->first();
                if ($file_check == null) {
                    $this->common->deleteImageToFolder('magazines', $value);
                }
            }
            foreach ($notification_name as $key => $value) {

                $file_check = Notification::select('id')->where('image', $value)->first();
                if ($file_check == null) {
                    $this->common->deleteImageToFolder('notification', $value);
                }
            }
            foreach ($novels_name as $key => $value) {

                $file_check = Novel::select('id')->where('portrait_img', $value)->orwhere('landscape_img', $value)->orwhere('full_novel', $value)->first();
                $file_check1 = Novel_Chapter::select('id')->where('image', $value)->orwhere('chapter', $value)->first();
                if ($file_check == null && $file_check1) {
                    $this->common->deleteImageToFolder('novels', $value);
                }
            }
            foreach ($setting_name as $key => $value) {

                $file_check = Social_Link::select('id')->where('image', $value)->first();
                $file_check1 = Onboarding_Screen::select('id')->where('image', $value)->first();
                $file_check2 = Page::select('id')->where('icon', $value)->first();

                $settingData = Setting_Data();
                $file_check3 = 'yes';
                if ($settingData['app_logo'] != $value && $settingData['panel_login_page_bg_image'] != $value) {
                    $file_check3 = 'no';
                }

                if ($file_check == null && $file_check1 == null && $file_check2 == null && $file_check3 == 'no') {
                    $this->common->deleteImageToFolder('setting', $value);
                }
            }
            foreach ($user_name as $key => $value) {

                $file_check = User::select('id')->where('image', $value)->first();
                if ($file_check == null) {
                    $this->common->deleteImageToFolder('user', $value);
                }
            }
            foreach ($plan_name as $key => $value) {

                $file_check = Plan::select('id')->where('image', $value)->first();
                if ($file_check == null) {
                    $this->common->deleteImageToFolder('plan', $value);
                }
            }

            return response()->json(['status' => 200, 'success' => 'Data Clear Successfully.']);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function DownloadDB()
    {
        try {

            Artisan::call('config:clear');

            $storageAt = storage_path() . "/app/public/database";
            if (!file_exists($storageAt)) {
                File::makeDirectory($storageAt, 0755, true, true);
            }

            $mysqlHostName = env('DB_HOST');
            $mysqlUserName = env('DB_USERNAME');
            $mysqlPassword = env('DB_PASSWORD');
            $DbName = env('DB_DATABASE');

            // get all table name
            $result = DB::select("SHOW TABLES");
            $prep = "Tables_in_$DbName";

            foreach ($result as $res) {
                $tables[] =  $res->$prep;
            }

            $connect = new \PDO("mysql:host=$mysqlHostName;dbname=$DbName;charset=utf8", "$mysqlUserName", "$mysqlPassword", [\PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES 'utf8'"]);
            $statement = $connect->prepare("SHOW TABLES");
            $statement->execute();
            $result = $statement->fetchAll();

            $output = '';
            foreach ($tables as $table) {

                $show_table_query = "SHOW CREATE TABLE " . $table . "";
                $statement = $connect->prepare($show_table_query);
                $statement->execute();
                $show_table_result = $statement->fetchAll();

                foreach ($show_table_result as $show_table_row) {
                    $output .= "\n\n" . $show_table_row["Create Table"] . ";\n\n";
                }
                $select_query = "SELECT * FROM " . $table . "";
                $statement = $connect->prepare($select_query);
                $statement->execute();
                $total_row = $statement->rowCount();

                for ($count = 0; $count < $total_row; $count++) {
                    $single_result = $statement->fetch(\PDO::FETCH_ASSOC);
                    $table_column_array = array_keys($single_result);
                    $table_value_array = array_values($single_result);
                    $output .= "\nINSERT INTO $table (";
                    $output .= "`" . implode("`, `", $table_column_array) . "`) VALUES (";
                    $output .= "'" . implode("', '", $table_value_array) . "');\n";
                }
            }

            $file_name = App_Name() . '_db_' . date('d_m_Y') . '.sql';
            $file_handle = fopen(storage_path() . '/app/public/database/' . $file_name, 'w+');
            fwrite($file_handle, $output);
            fclose($file_handle);
            header('Content-Description: File Transfer');
            header('Content-Type: application/octet-stream');
            header('Content-Disposition: attachment; filename=' . basename($file_name));
            header('Content-Transfer-Encoding: binary');
            header('Expires: 0');
            header('Cache-Control: must-revalidate');
            header('Pragma: public');
            header('Content-Length: ' . filesize(storage_path() . '/app/public/database/' . $file_name));
            ob_clean();
            flush();
            readfile(storage_path() . '/app/public/database/' . $file_name);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function CleanDatabase()
    {
        try {

            AudioBook::query()->truncate();
            AudioBook_Episode::query()->truncate();
            Author_Payout::query()->truncate();
            Author_Request::query()->truncate();
            Bookmark::query()->truncate();
            Category::query()->truncate();
            Contact_Us::query()->truncate();
            Content_Section::query()->truncate();
            Content_Transaction::query()->truncate();
            Content_View::query()->truncate();
            Coupon::query()->truncate();
            History::query()->truncate();
            Language::query()->truncate();
            Login_History::query()->truncate();
            Magazine::query()->truncate();
            Notification::query()->truncate();
            Novel::query()->truncate();
            Novel_Chapter::query()->truncate();
            Onboarding_Screen::query()->truncate();
            Page::query()->truncate();
            Read_Notification::query()->truncate();
            Review::query()->truncate();
            Social_Link::query()->truncate();
            Tax::query()->truncate();
            Transaction::query()->truncate();
            User::query()->truncate();
            Withdrawal_Request::query()->truncate();

            return response()->json(['status' => 200, 'success' => 'Data Clean Successfully.']);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
