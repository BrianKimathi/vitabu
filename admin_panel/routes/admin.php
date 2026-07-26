<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

use App\Http\Controllers\Admin\AdmobSettingController;
use App\Http\Controllers\Admin\AppSettingController;
use App\Http\Controllers\Admin\AudioBooksController;
use App\Http\Controllers\Admin\AudioBookSectionController;
use App\Http\Controllers\Admin\AudioBooksRequestController;
use App\Http\Controllers\Admin\AuthorController;
use App\Http\Controllers\Admin\SubscriptionPayoutController;
use App\Http\Controllers\Admin\AuthorRequestController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\ContactUsController;
use App\Http\Controllers\Admin\CouponController;
use App\Http\Controllers\Admin\CustomerReportController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\FaceBookAdsSettingController;
use App\Http\Controllers\Admin\FinanceReportController;
use App\Http\Controllers\Admin\HomeSectionController;
use App\Http\Controllers\Admin\LanguageController;
use App\Http\Controllers\Admin\LoginController;
use App\Http\Controllers\Admin\MagazinesController;
use App\Http\Controllers\Admin\MagazinesRequestController;
use App\Http\Controllers\Admin\MagazinesSectionController;
use App\Http\Controllers\Admin\NotificationConfigurationsController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\NovelsController;
use App\Http\Controllers\Admin\NovelSectionController;
use App\Http\Controllers\Admin\NovelsRequestController;
use App\Http\Controllers\Admin\PlanController;
use App\Http\Controllers\Admin\PageController;
use App\Http\Controllers\Admin\PanelSettingController;
use App\Http\Controllers\Admin\PaymentController;
use App\Http\Controllers\Admin\ProfileController;
use App\Http\Controllers\Admin\ReviewsController;
use App\Http\Controllers\Admin\SalesAudioBooksController;
use App\Http\Controllers\Admin\SalesMagazinesController;
use App\Http\Controllers\Admin\SalesNovelsController;
use App\Http\Controllers\Admin\SalesReportController;
use App\Http\Controllers\Admin\SystemSettingController;
use App\Http\Controllers\Admin\TaxController;
use App\Http\Controllers\Admin\TransactionController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\SubAdminController;
use App\Http\Controllers\Admin\WithdrawalController;
use Illuminate\Support\Facades\Route;

