<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Withdrawal_Request extends Model
{
    use HasFactory;

    protected $table = 'tbl_withdrawal_request';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'author_id' => 'integer',
        'price' => 'integer',
        'payment_type' => 'string',
        'payment_detail' => 'string',
        'status' => 'integer',
    ];

    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}
