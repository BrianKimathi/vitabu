<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasFactory;

    protected $table = 'tbl_user';
    protected $guarded = array();

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'id' => 'integer',
        'is_author' => 'integer',
        'is_publisher' => 'integer',
        'category_ids' => 'string',
        'user_name' => 'string',
        'first_name' => 'string',
        'last_name' => 'string',
        'email' => 'string',
        'password' => 'string',
        'mobile_number' => 'string',
        'image' => 'string',
        'type' => 'integer',
        'address' => 'string',
        'description' => 'string',
        'wallet_amount' => 'decimal:2',
        'bank_name' => 'string',
        'bank_code' => 'string',
        'bank_holder_name' => 'string',
        'account_no' => 'string',
        'ifsc_code' => 'string',
        'payment_method' => 'string',
        'mpesa_phone' => 'string',
        'subaccount_code' => 'string',
        'device_type' => 'integer',
        'device_token' => 'string',
        'status' => 'integer',
        'otp_code' => 'string',
        'otp_expiry' => 'datetime',
        'id_front' => 'string',
        'id_back' => 'string',
        'selfie' => 'string',
    ];

    public function author_request()
    {
        return $this->belongsTo(Author_Request::class, 'id', 'user_id');
    }
    public function novel()
    {
        return $this->hasMany(Novel::class, 'id');
    }
    public function magazine()
    {
        return $this->hasMany(Novel::class, 'id');
    }
    public function audio_book()
    {
        return $this->hasMany(Novel::class, 'id');
    }
    public function content_transaction()
    {
        return $this->hasMany(Content_Transaction::class, 'user_id');
    }
    public function login_history()
    {
        return $this->hasMany(Login_History::class, 'user_id');
    }
    public function audio_books()
    {
        return $this->hasMany(AudioBook::class, 'author_id');
    }
    public function novels()
    {
        return $this->hasMany(Novel::class, 'author_id');
    }
    public function magazines()
    {
        return $this->hasMany(Magazine::class, 'author_id');
    }
    public function content_transactions()
    {
        return $this->hasMany(Content_Transaction::class, 'author_id');
    }
}
