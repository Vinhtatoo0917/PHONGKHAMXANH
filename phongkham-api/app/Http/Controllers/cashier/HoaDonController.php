<?php

namespace App\Http\Controllers\cashier;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class HoaDonController extends Controller
{
    /**
     * Lấy danh sách hóa đơn chưa thanh toán trong ngày
     * GET /cashier/unpaid-invoices?date=2026-05-23
     */
    public function getUnpaidInvoices(Request $request)
    {
        try {
            $date = $request->query('date', Carbon::today()->format('Y-m-d'));

            $invoices = DB::table('hoadon as hd')
                ->leftJoin('benhnhan as bn', 'hd.MaBenhNhan', '=', 'bn.MaBenhNhan')
                ->whereDate('hd.NgayTao', $date)
                ->where('hd.TrangThai', 'pending')
                ->select(
                    'hd.MaHoaDon',
                    'hd.MaBenhNhan',
                    DB::raw("CONCAT(bn.ho, ' ', bn.ten) as TenBenhNhan"),
                    'hd.TongTien',
                    'hd.GiamBHYT',
                    'hd.SoTienPhaiTra',
                    'hd.TrangThai',
                    'hd.NgayTao'
                )
                ->orderBy('hd.NgayTao', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $invoices,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cập nhật trạng thái thanh toán của hóa đơn
     * POST /cashier/invoices/{maHoaDon}/mark-paid
     */
    public function markInvoicePaid(Request $request, $maHoaDon)
    {
        try {
            $validated = $request->validate([
                'payment_method' => 'required|in:bank,cash',
            ]);

            $invoice = DB::table('hoadon')
                ->where('MaHoaDon', $maHoaDon)
                ->first();

            if (!$invoice) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không tìm thấy hóa đơn',
                ], 404);
            }

            DB::table('hoadon')
                ->where('MaHoaDon', $maHoaDon)
                ->update([
                    'TrangThai' => 'paid',
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật trạng thái thành công',
                'data' => [
                    'MaHoaDon' => $maHoaDon,
                    'TrangThai' => 'paid',
                    'PhuongThucThanhToan' => $validated['payment_method'],
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
