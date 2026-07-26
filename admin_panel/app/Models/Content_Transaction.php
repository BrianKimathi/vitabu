<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Content_Transaction extends Model
{
    use HasFactory;

    protected $table = 'tbl_content_transaction';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'coupon_code' => 'string',
        'user_id' => 'integer',
        'author_id' => 'integer',
        'content_type' => 'integer',
        'content_id' => 'integer',
        'sub_content_id' => 'integer',
        'price' => 'decimal:2',
        'commission' => 'decimal:2',
        'total_tax' => 'decimal:2',
        'tax' => 'string',
        'author_earning' => 'decimal:2',
        'transaction_id' => 'string',
        'payment_method' => 'string',
        'status' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }
    public function audio_book()
    {
        return $this->belongsTo(AudioBook::class, 'content_id');
    }
    public function novel()
    {
        return $this->belongsTo(Novel::class, 'content_id');
    }
    public function magazine()
    {
        return $this->belongsTo(Magazine::class, 'content_id');
    }
    public function episode()
    {
        return $this->belongsTo(AudioBook_Episode::class, 'sub_content_id');
    }
    public function chapter()
    {
        return $this->belongsTo(Novel_Chapter::class, 'sub_content_id');
    }
}
