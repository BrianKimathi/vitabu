<?php

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\StorageFileController;
use App\Http\Controllers\Api\PaystackWebhookController;

// Public file-serving fallback for shared hosting without public/storage symlink.
Route::get('storage-file/{folder}/{name}', [StorageFileController::class, 'show'])
    ->where('name', '.*');

// Webhook for Paystack
Route::post('paystack/webhook', [PaystackWebhookController::class, 'handleWebhook']);

Route::group(['middleware' => 'apipurchasecode'], function () {

    // ---------------- UsersController ----------------
    Route::post('register', [UserController::class, 'register']);
    Route::post('login', [UserController::class, 'login']);
    Route::post('get_profile', [UserController::class, 'get_profile']);
    Route::post('update_profile', [UserController::class, 'update_profile']);
    Route::post('add_become_author_request', [UserController::class, 'add_become_author_request']);
    Route::post('get_paystack_banks', [UserController::class, 'get_paystack_banks']);
    Route::post('send_otp_sms', [UserController::class, 'send_otp_sms']);
    Route::post('get_author_list', [UserController::class, 'get_author_list']);
    Route::post('forgot_password', [UserController::class, 'forgot_password']);

    // ---------------- HomeController ------------------
    Route::post('general_setting', [HomeController::class, 'general_setting']);
    Route::post('get_payment_option', [HomeController::class, 'get_payment_option']);
    Route::post('get_onboarding_screen', [HomeController::class, 'get_onboarding_screen']);
    Route::post('get_social_link', [HomeController::class, 'get_social_link']);
    Route::post('get_pages', [HomeController::class, 'get_pages']);
    Route::post('get_category', [HomeController::class, 'get_category']);
    Route::post('get_language', [HomeController::class, 'get_language']);
    Route::post('get_section_list', [HomeController::class, 'get_section_list']);
    Route::post('get_section_detail', [HomeController::class, 'get_section_detail']);
    Route::post('get_content_detail', [HomeController::class, 'get_content_detail']);
    Route::post('get_episode_by_audiobook', [HomeController::class, 'get_episode_by_audiobook']);
    Route::post('get_chapter_by_novel', [HomeController::class, 'get_chapter_by_novel']);
    Route::post('get_releted_content', [HomeController::class, 'get_releted_content']);
    Route::post('add_review', [HomeController::class, 'add_review']);
    Route::post('delete_review', [HomeController::class, 'delete_review']);
    Route::post('get_review', [HomeController::class, 'get_review']);
    Route::post('add_content_view', [HomeController::class, 'add_content_view']);
    Route::post('add_remove_bookmark', [HomeController::class, 'add_remove_bookmark']);
    Route::post('get_bookmark_content', [HomeController::class, 'get_bookmark_content']);
    Route::post('search_content', [HomeController::class, 'search_content']);
    Route::post('add_transaction', [HomeController::class, 'add_transaction']);
    Route::post('get_transaction_history', [HomeController::class, 'get_transaction_history']);
    Route::post('get_notification', [HomeController::class, 'get_notification']);
    Route::post('read_notfication', [HomeController::class, 'read_notfication']);
    Route::post('get_content_by_category', [HomeController::class, 'get_content_by_category']);
    Route::post('get_content_by_language', [HomeController::class, 'get_content_by_language']);
    Route::post('get_content_by_author', [HomeController::class, 'get_content_by_author']);
    Route::post('apply_coupon', [HomeController::class, 'apply_coupon']);
    Route::post('get_tax', [HomeController::class, 'get_tax']);
    Route::post('logout', [HomeController::class, 'logout']);
    Route::post('change_transaction_state', [HomeController::class, 'change_transaction_state']);
    Route::post('get_content', [HomeController::class, 'get_content']);
    Route::post('contact_us', [HomeController::class, 'contact_us']);
    Route::post('buy_plan', [HomeController::class, 'buy_plan']);
    Route::post('add_history', [HomeController::class, 'add_history']);
    Route::post('get_user_plan', [HomeController::class, 'get_user_plan']);
    Route::post('get_plan', [HomeController::class, 'get_plan']);
    Route::post('get_user_plan_history', [HomeController::class, 'get_user_plan_history']);
    Route::post('cancel_subscription', [HomeController::class, 'cancel_subscription']);

    // ---- Author OTP Verification ----
    Route::post('send_author_otp', [UserController::class, 'send_author_otp']);
    Route::post('verify_author_otp', [UserController::class, 'verify_author_otp']);
});
