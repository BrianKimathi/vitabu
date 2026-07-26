<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AudioBook_Episode extends Model
{
    use HasFactory;

    protected $table = 'tbl_audio_book_episode';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'audio_book_id' => 'integer',
        'title' => 'string',
        'description' => 'string',
        'image' => 'string',
        'audio_type' => 'integer',
        'audio' => 'string',
        'is_episode_paid' => 'integer',
        'price' => 'integer',
        'total_played' => 'integer',
        'sort_order' => 'integer',
        'status' => 'integer',
    ];
    public function audio_book()
    {
        return $this->belongsTo(AudioBook::class, 'audio_book_id');
    }
}
