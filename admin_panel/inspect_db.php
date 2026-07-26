<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "--- CONTENT SECTIONS ---\n";
$sections = App\Models\Content_Section::where('status', 1)->get();
foreach ($sections as $s) {
    echo "ID: {$s->id} | Title: {$s->title} | SectionType: {$s->section_type} | ContentType: {$s->content_type} | AccessType: {$s->access_type} | ScreenLayout: {$s->screen_layout}\n";
}

echo "\n--- NOVELS (BOOKS) ---\n";
$novels = App\Models\Novel::where('status', 1)->get();
foreach ($novels as $n) {
    echo "ID: {$n->id} | Title: {$n->title} | AccessType: {$n->access_type} | Price: {$n->price}\n";
}

echo "\n--- MAGAZINES ---\n";
$magazines = App\Models\Magazine::where('status', 1)->get();
foreach ($magazines as $m) {
    echo "ID: {$m->id} | Title: {$m->title} | AccessType: {$m->access_type} | Price: {$m->price}\n";
}
