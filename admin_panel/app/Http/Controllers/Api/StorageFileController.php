<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class StorageFileController extends Controller
{
    /**
     * Shared-hosting fallback for serving files from storage/app/public
     * when public/storage symlink is unavailable.
     */
    public function show(string $folder, string $name): BinaryFileResponse
    {
        // Keep this list in sync with folder names used in Common.php / controllers.
        $allowedFolders = [
            'audio_books',
            'novels',
            'magazines',
            'plan',
            'user',
            'pages',
            'category',
            'language',
            'setting',
            'notification',
            'kyc_docs'
        ];

        if (!in_array($folder, $allowedFolders, true)) {
            abort(404);
        }

        $decodedName = urldecode($name);
        $path = $folder . '/' . $decodedName;
        if (!Storage::disk('public')->exists($path)) {
            abort(404);
        }

        $fullPath = storage_path('app/public/' . $path);
        $mimeType = mime_content_type($fullPath) ?: 'application/octet-stream';

        return response()->file($fullPath, [
            'Content-Type' => $mimeType,
            'Cache-Control' => 'public, max-age=3600',
        ]);
    }
}

