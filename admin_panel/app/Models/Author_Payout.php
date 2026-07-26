<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Author_Payout extends Model
{
    use HasFactory;

    protected $table = 'tbl_author_payout';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'author_id' => 'integer',
        'total_read_time' => 'integer',
        'gross_earning' => 'decimal:2',
        'admin_commission' => 'decimal:2',
        'total_payable_amount' => 'decimal:2',
        'author_payable_amount' => 'integer',
        'content_earnings' => 'integer',
        'payout_month' => 'integer',
        'payout_year' => 'integer',
        'status' => 'integer',
    ];

    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}
