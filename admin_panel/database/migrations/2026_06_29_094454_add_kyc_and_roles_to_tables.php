<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // tbl_admin
        if (Schema::hasTable('tbl_admin') && !Schema::hasColumn('tbl_admin', 'role')) {
            Schema::table('tbl_admin', function (Blueprint $table) {
                $table->string('role', 50)->default('admin')->after('password');
            });
        }

        // tbl_author_requests
        Schema::table('tbl_author_requests', function (Blueprint $table) {
            $table->string('legal_name')->nullable()->after('status');
            $table->string('national_id_number')->nullable()->after('legal_name');
            $table->string('kra_pin')->nullable()->after('national_id_number');
            $table->string('business_name')->nullable()->after('kra_pin');
            $table->string('business_certificate')->nullable()->after('business_name');
            $table->string('kra_pin_certificate')->nullable()->after('business_certificate');
            $table->string('rep_name')->nullable()->after('kra_pin_certificate');
            $table->string('rep_id_upload')->nullable()->after('rep_name');
            $table->tinyInteger('rights_declaration')->default(0)->after('rep_id_upload');
        });

        // tbl_users
        Schema::table('tbl_users', function (Blueprint $table) {
            $table->string('legal_name')->nullable()->after('status');
            $table->string('national_id_number')->nullable()->after('legal_name');
            $table->string('kra_pin')->nullable()->after('national_id_number');
            $table->string('business_name')->nullable()->after('kra_pin');
            $table->string('business_certificate')->nullable()->after('business_name');
            $table->string('kra_pin_certificate')->nullable()->after('business_certificate');
            $table->string('rep_name')->nullable()->after('kra_pin_certificate');
            $table->string('rep_id_upload')->nullable()->after('rep_name');
            $table->tinyInteger('rights_declaration')->default(0)->after('rep_id_upload');
            $table->string('subaccount_code')->nullable()->after('rights_declaration');
        });

        // tbl_novel
        Schema::table('tbl_novel', function (Blueprint $table) {
            $table->string('isbn')->nullable()->after('price');
            $table->string('bsnb')->nullable()->after('isbn');
            $table->string('publisher_author_name')->nullable()->after('bsnb');
        });

        // tbl_audio_book
        Schema::table('tbl_audio_book', function (Blueprint $table) {
            $table->string('isbn')->nullable()->after('price');
            $table->string('bsnb')->nullable()->after('isbn');
            $table->string('publisher_author_name')->nullable()->after('bsnb');
        });

        // tbl_magazine
        Schema::table('tbl_magazine', function (Blueprint $table) {
            $table->string('isbn')->nullable()->after('price');
            $table->string('bsnb')->nullable()->after('isbn');
            $table->string('publisher_author_name')->nullable()->after('bsnb');
        });

        // Add screenshot_protection key to tbl_general_setting if not exists
        if (Schema::hasTable('tbl_general_setting')) {
            $exists = DB::table('tbl_general_setting')->where('key', 'screenshot_protection')->exists();
            if (!$exists) {
                DB::table('tbl_general_setting')->insert([
                    'key' => 'screenshot_protection',
                    'value' => '1',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove columns
        if (Schema::hasTable('tbl_admin') && Schema::hasColumn('tbl_admin', 'role')) {
            Schema::table('tbl_admin', function (Blueprint $table) {
                $table->dropColumn('role');
            });
        }

        Schema::table('tbl_author_requests', function (Blueprint $table) {
            $table->dropColumn([
                'legal_name', 'national_id_number', 'kra_pin',
                'business_name', 'business_certificate', 'kra_pin_certificate',
                'rep_name', 'rep_id_upload', 'rights_declaration'
            ]);
        });

        Schema::table('tbl_users', function (Blueprint $table) {
            $table->dropColumn([
                'legal_name', 'national_id_number', 'kra_pin',
                'business_name', 'business_certificate', 'kra_pin_certificate',
                'rep_name', 'rep_id_upload', 'rights_declaration', 'subaccount_code'
            ]);
        });

        Schema::table('tbl_novel', function (Blueprint $table) {
            $table->dropColumn(['isbn', 'bsnb', 'publisher_author_name']);
        });

        Schema::table('tbl_audio_book', function (Blueprint $table) {
            $table->dropColumn(['isbn', 'bsnb', 'publisher_author_name']);
        });

        Schema::table('tbl_magazine', function (Blueprint $table) {
            $table->dropColumn(['isbn', 'bsnb', 'publisher_author_name']);
        });

        if (Schema::hasTable('tbl_general_setting')) {
            DB::table('tbl_general_setting')->where('key', 'screenshot_protection')->delete();
        }
    }
};
