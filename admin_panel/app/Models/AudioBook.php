<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AudioBook extends Model
{
    use HasFactory;

    protected $table = 'tbl_audio_book';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'author_id' => 'integer',
        'category_id' => 'integer',
        'language_id' => 'integer',
        'title' => 'string',
        'portrait_img' => 'string',
        'landscape_img' => 'string',
        'access_type' => 'integer',
        'price' => 'integer',
        'author_split_amount' => 'decimal:2',
        'author_split_percentage' => 'decimal:2',
        'description' => 'string',
        'full_audio' => 'string',
        'total_played' => 'integer',
        'status' => 'integer',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }
    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }
    public function language()
    {
        return $this->belongsTo(Language::class, 'language_id');
    }
    public function content_transaction()
    {
        return $this->hasMany(Content_Transaction::class, 'content_id')->where('content_type', 1);
    }
    public function audio_book_episodes()
    {
        return $this->hasMany(AudioBook_Episode::class, 'audio_book_id');
    }
}
