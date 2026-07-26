<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $fields = function (Blueprint $table) {
            $table->string('isbn')->nullable();
            $table->string('publisher_author_name')->nullable();
        };

        Schema::table('tbl_novel', $fields);
        Schema::table('tbl_audio_book', $fields);
        Schema::table('tbl_magazine', $fields);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $dropFields = function (Blueprint $table) {
            $table->dropColumn(['isbn', 'publisher_author_name']);
        };

        Schema::table('tbl_novel', $dropFields);
        Schema::table('tbl_audio_book', $dropFields);
        Schema::table('tbl_magazine', $dropFields);
    }
};
