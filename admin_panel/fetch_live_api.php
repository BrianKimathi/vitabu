<?php
require 'vendor/autoload.php';

$client = new GuzzleHttp\Client();
try {
    $res = $client->post('https://console.vitabu.online/api/get_section_list', [
        'form_params' => [
            'section_type' => 0,
            'user_id' => 0
        ]
    ]);
    echo $res->getBody();
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
