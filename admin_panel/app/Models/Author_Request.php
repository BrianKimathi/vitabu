<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Author_Request extends Model
{
    use HasFactory;

    protected $table = 'tbl_author_request';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'role' => 'string',
        'payment_method' => 'string',
        'bank_name' => 'string',
        'bank_code' => 'string',
        'bank_holder_name' => 'string',
        'account_no' => 'string',
        'ifsc_code' => 'string',
        'mpesa_phone' => 'string',
        'subaccount_code' => 'string',
        'status' => 'integer',
        'id_front' => 'string',
        'id_back' => 'string',
        'selfie' => 'string',
        'otp_code' => 'string',
        'otp_expiry' => 'datetime',
        'is_otp_verified' => 'integer',
        'otp_email' => 'string',
        'otp_phone' => 'string',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
