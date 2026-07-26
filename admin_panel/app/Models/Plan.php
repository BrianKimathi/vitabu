<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Plan extends Model
{
    use HasFactory;

    protected $table = 'tbl_plan';

    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'name' => 'string',
        'type' => 'string',
        'time' => 'integer',
        'price' => 'integer',
        'image' => 'string',
        'access_type' => 'string',
        'status' => 'integer',
    ];

    public function transaction()
    {
        return $this->hasMany(Transaction::class, 'plan_id');
    }
}
