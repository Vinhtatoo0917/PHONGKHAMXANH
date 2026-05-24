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
     * Lấy thống kê hóa đơn ngày hôm nay (cho cashier dashboard)
     * GET /cashier/today-statistics
     */
    public function getTodayStatistics(Request $request)
    {
        try {
            $today = Carbon::today();

            $statistics = DB::table('hoadon as hd')
                ->whereDate('hd.NgayTao', $today)
                ->select(
                    DB::raw("COUNT(CASE WHEN TrangThai = 'pending' THEN 1 END) as total_pending"),
                    DB::raw("COUNT(CASE WHEN TrangThai = 'paid' THEN 1 END) as total_paid"),
                    DB::raw("SUM(SoTienPhaiTra) as total_amount")
                )
                ->first();

            return response()->json([
                'success' => true,
                'data' => [
                    'total_pending' => (int)($statistics->total_pending ?? 0),
                    'total_paid' => (int)($statistics->total_paid ?? 0),
                    'total_amount' => (float)($statistics->total_amount ?? 0),
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lấy tất cả hóa đơn (tất cả ngày, có filter)
     * GET /cashier/all-invoices?status=pending|paid|all&date_from=2026-01-01&date_to=2026-12-31&search=keyword
     */
    public function getAllInvoices(Request $request)
    {
        try {
            $status = $request->query('status', 'all');
            $dateFrom = $request->query('date_from');
            $dateTo = $request->query('date_to');
            $search = $request->query('search');

            $query = DB::table('hoadon as hd')
                ->leftJoin('benhnhan as bn', 'hd.MaBenhNhan', '=', 'bn.MaBenhNhan')
                ->select(
                    'hd.MaHoaDon',
                    'hd.MaBenhNhan',
                    DB::raw("CONCAT(bn.ho, ' ', bn.ten) as TenBenhNhan"),
                    'hd.TongTien',
                    'hd.GiamBHYT',
                    'hd.SoTienPhaiTra',
                    'hd.TrangThai',
                    'hd.NgayTao'
                );

            if ($status !== 'all') {
                $query->where('hd.TrangThai', $status);
            }

            if ($dateFrom) {
                $query->whereDate('hd.NgayTao', '>=', $dateFrom);
            }

            if ($dateTo) {
                $query->whereDate('hd.NgayTao', '<=', $dateTo);
            }

            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('hd.MaHoaDon', 'like', "%{$search}%")
                      ->orWhereRaw("CONCAT(bn.ho, ' ', bn.ten) LIKE ?", ["%{$search}%"]);
                });
            }

            $invoices = $query->orderBy('hd.NgayTao', 'desc')->get();

            return response()->json([
                'success' => true,
                'data' => $invoices,
                'total' => $invoices->count(),
            ]);
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

            if ($invoice->TrangThai === 'paid') {
                return response()->json([
                    'success' => false,
                    'message' => 'Hóa đơn đã được thanh toán',
                ], 400);
            }

            // Lấy MaThuNgan từ token của thu ngân đang đăng nhập
            $token = $request->bearerToken();
            $maThuNgan = null;
            if ($token) {
                $taikhoan = DB::table('taikhoan')->where('Accesstoken', $token)->first();
                if ($taikhoan) {
                    $maThuNgan = DB::table('nhanvienthungan')
                        ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
                        ->value('MaThuNgan');
                }
            }

            DB::transaction(function () use ($maHoaDon, $invoice, $validated, $maThuNgan) {
                // Insert vào bảng thanhtoan (tiền mặt cần MaThuNgan)
                DB::table('thanhtoan')->insert([
                    'MaHoaDon' => (int)$maHoaDon,
                    'MaThuNgan' => $maThuNgan,
                    'SoTien' => $invoice->SoTienPhaiTra,
                    'PhuongThuc' => $validated['payment_method'],
                    'TrangThai' => 'completed',
                    'ThoiDiem' => Carbon::now(),
                ]);

                // Cập nhật trạng thái hóa đơn
                DB::table('hoadon')
                    ->where('MaHoaDon', $maHoaDon)
                    ->update(['TrangThai' => 'paid']);
            });

            return response()->json([
                'success' => true,
                'message' => 'Thanh toán thành công',
                'data' => [
                    'MaHoaDon' => $maHoaDon,
                    'TrangThai' => 'paid',
                    'PhuongThuc' => $validated['payment_method'],
                    'MaThuNgan' => $maThuNgan,
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
