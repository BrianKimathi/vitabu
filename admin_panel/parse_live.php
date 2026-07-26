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
    $json = json_decode((string)$res->getBody(), true);
    
    echo "=== LIVE BACKEND RETURNED SECTIONS ===\n\n";
    foreach ($json['result'] as $sec) {
        echo "SECTION ID: {$sec['id']} | Title: '{$sec['title']}' | AccessType setting: {$sec['access_type']}\n";
        if (isset($sec['data']) && is_array($sec['data'])) {
            foreach ($sec['data'] as $item) {
                echo "   -> BOOK ID: {$item['id']} | Title: '{$item['title']}' | Item AccessType: {$item['access_type']} | Price: {$item['price']}\n";
            }
        }
        echo "--------------------------------------------------------\n";
    }
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
