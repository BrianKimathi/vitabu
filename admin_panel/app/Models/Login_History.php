<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Login_History extends Model
{
    use HasFactory;

    protected $table = 'tbl_login_history';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'login_time' => 'string',
        'logout_time' => 'integer',
    ];
}
