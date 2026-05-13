<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CaKhamSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Kiểm tra xem đã có dữ liệu chưa
        if (DB::table('cakham')->count() > 0) {
            echo "Các ca khám đã tồn tại, bỏ qua seeding.\n";
            return;
        }

        // Thêm các ca khám mặc định
        DB::table('cakham')->insert([
            [
                'MaCa' => 1,
                'TenCa' => 'Ca Sáng',
                'SoLuongToiDa' => 20,
                'ThoiLuongKham' => 15, // 15 phút/bệnh nhân
                'GioBatDau' => '07:00:00',
                'GioKetThuc' => '11:30:00',
                'TrangThai' => 'active'
            ],
            [
                'MaCa' => 2,
                'TenCa' => 'Ca Chiều',
                'SoLuongToiDa' => 20,
                'ThoiLuongKham' => 15,
                'GioBatDau' => '13:00:00',
                'GioKetThuc' => '17:30:00',
                'TrangThai' => 'active'
            ],
            [
                'MaCa' => 3,
                'TenCa' => 'Ca Tối',
                'SoLuongToiDa' => 15,
                'ThoiLuongKham' => 15,
                'GioBatDau' => '18:00:00',
                'GioKetThuc' => '21:00:00',
                'TrangThai' => 'active'
            ],
            [
                'MaCa' => 4,
                'TenCa' => 'Ca Đêm',
                'SoLuongToiDa' => 10,
                'ThoiLuongKham' => 20,
                'GioBatDau' => '21:00:00',
                'GioKetThuc' => '23:59:00',
                'TrangThai' => 'inactive'
            ]
        ]);
    }
}
