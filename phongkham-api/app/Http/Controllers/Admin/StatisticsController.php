<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class StatisticsController
{
    public function overview(Request $request)
    {
        $from = $request->query('from', Carbon::now()->startOfMonth()->toDateString());
        $to   = $request->query('to',   Carbon::today()->toDateString());

        // ── Tổng lịch khám ──────────────────────────────────────────
        $totalAppointments = DB::table('lichkham as lk')
            ->join('lichlamviec as llv', 'lk.MaLichLamViec', '=', 'llv.MaLichLamViec')
            ->whereBetween('llv.Ngay', [$from, $to])
            ->count();

        // ── Theo trạng thái ──────────────────────────────────────────
        $byStatus = DB::table('lichkham as lk')
            ->join('lichlamviec as llv', 'lk.MaLichLamViec', '=', 'llv.MaLichLamViec')
            ->whereBetween('llv.Ngay', [$from, $to])
            ->select('lk.TrangThai', DB::raw('COUNT(*) as total'))
            ->groupBy('lk.TrangThai')
            ->get()
            ->keyBy('TrangThai');

        // ── Doanh thu (hóa đơn đã thanh toán) ───────────────────────
        $revenue = DB::table('hoadon')
            ->whereBetween('NgayTao', [$from, $to])
            ->where('TrangThai', 'paid')
            ->sum('SoTienPhaiTra') ?? 0;

        $pendingRevenue = DB::table('hoadon')
            ->whereBetween('NgayTao', [$from, $to])
            ->where('TrangThai', 'pending')
            ->sum('SoTienPhaiTra') ?? 0;

        $paidCount = DB::table('hoadon')
            ->whereBetween('NgayTao', [$from, $to])
            ->where('TrangThai', 'paid')->count();

        $pendingCount = DB::table('hoadon')
            ->whereBetween('NgayTao', [$from, $to])
            ->where('TrangThai', 'pending')->count();

        // ── Bệnh nhân mới (đăng ký trong khoảng) ────────────────────
        $newPatients = DB::table('taikhoan')
            ->where('VaiTro', 'benhnhan')
            ->whereBetween('ngaytao', [$from . ' 00:00:00', $to . ' 23:59:59'])
            ->count();

        $totalPatients = DB::table('benhnhan')->count();

        // ── Bác sĩ trực (có lịch làm việc) ──────────────────────────
        $activeDoctors = DB::table('lichlamviec')
            ->whereBetween('Ngay', [$from, $to])
            ->distinct('MaBacSi')
            ->count('MaBacSi');

        // ── Doanh thu 7 ngày gần nhất ────────────────────────────────
        $revenueByDay = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i)->toDateString();
            $amount = DB::table('hoadon')
                ->whereDate('NgayTao', $date)
                ->where('TrangThai', 'paid')
                ->sum('SoTienPhaiTra') ?? 0;
            $revenueByDay[] = ['date' => $date, 'revenue' => (float)$amount];
        }

        // ── Top 5 bác sĩ nhiều lịch khám nhất ───────────────────────
        $topDoctors = DB::table('lichkham as lk')
            ->join('lichlamviec as llv', 'lk.MaLichLamViec', '=', 'llv.MaLichLamViec')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->whereBetween('llv.Ngay', [$from, $to])
            ->select(
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as tenBacSi"),
                'bs.ChuyenKhoa',
                DB::raw('COUNT(*) as soLichKham')
            )
            ->groupBy('llv.MaBacSi', 'bs.ho', 'bs.ten', 'bs.ChuyenKhoa')
            ->orderByDesc('soLichKham')
            ->limit(5)
            ->get();

        // ── Bệnh nhân theo giới tính ─────────────────────────────────
        $genderStats = DB::table('benhnhan')
            ->select('gioitinh', DB::raw('COUNT(*) as total'))
            ->groupBy('gioitinh')
            ->get()
            ->keyBy('gioitinh');

        // ── Lịch khám theo chuyên khoa ───────────────────────────────
        $bySpecialty = DB::table('lichkham as lk')
            ->join('lichlamviec as llv', 'lk.MaLichLamViec', '=', 'llv.MaLichLamViec')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->whereBetween('llv.Ngay', [$from, $to])
            ->select('bs.ChuyenKhoa', DB::raw('COUNT(*) as total'))
            ->groupBy('bs.ChuyenKhoa')
            ->orderByDesc('total')
            ->limit(6)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'period' => ['from' => $from, 'to' => $to],
                'overview' => [
                    'totalAppointments' => (int)$totalAppointments,
                    'revenue'           => (float)$revenue,
                    'pendingRevenue'    => (float)$pendingRevenue,
                    'paidCount'         => (int)$paidCount,
                    'pendingCount'      => (int)$pendingCount,
                    'newPatients'       => (int)$newPatients,
                    'totalPatients'     => (int)$totalPatients,
                    'activeDoctors'     => (int)$activeDoctors,
                ],
                'appointmentsByStatus' => [
                    'completed' => (int)($byStatus['completed']->total ?? 0),
                    'confirmed' => (int)($byStatus['confirmed']->total ?? 0),
                    'pending'   => (int)($byStatus['pending']->total   ?? 0),
                    'cancelled' => (int)($byStatus['cancelled']->total ?? 0),
                    'checked_in'=> (int)($byStatus['checked_in']->total?? 0),
                ],
                'revenueByDay' => $revenueByDay,
                'topDoctors'   => $topDoctors,
                'bySpecialty'  => $bySpecialty,
                'genderStats'  => [
                    'nam'  => (int)($genderStats['Nam']->total  ?? $genderStats['nam']->total  ?? 0),
                    'nu'   => (int)($genderStats['Nữ']->total   ?? $genderStats['nu']->total   ?? 0),
                    'other'=> (int)($genderStats['other']->total ?? 0),
                ],
            ],
        ]);
    }
}
