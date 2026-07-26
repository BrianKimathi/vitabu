<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Mail;
use Exception;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class Common extends Model
{
    private $folder_audiobook = "audio_books";
    private $folder_novels = "novels";
    private $folder_magazines = "magazines";
    private $folder_plan = "plan";

    private function resolveStorageAssetUrl($folder, $name)
    {
        if ($folder == "" || $name == "") {
            return "";
        }
        if (!Storage::disk('public')->exists($folder . '/' . $name)) {
            return "";
        }

        $baseStorageUrl = rtrim((string) Config::get('app.image_url'), '/');
        $directPublicUrl = $baseStorageUrl . '/' . $folder . '/' . $name;

        // Shared-hosting fallback: serve from Laravel route (no symlink needed).
        $appUrl = (string) Config::get('app.url');
        if ($appUrl === '' || $appUrl === 'null') {
            // Derive from APP_URL/storage/... if `app.url` isn't set.
            $appUrl = rtrim($baseStorageUrl, '/');
            $appUrl = preg_replace('~\/storage$~', '', $appUrl);
        }
        $appUrl = rtrim($appUrl, '/');

        // Always use the API route for consistency across hosting environments.
        // Direct `/storage/...` may return 404 on some shared hosts even when the file exists.
        if ($appUrl !== '') {
            return $appUrl . '/api/storage-file/' . rawurlencode($folder) . '/' . rawurlencode($name);
        }

        // Last resort: return direct URL.
        return $directPublicUrl;
    }

    // Image Functions
    public function saveImage($org_name, $folder, $prefix = "")
    {
        try {
            $img_ext = $org_name->getClientOriginalExtension();
            $filename = $prefix . date('d_m_Y_') . rand(1111, 9999) . '.' . $img_ext;
            $org_name->move(base_path('storage/app/public/' . $folder), $filename);

            return $filename;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function imageNameToUrl($array, $column, $folder)
    {
        try {

            $appName = Config::get('app.image_url');

            foreach ($array as $key => $value) {

                if (isset($value[$column]) && $value[$column] != "") {

                    if ($folder == "user") {
                        $resolved = $this->resolveStorageAssetUrl($folder, $value[$column]);
                        $value[$column] = $resolved != ""
                            ? $resolved
                            : asset('assets/imgs/default.png');
                    } else {
                        $resolved = $this->resolveStorageAssetUrl($folder, $value[$column]);
                        $value[$column] = $resolved != ""
                            ? $resolved
                            : asset('assets/imgs/no_img.png');
                    }
                } else {

                    if ($folder == "user") {
                        $value[$column] = asset('assets/imgs/default.png');
                    } else {
                        $value[$column] = asset('assets/imgs/no_img.png');
                    }
                }
            }

            return $array;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function deleteImageToFolder($folder, $name)
    {
        try {

            Storage::disk('public')->delete($folder . '/' . $name);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function fileNameToUrl($array, $column, $folder)
    {
        try {

            $appName = Config::get('app.image_url');

            foreach ($array as $key => $value) {

                if (isset($value[$column]) && $value[$column] != "") {

                    if (Storage::disk('public')->exists($folder . '/' . $value[$column])) {
                        $value[$column] = $appName . $folder . '/' . $value[$column];
                    } else {
                        $value[$column] = "";
                    }
                } else {
                    $value[$column] = "";
                }
            }
            return $array;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function getImage($folder = "", $name = "")
    {
        try {
            if ($folder != "" && $name != "") {
                $resolved = $this->resolveStorageAssetUrl($folder, $name);
                if ($resolved != "") {
                    $name = $resolved;
                } else {

                    if ($folder == "user") {
                        $name = asset('assets/imgs/default.png');
                    } else {
                        $name = asset('assets/imgs/no_img.png');
                    }
                }
            } else {
                if ($folder == "user") {
                    $name = asset('assets/imgs/default.png');
                } else {
                    $name = asset('assets/imgs/no_img.png');
                }
            }
            return $name;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function getFile($folder = "", $name = "")
    {
        try {
            if ($folder != "" && $name != "") {
                $relativePath = $folder . '/' . $name;
                $existsOnDisk = Storage::disk('public')->exists($relativePath);
                $name = $this->resolveStorageAssetUrl($folder, $name);

                // Trace file URL resolution for shared hosting issues (404 despite DB value).
                if ($folder === 'novels') {
                    $publicStoragePath = public_path('storage/' . $relativePath);
                    $storagePath = storage_path('app/public/' . $relativePath);
                    $storageLink = public_path('storage');
                    Log::info('file.getFile.trace', [
                        'folder' => $folder,
                        'relative_path' => $relativePath,
                        'app_image_url' => Config::get('app.image_url'),
                        'disk_public_exists' => $existsOnDisk,
                        'storage_path' => $storagePath,
                        'storage_path_exists' => file_exists($storagePath),
                        'public_storage_path' => $publicStoragePath,
                        'public_storage_path_exists' => file_exists($publicStoragePath),
                        'storage_link_path' => $storageLink,
                        'storage_link_is_link' => is_link($storageLink),
                        'storage_link_target' => is_link($storageLink) ? readlink($storageLink) : null,
                        'serving_mode' => file_exists($publicStoragePath) ? 'direct_storage_url' : 'api_storage_file_fallback',
                        'resolved_url' => $name,
                    ]);
                }
            } else {
                $name = "";
            }
            return $name;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // API's Functions
    public function API_Response($status_code, $message, $array = [], $pagination = '')
    {
        try {
            $data['status'] = $status_code;
            $data['message'] = $message;

            if ($status_code == 200) {
                $data['result'] = $array;
            }

            if ($pagination) {
                $data['total_rows'] = $pagination['total_rows'];
                $data['total_page'] = $pagination['total_page'];
                $data['current_page'] = $pagination['current_page'];
                $data['more_page'] = $pagination['more_page'];
            }
            return $data;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function more_page($current_page, $page_size)
    {
        try {
            $more_page = false;
            if ($current_page < $page_size) {
                $more_page = true;
            }
            return $more_page;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function pagination_array($total_rows, $page_size, $current_page, $more_page)
    {
        try {
            $array['total_rows'] = $total_rows;
            $array['total_page'] = $page_size;
            $array['current_page'] = (int) $current_page;
            $array['more_page'] = $more_page;

            return $array;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function userName($string)
    {
        $cleanString = preg_replace('/\s+/', '', trim($string));
        if (empty($cleanString)) {
            $cleanString = 'user';
        }

        // If string is mobile number (or numeric), strip any leading '+' or '254' prefix for a clean handle
        if (is_numeric(preg_replace('/\D+/', '', $cleanString))) {
            $digits = preg_replace('/\D+/', '', $cleanString);
            if (str_starts_with($digits, '254') && strlen($digits) > 9) {
                $digits = '0' . substr($digits, 3);
            }
            $user_name = '@' . $digits;
        } else {
            $user_name = '@' . $cleanString;
        }

        $check = User::where('user_name', $user_name)->first();
        if (isset($check) && $check != null) {
            $user_name = $user_name . rand(10, 99);
        }
        return $user_name;
    }
    public function user_tag_line()
    {
        return "Hey, I am using the " . App_Name() . " App.";
    }
    public function section_query($user_id, $content_type, $author_id, $category_id, $language_id, $access_type, $no_of_content, $order_by_upload, $order_by_view)
    {
        try {
            $traceId = uniqid('section_query_', true);
            Log::info('api.section_query.start', [
                'trace_id' => $traceId,
                'user_id' => $user_id,
                'content_type' => $content_type,
                'author_id' => $author_id,
                'category_id' => $category_id,
                'language_id' => $language_id,
                'access_type' => $access_type,
                'no_of_content' => $no_of_content,
                'order_by_upload' => $order_by_upload,
                'order_by_view' => $order_by_view,
            ]);
            // Audio Books
            if ($content_type == 1) {

                $content = AudioBook::where('status', 1);
                if ($author_id != 0) {
                    $content->where('author_id', $author_id);
                }
                if ($category_id != 0) {
                    $content->where('category_id', $category_id);
                }
                if ($language_id != 0) {
                    $content->where('language_id', $language_id);
                }
                // In section settings, access_type values: 0=Free, 1=Paid, 2=Subscription, 3=All
                if ((string)$access_type === '0') {
                    $content->where('access_type', 0);
                } else if ((string)$access_type === '1') {
                    $content->where('access_type', 1);
                } else if ((string)$access_type === '2') {
                    $content->where('access_type', 2);
                }
                if ($order_by_view == 1) {
                    $content->orderBy('total_played', 'asc');
                } else {
                    $content->orderBy('total_played', 'desc');
                }
                if ($order_by_upload == 1) {
                    $content->orderBy('id', 'asc');
                } else {
                    $content->orderBy('id', 'desc');
                }
                $query = $content->take($no_of_content)->get();
                Log::info('api.section_query.raw_result', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'raw_count' => count($query),
                    'raw_ids' => $query->pluck('id')->values()->all(),
                ]);

                for ($j = 0; $j < count($query); $j++) {

                    $query[$j]['portrait_img'] = $this->getImage($this->folder_audiobook, $query[$j]['portrait_img']);
                    $query[$j]['landscape_img'] = $this->getImage($this->folder_audiobook, $query[$j]['landscape_img']);
                    $query[$j]['full_audio'] = $this->getFile($this->folder_audiobook, $query[$j]['full_audio']);
                    $query[$j]['author_name'] = $this->GetAuthorNameById($query[$j]['author_id']);
                    $query[$j]['category_name'] = $this->GetCategoryNameById($query[$j]['category_id']);
                    $query[$j]['language_name'] = $this->GetLanguageNameById($query[$j]['language_id']);
                    $query[$j]['total_episodes'] = $this->getTotalEpisodes($query[$j]['id']);
                    $query[$j]['total_reviews'] = $this->getTotalReviews(1, $query[$j]['id']);
                    $query[$j]['avg_reviews'] = $this->getAvgReviews(1, $query[$j]['id']);
                    $query[$j]['is_bookmark'] = $this->isBookmarkContent($user_id, 1, $query[$j]['id']);
                    $query[$j]['is_buy'] = $this->isContentBuy($user_id, 1, $query[$j]['id'], 0);
                }
                Log::info('api.section_query.end', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'final_count' => count($query),
                    'final_ids' => collect($query)->pluck('id')->values()->all(),
                ]);
                return $query;
            }
            // Novels
            if ($content_type == 2) {

                $content = Novel::where('status', 1);
                if ($author_id != 0) {
                    $content->where('author_id', $author_id);
                }
                if ($category_id != 0) {
                    $content->where('category_id', $category_id);
                }
                if ($language_id != 0) {
                    $content->where('language_id', $language_id);
                }
                // In section settings, access_type values: 0=Free, 1=Paid, 2=Subscription, 3=All
                if ((string)$access_type === '0') {
                    $content->where('access_type', 0);
                } else if ((string)$access_type === '1') {
                    $content->where('access_type', 1);
                } else if ((string)$access_type === '2') {
                    $content->where('access_type', 2);
                }
                if ($order_by_view == 1) {
                    $content->orderBy('total_read', 'asc');
                } else {
                    $content->orderBy('total_read', 'desc');
                }
                if ($order_by_upload == 1) {
                    $content->orderBy('id', 'asc');
                } else {
                    $content->orderBy('id', 'desc');
                }
                $query = $content->take($no_of_content)->get();
                Log::info('api.section_query.raw_result', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'raw_count' => count($query),
                    'raw_ids' => $query->pluck('id')->values()->all(),
                ]);

                for ($j = 0; $j < count($query); $j++) {

                    $query[$j]['portrait_img'] = $this->getImage($this->folder_novels, $query[$j]['portrait_img']);
                    $query[$j]['landscape_img'] = $this->getImage($this->folder_novels, $query[$j]['landscape_img']);
                    $query[$j]['full_novel'] = $this->getFile($this->folder_novels, $query[$j]['full_novel']);
                    $query[$j]['author_name'] = $this->GetAuthorNameById($query[$j]['author_id']);
                    $query[$j]['category_name'] = $this->GetCategoryNameById($query[$j]['category_id']);
                    $query[$j]['language_name'] = $this->GetLanguageNameById($query[$j]['language_id']);
                    $query[$j]['total_chapters'] = $this->getTotalchapters($query[$j]['id']);
                    $query[$j]['total_reviews'] = $this->getTotalReviews(2, $query[$j]['id']);
                    $query[$j]['avg_reviews'] = $this->getAvgReviews(2, $query[$j]['id']);
                    $query[$j]['is_bookmark'] = $this->isBookmarkContent($user_id, 2, $query[$j]['id']);
                    $query[$j]['is_buy'] = $this->isContentBuy($user_id, 2, $query[$j]['id'], 0);
                }
                Log::info('api.section_query.end', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'final_count' => count($query),
                    'final_ids' => collect($query)->pluck('id')->values()->all(),
                ]);
                return $query;
            }
            // Magazines
            if ($content_type == 3) {

                $content = Magazine::where('status', 1);
                if ($author_id != 0) {
                    $content->where('author_id', $author_id);
                }
                if ($category_id != 0) {
                    $content->where('category_id', $category_id);
                }
                if ($language_id != 0) {
                    $content->where('language_id', $language_id);
                }
                // In section settings, access_type values: 0=Free, 1=Paid, 2=Subscription, 3=All
                if ((string)$access_type === '0') {
                    $content->where('access_type', 0);
                } else if ((string)$access_type === '1') {
                    $content->where('access_type', 1);
                } else if ((string)$access_type === '2') {
                    $content->where('access_type', 2);
                }
                if ($order_by_view == 1) {
                    $content->orderBy('total_read', 'asc');
                } else {
                    $content->orderBy('total_read', 'desc');
                }
                if ($order_by_upload == 1) {
                    $content->orderBy('id', 'asc');
                } else {
                    $content->orderBy('id', 'desc');
                }
                $query = $content->take($no_of_content)->get();
                Log::info('api.section_query.raw_result', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'raw_count' => count($query),
                    'raw_ids' => $query->pluck('id')->values()->all(),
                ]);

                for ($j = 0; $j < count($query); $j++) {

                    $query[$j]['portrait_img'] = $this->getImage($this->folder_magazines, $query[$j]['portrait_img']);
                    $query[$j]['landscape_img'] = $this->getImage($this->folder_magazines, $query[$j]['landscape_img']);
                    $query[$j]['full_magazine'] = $this->getFile($this->folder_magazines, $query[$j]['full_magazine']);
                    $query[$j]['author_name'] = $this->GetAuthorNameById($query[$j]['author_id']);
                    $query[$j]['category_name'] = $this->GetCategoryNameById($query[$j]['category_id']);
                    $query[$j]['language_name'] = $this->GetLanguageNameById($query[$j]['language_id']);
                    $query[$j]['total_reviews'] = $this->getTotalReviews(3, $query[$j]['id']);
                    $query[$j]['avg_reviews'] = $this->getAvgReviews(3, $query[$j]['id']);
                    $query[$j]['is_bookmark'] = $this->isBookmarkContent($user_id, 3, $query[$j]['id']);
                    $query[$j]['is_buy'] = $this->isContentBuy($user_id, 3, $query[$j]['id'], 0);
                }
                Log::info('api.section_query.end', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'final_count' => count($query),
                    'final_ids' => collect($query)->pluck('id')->values()->all(),
                ]);
                return $query;
            }
        } catch (Exception $e) {
            Log::error('api.section_query.exception', [
                'content_type' => $content_type,
                'author_id' => $author_id,
                'category_id' => $category_id,
                'language_id' => $language_id,
                'access_type' => $access_type,
                'error' => $e->getMessage(),
            ]);
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function section_details_query($user_id = 0, $content_type, $author_id, $category_id, $language_id, $access_type, $no_of_content, $order_by_upload, $order_by_view)
    {
        try {
            $traceId = uniqid('section_details_', true);
            Log::info('api.section_details_query.start', [
                'trace_id' => $traceId,
                'user_id' => $user_id,
                'content_type' => $content_type,
                'author_id' => $author_id,
                'category_id' => $category_id,
                'language_id' => $language_id,
                'access_type' => $access_type,
                'no_of_content' => $no_of_content,
                'order_by_upload' => $order_by_upload,
                'order_by_view' => $order_by_view,
            ]);
            // Audio Books
            if ($content_type == 1) {

                $content = AudioBook::where('status', 1);
                if ($order_by_view == 1) {
                    $content->orderBy('total_played', 'asc');
                } else {
                    $content->orderBy('total_played', 'desc');
                }
            }
            // Novels
            if ($content_type == 2) {

                $content = Novel::where('status', 1);
                if ($order_by_view == 1) {
                    $content->orderBy('total_read', 'asc');
                } else {
                    $content->orderBy('total_read', 'desc');
                }
            }
            // Magazines
            if ($content_type == 3) {

                $content = Magazine::where('status', 1);
                if ($order_by_view == 1) {
                    $content->orderBy('total_read', 'asc');
                } else {
                    $content->orderBy('total_read', 'desc');
                }
            }

            if ($author_id != 0) {
                $content->where('author_id', $author_id);
            }
            if ($category_id != 0) {
                $content->where('category_id', $category_id);
            }
            if ($language_id != 0) {
                $content->where('language_id', $language_id);
            }
            // In section settings, access_type values: 0=Free, 1=Paid, 2=Subscription, 3=All
            if ((string)$access_type === '0') {
                $content->where('access_type', 0);
            } else if ((string)$access_type === '1') {
                $content->where('access_type', 1);
            } else if ((string)$access_type === '2') {
                $content->where('access_type', 2);
            }
            if ($order_by_upload == 1) {
                $content->orderBy('id', 'asc');
            } else {
                $content->orderBy('id', 'desc');
            }
            $debugQuery = (clone $content)->take($no_of_content)->get();
            Log::info('api.section_details_query.preview', [
                'trace_id' => $traceId,
                'content_type' => $content_type,
                'preview_count' => count($debugQuery),
                'preview_ids' => $debugQuery->pluck('id')->values()->all(),
            ]);

            $query = $content->take($no_of_content);
            return $query;
        } catch (Exception $e) {
            Log::error('api.section_details_query.exception', [
                'content_type' => $content_type,
                'author_id' => $author_id,
                'category_id' => $category_id,
                'language_id' => $language_id,
                'access_type' => $access_type,
                'error' => $e->getMessage(),
            ]);
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function BasicNotiConfiguration($type)
    {
        if ($type != null) {
            return Notification_Configuration::where('type', $type)->first();
        }
        return [];
    }
    public function SetSmtpConfig()
    {
        $smtp = Smtp::latest()->first();
        if (isset($smtp) && $smtp != null && $smtp['status'] == 1) {

            if ($smtp) {
                $data = [
                    'driver' => 'smtp',
                    'host' => $smtp->host,
                    'port' => $smtp->port,
                    'encryption' => 'tls',
                    'username' => $smtp->user,
                    'password' => $smtp->pass,
                    'from' => [
                        'address' => $smtp->from_email,
                        'name' => $smtp->from_name
                    ]
                ];
                Config::set('mail', $data);
            }
        }
        return true;
    }
    public function Send_Mail($type, $email, $request_status = 0, $content_title = "", $price = 0, $first_name = "", $last_name = "", $transaction_id = "", $date = "", $content_type = 0, $password = "", $payout_period = "", $subscription_earnings = 0, $content_earnings = 0)
    {
        try {

            $this->SetSmtpConfig();

            $smtp = Smtp::latest()->first();
            if (isset($smtp) && $smtp['status'] == 1) {

                if ($type == 1) {

                    $details = [
                        'title' => App_Name() . " - Registration",
                        'view' => 'mail.register',
                    ];
                } else if ($type == 2) {
                    $details = [
                        'title' => App_Name() . " - Login",
                        'view' => 'mail.login',
                    ];
                } else if ($type == 3) {

                    $details = [
                        'title' => App_Name() . " - Become Auther Request",
                        'view' => 'mail.become_author_request',
                    ];
                } else if ($type == 4) {

                    if ($request_status == 0) {
                        $details = [
                            'title' => App_Name() . " - Author Request Status",
                            'view' => 'mail.author_request_no',
                        ];
                    } else {
                        $details = [
                            'title' => App_Name() . " - Author Request Status",
                            'view' => 'mail.author_request_yes',
                        ];
                    }
                } else if ($type == 5) {

                    $details = [
                        'title' => App_Name() . " - Purchase Content",
                        'user_name' => $first_name . ' ' . $last_name,
                        'content_title' => $content_title,
                        'price' => $price,
                        'transaction_id' => $transaction_id,
                        'date' => $date,
                        'view' => 'mail.purchase',
                    ];
                } else if ($type == 6) {

                    $details = [
                        'title' => 'Withdrawal Request Submitted!',
                        'username' => $first_name . ' ' . $last_name,
                        'view' => 'mail.withdrawal_request',
                    ];
                } else if ($type == 7) {

                    $status = $request_status == 1 ? 'Approved' : 'Rejected';
                    $details = [
                        'title' => 'Withdrawal Request ' . ucfirst($status),
                        'username' => $first_name . ' ' . $last_name,
                        'status' => $status,
                        'view' => 'mail.withdrawal_status_update',
                    ];
                } else if ($type == 8) {
                    if ($content_type == 1) {
                        $book_type = "Audio Book";
                    } elseif ($content_type == 2) {
                        $book_type = "Novel";
                    } elseif ($content_type == 3) {
                        $book_type = "Magazine";
                    } else {
                        $book_type = "Book";
                    }
                    if ($request_status == 0) {
                        $details = [
                            'title' => App_Name() . " - " . $book_type . " Request Status",
                            'book_name' => $content_title,
                            'book_type' => $book_type,
                            'view' => 'mail.book_request_no',
                        ];
                    } else {
                        $details = [
                            'title' => App_Name() . " - " . $book_type . " Request Status",
                            'book_name' => $content_title,
                            'book_type' => $book_type,
                            'view' => 'mail.book_request_yes',
                        ];
                    }
                } else if ($type == 9) {

                    $details = [
                        'title' => App_Name() . " - Forgot Password",
                        'email' => $email,
                        'password' => $password,
                        'view' => 'mail.forgot_password',
                    ];
                } else if ($type == 10) {

                    $details = [
                        'title' => App_Name() . " - Test Smtp",
                        'view' => 'mail.test',
                    ];
                } else if ($type == 11) {

                    $details = [
                        'title' => App_Name() . " - Purchase Plan",
                        'user_name' => $first_name . ' ' . $last_name,
                        'price' => $price,
                        'transaction_id' => $transaction_id,
                        'date' => $date,
                        'view' => 'mail.buy_plan',
                    ];
                } else if ($type == 12) {

                    $details = [
                        'title' => App_Name() . " - Subscription Payout",
                        'plan_name' => $content_title,
                        'user_name' => $first_name . ' ' . $last_name,
                        'payout' => $price,
                        'subscription_earnings' => $subscription_earnings,
                        'content_earnings' => $content_earnings,
                        'payout_period' => $payout_period,
                        'payout_date' => $date,
                        'view' => 'mail.subscription_payout',
                    ];
                } else if ($type == 13) {

                    $details = [
                        'title' => App_Name() . " - OTP Verification",
                        'otp' => $password,  // reuse $password param for OTP code
                        'view' => 'mail.otp_verification',
                    ];
                } else {
                    return true;
                }

                Mail::to($email)->send(new \App\Mail\mail($details));
            } else {
                return true;
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function SaveNotification($send_type, $noti_type, $user_id, $auther_id, $content_type, $content_id, $sub_content_id, $imageURL, $device_token, $device_type, $request_status = 0, $content_title = "")
    {
        try {

            $title = "";
            $message = "";

            if ($content_type == 1) {
                $book_type = __('label.audiobook');
            } elseif ($content_type == 2) {
                $book_type = __('label.novel');
            } else {
                $book_type = __('label.magazine');
            }

            if ($noti_type == 2) {
                $title = "Your Author Request Has Been Submitted!";
                $message = "Thank you for submitting your request to become an author on our platform. We are reviewing your application and will get back to you soon. Stay tuned!";
            }
            if ($noti_type == 3 && $request_status == 1) {
                $title = "Your Author Request Has Been Approved!";
                $message = "Congratulations! Your request to become an author has been approved.";
            }
            if ($noti_type == 3 && $request_status == 0) {
                $title = "Your Author Request Has Been Rejected!";
                $message = "We regret to inform you that your request to become an author on our platform has been rejected.";
            }
            if ($noti_type == 4) {
                $title = "New Release: {$content_title}";
                $message = "Tap to Read/Play now!";
            }
            if ($noti_type == 5) {
                $title = "Withdrawal Request Sent!";
                $message = "Your withdrawal request has been submitted. You'll be notified once it's processed.";
            }
            if ($noti_type == 6) {
                $title = "Withdrawal Status Updated";
                $message = "Your withdrawal request status has been updated. Please check your dashboard for details.";
            }
            if ($noti_type == 7) {
                $title = "Withdrawal Status Updated";
                $message = "Your withdrawal request status has been updated. Please check your dashboard for details.";
            }
            if ($noti_type == 8 && $request_status == 1) {
                $title = "Your " . $content_title . $book_type  . " Has Been Approved!";
                $message = "Congratulations! Your request to add " . $content_title . $book_type  . " has been approved.";
            }
            if ($noti_type == 8 && $request_status == 0) {
                $title = "Your" . $content_title . $book_type . " Has Been Rejected!";
                $message = "We regret to inform you that your request to add " . $content_title . $book_type . " on our platform has been rejected.";
            }

            $data['type'] = $noti_type;
            $data['user_id'] = $user_id;
            $data['auther_id'] = $auther_id;
            $data['content_type'] = $content_type;
            $data['content_id'] = $content_id;
            $data['sub_content_id'] = $sub_content_id;
            $data['title'] = $title;
            $data['message'] = $message;
            $data['image'] = "";
            $data['status'] = 1;
            Notification::insert($data);

            if ($send_type == 1) {
                $this->send_user_push_notification($device_type, $device_token, $title, $message);
                return true;
            } else if ($send_type == 0) {

                $noti_array = array(
                    'title' => $title,
                    'image' => $imageURL,
                    'description' => $message,
                );
                $this->send_notification($noti_array);
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function send_user_push_notification($device_type, $device_token, $title, $message)
    {
        try {
            $setting = Setting_Data();
            $ONESIGNAL_APP_ID = $setting['onesignal_apid'];
            $ONESIGNAL_REST_KEY = $setting['onesignal_rest_key'];
            $fields = [
                'app_id' => $ONESIGNAL_APP_ID,
                'headings' => ['en' => $title],
                'contents' => ['en' => $message],
                'channel_for_external_user_ids' => 'push',
                'include_player_ids' => [$device_token],
            ];

            // Send the push notification via OneSignal API
            $response = Http::withHeaders([
                'Content-Type' => 'application/json; charset=utf-8',
                'Authorization' => 'Basic ' . $ONESIGNAL_REST_KEY,
            ])->post('https://onesignal.com/api/v1/notifications', $fields);

            if ($response->successful()) {
                return true;
            }
            return false;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function send_notification($array)
    {
        try {
            $settingData = Setting_Data();
            $ONESIGNAL_APP_ID = $settingData['onesignal_apid'];
            $ONESIGNAL_REST_KEY = $settingData['onesignal_rest_key'];

            $fields = array(
                'app_id' => $ONESIGNAL_APP_ID,
                'included_segments' => array('All'),
                'data' => $array,
                'headings' => array("en" => $array['title']),
                'contents' => array("en" => $array['description']),
                'big_picture' => $array['image'],
            );

            $fields = json_encode($fields);

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
            curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                'Content-Type: application/json; charset=utf-8',
                'Authorization: Basic ' . $ONESIGNAL_REST_KEY,
            ));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            curl_close($ch);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function GetCategoryNameById($id)
    {
        $data = Category::select('id', 'name')->where('id', $id)->first();
        if ($data) {
            return $data['name'];
        } else {
            return "";
        }
    }
    public function GetLanguageNameById($id)
    {
        $data = Language::select('id', 'name')->where('id', $id)->first();
        if ($data) {
            return $data['name'];
        } else {
            return "";
        }
    }
    public function GetAuthorNameById($id)
    {
        $data = User::select('id', 'first_name', 'last_name')->where('is_author', 1)->where('id', $id)->first();
        if ($data) {
            return $data['first_name'] . ' ' . $data['last_name'];
        } else {
            return "";
        }
    }
    public function getTotalReviews($content_type, $content_id)
    {
        return Review::where('content_type', $content_type)->where('content_id', $content_id)->where('status', 1)->count();
    }
    public function getAvgReviews($content_type, $content_id)
    {
        $average = Review::where('content_type', $content_type)->where('content_id', $content_id)->where('status', 1)->avg('rating');
        return round($average, 1);
    }
    public function isBookmarkContent($user_id, $content_type, $content_id)
    {
        $bookmark = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->first();
        if ($bookmark) {
            return 1;
        } else {
            return 0;
        }
    }
    public function getTotalEpisodes($audio_book_id)
    {
        return AudioBook_Episode::where('audio_book_id', $audio_book_id)->where('status', 1)->count();
    }
    public function getTotalChapters($novel_id)
    {
        return Novel_Chapter::where('novel_id', $novel_id)->where('status', 1)->count();
    }
    public function isContentBuy($user_id, $content_type, $content_id, $sub_content_id = 0)
    {
        $status = Content_Transaction::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->where('sub_content_id', $sub_content_id)->where('status', 1)->first();
        if ($status) {
            return 1;
        }
        return 0;
    }
    public function totalAudioBooks($author_id)
    {
        return AudioBook::where('author_id', $author_id)->where('status', 1)->count();
    }
    public function totalNovels($author_id)
    {
        return Novel::where('author_id', $author_id)->where('status', 1)->count();
    }
    public function totalMagazine($author_id)
    {
        return Magazine::where('author_id', $author_id)->where('status', 1)->count();
    }
    public function couponCode()
    {
        $code = Str::random(6);

        $check = Coupon::where('coupon_code', $code)->first();
        if (isset($check) && $check != null) {
            $this->couponCode();
        }
        return $code;
    }
    public function checkCoupon($coupon_code, $user_id = '', $price)
    {
        $coupon = Coupon::where('coupon_code', $coupon_code)->where('status', 1)->first();
        if (!$coupon) {
            return [
                'success' => false,
                'message' => __('label.invalid_coupon_code')
            ];
        }

        $today = date('Y-m-d');
        $start_date = $coupon->start_date;
        $end_date = $coupon->end_date;
        if ($today < $start_date || $today > $end_date) {
            return [
                'success' => false,
                'message' => __('label.coupon_is_not_valid_at_this_time')
            ];
        }

        $count = Content_Transaction::where('coupon_code', $coupon_code)->count();
        if ($count >= $coupon->use_limit) {
            return [
                'success' => false,
                'message' => __('label.coupon_limit_exceeded')
            ];
        }

        if ($coupon->is_use == 1) {
            $transaction = Content_Transaction::where('coupon_code', $coupon_code)->where('user_id', $user_id)->first();
            if ($transaction) {
                return [
                    'success' => false,
                    'message' => __('label.coupon_already_used')
                ];
            }
        }

        if ($coupon->amount_type == 1) {
            $discount_price = ($price * $coupon->price) / 100;
        } else {
            $discount_price = $coupon->price;
        }

        $discount_price = max(0, $discount_price);

        return [
            'success' => true,
            'discount' => $discount_price
        ];
    }
    public function generateTransactionId()
    {
        $id = "pay_" . Str::random(15);
        $check1 = Transaction::where('transaction_id', $id)->first();
        $check2 = Content_Transaction::where('transaction_id', $id)->first();
        if (isset($check1) && $check1 != null && isset($check2) && $check2 != null) {
            $id = $this->generateTransactionId();
        }
        return $id;
    }
    public function isSubscription($user_id)
    {
        if (Transaction::where('user_id', $user_id)->where('status', 1)->where('expiry_date', '>', date('Y-m-d H:i'))->exists()) {
            return 1;
        } else {
            return 0;
        }
    }
    public function get_access_type_names($access_type)
    {
        $map = [
            '1' => __('label.unlimited_reading'),
            '2' => __('label.access_mobile_web'),
            '3' => __('label.dark_mode_reading'),
        ];

        $selected = explode(',', $access_type);

        return implode(', ', array_intersect_key($map, array_flip($selected)));
    }
    public function get_last_position($user_id, $content_type, $content_id, $sub_content_id)
    {
        $data = History::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->where('sub_content_id', $sub_content_id)->first();

        if ($data) {
            return $data['last_position'] ?? 0;
        } else {
            return 0;
        }
    }
    public function is_plan_buy($user_id, $plan_id)
    {
        if (Transaction::where('user_id', $user_id)->where('plan_id', $plan_id)->where('status', 1)->exists()) {
            return 1;
        } else {
            return 0;
        }
    }
    public function days_calculate($time, $type)
    {
        $type = strtolower($type);
        if ($type == 'day') {
            return $time;
        } else if ($type == 'week') {
            return $time * 7;
        } else if ($type == 'month') {
            return $time * 30;
        } else if ($type == 'year') {
            return $time * 365;
        } else {
            return 0;
        }
    }
    public function get_plan_from_transaction($transaction)
    {
        if (!$transaction) {
            return null;
        }

        $plan = Plan::where('id', $transaction['plan_id'])->first();
        if (!$plan) {
            return null;
        }

        $transaction['buy_date'] = date('Y-m-d H:i', strtotime($transaction['created_at']));
        $transaction['plan_name'] = $plan['name'];
        $transaction['plan_image'] = $this->getImage($this->folder_plan, $plan['image']);
        $transaction['plan_type'] = $plan['type'];
        $transaction['plan_time'] = $plan['time'];
        $transaction['plan_price'] = $plan['price'];
        $transaction['cancel_anytime'] = $plan['cancel_anytime'];

        return $transaction;
    }

    /**
     * Active platform commission rate (%) from admin settings.
     */
    public function getActiveCommissionRate(): float
    {
        $setting_data = Setting_Data();

        return (float) ($setting_data['active_commission'] ?? $setting_data['commission'] ?? 0);
    }

    /**
     * Build price, tax, commission, and author net for a content purchase.
     * When tax is not supplied, active taxes are applied to the pre-tax base price.
     */
    public function prepareContentTransactionFinancials(
        float $basePrice,
        ?float $providedTotalTax = null,
        ?string $providedTax = null
    ): array {
        $basePrice = max(round($basePrice, 2), 0);

        if ($providedTotalTax !== null && $providedTotalTax > 0) {
            $totalTax = round($providedTotalTax, 2);
            $finalPrice = round($basePrice + $totalTax, 2);
            $tax = $providedTax ?? '';
        } else {
            $taxes = Tax::select('id', 'name', 'percentage')->where('status', 1)->get();
            $totalTax = 0;
            $taxRows = [];
            foreach ($taxes as $tax) {
                $taxAmount = round(((float) $basePrice * (float) $tax->percentage) / 100, 2);
                $row = $tax->toArray();
                $row['amount'] = $taxAmount;
                $taxRows[] = $row;
                $totalTax += $taxAmount;
            }
            $totalTax = round($totalTax, 2);
            $finalPrice = round($basePrice + $totalTax, 2);
            $tax = json_encode($taxRows);
        }

        $splits = $this->calculateContentTransactionSplits($finalPrice, $totalTax);

        return [
            'price' => $finalPrice,
            'total_tax' => $totalTax,
            'tax' => $tax,
            'commission' => $splits['commission'],
            'author_earning' => $splits['author_earning'],
        ];
    }

    /**
     * Split a content purchase into admin commission and author net earnings.
     * Commission is calculated on the pre-tax amount when tax is provided separately.
     */
    public function calculateContentTransactionSplits(float $grossPrice, float $totalTax = 0): array
    {
        $rate = $this->getActiveCommissionRate();
        $baseAmount = max($grossPrice - $totalTax, 0);
        if ($baseAmount <= 0 && $grossPrice > 0) {
            $baseAmount = $grossPrice;
        }
        $commission = round(($baseAmount * $rate) / 100, 2);
        $authorEarning = round(max($baseAmount - $commission, 0), 2);

        return [
            'commission' => $commission,
            'author_earning' => $authorEarning,
        ];
    }

    /**
     * Credit an author's wallet with net earnings after commission.
     */
    public function creditAuthorWallet(int $authorId, float $amount): void
    {
        $amount = round(max($amount, 0), 2);
        if ($authorId <= 0 || $amount <= 0) {
            return;
        }

        User::where('id', $authorId)->increment('wallet_amount', $amount);
    }

    /**
     * Mark a pending content transaction as paid and credit the author wallet.
     */
    public function confirmContentTransaction(Content_Transaction $transaction): bool
    {
        if ((int) $transaction->status !== 0) {
            return false;
        }

        return DB::transaction(function () use ($transaction) {
            $locked = Content_Transaction::where('id', $transaction->id)
                ->where('status', 0)
                ->lockForUpdate()
                ->first();

            if (!$locked) {
                return false;
            }

            $locked->status = 1;
            $locked->save();

            $this->creditAuthorWallet(
                (int) ($locked->author_id ?? 0),
                (float) ($locked->author_earning ?? 0)
            );

            $alreadyBookmarked = Bookmark::where('user_id', $locked->user_id)
                ->where('content_type', $locked->content_type)
                ->where('content_id', $locked->content_id)
                ->first();

            if (!$alreadyBookmarked) {
                Bookmark::create([
                    'user_id' => $locked->user_id,
                    'content_type' => $locked->content_type,
                    'content_id' => $locked->content_id,
                    'status' => 1,
                ]);
            }

            return true;
        });
    }
}
