<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Category;
use App\Models\AudioBook;
use App\Models\AudioBook_Episode;
use App\Models\General_Setting;
use App\Models\Page;
use App\Models\Payment_Option;
use App\Models\Notification;
use App\Models\Social_Link;
use App\Models\Onboarding_Screen;
use App\Models\User;
use App\Models\Contact_Us;
use App\Models\Content_Section;
use App\Models\Content_Transaction;
use App\Models\Content_View;
use App\Models\Coupon;
use App\Models\Language;
use App\Models\Login_History;
use App\Models\Magazine;
use App\Models\Novel;
use App\Models\Novel_Chapter;
use App\Models\Plan;
use App\Models\Read_Notification;
use App\Models\Review;
use App\Models\Tax;
use App\Models\History;
use App\Models\Transaction;
use App\Models\Bookmark;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class HomeController extends Controller
{
    private $folder_user = "user";
    private $folder_setting = "setting";
    private $folder_category = "category";
    private $folder_language = "language";
    private $folder_audiobook = "audio_books";
    private $folder_novels = "novels";
    private $folder_magazines = "magazines";
    private $folder_notification = "notification";
    private $folder_plan = "plan";

    public $common;
    public $page_limit;
    public function __construct()
    {
        try {

            $this->common = new Common();
            $this->page_limit = env('PAGE_LIMIT');
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function general_setting()
    {
        try {

            $list = General_Setting::get();
            foreach ($list as $key => $value) {

                if ($value['key'] == 'app_logo' || $value['key'] == 'company_logo') {
                    $value['value'] = $this->common->getImage($this->folder_setting, $value['value']);
                }
            }

            return $this->common->API_Response(200, __('api_msg.data_retrieved'), $list);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_payment_option()
    {
        try {

            $return['status'] = 200;
            $return['message'] = __('api_msg.data_retrieved');
            $return['result'] = [];

            $data = Payment_Option::get();
            foreach ($data as $key => $value) {
                $return['result'][$value['name']] = $value;
            }

            // Ensure Paystack key exists even if DB row not seeded yet.
            if (!isset($return['result']['paystack'])) {
                $return['result']['paystack'] = [
                    'id' => 0,
                    'name' => 'paystack',
                    'visibility' => '0',
                    'is_live' => '0',
                    'key_1' => '',
                    'key_2' => '',
                    'key_3' => '',
                    'key_4' => '',
                ];
            }

            return $return;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_onboarding_screen()
    {
        try {
            $data = Onboarding_Screen::get();
            if (sizeof($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_setting);
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_social_link()
    {
        try {
            $data = Social_Link::get();
            if (sizeof($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_setting);
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_pages()
    {
        try {
            $return['status'] = 200;
            $return['message'] = __('api_msg.data_retrieved');
            $return['result'] = [];

            $data = Page::get();
            for ($i = 0; $i < count($data); $i++) {
                $return['result'][$i]['title'] = $data[$i]['title'];
                $return['result'][$i]['url'] = env('APP_URL') . '/public/pages/' . $data[$i]['title'];
                $return['result'][$i]['icon'] = $this->common->getImage($this->folder_setting, $data[$i]['icon']);
            }
            return $return;
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_category(Request $request)
    {
        try {

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Category::where('status', 1)->orderBy('sort_order', 'asc');

            $total_rows = $data->count();
            $total_page = 50;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->get();
            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_category);
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_language(Request $request)
    {
        try {

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Language::where('status', 1)->orderBy('sort_order', 'asc');

            $total_rows = $data->count();
            $total_page = 50;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->get();
            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_language);
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_section_list(Request $request)
    {
        try {
            $traceId = uniqid('get_section_list_', true);
            $validation = Validator::make($request->all(), [
                'section_type' => 'required',
            ]);
            if ($validation->fails()) {
                Log::warning('api.get_section_list.validation_failed', [
                    'trace_id' => $traceId,
                    'payload' => $request->all(),
                    'first_error' => $validation->errors()->first(),
                ]);
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $section_type = $request['section_type'] ?? 0;
            $user_id = $request['user_id'] ?? 0;
            $user_category_ids = explode(',', $request['user_category_ids'] ?? "");
            $user_category_ids = array_filter(array_map('intval', $user_category_ids));
            Log::info('api.get_section_list.request', [
                'trace_id' => $traceId,
                'section_type' => $section_type,
                'user_id' => $user_id,
                'page_no' => $request->page_no ?? 1,
                'raw_user_category_ids' => $request['user_category_ids'] ?? '',
                'parsed_user_category_ids' => $user_category_ids,
            ]);

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Content_Section::where('section_type', $section_type)->where('status', 1)->orderBy('sort_order', 'asc');
            // If user has selected preferred categories, include those + generic sections (category_id = 0).
            // If no preferences are provided, don't filter by category so all sections can appear.
            if (!empty($user_category_ids)) {
                $category_ids = array_merge([0], $user_category_ids);
                $data->whereIn('category_id', $category_ids);
                Log::info('api.get_section_list.section_category_filter', [
                    'trace_id' => $traceId,
                    'effective_category_ids' => $category_ids,
                ]);
            } else {
                Log::info('api.get_section_list.section_category_filter_skipped', [
                    'trace_id' => $traceId,
                ]);
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;
            $data->take($total_page)->offset($offset);

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);
            $data = $data->latest()->get();
            Log::info('api.get_section_list.sections_loaded', [
                'trace_id' => $traceId,
                'total_rows' => $total_rows,
                'page_limit' => $total_page,
                'current_page' => $current_page,
                'sections_returned' => count($data),
                'section_ids' => $data->pluck('id')->values()->all(),
                'section_types' => $data->pluck('content_type')->values()->all(),
                'section_titles' => $data->pluck('title')->values()->all(),
            ]);

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['data'] = [];
                    if ($data[$i]['content_type'] == 1 || $data[$i]['content_type'] == 2 || $data[$i]['content_type'] == 3) {
                        $query = $this->common->section_query($user_id, $data[$i]['content_type'], $data[$i]['author_id'], $data[$i]['category_id'], $data[$i]['language_id'], $data[$i]['access_type'], $data[$i]['no_of_content'], $data[$i]['order_by_upload'], $data[$i]['order_by_view']);
                        $data[$i]['data'] = $query;
                        Log::info('api.get_section_list.section_data_query_result', [
                            'trace_id' => $traceId,
                            'section_id' => $data[$i]['id'],
                            'section_title' => $data[$i]['title'],
                            'section_content_type' => $data[$i]['content_type'],
                            'filters' => [
                                'author_id' => $data[$i]['author_id'],
                                'category_id' => $data[$i]['category_id'],
                                'language_id' => $data[$i]['language_id'],
                                'access_type' => $data[$i]['access_type'],
                                'no_of_content' => $data[$i]['no_of_content'],
                                'order_by_upload' => $data[$i]['order_by_upload'],
                                'order_by_view' => $data[$i]['order_by_view'],
                            ],
                            'result_count' => is_countable($query) ? count($query) : null,
                            'result_ids' => collect($query)->pluck('id')->values()->all(),
                        ]);
                    }
                    if ($data[$i]['content_type'] == 4) {
                        $query = Category::where('status', 1)->orderBy('sort_order', 'asc')->take($data[$i]['no_of_content'])->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_category);
                        $data[$i]['data'] = $query;
                    }
                    if ($data[$i]['content_type'] == 5) {
                        $query = Language::where('status', 1)->orderBy('sort_order', 'asc')->take($data[$i]['no_of_content'])->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_language);
                        $data[$i]['data'] = $query;
                    }
                    if ($data[$i]['content_type'] == 6) {
                        $query = User::where('is_author', 1)->where('status', 1)->orderBy('id', 'desc')->take($data[$i]['no_of_content'])->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_user);
                        $data[$i]['data'] = $query;
                    }
                    Log::info('api.get_section_list.section_final_bucket', [
                        'trace_id' => $traceId,
                        'section_id' => $data[$i]['id'],
                        'section_title' => $data[$i]['title'],
                        'content_type' => $data[$i]['content_type'],
                        'bucket_count' => isset($data[$i]['data']) && is_countable($data[$i]['data']) ? count($data[$i]['data']) : null,
                    ]);
                }
                Log::info('api.get_section_list.success', [
                    'trace_id' => $traceId,
                    'sections_count' => count($data),
                ]);

                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                Log::warning('api.get_section_list.no_sections', [
                    'trace_id' => $traceId,
                    'section_type' => $section_type,
                    'user_category_ids' => $user_category_ids,
                ]);
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            Log::error('api.get_section_list.exception', [
                'payload' => $request->all(),
                'error' => $e->getMessage(),
            ]);
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_section_detail(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'section_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $section_id = $request['section_id'] ?? 0;
            $user_id = $request['user_id'] ?? 0;
            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $section = Content_Section::where('id', $section_id)->first();
            if ($section) {

                if ($section['content_type'] == 1 || $section['content_type'] == 2 || $section['content_type'] == 3) {

                    $data = $this->common->section_details_query($user_id, $section['content_type'], $section['author_id'], $section['category_id'], $section['language_id'], $section['access_type'], $section['no_of_content'], $section['order_by_upload'], $section['order_by_view']);
                    $total_rows = $data->count();
                    $total_page = 50;
                    $page_size = ceil($total_rows / $total_page);
                    $current_page = $request->page_no ?? 1;
                    $offset = $current_page * $total_page - $total_page;

                    $more_page = $this->common->more_page($current_page, $page_size);
                    $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);
                    $data = $data->take($total_page)->offset($offset)->get();

                    if (count($data) > 0) {

                        if ($section['content_type'] == 1) {
                            for ($i = 0; $i < count($data); $i++) {

                                $data[$i]['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['portrait_img']);
                                $data[$i]['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['landscape_img']);
                                $data[$i]['full_audio'] = $this->common->getFile($this->folder_audiobook, $data[$i]['full_audio']);
                                $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                                $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                                $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                                $data[$i]['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['id']);
                                $data[$i]['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['id']);
                                $data[$i]['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['id']);
                                $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['id']);
                                $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['id'], 0);
                            }
                        }
                        if ($section['content_type'] == 2) {
                            for ($i = 0; $i < count($data); $i++) {

                                $data[$i]['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['portrait_img']);
                                $data[$i]['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['landscape_img']);
                                $data[$i]['full_novel'] = $this->common->getFile($this->folder_novels, $data[$i]['full_novel']);
                                $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                                $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                                $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                                $data[$i]['total_chapters'] = $this->common->getTotalchapters($data[$i]['id']);
                                $data[$i]['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['id']);
                                $data[$i]['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['id']);
                                $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['id']);
                                $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['id'], 0);
                            }
                        }
                        if ($section['content_type'] == 3) {
                            for ($i = 0; $i < count($data); $i++) {

                                $data[$i]['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['portrait_img']);
                                $data[$i]['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['landscape_img']);
                                $data[$i]['full_magazine'] = $this->common->getFile($this->folder_magazines, $data[$i]['full_magazine']);
                                $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                                $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                                $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                                $data[$i]['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['id']);
                                $data[$i]['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['id']);
                                $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['id']);
                                $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['id'], 0);
                            }
                        }
                        return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_found'));
                    }
                }
                if ($section['content_type'] == 4) {

                    $data = Category::where('status', 1)->orderBy('sort_order', 'asc');

                    $total_rows = $data->count();
                    $total_page = 50;
                    $page_size = ceil($total_rows / $total_page);
                    $current_page = $request->page_no ?? 1;
                    $offset = $current_page * $total_page - $total_page;
                    $data->take($total_page)->offset($offset);

                    $more_page = $this->common->more_page($current_page, $page_size);
                    $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);
                    $data = $data->latest()->get();

                    if (count($data) > 0) {

                        $this->common->imageNameToUrl($data, 'image', $this->folder_category);
                        return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_found'));
                    }
                }
                if ($section['content_type'] == 5) {

                    $data = Language::where('status', 1)->orderBy('sort_order', 'asc');

                    $total_rows = $data->count();
                    $total_page = 50;
                    $page_size = ceil($total_rows / $total_page);
                    $current_page = $request->page_no ?? 1;
                    $offset = $current_page * $total_page - $total_page;
                    $data->take($total_page)->offset($offset);

                    $more_page = $this->common->more_page($current_page, $page_size);
                    $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);
                    $data = $data->latest()->get();

                    if (count($data) > 0) {

                        $this->common->imageNameToUrl($data, 'image', $this->folder_language);
                        return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_found'));
                    }
                }
                if ($section['content_type'] == 6) {

                    $data = User::where('is_author', 1)->where('status', 1)->orderBy('id', 'desc');

                    $total_rows = $data->count();
                    $total_page = 50;
                    $page_size = ceil($total_rows / $total_page);
                    $current_page = $request->page_no ?? 1;
                    $offset = $current_page * $total_page - $total_page;
                    $data->take($total_page)->offset($offset);

                    $more_page = $this->common->more_page($current_page, $page_size);
                    $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);
                    $data = $data->latest()->get();

                    if (count($data) > 0) {

                        $this->common->imageNameToUrl($data, 'image', $this->folder_user);
                        return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_found'));
                    }
                }
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_content_detail(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'content_type' => 'required|numeric',
                'content_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $user_id = $request['user_id'] ?? 0;

            if ($content_type == 1) {

                $content = AudioBook::where('id', $content_id)->where('status', 1)->with('author')->first();
                if ($content) {

                    $content['portrait_img'] = $this->common->getImage($this->folder_audiobook, $content['portrait_img']);
                    $content['landscape_img'] = $this->common->getImage($this->folder_audiobook, $content['landscape_img']);
                    $content['full_audio'] = $this->common->getFile($this->folder_audiobook, $content['full_audio']);
                    $content['author_name'] = $this->common->GetAuthorNameById($content['author_id']);
                    $content['author_image'] = $this->common->getImage($this->folder_user, $content['author']['image'] ?? "");
                    $content['author_subaccount'] = $content['author']['subaccount_code'] ?? "";
                    $content['bsnb'] = $content['bsnb'] ?? "";
                    $content['custom_author_name'] = $content['publisher_author_name'] ?? "";
                    $content['category_name'] = $this->common->GetCategoryNameById($content['category_id']);
                    $content['language_name'] = $this->common->GetLanguageNameById($content['language_id']);
                    $content['total_episodes'] = $this->common->getTotalEpisodes($content['id']);
                    $content['total_reviews'] = $this->common->getTotalReviews(1, $content['id']);
                    $content['avg_reviews'] = $this->common->getAvgReviews(1, $content['id']);
                    $content['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $content['id']);
                    $content['is_buy'] = $this->common->isContentBuy($user_id, 1, $content['id'], 0);
                    $content['is_subscription'] = $this->common->isSubscription($user_id);

                    unset($content['author']);

                    return $this->common->API_Response(200, __('api_msg.data_retrieved'), $content);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            }
            if ($content_type == 2) {

                $content = Novel::where('id', $content_id)->where('status', 1)->with('author')->first();
                if ($content) {

                    $content['portrait_img'] = $this->common->getImage($this->folder_novels, $content['portrait_img']);
                    $content['landscape_img'] = $this->common->getImage($this->folder_novels, $content['landscape_img']);
                    $content['full_novel'] = $this->common->getFile($this->folder_novels, $content['full_novel']);
                    $content['author_name'] = $this->common->GetAuthorNameById($content['author_id']);
                    $content['author_image'] = $this->common->getImage($this->folder_user, $content['author']['image'] ?? "");
                    $content['author_subaccount'] = $content['author']['subaccount_code'] ?? "";
                    $content['bsnb'] = $content['bsnb'] ?? "";
                    $content['custom_author_name'] = $content['publisher_author_name'] ?? "";
                    $content['category_name'] = $this->common->GetCategoryNameById($content['category_id']);
                    $content['language_name'] = $this->common->GetLanguageNameById($content['language_id']);
                    $content['total_chapters'] = $this->common->getTotalchapters($content['id']);
                    $content['total_reviews'] = $this->common->getTotalReviews(2, $content['id']);
                    $content['avg_reviews'] = $this->common->getAvgReviews(2, $content['id']);
                    $content['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $content['id']);
                    $content['is_buy'] = $this->common->isContentBuy($user_id, 2, $content['id'], 0);
                    $content['is_subscription'] = $this->common->isSubscription($user_id);

                    unset($content['author']);

                    return $this->common->API_Response(200, __('api_msg.data_retrieved'), $content);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            }
            if ($content_type == 3) {

                $content = Magazine::where('id', $content_id)->where('status', 1)->with('author')->first();
                if ($content) {

                    $content['portrait_img'] = $this->common->getImage($this->folder_magazines, $content['portrait_img']);
                    $content['landscape_img'] = $this->common->getImage($this->folder_magazines, $content['landscape_img']);
                    $content['full_magazine'] = $this->common->getFile($this->folder_magazines, $content['full_magazine']);
                    $content['author_name'] = $this->common->GetAuthorNameById($content['author_id']);
                    $content['author_image'] = $this->common->getImage($this->folder_user, $content['author']['image'] ?? "");
                    $content['author_subaccount'] = $content['author']['subaccount_code'] ?? "";
                    $content['bsnb'] = $content['bsnb'] ?? "";
                    $content['custom_author_name'] = $content['publisher_author_name'] ?? "";
                    $content['category_name'] = $this->common->GetCategoryNameById($content['category_id']);
                    $content['language_name'] = $this->common->GetLanguageNameById($content['language_id']);
                    $content['total_reviews'] = $this->common->getTotalReviews(3, $content['id']);
                    $content['avg_reviews'] = $this->common->getAvgReviews(3, $content['id']);
                    $content['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $content['id']);
                    $content['is_buy'] = $this->common->isContentBuy($user_id, 3, $content['id'], 0);
                    $content['is_subscription'] = $this->common->isSubscription($user_id);
                    $content['last_position'] = $this->common->get_last_position($user_id, 3, $content_id, 0);


                    unset($content['author']);

                    return $this->common->API_Response(200, __('api_msg.data_retrieved'), $content);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            }
            return $this->common->API_Response(400, __('api_msg.data_not_found'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_episode_by_audiobook(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'audio_book_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $audio_book_id = $request['audio_book_id'];
            $user_id = $request['user_id'] ?? 0;

            $audiobook = AudioBook::where('id', $audio_book_id)->where('status', 1)->first();
            if (!$audiobook) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = AudioBook_Episode::where('audio_book_id', $audio_book_id)->where('status', 1)->orderBy('sort_order', 'asc');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);
            $data = $data->take($total_page)->offset($offset)->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['image'] = $this->common->getImage($this->folder_audiobook, $data[$i]['image']);
                    if ($data[$i]['audio_type'] == 1) {
                        $data[$i]['audio'] = $this->common->getFile($this->folder_audiobook, $data[$i]['audio']);
                    }
                    $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $audio_book_id, $data[$i]['id']);
                    $content['last_position'] = $this->common->get_last_position($user_id, 1, $audio_book_id, $data[$i]['id']);
                    $data[$i]['author_id'] = $audiobook['author_id'];
                }

                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_chapter_by_novel(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'novel_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $novel_id = $request['novel_id'];
            $user_id = $request['user_id'] ?? 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Novel_Chapter::where('novel_id', $novel_id)->where('status', 1)->orderBy('sort_order', 'asc');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);
            $data = $data->take($total_page)->offset($offset)->latest()->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['image'] = $this->common->getImage($this->folder_novels, $data[$i]['image']);
                    if ($data[$i]['chapter_type'] == 1) {
                        $data[$i]['chapter'] = $this->common->getFile($this->folder_novels, $data[$i]['chapter']);
                    }
                    $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $novel_id, $data[$i]['id']);
                    $content['last_position'] = $this->common->get_last_position($user_id, 2, $novel_id, $data[$i]['id']);
                }

                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_releted_content(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'content_type' => 'required',
                'content_id' => 'required',
                'category_id' => 'required',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $category_id = $request['category_id'];
            $user_id = $request['user_id'] ?? 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 1) {

                $data = AudioBook::where('id', '!=', $content_id)->where('category_id', $category_id)->where('status', 1)->orderBy('total_played', 'desc');
                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data = $data->take($total_page)->offset($offset)->get();
                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['id'], 0);
                        $data[$i]['full_audio'] = $this->common->getFile($this->folder_audiobook, $data[$i]['full_audio']);
                    }
                    return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            }
            if ($content_type == 2) {

                $data = Novel::where('id', '!=', $content_id)->where('category_id', $category_id)->where('status', 1)->orderBy('total_read', 'desc');
                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data = $data->take($total_page)->offset($offset)->get();
                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_chapters'] = $this->common->getTotalchapters($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['id'], 0);
                        $data[$i]['full_novel'] = $this->common->getFile($this->folder_novels, $data[$i]['full_novel']);
                    }
                    return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            }
            if ($content_type == 3) {

                $data = Magazine::where('id', '!=', $content_id)->where('category_id', $category_id)->where('status', 1)->orderBy('total_read', 'desc');
                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data = $data->take($total_page)->offset($offset)->get();
                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['id'], 0);
                        $data[$i]['full_magazine'] = $this->common->getFile($this->folder_magazines, $data[$i]['full_magazine']);
                    }
                    return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            }
            return $this->common->API_Response(400, __('api_msg.data_not_found'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function add_review(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'content_type' => 'required|numeric',
                'content_id' => 'required|numeric',
                'review' => 'required',
                'rating' => 'required|numeric'
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $review = $request['review'];
            $rating = $request['rating'] ?? 0;

            $check = Review::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->first();
            if ($check) {

                $check['user_id'] = $user_id;
                $check['content_type'] = $content_type;
                $check['content_id'] = $content_id;
                $check['review'] = $review;
                $check['rating'] = $rating;
                $check['status'] = 1;
                $check->save();
            } else {

                $insert = new Review();
                $insert['user_id'] = $user_id;
                $insert['content_type'] = $content_type;
                $insert['content_id'] = $content_id;
                $insert['review'] = $review;
                $insert['rating'] = $rating;
                $insert['status'] = 1;
                $insert->save();
            }
            return $this->common->API_Response(200, __('api_msg.review_add_successfully'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function delete_review(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'review_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            Review::where('id', $request['review_id'])->delete();

            return $this->common->API_Response(200, __('api_msg.review_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_review(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'content_type' => 'required|numeric',
                'content_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Review::where('content_type', $content_type)->where('content_id', $content_id)->where('status', 1)->orderBy('id', 'desc')->with('user');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['first_name'] = $data[$i]['user']['first_name'] ?? "";
                    $data[$i]['last_name'] = $data[$i]['user']['last_name'] ?? "";
                    $data[$i]['user_name'] = $data[$i]['user']['user_name'] ?? "";
                    $data[$i]['user_image'] = $this->common->getImage($this->folder_user, $data[$i]['user']['image'] ?? "");

                    unset($data[$i]['user']);
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function add_content_view(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'content_type' => 'required|numeric',
                'content_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $sub_content_id = $request['sub_content_id'] ?? 0;

            $check_view = Content_View::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->where('sub_content_id', $sub_content_id)->first();
            if ($check_view) {
                return $this->common->API_Response(200, __('api_msg.view_add_successfully'));
            }

            $insert = new Content_View();
            $insert['user_id'] = $user_id;
            $insert['content_type'] = $content_type;
            $insert['content_id'] = $content_id;
            $insert['sub_content_id'] = $sub_content_id;
            $insert['status'] = 1;
            $insert->save();

            // Audio Books
            if ($content_type == 1) {
                AudioBook::where('id', $content_id)->increment('total_played', 1);

                if ($sub_content_id != 0) {
                    AudioBook_Episode::where('id', $sub_content_id)->where('audio_book_id', $content_id)->increment('total_played', 1);
                }
            }
            // Novels
            if ($content_type == 2) {
                Novel::where('id', $content_id)->increment('total_read', 1);

                if ($sub_content_id != 0) {
                    Novel_Chapter::where('id', $sub_content_id)->where('novel_id', $content_id)->increment('total_read', 1);
                }
            }
            // Magazines
            if ($content_type == 3) {
                Magazine::where('id', $content_id)->increment('total_read', 1);
            }
            return $this->common->API_Response(200, __('api_msg.view_add_successfully'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function add_remove_bookmark(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'content_type' => 'required|numeric',
                'content_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $content_type = $request['content_type'];
            $content_id = $request['content_id'];

            $data = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->first();
            if ($data) {
                $data->delete();
                return $this->common->API_Response(200, __('api_msg.remove_bookmark_successfully'));
            } else {

                $insert = new Bookmark();
                $insert['user_id'] = $user_id;
                $insert['content_type'] = $content_type;
                $insert['content_id'] = $content_id;
                $insert['status'] = 1;
                $insert->save();
                return $this->common->API_Response(200, __('api_msg.add_bookmark_successfully'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_bookmark_content(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'content_type' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $content_type = $request['content_type'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 1) {
                $data = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->with('audio_book')->latest();
            } else if ($content_type == 2) {
                $data = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->with('novel')->latest();
            } else if ($content_type == 3) {
                $data = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->with('magazine')->latest();
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->get();
            if (count($data) > 0) {

                $array = [];
                for ($i = 0; $i < count($data); $i++) {

                    // Audio Books
                    if ($content_type == 1 && $data[$i]['audio_book'] != null) {

                        $data[$i]['audio_book']['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['audio_book']['portrait_img']);
                        $data[$i]['audio_book']['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['audio_book']['landscape_img']);
                        $data[$i]['audio_book']['author_name'] = $this->common->GetAuthorNameById($data[$i]['audio_book']['author_id']);
                        $data[$i]['audio_book']['category_name'] = $this->common->GetCategoryNameById($data[$i]['audio_book']['category_id']);
                        $data[$i]['audio_book']['language_name'] = $this->common->GetLanguageNameById($data[$i]['audio_book']['language_id']);
                        $data[$i]['audio_book']['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['audio_book']['id']);
                        $data[$i]['audio_book']['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['audio_book']['id']);
                        $data[$i]['audio_book']['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['audio_book']['id']);
                        $data[$i]['audio_book']['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['audio_book']['id']);
                        $data[$i]['audio_book']['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['audio_book']['id'], 0);

                        $array[] = $data[$i]['audio_book'];
                    }
                    // Novels
                    if ($content_type == 2 && $data[$i]['novel'] != null) {

                        $data[$i]['novel']['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['novel']['portrait_img']);
                        $data[$i]['novel']['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['novel']['landscape_img']);
                        $data[$i]['novel']['author_name'] = $this->common->GetAuthorNameById($data[$i]['novel']['author_id']);
                        $data[$i]['novel']['category_name'] = $this->common->GetCategoryNameById($data[$i]['novel']['category_id']);
                        $data[$i]['novel']['language_name'] = $this->common->GetLanguageNameById($data[$i]['novel']['language_id']);
                        $data[$i]['novel']['total_chapters'] = $this->common->getTotalchapters($data[$i]['novel']['id']);
                        $data[$i]['novel']['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['novel']['id']);
                        $data[$i]['novel']['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['novel']['id']);
                        $data[$i]['novel']['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['novel']['id']);
                        $data[$i]['novel']['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['novel']['id'], 0);

                        $array[] = $data[$i]['novel'];
                    }
                    // Magazines
                    if ($content_type == 3 && $data[$i]['magazine'] != null) {

                        $data[$i]['magazine']['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['magazine']['portrait_img']);
                        $data[$i]['magazine']['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['magazine']['landscape_img']);
                        $data[$i]['magazine']['author_name'] = $this->common->GetAuthorNameById($data[$i]['magazine']['author_id']);
                        $data[$i]['magazine']['category_name'] = $this->common->GetCategoryNameById($data[$i]['magazine']['category_id']);
                        $data[$i]['magazine']['language_name'] = $this->common->GetLanguageNameById($data[$i]['magazine']['language_id']);
                        $data[$i]['magazine']['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['magazine']['id']);
                        $data[$i]['magazine']['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['magazine']['id']);
                        $data[$i]['magazine']['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['magazine']['id']);
                        $data[$i]['magazine']['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['magazine']['id'], 0);

                        $array[] = $data[$i]['magazine'];
                    }
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $array, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function search_content(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'content_type' => 'required|numeric',
                'title' => 'required',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $content_type = $request['content_type'];
            $title = $request['title'];
            $user_id = $request['user_id'] ?? 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 1) {
                $data = AudioBook::where('title', 'like', '%' . $title . '%')->where('status', 1)->orderBy('total_played', 'desc');
            } else if ($content_type == 2) {
                $data = Novel::where('title', 'like', '%' . $title . '%')->where('status', 1)->orderBy('total_read', 'desc');
            } else if ($content_type == 3) {
                $data = Magazine::where('title', 'like', '%' . $title . '%')->where('status', 1)->orderBy('total_read', 'desc');
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {

                if ($content_type == 1) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['id'], 0);
                    }
                }
                if ($content_type == 2) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_chapters'] = $this->common->getTotalchapters($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['id'], 0);
                    }
                }
                if ($content_type == 3) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['id'], 0);
                    }
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function add_transaction(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'author_id' => 'required|numeric',
                'content_type' => 'required|numeric',
                'content_id' => 'required|numeric',
                'price' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $author_id = $request['author_id'];
            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $sub_content_id = $request['sub_content_id'] ?? 0;
            $coupon_code = $request['coupon_code'] ?? '';
            $base_price = (float) $request['price'];
            $transaction_id = $request['transaction_id'] ?? '';
            $payment_method = $request['payment_method'] ?? '';

            if (!empty($coupon_code)) {
                $couponResult = $this->common->checkCoupon($coupon_code, $user_id, $base_price);
                if (!$couponResult['success']) {
                    return $this->common->API_Response(400, $couponResult['message']);
                }
                $base_price = max($base_price - $couponResult['discount'], 0);
            }

            $providedTax = isset($request['total_tax']) && (float) $request['total_tax'] > 0
                ? (float) $request['total_tax']
                : null;
            $financials = $this->common->prepareContentTransactionFinancials(
                $base_price,
                $providedTax,
                $request['tax'] ?? null
            );

            $data = array(
                'user_id' => $user_id,
                'author_id' => $author_id,
                'content_type' => $content_type,
                'content_id' => $content_id,
                'sub_content_id' => $sub_content_id,
                'coupon_code' => $coupon_code,
                'price' => $financials['price'],
                'commission' => $financials['commission'],
                'total_tax' => $financials['total_tax'],
                'tax' => $financials['tax'],
                'author_earning' => $financials['author_earning'],
                'transaction_id' => $transaction_id,
                'payment_method' => $payment_method,
                'status' => 0,
            );

            $insertId = Content_Transaction::insertGetId($data);
            if ($insertId != null) {

                $user = User::where('id', $user_id)->first();
                $status = $this->common->BasicNotiConfiguration('buy-content');
                if ($status['status'] == 1 && $status['send_mail'] == 1) {

                    if ($sub_content_id == 0) {

                        if ($content_type == 1) {
                            $content = AudioBook::where('id', $content_id)->first();
                        }
                        if ($content_type == 2) {
                            $content = Novel::where('id', $content_id)->first();
                        }
                        if ($content_type == 3) {
                            $content = Magazine::where('id', $content_id)->first();
                        }
                    } else {
                        if ($content_type == 1) {
                            $content = AudioBook_Episode::where('id', $sub_content_id)->first();
                        }
                        if ($content_type == 2) {
                            $content = Novel_Chapter::where('id', $sub_content_id)->first();
                        }
                    }

                    $this->common->Send_Mail(5, $user['email'], 0, $content['title'], $financials['price'], $user['first_name'], $user['last_name'], $transaction_id, date('d M Y'));
                }
                return $this->common->API_Response(200, __('api_msg.transaction_successfully'), $insertId);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_transaction_history(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];
            $content_type = $request['content_type'] ?? 0;
            $status = $request['status'] ?? "";

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 0) {
                $data = Content_Transaction::where('user_id', $user_id)->with('audio_book', 'novel', 'magazine', 'episode', 'chapter')->orderBy('id', 'DESC');
            } else {
                $data = Content_Transaction::where('user_id', $user_id)->where('content_type', $content_type)->with('audio_book', 'novel', 'magazine', 'episode', 'chapter')->orderBy('id', 'DESC');
            }
            if (isset($status) && $status != "") {
                $data->where('status', $status);
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->get();
            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);

                    $data[$i]['content_name'] = "";
                    $data[$i]['content_image'] = $this->common->getImage($this->folder_audiobook, "");
                    $data[$i]['sub_content_name'] = "";
                    $data[$i]['sub_content_image'] = $this->common->getImage($this->folder_audiobook, "");
                    $data[$i]['category_id'] = 0;
                    if ($data[$i]['sub_content_id'] == 0) {

                        if ($data[$i]['content_type'] == 1) {
                            $data[$i]['content_name'] = $data[$i]['audio_book']['title'] ?? "";
                            $data[$i]['content_image'] = $this->common->getImage($this->folder_audiobook, $data[$i]['audio_book']['portrait_img'] ?? "");
                            $data[$i]['category_id'] = $data[$i]['audio_book']['category_id'] ?? 0;
                        }
                        if ($data[$i]['content_type'] == 2) {
                            $data[$i]['content_name'] = $data[$i]['novel']['title'] ?? "";
                            $data[$i]['content_image'] = $this->common->getImage($this->folder_novels, $data[$i]['novel']['portrait_img'] ?? "");
                            $data[$i]['category_id'] = $data[$i]['novel']['category_id'] ?? 0;
                        }
                        if ($data[$i]['content_type'] == 3) {
                            $data[$i]['content_name'] = $data[$i]['magazine']['title'] ?? "";
                            $data[$i]['content_image'] = $this->common->getImage($this->folder_magazines, $data[$i]['magazine']['portrait_img'] ?? "");
                            $data[$i]['category_id'] = $data[$i]['magazine']['category_id'] ?? 0;
                        }
                    } else {

                        if ($data[$i]['content_type'] == 1) {
                            $data[$i]['content_name'] = $data[$i]['audio_book']['title'] ?? "";
                            $data[$i]['content_image'] = $this->common->getImage($this->folder_audiobook, $data[$i]['audio_book']['portrait_img'] ?? "");
                            $data[$i]['category_id'] = $data[$i]['audio_book']['category_id'] ?? 0;
                            $data[$i]['sub_content_name'] = $data[$i]['episode']['title'] ?? "";
                            $data[$i]['sub_content_image'] = $this->common->getImage($this->folder_audiobook, $data[$i]['episode']['image'] ?? "");
                        }
                        if ($data[$i]['content_type'] == 2) {
                            $data[$i]['content_name'] = $data[$i]['novel']['title'] ?? "";
                            $data[$i]['content_image'] = $this->common->getImage($this->folder_novels, $data[$i]['novel']['portrait_img'] ?? "");
                            $data[$i]['category_id'] = $data[$i]['novel']['category_id'] ?? 0;
                            $data[$i]['sub_content_name'] = $data[$i]['chapter']['title'] ?? "";
                            $data[$i]['sub_content_image'] = $this->common->getImage($this->folder_novels, $data[$i]['chapter']['image'] ?? "");
                        }
                    }

                    unset($data[$i]['audio_book'], $data[$i]['novel'], $data[$i]['magazine'], $data[$i]['episode'], $data[$i]['chapter']);
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_notification(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request['user_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $readNotificationIds = Read_Notification::where('user_id', $user_id)->pluck('notification_id')->toArray();
            $data = Notification::where(function ($query) use ($readNotificationIds) {
                $query->whereIn('type', [1, 4])->whereNotIn('id', $readNotificationIds);
            })->orWhere(function ($query) use ($user_id, $readNotificationIds) {
                $query->whereNotIn('type', [1, 4])->whereNotIn('id', $readNotificationIds)->where('user_id', $user_id);
            })->orderBy('id', 'desc');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_notification);
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function read_notfication(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'notification_id' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $insert = new Read_Notification();
            $insert['user_id'] = $request['user_id'];
            $insert['notification_id'] = $request['notification_id'];
            if ($insert->save()) {
                return $this->common->API_Response(200, __('api_msg.notification_read_successfully'));
            } else {
                return $this->common->API_Response(400,  __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_content_by_category(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'category_id' => 'required|numeric',
                'content_type' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $content_type = $request['content_type'];
            $category_id = $request['category_id'];
            $user_id = $request['user_id'] ?? 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 1) {
                $data = AudioBook::where('category_id', $category_id)->where('status', 1)->orderBy('total_played', 'desc');
            } else if ($content_type == 2) {
                $data = Novel::where('category_id', $category_id)->where('status', 1)->orderBy('total_read', 'desc');
            } else if ($content_type == 3) {
                $data = Magazine::where('category_id', $category_id)->where('status', 1)->orderBy('total_read', 'desc');
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {

                if ($content_type == 1) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['id'], 0);
                        $data[$i]['full_audio'] = $this->common->getFile($this->folder_audiobook, $data[$i]['full_audio']);
                    }
                }
                if ($content_type == 2) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_chapters'] = $this->common->getTotalchapters($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['id'], 0);
                        $data[$i]['full_novel'] = $this->common->getFile($this->folder_novels, $data[$i]['full_novel']);
                    }
                }
                if ($content_type == 3) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['id'], 0);
                        $data[$i]['full_magazine'] = $this->common->getFile($this->folder_magazines, $data[$i]['full_magazine']);
                    }
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_content_by_language(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'language_id' => 'required|numeric',
                'content_type' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $content_type = $request['content_type'];
            $language_id = $request['language_id'];
            $user_id = $request['user_id'] ?? 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 1) {
                $data = AudioBook::where('language_id', $language_id)->where('status', 1)->orderBy('total_played', 'desc');
            } else if ($content_type == 2) {
                $data = Novel::where('language_id', $language_id)->where('status', 1)->orderBy('total_read', 'desc');
            } else if ($content_type == 3) {
                $data = Magazine::where('language_id', $language_id)->where('status', 1)->orderBy('total_read', 'desc');
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {

                if ($content_type == 1) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['id'], 0);
                        $data[$i]['full_audio'] = $this->common->getFile($this->folder_audiobook, $data[$i]['full_audio']);
                    }
                }
                if ($content_type == 2) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_chapters'] = $this->common->getTotalchapters($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['id'], 0);
                        $data[$i]['full_novel'] = $this->common->getFile($this->folder_novels, $data[$i]['full_novel']);
                    }
                }
                if ($content_type == 3) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['id'], 0);
                        $data[$i]['full_magazine'] = $this->common->getFile($this->folder_magazines, $data[$i]['full_magazine']);
                    }
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_content_by_author(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'author_id' => 'required|numeric',
                'content_type' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $content_type = $request['content_type'];
            $author_id = $request['author_id'];
            $user_id = $request['user_id'] ?? 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 1) {
                $data = AudioBook::where('author_id', $author_id)->where('status', 1)->orderBy('total_played', 'desc');
            } else if ($content_type == 2) {
                $data = Novel::where('author_id', $author_id)->where('status', 1)->orderBy('total_read', 'desc');
            } else if ($content_type == 3) {
                $data = Magazine::where('author_id', $author_id)->where('status', 1)->orderBy('total_read', 'desc');
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {

                if ($content_type == 1) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['id'], 0);
                        $data[$i]['full_audio'] = $this->common->getFile($this->folder_audiobook, $data[$i]['full_audio']);
                    }
                }
                if ($content_type == 2) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_chapters'] = $this->common->getTotalchapters($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['id'], 0);
                        $data[$i]['full_novel'] = $this->common->getFile($this->folder_novels, $data[$i]['full_novel']);
                    }
                }
                if ($content_type == 3) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['id'], 0);
                        $data[$i]['full_magazine'] = $this->common->getFile($this->folder_magazines, $data[$i]['full_magazine']);
                    }
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function apply_coupon(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'coupon_code' => 'required|string',
                'price' => 'required|numeric',
            ]);
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request->user_id;
            $coupon_code = $request->coupon_code;
            $price = $request->price;

            $coupon = Coupon::where('coupon_code', $coupon_code)->where('status', 1)->first();
            if (!$coupon) {
                return $this->common->API_Response(400, __('Api_msg.invalid_coupon_code'));
            }

            $today = date('Y-m-d');
            $start_date = $coupon->start_date;
            $end_date = $coupon->end_date;
            if ($today < $start_date || $today > $end_date) {
                return $this->common->API_Response(400, __('api_msg.coupon_is_not_valid_at_this_time'));
            }

            if ($coupon->is_use == 1) {
                $transaction = Content_Transaction::where('coupon_code', $coupon_code)->where('user_id', $user_id)->first();
                if ($transaction) {
                    return $this->common->API_Response(400, __('api_msg.coupon_already_used'));
                }
            } else {
                $count = Content_Transaction::where('coupon_code', $coupon_code)->count();
                if ($count >= $coupon->use_limit) {
                    return $this->common->API_Response(400, __('api_msg.coupon_limit_exceeded'));
                }
            }

            if ($coupon->amount_type == 1) {
                $final_price = $price - (($price * $coupon->price) / 100);
            } else {
                $final_price = $price - $coupon->price;
            }

            $final_price = max(0, $final_price);

            $response = [
                'coupon_id' => $coupon->id,
                'coupon_code' => $coupon->coupon_code,
                'orginal_price' => (int)$price,
                'discount_price' => (int)$final_price,
            ];

            $response = [$response];

            return $this->common->API_Response(200, __('api_msg.coupon_applied_successfully'), $response);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_tax(Request $request)
    {
        try {

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Tax::where('status', 1);

            $total_rows = $data->count();
            $total_page = 50;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function logout(Request $request)
    {
        try {
            $validate = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ]
            );
            if ($validate->fails()) {
                return $this->common->API_Response(400, $validate->errors()->first());
            }

            $user = Login_History::where('user_id', $request->user_id)->where('logout_time', '=', '')->latest()->first();
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $user->update(['logout_time' => now()->toDateTimeString()]);

            return $this->common->API_Response(200, __('api_msg.logout_successfull'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function change_transaction_state(Request $request)
    {
        try {
            $validate = Validator::make(
                $request->all(),
                [
                    'transaction_id' => 'required|numeric',
                    'status' => 'required|numeric'
                ]
            );
            if ($validate->fails()) {
                return $this->common->API_Response(400, $validate->errors()->first());
            }
            $transaction = Content_Transaction::where('id', $request->transaction_id)->where('status', 0)->first();
            if (!$transaction) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $newStatus = (int) $request->status;

            if ($newStatus === 1) {
                $this->common->confirmContentTransaction($transaction);
            } else {
                $transaction->update(['status' => $newStatus]);
            }

            return $this->common->API_Response(200, __('api_msg.transaction_update'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_content(Request $request)
    {
        try {
            $traceId = uniqid('get_content_', true);
            $content_type = $request['content_type'] ?? 0;
            $category_id = isset($request['category_id']) ? explode(',', $request['category_id']) : [];
            $author_id =  isset($request['author_id']) ? explode(',', $request['author_id']) : [];
            $language_id = isset($request['language_id']) ? explode(',', $request['language_id']) : [];
            // Normalize request filters: avoid [''] causing whereIn(..., ['']) that returns zero rows.
            $category_id = array_values(array_filter(array_map('intval', $category_id), fn ($v) => $v > 0));
            $author_id = array_values(array_filter(array_map('intval', $author_id), fn ($v) => $v > 0));
            $language_id = array_values(array_filter(array_map('intval', $language_id), fn ($v) => $v > 0));
            $user_id = $request['user_id'] ?? 0;
            Log::info('api.get_content.request', [
                'trace_id' => $traceId,
                'content_type' => $content_type,
                'user_id' => $user_id,
                'page_no' => $request->page_no ?? 1,
                'raw_category_id' => $request['category_id'] ?? null,
                'raw_author_id' => $request['author_id'] ?? null,
                'raw_language_id' => $request['language_id'] ?? null,
                'parsed_category_ids' => $category_id,
                'parsed_author_ids' => $author_id,
                'parsed_language_ids' => $language_id,
            ]);

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 1) {
                $data = AudioBook::where('status', 1)->orderBy('total_played', 'desc');
            } else if ($content_type == 2) {
                $data = Novel::where('status', 1)->orderBy('total_read', 'desc');
            } else if ($content_type == 3) {
                $data = Magazine::where('status', 1)->orderBy('total_read', 'desc');
            } else {
                Log::warning('api.get_content.invalid_content_type', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                ]);
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            if (!empty($category_id)) {
                $data->whereIn('category_id', $category_id);
            }
            if (!empty($author_id)) {
                $data->whereIn('author_id', $author_id);
            }
            if (!empty($language_id)) {
                $data->whereIn('language_id', $language_id);
            }
            Log::info('api.get_content.filters_applied', [
                'trace_id' => $traceId,
                'content_type' => $content_type,
                'category_ids' => $category_id,
                'author_ids' => $author_id,
                'language_ids' => $language_id,
            ]);

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;
            Log::info('api.get_content.counts', [
                'trace_id' => $traceId,
                'total_rows' => $total_rows,
                'page_limit' => $total_page,
                'page_size' => $page_size,
                'current_page' => $current_page,
                'offset' => $offset,
            ]);

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            Log::info('api.get_content.rows_loaded', [
                'trace_id' => $traceId,
                'loaded_count' => count($data),
                'loaded_ids' => $data->pluck('id')->values()->all(),
            ]);
            if (count($data) > 0) {

                if ($content_type == 1) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_audiobook, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_episodes'] = $this->common->getTotalEpisodes($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(1, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(1, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 1, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 1, $data[$i]['id'], 0);
                        $data[$i]['full_audio'] = $this->common->getFile($this->folder_audiobook, $data[$i]['full_audio']);
                    }
                }
                if ($content_type == 2) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_novels, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_novels, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_chapters'] = $this->common->getTotalchapters($data[$i]['id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(2, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(2, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 2, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 2, $data[$i]['id'], 0);
                        $data[$i]['full_novel'] = $this->common->getFile($this->folder_novels, $data[$i]['full_novel']);
                    }
                }
                if ($content_type == 3) {
                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_magazines, $data[$i]['landscape_img']);
                        $data[$i]['author_name'] = $this->common->GetAuthorNameById($data[$i]['author_id']);
                        $data[$i]['category_name'] = $this->common->GetCategoryNameById($data[$i]['category_id']);
                        $data[$i]['language_name'] = $this->common->GetLanguageNameById($data[$i]['language_id']);
                        $data[$i]['total_reviews'] = $this->common->getTotalReviews(3, $data[$i]['id']);
                        $data[$i]['avg_reviews'] = $this->common->getAvgReviews(3, $data[$i]['id']);
                        $data[$i]['is_bookmark'] = $this->common->isBookmarkContent($user_id, 3, $data[$i]['id']);
                        $data[$i]['is_buy'] = $this->common->isContentBuy($user_id, 3, $data[$i]['id'], 0);
                        $data[$i]['full_magazine'] = $this->common->getFile($this->folder_magazines, $data[$i]['full_magazine']);
                    }
                }
                Log::info('api.get_content.success', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'response_count' => count($data),
                    'response_ids' => $data->pluck('id')->values()->all(),
                ]);
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                Log::warning('api.get_content.no_data', [
                    'trace_id' => $traceId,
                    'content_type' => $content_type,
                    'category_ids' => $category_id,
                    'author_ids' => $author_id,
                    'language_ids' => $language_id,
                ]);
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            Log::error('api.get_content.exception', [
                'payload' => $request->all(),
                'error' => $e->getMessage(),
            ]);
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function contact_us(Request $request)
    {
        try {
            $validate = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'name' => 'required|string',
                    'email' => 'required|email',
                    'subject' => 'required|string|min:4',
                ]
            );
            if ($validate->fails()) {
                return $this->common->API_Response(400, $validate->errors()->first());
            }

            $user = User::where('id', $request->user_id)->where('status', 1)->first();
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $requestData = $request->all();

            $requestData['user_id'] = $requestData['user_id'];
            $requestData['name'] = $requestData['name'];
            $requestData['email'] = $requestData['email'];
            $requestData['subject'] = $requestData['subject'];
            $requestData['details'] = !empty($requestData['details']) ? $requestData['details'] : "";

            $contactus_id = Contact_Us::insertGetId($requestData);
            if ($contactus_id) {
                return $this->common->API_Response(200, __('api_msg.form_submit'));
            } else {
                return $this->common->API_Response(400, __('api_msg.form_not_submit'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function buy_plan(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required',
                    'plan_id' => 'required',
                    'price' => 'required',
                ]
            );
            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user = User::where('id', $request->user_id)->first();
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.user_not_found'));
            }

            $plan = Plan::where('id', $request->plan_id)->first();
            if (!$plan) {
                return $this->common->API_Response(400, __('api_msg.plan_not_found'));
            }

            $insert = new Transaction();
            $insert['coupon_code'] = $request->coupon_code ?? "";
            $insert['user_id'] = $request->user_id;
            $insert['plan_id'] = $request->plan_id;
            $insert['auto_renew'] = $plan->auto_renew ?? 0;
            $insert['price'] = $request->price;
            $insert['total_tax'] = $request->total_tax ?? 0;
            $insert['tax'] = $request->tax ?? "";
            $insert['transaction_id'] = $request->transaction_id ?? "";
            $insert['payment_method'] = $request->payment_method ?? "";

            $plan_days = $this->common->days_calculate($plan->time, $plan->type);
            $transaction = Transaction::where('user_id', $request->user_id)->whereIn('status', [1, 2])->latest()->first();
            if ($transaction) {
                if ($transaction['status'] == 2) {
                    return $this->common->API_Response(400, __('api_msg.you_already_have_an_upcoming_plan'));
                }
                $insert['status'] = 2;
                $insert['starts_at'] = date('Y-m-d H:i', strtotime($transaction['expiry_date']));
                $insert['expiry_date'] = date('Y-m-d H:i', strtotime('+' . $plan_days . ' Days', strtotime($insert['starts_at'])));
                $transaction->update(['auto_renew' => 0]);
            } else {
                $insert['status'] = 1;
                $insert['starts_at'] = date('Y-m-d H:i');
                $insert['expiry_date'] = date('Y-m-d H:i', strtotime('+' . $plan_days . ' Days', time()));
            }

            if ($insert->save()) {

                $user = User::where('id', $request->user_id)->first();
                $status = $this->common->BasicNotiConfiguration('buy-plan');
                if ($status['status'] == 1 && $status['send_mail'] == 1) {

                    $this->common->Send_Mail(11, $user['email'], 0, $plan['name'], $request->price, $user['first_name'], $user['last_name'], $insert->transaction_id, date('d M Y'));
                }
                return $this->common->API_Response(200, __('api_msg.transaction_successfully'), [$insert]);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function add_history(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required',
                    'author_id' => 'required',
                    'content_type' => 'required',
                    'content_id' => 'required',
                    'time_spend' => 'required',
                ]
            );

            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request->user_id;
            $author_id = $request->author_id;
            $content_type = $request->content_type;
            $content_id = $request->content_id;
            $time_spend = $request->time_spend;
            $sub_content_id = $request->sub_content_id ?? 0;
            $is_subscription = $request->is_subscription ?? 0;
            $last_position = $request->last_position ?? 0;
            $current_month = now()->month;
            $current_year = now()->year;

            $history = History::firstOrCreate(
                [
                    'user_id' => $user_id,
                    'author_id' => $author_id,
                    'content_type' => $content_type,
                    'content_id' => $content_id,
                    'sub_content_id' => $sub_content_id,
                    'activity_month' => $current_month,
                    'activity_year' => $current_year,
                ],
                [
                    'is_subscription' => $is_subscription,
                    'last_position' => 0,
                    'time_spend' => 0,
                    'status' => 1
                ]
            );

            $history->increment('time_spend', $time_spend);
            $history->last_position = $last_position;
            $history->save();

            return $this->common->API_Response(200, __('api_msg.data_save'), [$history]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_user_plan(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required',
                ]
            );

            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }
            $user_id = $request->user_id;
            $user = User::where('id', $user_id)->first();
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.user_not_found'));
            }

            $active_transaction = Transaction::where('user_id', $user_id)->where('status', 1)->latest()->first();

            $upcoming_transaction = Transaction::where('user_id', $user_id)->where('status', 2)->latest()->first();

            $result = [
                'active_plan' => $this->common->get_plan_from_transaction($active_transaction),
                'upcoming_plan' => $this->common->get_plan_from_transaction($upcoming_transaction),
            ];


            return $this->common->API_Response(200, __('api_msg.data_retrieved'), [$result]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_plan(Request $request)
    {
        try {

            $user_id = $request->user_id ?? 0;
            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Plan::orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();
            if (count($data) > 0) {
                $this->common->imageNameToUrl($data, 'image', $this->folder_plan);
                foreach ($data as $plan) {
                    $plan['is_buy'] = $this->common->is_plan_buy($user_id, $plan['id']);
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function get_user_plan_history(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required',
                ]
            );

            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request->user_id;
            $status = $request->status ?? "";

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Transaction::with('plan')->where('user_id', $user_id);

            if (isset($status) && $status != "") {
                $data->where('status', $status);
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data = $data->take($total_page)->offset($offset)->latest()->get();

            if (count($data) > 0) {
                foreach ($data as $transaction) {
                    if ($transaction['plan'] != null) {
                        $transaction['plan_name'] = $transaction['plan']['name'];
                        $transaction['plan_duration'] = $transaction['plan']['time'] . " " . $transaction['plan']['type'];
                    } else {
                        $transaction['plan_name'] = "";
                        $transaction['plan_duration'] = "";
                    }
                    $transaction['buy_date'] = date('Y-m-d H:i', strtotime($transaction['created_at']));
                    unset($transaction['plan']);
                }
                return $this->common->API_Response(200, __('api_msg.data_retrieved'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
    public function cancel_subscription(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'transaction_id' => 'required',
                ]
            );

            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $transaction_id = $request->transaction_id;
            $transaction = Transaction::where('id', $transaction_id)->where('auto_renew', 1)->where('status', 1)->first();
            if (!$transaction) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
            $transaction->update([
                'auto_renew' => 0,
            ]);

            return $this->common->API_Response(200, __('api_msg.subscription_cancel'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