Route::group(['middleware' => 'installation'], function () {

    // Login-Logout
    Route::get('login', [LoginController::class, 'login'])->name('admin.login');
    Route::post('login', [LoginController::class, 'save_login'])->name('admin.save.login');
    Route::get('logout', [LoginController::class, 'logout'])->name('admin.logout');

    // Chunk
    Route::any('novels/savechunk', [NovelsController::class, 'saveChunkFullNovel']);
    Route::any('novels/chapters/savechunk', [NovelsController::class, 'saveChunkChapter']);
    Route::any('magazines/savechunk', [MagazinesController::class, 'saveChunkMagazines']);
    Route::any('audiobooks/savechunk', [AudioBooksController::class, 'saveChunkFullAudio']);
    Route::any('audiobooks/episode/savechunk', [AudioBooksController::class, 'saveChunkEpisode']);

    Route::group(['middleware' => ['authadmin', 'adminrole'], 'as' => 'admin.'], function () {

        // Dashboard
        Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');
        // Sales Report
        Route::resource('salesreport', SalesReportController::class)->only(['index']);
        Route::get('salesreport/get_novel', [SalesReportController::class, 'get_novel'])->name('salesreport.get_novel');
        Route::get('salesreport/get_audiobook', [SalesReportController::class, 'get_audiobook'])->name('salesreport.get_audiobook');
        Route::get('salesreport/get_magazine', [SalesReportController::class, 'get_magazine'])->name('salesreport.get_magazine');
        // Finance Report 
        Route::resource('financereport', FinanceReportController::class)->only(['index']);
        Route::get('financereport/get_withdrawels', [FinanceReportController::class, 'get_withdrawels'])->name('financereport.get_withdrawels');
        // Customer Report 
        Route::resource('customerreport', CustomerReportController::class)->only(['index']);
        Route::get('customerreport/get_user_transactions', [CustomerReportController::class, 'get_user_transactions'])->name('customerreport.get_user_transactions');
        Route::get('customerreport/get_authors', [CustomerReportController::class, 'get_authors'])->name('customerreport.get_authors');
        // Profile
        Route::resource('profile', ProfileController::class)->only(['index', 'store']);
        Route::post('profile/changepassword', [ProfileController::class, 'ChangePassword'])->name('profile.changepassword');
        // Category
        Route::resource('category', CategoryController::class)->only(['index', 'store', 'update', 'show']);
        Route::post('category/sortorder/save', [CategoryController::class, 'CategorySortOrderSave'])->name('category.sortorder.save');
        // Language
        Route::resource('language', LanguageController::class)->only(['index', 'store', 'update', 'show']);
        Route::post('language/sortorder/save', [LanguageController::class, 'LanguageSortOrderSave'])->name('language.sortorder.save');
        // User
        Route::resource('user', UserController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        // Sub Admin
        Route::resource('subadmin', SubAdminController::class);
        // Author Request
        Route::resource('authorrequest', AuthorRequestController::class)->only(['index', 'show']);
        Route::get('authorrequest/detail/{id}', [AuthorRequestController::class, 'detail'])->name('authorrequest.detail');
        // Author
        Route::resource('author', AuthorController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        // Home Section
        Route::resource('homesection', HomeSectionController::class)->only(['index', 'store', 'edit', 'update', 'show']);
        Route::post('homesection/status', [HomeSectionController::class, 'changeStatus'])->name('homesection.status');
        Route::post('homesection/sortable', [HomeSectionController::class, 'SortableSave'])->name('homesection.sortable');
        // Novels
        Route::resource('novels', NovelsController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        Route::get('novels/chapters/{id}', [NovelsController::class, 'ChapterIndex'])->name('novels.chapters.index');
        Route::get('novels/chapters/add/{id}', [NovelsController::class, 'ChapterAdd'])->name('novels.chapters.add');
        Route::post('novels/chapters/save', [NovelsController::class, 'ChapterSave'])->name('novels.chapters.save');
        Route::get('novels/chapters/edit/{novel_id}/{chapter_id}', [NovelsController::class, 'ChapterEdit'])->name('novels.chapters.edit');
        Route::post('novels/chapters/update/{id}', [NovelsController::class, 'ChapterUpdate'])->name('novels.chapters.update');
        Route::post('novels/chapters/sortorder', [NovelsController::class, 'ChapterSortOrder'])->name('novels.chapters.sortorder');
        // Novel Section
        Route::resource('novelsection', NovelSectionController::class)->only(['index', 'store', 'edit', 'update', 'show']);
        Route::post('novelsection/status', [NovelSectionController::class, 'changeStatus'])->name('novelsection.status');
        Route::post('novelsection/sortable', [NovelSectionController::class, 'SortableSave'])->name('novelsection.sortable');
        //Novel Request 
        Route::resource('novels_request', NovelsRequestController::class)->only(['index', 'show']);
        //Magazines Request 
        Route::resource('magazines_request', MagazinesRequestController::class)->only(['index', 'show']);
        //Audio Book Request 
        Route::resource('audio_books_request', AudioBooksRequestController::class)->only(['index', 'show']);
        // Magazines
        Route::resource('magazines', MagazinesController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        // Magazines Section
        Route::resource('magazinessection', MagazinesSectionController::class)->only(['index', 'store', 'edit', 'update', 'show']);
        Route::post('magazinessection/status', [MagazinesSectionController::class, 'changeStatus'])->name('magazinessection.status');
        Route::post('magazinessection/sortable', [MagazinesSectionController::class, 'SortableSave'])->name('magazinessection.sortable');
        // Audio Books
        Route::resource('audiobooks', AudioBooksController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        Route::get('audiobooks/episodes/{id}', [AudioBooksController::class, 'EpisodesIndex'])->name('audiobooks.episodes.index');
        Route::get('audiobooks/episodes/add/{id}', [AudioBooksController::class, 'EpisodesAdd'])->name('audiobooks.episodes.add');
        Route::post('audiobooks/episodes/save', [AudioBooksController::class, 'EpisodesSave'])->name('audiobooks.episodes.save');
        Route::get('audiobooks/episodes/edit/{audiobook_id}/{episode_id}', [AudioBooksController::class, 'EpisodesEdit'])->name('audiobooks.episodes.edit');
        Route::post('audiobooks/episodes/update/{id}', [AudioBooksController::class, 'EpisodesUpdate'])->name('audiobooks.episodes.update');
        Route::post('audiobooks/episodes/sortorder', [AudioBooksController::class, 'EpisodesSortOrder'])->name('audiobooks.episodes.sortorder');
        // Audio Books Section
        Route::resource('audiobooksection', AudioBookSectionController::class)->only(['index', 'store', 'edit', 'update', 'show']);
        Route::post('audiobooksection/status', [AudioBookSectionController::class, 'changeStatus'])->name('audiobooksection.status');
        Route::post('audiobooksection/sortable', [AudioBookSectionController::class, 'SortableSave'])->name('audiobooksection.sortable');
        // Reviews
        Route::resource('reviews', ReviewsController::class)->only(['index', 'show']);
        // Notification
        Route::resource('notification', NotificationController::class)->only(['index', 'create', 'store']);
        // Coupon
        Route::resource('coupon', CouponController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        // Tax
        Route::resource('tax', TaxController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        // App Setting
        Route::get('appsetting', [AppSettingController::class, 'index'])->name('appsetting.index');
        Route::post('appsetting/app', [AppSettingController::class, 'app'])->name('appsetting.app');
        Route::post('appsetting/currency', [AppSettingController::class, 'currency'])->name('appsetting.currency');
        Route::post('appsetting/screenshot', [AppSettingController::class, 'screenshot'])->name('appsetting.screenshot');
        Route::post('appsetting/vap_id_key', [AppSettingController::class, 'vap_id_key'])->name('appsetting.vap_id_key');
        Route::post('appsetting/reading_time', [AppSettingController::class, 'reading_time'])->name('appsetting.reading_time');
        Route::post('appsetting/smtp', [AppSettingController::class, 'smtp'])->name('appsetting.smtp');
        Route::post('appsetting/testsmtp', [AppSettingController::class, 'testsmtp'])->name('appsetting.testsmtp');
        Route::post('appsetting/commission', [AppSettingController::class, 'commission'])->name('appsetting.commission');
        Route::post('appsetting/sociallink', [AppSettingController::class, 'sociallink'])->name('appsetting.sociallink');
        Route::post('appsetting/onboardingscreen', [AppSettingController::class, 'onboardingscreen'])->name('appsetting.onboardingscreen');
        // Pages
        Route::resource('pages', PageController::class)->only(['index', 'create', 'store', 'edit', 'update', 'show']);
        Route::post('pages/layout', [PageController::class, 'layout'])->name('pages.layout');
        // Payment
        Route::resource('payment', PaymentController::class)->only(['index']);
        // Panel Setting
        Route::get('panelsetting', [PanelSettingController::class, 'index'])->name('panelsetting.index');
        Route::post('panelsetting/save', [PanelSettingController::class, 'save'])->name('panelsetting.save');
        // Admob
        Route::resource('admob', AdmobSettingController::class)->only(['index']);
        Route::post('admob/status', [AdmobSettingController::class, 'admobStatus'])->name('admob.status');
        Route::post('admob/android', [AdmobSettingController::class, 'admobAndroid'])->name('admob.android');
        Route::post('admob/ios', [AdmobSettingController::class, 'admobIos'])->name('admob.ios');
        // FaceBook Ads
        Route::resource('fbads', FaceBookAdsSettingController::class)->only(['index']);
        Route::post('fbads/status', [FaceBookAdsSettingController::class, 'facebookadStatus'])->name('fbads.status');
        Route::post('fbads/android', [FaceBookAdsSettingController::class, 'facebookadAndroid'])->name('fbads.android');
        Route::post('fbads/ios', [FaceBookAdsSettingController::class, 'facebookadIos'])->name('fbads.ios');
        // System Setting
        Route::get('systemsetting', [SystemSettingController::class, 'index'])->name('system.setting.index');
        Route::post('systemsetting/cleardata', [SystemSettingController::class, 'ClearData'])->name('system.setting.cleardata');
        Route::post('systemsetting/cleandatabase', [SystemSettingController::class, 'CleanDatabase'])->name('system.setting.cleandatabase');
        // Notification Configurations
        Route::resource('notificationconfigurations', NotificationConfigurationsController::class)->only(['index', 'store']);
        // Novels Sales Report
        Route::resource('salesnovels', SalesNovelsController::class)->only(['index', 'create', 'store']);
        Route::post('salesnovels/get_novel', [SalesNovelsController::class, 'get_novel'])->name('salesnovels.get_novel');
        Route::post('salesnovels/get_episode', [SalesNovelsController::class, 'get_episode'])->name('salesnovels.get_episode');
        // Magazines Sales Report
        Route::resource('salesmagazines', SalesMagazinesController::class)->only(['index', 'create', 'store']);
        Route::post('salesmagazines/get_magazine', [SalesMagazinesController::class, 'get_magazine'])->name('salesmagazines.get_magazine');
        // Audio Books Sales Report
        Route::resource('salesaudiobooks', SalesAudioBooksController::class)->only(['index', 'create', 'store']);
        Route::post('salesaudiobooks/get_audiobook', [SalesAudioBooksController::class, 'get_audiobook'])->name('salesaudiobooks.get_audiobook');
        Route::post('salesaudiobooks/get_episode', [SalesAudioBooksController::class, 'get_episode'])->name('salesaudiobooks.get_episode');
        // Contact Us
        Route::resource('contact_us', ContactUsController::class)->only(['index']);
        //Plan
        Route::resource('plan', PlanController::class)->only(['index', 'create', 'store', 'edit', 'update']);
        Route::post('plan/status', [PlanController::class, 'change_status'])->name('plan.change.status');
        //Transaction
        Route::resource('transaction', TransactionController::class)->only(['index', 'create', 'store', 'edit', 'update']);
        // Author Payout
        Route::resource('subscription_payout', SubscriptionPayoutController::class)->only(['index', 'show']);

        // Hidden
        // Withdrawal
        Route::resource('withdrawal', WithdrawalController::class)->only(['index', 'show']);

        Route::group(['middleware' => 'checkadmin'], function () {

            // Category
            Route::resource('category', CategoryController::class)->only(['destroy']);
            // Language
            Route::resource('language', LanguageController::class)->only(['destroy']);
            // User
            Route::resource('user', UserController::class)->only(['destroy']);
            // Author
            Route::resource('author', AuthorController::class)->only(['destroy']);
            // Novels
            Route::resource('novels', NovelsController::class)->only(['destroy']);
            Route::get('novels/chapters/delete/{novel_id}/{chapter_id}', [NovelsController::class, 'ChapterDelete'])->name('novels.chapters.delete');
            // Magazines
            Route::resource('magazines', MagazinesController::class)->only(['destroy']);
            // Audio Books
            Route::resource('audiobooks', AudioBooksController::class)->only(['destroy']);
            Route::get('audiobooks/episodes/delete/{audiobook_id}/{episode_id}', [AudioBooksController::class, 'EpisodesDelete'])->name('audiobooks.episodes.delete');
            // Reviews
            Route::resource('reviews', ReviewsController::class)->only(['destroy']);
            // Notification
            Route::resource('notification', NotificationController::class)->only(['destroy']);
            Route::get('notification/setting', [NotificationController::class, 'setting'])->name('notification.setting');
            Route::post('notification/setting', [NotificationController::class, 'settingsave'])->name('notification.setting.save');
            // Pages
            Route::resource('pages', PageController::class)->only(['destroy']);
            // Payment
            Route::resource('payment', PaymentController::class)->only(['edit', 'update']);
            // System Setting
            Route::get('systemsetting/downloaddb', [SystemSettingController::class, 'DownloadDB'])->name('system.setting.downloaddb');
            // Novels Sales Report
            Route::resource('salesnovels', SalesNovelsController::class)->only(['destroy']);
            // Magazines Sales Report
            Route::resource('salesmagazines', SalesMagazinesController::class)->only(['destroy']);
            // Audio Books Sales Report
            Route::resource('salesaudiobooks', SalesAudioBooksController::class)->only(['destroy']);
            // Coupon
            Route::resource('coupon', CouponController::class)->only(['destroy']);
            // Tax
            Route::resource('tax', TaxController::class)->only(['destroy']);
            // Contact Us
            Route::resource('contact_us', ContactUsController::class)->only(['destroy']);
            // Plan
            Route::resource('plan', PlanController::class)->only(['destroy']);
            // Transaction
            Route::resource('transaction', TransactionController::class)->only(['destroy']);
            // Autho Payout
            Route::resource('subscription_payout', SubscriptionPayoutController::class)->only(['destroy']);
        });
    });
});

