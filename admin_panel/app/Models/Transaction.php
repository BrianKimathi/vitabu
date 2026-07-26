<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $table = 'tbl_transaction';

    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'coupon_code' => 'string',
        'user_id' => 'integer',
        'plan_id' => 'integer',
        'auto_renew' => 'integer',
        'transaction_id' => 'string',
        'price' => 'integer',
        'payment_method' => 'string',
        'starts_at' => 'string',
        'expiry_date' => 'string',
        'status' => 'integer',
    ];
    public function plan()
    {
        return $this->belongsTo(Plan::class, 'plan_id');
    }
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
