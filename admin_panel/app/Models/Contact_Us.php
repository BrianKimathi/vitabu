<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Contact_Us extends Model
{
    use HasFactory;

    protected $table = 'tbl_contact_us';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'name' => 'string',
        'email' => 'string',
        'subject' => 'string',
        'details' => 'string',
        'status' => 'integer',
    ];
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
