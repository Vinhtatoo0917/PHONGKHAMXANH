<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('taikhoan', function (Blueprint $table) {
            $table->string('otp_reset_code', 6)->nullable()->after('Accesstoken');
            $table->dateTime('otp_reset_expires_at')->nullable()->after('otp_reset_code');
        });
    }

    public function down(): void
    {
        Schema::table('taikhoan', function (Blueprint $table) {
            $table->dropColumn(['otp_reset_code', 'otp_reset_expires_at']);
        });
    }
};
