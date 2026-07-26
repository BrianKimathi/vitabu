<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Bookmark extends Model
{
    use HasFactory;

    protected $table = 'tbl_bookmark';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'user_id' => 'integer',
        'content_type' => 'integer',
        'content_id' => 'integer',
        'status' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    public function novel()
    {
        return $this->belongsTo(Novel::class, 'content_id');
    }
    public function audio_book()
    {
        return $this->belongsTo(AudioBook::class, 'content_id');
    }
    public function magazine()
    {
        return $this->belongsTo(Magazine::class, 'content_id');
    }
}
