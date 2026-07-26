<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class History extends Model
{
    use HasFactory;

    protected $table = 'tbl_history';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'author_id' => 'integer',
        'content_type' => 'integer',
        'content_id' => 'integer',
        'sub_content_id' => 'integer',
        'is_subscription' => 'integer',
        'time_spend' => 'integer',
        'last_position' => 'integer',
        'activity_month' => 'integer',
        'activity_year' => 'integer',
        'status' => 'integer',
    ];
}
