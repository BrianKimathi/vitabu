<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Novel extends Model
{
    use HasFactory;

    protected $table = 'tbl_novel';
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
        'full_novel' => 'string',
        'total_read' => 'integer',
        'status' => 'integer',
    ];

    public function chapters()
    {
        return $this->hasMany(Novel_Chapter::class, 'novel_id');
    }
    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }
    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }
    public function language()
    {
        return $this->belongsTo(Language::class, 'language_id');
    }
    public function content_transaction()
    {
        return $this->hasMany(Content_Transaction::class, 'content_id')->where('content_type', 2);
    }
}
