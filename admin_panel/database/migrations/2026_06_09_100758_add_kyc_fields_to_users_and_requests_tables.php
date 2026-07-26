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
            $table->string('legal_name')->nullable();
            $table->string('national_id_number')->nullable();
            $table->string('kra_pin')->nullable();
            $table->string('country')->nullable();
            $table->integer('copyright_declaration')->default(0);

            $table->string('business_name')->nullable();
            $table->string('business_certificate')->nullable();
            $table->string('kra_pin_certificate')->nullable();
            $table->string('rep_name')->nullable();
            $table->string('rep_id_upload')->nullable();
            $table->integer('rights_declaration')->default(0);
        };

        Schema::table('tbl_user', $fields);
        Schema::table('tbl_author_request', $fields);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $dropFields = function (Blueprint $table) {
            $table->dropColumn([
                'legal_name',
                'national_id_number',
                'kra_pin',
                'country',
                'copyright_declaration',
                'business_name',
                'business_certificate',
                'kra_pin_certificate',
                'rep_name',
                'rep_id_upload',
                'rights_declaration'
            ]);
        };

        Schema::table('tbl_user', $dropFields);
        Schema::table('tbl_author_request', $dropFields);
    }
};
