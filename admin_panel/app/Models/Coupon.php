<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    use HasFactory;

    protected $table = 'tbl_coupon';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'coupon_code' => 'string',
        'name'=>'string',
        'amount_type'=>'integer',
        'amount'=>'string',
        'use_limit' => 'integer',
        'is_use'=>'integer',
        'start_date' => 'string',
        'end_date' => 'string',
        'status' => 'integer',
    ];
}
