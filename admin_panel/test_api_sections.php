<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$common = new App\Models\Common();

echo "=== LOCAL DB TEST: Top Free Books (ContentType: 2, AccessType: 0) ===\n";
$freeBooks = $common->section_query(0, 2, 0, 0, 0, 0, 10, 2, 2);
if (is_array($freeBooks) || $freeBooks instanceof Countable) {
    foreach ($freeBooks as $b) {
        echo "ID: " . ($b->id ?? $b['id']) . " | Title: " . ($b->title ?? $b['title']) . " | AccessType: " . ($b->access_type ?? $b['access_type']) . " | Price: " . ($b->price ?? $b['price']) . "\n";
    }
} else {
    var_dump($freeBooks);
}

echo "\n=== LOCAL DB TEST: Top Paid Books (ContentType: 2, AccessType: 1) ===\n";
$paidBooks = $common->section_query(0, 2, 0, 0, 0, 1, 10, 2, 2);
if (is_array($paidBooks) || $paidBooks instanceof Countable) {
    foreach ($paidBooks as $b) {
        echo "ID: " . ($b->id ?? $b['id']) . " | Title: " . ($b->title ?? $b['title']) . " | AccessType: " . ($b->access_type ?? $b['access_type']) . " | Price: " . ($b->price ?? $b['price']) . "\n";
    }
}

echo "\n=== LOCAL DB TEST: All Books Section (ContentType: 2, AccessType: 3) ===\n";
$allBooks = $common->section_query(0, 2, 0, 0, 0, 3, 10, 2, 2);
if (is_array($allBooks) || $allBooks instanceof Countable) {
    foreach ($allBooks as $b) {
        echo "ID: " . ($b->id ?? $b['id']) . " | Title: " . ($b->title ?? $b['title']) . " | AccessType: " . ($b->access_type ?? $b['access_type']) . " | Price: " . ($b->price ?? $b['price']) . "\n";
    }
}
