<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Content_Section extends Model
{
    use HasFactory;

    protected $table = 'tbl_content_section';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'section_type' => 'integer',
        'content_type' => 'integer',
        'title' => 'string',
        'short_title' => 'string',
        'screen_layout' => 'string',
        'author_id' => 'integer',
        'category_id' => 'integer',
        'language_id' => 'integer',
        'access_type' => 'integer',
        'order_by_view' => 'integer',
        'order_by_upload' => 'integer',
        'no_of_content' => 'integer',
        'view_all' => 'integer',
        'sort_order' => 'integer',
        'status' => 'integer',
    ];
}
