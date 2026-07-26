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
        Schema::table('tbl_user', function (Blueprint $table) {
            $table->string('otp_code')->nullable()->after('status');
            $table->dateTime('otp_expiry')->nullable()->after('otp_code');
            // KYC image fields (copied from author_request on approval)
            $table->string('id_front')->nullable()->after('otp_expiry');
            $table->string('id_back')->nullable()->after('id_front');
            $table->string('selfie')->nullable()->after('id_back');
            // Paystack subaccount code for split payments
            $table->string('subaccount_code')->nullable()->after('selfie');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tbl_user', function (Blueprint $table) {
            $table->dropColumn(['otp_code', 'otp_expiry', 'id_front', 'id_back', 'selfie']);
        });
    }
};
