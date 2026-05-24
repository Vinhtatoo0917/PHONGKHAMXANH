<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController
{
    public function dashboardStats(Request $request)
    {
        $date = $request->query('date') ?? today()->toDateString();
        $date = Carbon::createFromFormat('Y-m-d', $date)->startOfDay();

        // Lịch khám hôm nay
        $lichKham = DB::table('lichkham')
            ->whereDate('NgayKham', $date)
            ->count();

        // Tiền được thêm vào hôm nay (từ hóa đơn)
        $revenue = DB::table('hoadon')
            ->whereDate('NgayLap', $date)
            ->sum('TongTien') ?? 0;

        // Bác sĩ trực hôm nay (count distinct doctors)
        $bacSiTruc = DB::table('lichlamviec')
            ->whereDate('Ngay', $date)
            ->select('MaBacSi')
            ->distinct()
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'lichKham' => (int)$lichKham,
                'revenue' => (float)$revenue,
                'bacSiTruc' => (int)$bacSiTruc,
            ]
        ]);
    }

    public function doctorSchedules(Request $request)
    {
        $date = $request->query('date') ?? today()->toDateString();
        $date = Carbon::createFromFormat('Y-m-d', $date)->startOfDay();

        $schedules = DB::table('lichlamviec')
            ->whereDate('Ngay', $date)
            ->select('MaBacSi', 'Ngay', 'MaCa')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $schedules->count() > 0 ? $schedules : []
        ]);
    }
}
