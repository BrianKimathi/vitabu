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

use App\Http\Controllers\Admin\PageController;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Route;

// Artisan
Route::get('clearcache', function () {

    Artisan::call('config:clear');
    Artisan::call('config:cache');
    Artisan::call('cache:clear');
    Artisan::call('view:clear');
    Artisan::call('route:clear');
    return "<h1>All Config Cache Clear Successfully.</h1>";
});
// Version
Route::get('version', function () {
    return "<h1>
        <li>PHP : " . phpversion() . "</li>
        <li>Laravel : " . app()->version() . "</li>
    </h1>";
});

// Open Graph Social Media Link Sharing Preview with Image Metadata
Route::get('share', function (\Illuminate\Http\Request $request) {
    $contentType = $request->query('content_type', '2');
    $contentId = $request->query('content_id');
    $name = urldecode($request->query('name', 'Vitabu Book'));
    $imageUrl = urldecode($request->query('image', ''));

    $redirectUrl = "https://vitabu.online/?content_type={$contentType}&content_id={$contentId}&name=" . urlencode($name);

    if (empty($imageUrl)) {
        if ($contentType == '1') {
            $item = \App\Models\Audio_Book::find($contentId);
            $imageUrl = $item ? $item->portrait_img : '';
        } elseif ($contentType == '3') {
            $item = \App\Models\Magazine::find($contentId);
            $imageUrl = $item ? $item->portrait_img : '';
        } else {
            $item = \App\Models\Book::find($contentId);
            $imageUrl = $item ? $item->portrait_img : '';
        }
    }

    if (!empty($imageUrl) && !str_starts_with($imageUrl, 'http')) {
        $imageUrl = "https://console.vitabu.online/public/images/" . ltrim($imageUrl, '/');
    }

    $title = htmlspecialchars($name, ENT_QUOTES, 'UTF-8');
    $description = "Read or listen to {$title} on Vitabu — Your World of Books & Magazines.";
    $imageUrl = htmlspecialchars($imageUrl, ENT_QUOTES, 'UTF-8');

    return response("<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <title>{$title} - Vitabu</title>
    <!-- Open Graph / WhatsApp / Facebook Meta Tags -->
    <meta property=\"og:type\" content=\"book\" />
    <meta property=\"og:site_name\" content=\"Vitabu\" />
    <meta property=\"og:title\" content=\"{$title}\" />
    <meta property=\"og:description\" content=\"{$description}\" />
    <meta property=\"og:image\" content=\"{$imageUrl}\" />
    <meta property=\"og:image:width\" content=\"600\" />
    <meta property=\"og:image:height\" content=\"800\" />
    <meta property=\"og:url\" content=\"{$redirectUrl}\" />

    <!-- Twitter Card Meta Tags -->
    <meta name=\"twitter:card\" content=\"summary_large_image\" />
    <meta name=\"twitter:title\" content=\"{$title}\" />
    <meta name=\"twitter:description\" content=\"{$description}\" />
    <meta name=\"twitter:image\" content=\"{$imageUrl}\" />

    <meta http-equiv=\"refresh\" content=\"0;url={$redirectUrl}\" />
</head>
<body>
    <p>Redirecting to <a href=\"{$redirectUrl}\">{$title}</a>...</p>
    <script>window.location.href = \"{$redirectUrl}\";</script>
</body>
</html>", 200, ['Content-Type' => 'text/html']);
});

// Page
Route::group(['middleware' => 'installation'], function () {
    Route::get('pages/{page_name}', [PageController::class, 'page_view'])->name('page.view');

    Route::get('/lang/{locale}', function ($locale) {
        if (in_array($locale, ['en', 'hi', 'fr'])) {
            session(['locale' => $locale]);
            App::setLocale($locale);
        }
        return redirect()->back();
    })->name('change.language');
});
