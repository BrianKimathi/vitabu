<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "--- ALL NOVELS IN DB ---\n";
$novels = App\Models\Novel::all();
foreach ($novels as $n) {
    echo "ID: {$n->id} | Title: {$n->title} | Status: {$n->status} | AccessType: '{$n->access_type}' (type: " . gettype($n->access_type) . ") | Price: {$n->price}\n";
}

echo "\n--- ALL MAGAZINES IN DB ---\n";
$mags = App\Models\Magazine::all();
foreach ($mags as $m) {
    echo "ID: {$m->id} | Title: {$m->title} | Status: {$m->status} | AccessType: '{$m->access_type}' (type: " . gettype($m->access_type) . ") | Price: {$m->price}\n";
}

echo "\n--- ALL SECTIONS IN DB ---\n";
$sections = App\Models\Content_Section::all();
foreach ($sections as $s) {
    echo "ID: {$s->id} | Title: '{$s->title}' | SectionType: {$s->section_type} | ContentType: {$s->content_type} | AccessType: '{$s->access_type}' (type: " . gettype($s->access_type) . ")\n";
}
