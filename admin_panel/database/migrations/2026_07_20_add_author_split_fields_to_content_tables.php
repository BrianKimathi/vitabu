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
        $addFields = function (Blueprint $table) {
            $table->decimal('author_split_amount', 10, 2)->nullable()->default(null)->after('price');
            $table->decimal('author_split_percentage', 5, 2)->nullable()->default(null)->after('author_split_amount');
        };

        Schema::table('tbl_novel', $addFields);
        Schema::table('tbl_audio_book', $addFields);
        Schema::table('tbl_magazine', $addFields);

        // Add subaccount_code to author_request table if missing
        if (Schema::hasTable('tbl_author_request') && !Schema::hasColumn('tbl_author_request', 'subaccount_code')) {
            Schema::table('tbl_author_request', function (Blueprint $table) {
                $table->string('subaccount_code')->nullable()->after('status');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $dropFields = function (Blueprint $table) {
            $table->dropColumn(['author_split_amount', 'author_split_percentage']);
        };

        Schema::table('tbl_novel', $dropFields);
        Schema::table('tbl_audio_book', $dropFields);
        Schema::table('tbl_magazine', $dropFields);

        if (Schema::hasTable('tbl_author_request') && Schema::hasColumn('tbl_author_request', 'subaccount_code')) {
            Schema::table('tbl_author_request', function (Blueprint $table) {
                $table->dropColumn(['subaccount_code']);
            });
        }
    }
};
