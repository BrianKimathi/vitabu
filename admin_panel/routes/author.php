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

use App\Http\Controllers\Author\SubscriptionPayoutController;
use App\Http\Controllers\Author\AudioBooksController;
use App\Http\Controllers\Author\CategoryController;
use App\Http\Controllers\Author\DashboardController;
use App\Http\Controllers\Author\LanguageController;
use App\Http\Controllers\Author\LoginController;
use App\Http\Controllers\Author\MagazinesController;
use App\Http\Controllers\Author\NovelsController;
use App\Http\Controllers\Author\ProfileController;
use App\Http\Controllers\Author\ReviewsController;
use App\Http\Controllers\Author\SalesAudioBooksController;
use App\Http\Controllers\Author\SalesMagazinesController;
use App\Http\Controllers\Author\SalesNovelsController;
use App\Http\Controllers\Author\WithdrawalController;
use Illuminate\Support\Facades\Route;

Route::group(['middleware' => 'installation'], function () {

    // Login-Logout
    Route::get('login', [LoginController::class, 'login'])->name('author.login');
    Route::post('login', [LoginController::class, 'save_login'])->name('author.save.login');
    Route::get('logout', [LoginController::class, 'logout'])->name('author.logout');

    // Author forgot password (email-based).
    Route::get('forgot-password', [LoginController::class, 'forgot_password'])->name('author.forgot.password');
    Route::post('forgot-password', [LoginController::class, 'send_forgot_password'])->name('author.send.forgot.password');

    Route::group(['middleware' => 'authauthor', 'as' => 'author.'], function () {

        // Dashboard
        Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');
        // Profile
        Route::resource('profile', ProfileController::class)->only(['index', 'store']);
        Route::post('profile/changepassword', [ProfileController::class, 'ChangePassword'])->name('profile.changepassword');
        // Category
        Route::resource('category', CategoryController::class)->only(['index']);
        // Language
        Route::resource('language', LanguageController::class)->only(['index']);
        // Novels
        Route::resource('novels', NovelsController::class)->only(['index', 'create', 'store', 'edit', 'update']);
        Route::get('novels/chapters/{id}', [NovelsController::class, 'ChapterIndex'])->name('novels.chapters.index');
        Route::get('novels/chapters/add/{id}', [NovelsController::class, 'ChapterAdd'])->name('novels.chapters.add');
        Route::post('novels/chapters/save', [NovelsController::class, 'ChapterSave'])->name('novels.chapters.save');
        Route::get('novels/chapters/edit/{novel_id}/{chapter_id}', [NovelsController::class, 'ChapterEdit'])->name('novels.chapters.edit');
        Route::post('novels/chapters/update/{id}', [NovelsController::class, 'ChapterUpdate'])->name('novels.chapters.update');
        Route::post('novels/chapters/sortorder', [NovelsController::class, 'ChapterSortOrder'])->name('novels.chapters.sortorder');
        // Magazines
        Route::resource('magazines', MagazinesController::class)->only(['index', 'create', 'store', 'edit', 'update', 'destroy']);
        // Audio Books
        Route::resource('audiobooks', AudioBooksController::class)->only(['index', 'create', 'store', 'edit', 'update', 'destroy']);
        Route::get('audiobooks/episodes/{id}', [AudioBooksController::class, 'EpisodesIndex'])->name('audiobooks.episodes.index');
        Route::get('audiobooks/episodes/add/{id}', [AudioBooksController::class, 'EpisodesAdd'])->name('audiobooks.episodes.add');
        Route::post('audiobooks/episodes/save', [AudioBooksController::class, 'EpisodesSave'])->name('audiobooks.episodes.save');
        Route::get('audiobooks/episodes/edit/{audiobook_id}/{episode_id}', [AudioBooksController::class, 'EpisodesEdit'])->name('audiobooks.episodes.edit');
        Route::post('audiobooks/episodes/update/{id}', [AudioBooksController::class, 'EpisodesUpdate'])->name('audiobooks.episodes.update');
        Route::get('audiobooks/episodes/delete/{audiobook_id}/{episode_id}', [AudioBooksController::class, 'EpisodesDelete'])->name('audiobooks.episodes.delete');
        Route::post('audiobooks/episodes/sortorder', [AudioBooksController::class, 'EpisodesSortOrder'])->name('audiobooks.episodes.sortorder');
        // Reviews
        Route::resource('reviews', ReviewsController::class)->only(['index']);
        // Novels Sales Report
        Route::resource('salesnovels', SalesNovelsController::class)->only(['index']);
        // Magazines Sales Report
        Route::resource('salesmagazines', SalesMagazinesController::class)->only(['index']);
        // Audio Books Sales Report
        Route::resource('salesaudiobooks', SalesAudioBooksController::class)->only(['index']);
        // Payout History
        Route::resource('subscription_payout', SubscriptionPayoutController::class)->only(['index']);

        // Hidden
        // Withdrawal
        Route::resource('withdrawal', WithdrawalController::class)->only(['index', 'store']);
        Route::post('withdrawal/payout-details/update', [WithdrawalController::class, 'updatePayoutDetails'])->name('withdrawal.payout.update');

        Route::group(['middleware' => 'checkadmin'], function () {
            // Novels
            Route::resource('novels', NovelsController::class)->only(['destroy']);
            Route::get('novels/chapters/delete/{novel_id}/{chapter_id}', [NovelsController::class, 'ChapterDelete'])->name('novels.chapters.delete');
            // Magazines
            Route::resource('magazines', MagazinesController::class)->only(['destroy']);
            // Audio Books
            Route::resource('audiobooks', AudioBooksController::class)->only(['destroy']);
            Route::get('audiobooks/episodes/delete/{audiobook_id}/{episode_id}', [AudioBooksController::class, 'EpisodesDelete'])->name('audiobooks.episodes.delete');
        });
    });
});
