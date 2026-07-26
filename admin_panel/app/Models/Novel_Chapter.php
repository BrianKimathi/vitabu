<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Novel_Chapter extends Model
{
    use HasFactory;

    protected $table = 'tbl_novel_chapter';
    protected $guarded = array();

    protected $casts = [
        'id' => 'integer',
        'novel_id' => 'integer',
        'title' => 'string',
        'description' => 'string',
        'image' => 'string',
        'chapter_type' => 'integer',
        'chapter' => 'string',
        'is_chapter_paid' => 'integer',
        'price' => 'integer',
        'total_read' => 'integer',
        'sort_order' => 'integer',
        'status' => 'integer',
    ];

    public function novel()
    {
        return $this->belongsTo(Novel::class, 'novel_id');
    }
}
