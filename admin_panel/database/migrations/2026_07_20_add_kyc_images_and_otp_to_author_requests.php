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
        Schema::table('tbl_author_request', function (Blueprint $table) {
            // KYC image uploads
            $table->string('id_front')->nullable()->after('mpesa_phone');
            $table->string('id_back')->nullable()->after('id_front');
            $table->string('selfie')->nullable()->after('id_back');

            // OTP verification fields
            $table->string('otp_code')->nullable()->after('selfie');
            $table->dateTime('otp_expiry')->nullable()->after('otp_code');
            $table->tinyInteger('is_otp_verified')->default(0)->after('otp_expiry');
            $table->string('otp_email')->nullable()->after('is_otp_verified');
            $table->string('otp_phone')->nullable()->after('otp_email');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tbl_author_request', function (Blueprint $table) {
            $table->dropColumn([
                'id_front',
                'id_back',
                'selfie',
                'otp_code',
                'otp_expiry',
                'is_otp_verified',
                'otp_email',
                'otp_phone',
            ]);
        });
    }
};
