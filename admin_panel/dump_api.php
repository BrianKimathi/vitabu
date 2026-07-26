<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "--- DUMPING GET_SECTION_LIST API OUTPUT ---\n";
$controller = new App\Http\Controllers\Api\HomeController();
$request = new Illuminate\Http\Request();
$request->replace(['section_type' => 0]);
$res = $controller->get_section_list($request);
echo json_encode($res, JSON_PRETTY_PRINT);
