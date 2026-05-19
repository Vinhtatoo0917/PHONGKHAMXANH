<?php

namespace App\Http\Controllers;

use App\Models\LichKham;
use App\Models\LichLamViec;
use App\Models\ChiTietLichKham;
use App\Models\BenhNhan;
use App\Models\DichVu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LichKhamController extends Controller
{
    /**
     * Lấy danh sách lịch làm việc của bác sĩ (để bệnh nhân chọn)
     */
    public function getAvailableSchedules(Request $request)
    {
        try {
            $validated = $request->validate([
                'ngay_bat_dau' => 'required|date',
                'ngay_ket_thuc' => 'required|date|after_or_equal:ngay_bat_dau',
                'ma_khoa' => 'nullable|integer',
            ]);

            $query = LichLamViec::with([
                'bacSi',
                'caKham',
                'phongKham',
                'lichKham'
            ])
            ->whereBetween('Ngay', [$validated['ngay_bat_dau'], $validated['ngay_ket_thuc']])
            ->where('lichlamviec.TrangThai', '!=', 'inactive');

            if ($request->has('ma_khoa') && $request->ma_khoa) {
                $query->whereHas('bacSi', function ($q) use ($request) {
                    $q->where('ChuyenKhoa', 'like', '%' . $request->ma_khoa . '%');
                });
            }

            $schedules = $query->get()->map(function ($schedule) {
                $soLuongDaDat = $schedule->lichKham()->where('TrangThai', '!=', 'cancelled')->count();
                $soChoTrong = $schedule->caKham->SoLuongToiDa - $soLuongDaDat;

                return [
                    'MaLichLamViec' => $schedule->MaLichLamViec,
                    'MaBacSi' => $schedule->MaBacSi,
                    'TenBacSi' => $schedule->bacSi->ho . ' ' . $schedule->bacSi->ten,
                    'ChuyenKhoa' => $schedule->bacSi->ChuyenKhoa,
                    'Ngay' => $schedule->Ngay,
                    'TenCa' => $schedule->caKham->TenCa,
                    'GioBatDau' => $schedule->caKham->GioBatDau,
                    'GioKetThuc' => $schedule->caKham->GioKetThuc,
                    'TenPhong' => $schedule->phongKham->TenPhong,
                    'SoChoTrong' => $soChoTrong,
                    'SoLuongToiDa' => $schedule->caKham->SoLuongToiDa,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $schedules
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Đặt lịch khám mới
     */
    public function bookAppointment(Request $request)
    {
        try {
            $validated = $request->validate([
                'ma_benh_nhan' => 'required|integer|exists:benhnhan,MaBenhNhan',
                'ma_lich_lam_viec' => 'required|integer|exists:lichlamviec,MaLichLamViec',
                'dich_vu_ids' => 'required|array',
                'dich_vu_ids.*' => 'integer|exists:dichvu,MaDichVu',
            ]);

            DB::beginTransaction();

            // Kiểm tra số chỗ trống
            $lichLamViec = LichLamViec::with('caKham')->findOrFail($validated['ma_lich_lam_viec']);
            $soLuongDaDat = LichKham::where('MaLichLamViec', $validated['ma_lich_lam_viec'])
                ->where('TrangThai', '!=', 'cancelled')
                ->count();

            if ($soLuongDaDat >= $lichLamViec->caKham->SoLuongToiDa) {
                return response()->json([
                    'success' => false,
                    'message' => 'Lịch khám này đã đầy'
                ], 400);
            }

            // Kiểm tra bệnh nhân chưa đặt lịch cùng ngày
            $existingAppointment = LichKham::whereHas('lichLamViec', function ($q) use ($lichLamViec) {
                $q->where('Ngay', $lichLamViec->Ngay);
            })
            ->where('MaBenhNhan', $validated['ma_benh_nhan'])
            ->where('TrangThai', '!=', 'cancelled')
            ->first();

            if ($existingAppointment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bạn đã có lịch khám vào ngày này'
                ], 400);
            }

            // Tính số thứ tự
            $soThuTu = $soLuongDaDat + 1;

            // Tạo lịch khám
            $lichKham = LichKham::create([
                'MaBenhNhan' => $validated['ma_benh_nhan'],
                'MaLichLamViec' => $validated['ma_lich_lam_viec'],
                'SoThuTu' => $soThuTu,
                'TrangThai' => 'pending',
                'TrangThaiThanhToan' => 'unpaid',
            ]);

            // Tính tổng tiền và tạo chi tiết lịch khám
            $tongTien = 0;
            foreach ($validated['dich_vu_ids'] as $dichVuId) {
                $dichVu = DichVu::findOrFail($dichVuId);
                $thanhTien = $dichVu->Gia;
                $tongTien += $thanhTien;

                ChiTietLichKham::create([
                    'MaLichKham' => $lichKham->MaLichKham,
                    'MaDichVu' => $dichVuId,
                    'SoLuong' => 1,
                    'DonGia' => $dichVu->Gia,
                    'ThanhTien' => $thanhTien,
                ]);
            }

            // Cập nhật tổng tiền
            $lichKham->update(['TongTien' => $tongTien]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Đặt lịch khám thành công',
                'data' => $lichKham->load('lichLamViec.bacSi', 'lichLamViec.caKham', 'chiTietLichKham.dichVu')
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Lấy danh sách lịch khám của bệnh nhân
     */
    public function getMyAppointments(Request $request)
    {
        try {
            $maBenhNhan = $request->user()->benhNhan->MaBenhNhan ?? null;

            if (!$maBenhNhan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không tìm thấy thông tin bệnh nhân'
                ], 404);
            }

            $lichKhams = LichKham::where('MaBenhNhan', $maBenhNhan)
                ->with([
                    'lichLamViec.bacSi',
                    'lichLamViec.caKham',
                    'lichLamViec.phongKham',
                    'chiTietLichKham.dichVu'
                ])
                ->orderBy('MaLichKham', 'desc')
                ->get()
                ->map(function ($lich) {
                    return [
                        'MaLichKham' => $lich->MaLichKham,
                        'SoThuTu' => $lich->SoThuTu,
                        'TrangThai' => $lich->TrangThai,
                        'TrangThaiThanhToan' => $lich->TrangThaiThanhToan,
                        'TongTien' => $lich->TongTien,
                        'Ngay' => $lich->lichLamViec->Ngay,
                        'TenCa' => $lich->lichLamViec->caKham->TenCa,
                        'GioBatDau' => $lich->lichLamViec->caKham->GioBatDau,
                        'GioKetThuc' => $lich->lichLamViec->caKham->GioKetThuc,
                        'TenBacSi' => $lich->lichLamViec->bacSi->ho . ' ' . $lich->lichLamViec->bacSi->ten,
                        'TenPhong' => $lich->lichLamViec->phongKham->TenPhong,
                        'DichVu' => $lich->chiTietLichKham->map(fn($ct) => [
                            'TenDichVu' => $ct->dichVu->TenDichVu,
                            'Gia' => $ct->DonGia,
                        ]),
                        'ThoiDiemCheckIn' => $lich->ThoiDiemCheckIn,
                        'ThoiDiemCheckOut' => $lich->ThoiDiemCheckOut,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $lichKhams
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Hủy lịch khám
     */
    public function cancelAppointment(Request $request, $maLichKham)
    {
        try {
            $lichKham = LichKham::findOrFail($maLichKham);

            // Kiểm tra quyền
            $maBenhNhan = $request->user()->benhNhan->MaBenhNhan ?? null;
            if ($lichKham->MaBenhNhan != $maBenhNhan && $request->user()->VaiTro != 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Bạn không có quyền hủy lịch này'
                ], 403);
            }

            $lichKham->update(['TrangThai' => 'cancelled']);

            return response()->json([
                'success' => true,
                'message' => 'Hủy lịch khám thành công'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Lấy danh sách lịch khám của bác sĩ
     */
    public function getDoctorSchedule(Request $request)
    {
        try {
            $maBacSi = $request->user()->bacSi->MaBacSi ?? null;

            if (!$maBacSi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không tìm thấy thông tin bác sĩ'
                ], 404);
            }

            $validated = $request->validate([
                'ngay_bat_dau' => 'nullable|date',
                'ngay_ket_thuc' => 'nullable|date',
            ]);

            $query = LichLamViec::where('MaBacSi', $maBacSi)
                ->with(['caKham', 'phongKham', 'lichKham.benhNhan', 'lichKham.chiTietLichKham.dichVu']);

            if ($request->has('ngay_bat_dau') && $request->ngay_bat_dau) {
                $query->where('Ngay', '>=', $validated['ngay_bat_dau']);
            }

            if ($request->has('ngay_ket_thuc') && $request->ngay_ket_thuc) {
                $query->where('Ngay', '<=', $validated['ngay_ket_thuc']);
            }

            $schedules = $query->orderBy('Ngay', 'asc')
                ->orderBy('MaLichLamViec', 'asc')
                ->get()
                ->map(function ($schedule) {
                    return [
                        'MaLichLamViec' => $schedule->MaLichLamViec,
                        'Ngay' => $schedule->Ngay,
                        'TenCa' => $schedule->caKham->TenCa,
                        'GioBatDau' => $schedule->caKham->GioBatDau,
                        'GioKetThuc' => $schedule->caKham->GioKetThuc,
                        'TenPhong' => $schedule->phongKham->TenPhong,
                        'SoLuongToiDa' => $schedule->caKham->SoLuongToiDa,
                        'LichKham' => $schedule->lichKham->map(function ($lich) {
                            return [
                                'MaLichKham' => $lich->MaLichKham,
                                'SoThuTu' => $lich->SoThuTu,
                                'TenBenhNhan' => $lich->benhNhan->ho . ' ' . $lich->benhNhan->ten,
                                'TrangThai' => $lich->TrangThai,
                                'TongTien' => $lich->TongTien,
                                'DichVu' => $lich->chiTietLichKham->map(fn($ct) => [
                                    'TenDichVu' => $ct->dichVu->TenDichVu,
                                    'Gia' => $ct->DonGia,
                                ]),
                                'ThoiDiemCheckIn' => $lich->ThoiDiemCheckIn,
                            ];
                        }),
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $schedules
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Admin: Lấy danh sách tất cả lịch khám
     */
    public function getAllAppointments(Request $request)
    {
        try {
            $validated = $request->validate([
                'trang_thai' => 'nullable|string',
                'ngay_bat_dau' => 'nullable|date',
                'ngay_ket_thuc' => 'nullable|date',
                'ma_bac_si' => 'nullable|integer',
                'page' => 'nullable|integer|min:1',
                'per_page' => 'nullable|integer|min:1|max:100',
            ]);

            $perPage = $validated['per_page'] ?? 15;

            $query = LichKham::with([
                'benhNhan',
                'lichLamViec.bacSi',
                'lichLamViec.caKham',
                'lichLamViec.phongKham',
                'chiTietLichKham.dichVu'
            ]);

            if ($request->has('trang_thai') && $request->trang_thai) {
                $query->where('TrangThai', $validated['trang_thai']);
            }

            if ($request->has('ngay_bat_dau') && $request->ngay_bat_dau) {
                $query->whereHas('lichLamViec', function ($q) use ($validated) {
                    $q->where('Ngay', '>=', $validated['ngay_bat_dau']);
                });
            }

            if ($request->has('ngay_ket_thuc') && $request->ngay_ket_thuc) {
                $query->whereHas('lichLamViec', function ($q) use ($validated) {
                    $q->where('Ngay', '<=', $validated['ngay_ket_thuc']);
                });
            }

            if ($request->has('ma_bac_si') && $request->ma_bac_si) {
                $query->whereHas('lichLamViec', function ($q) use ($validated) {
                    $q->where('MaBacSi', $validated['ma_bac_si']);
                });
            }

            $appointments = $query->orderBy('MaLichKham', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $appointments->items(),
                'pagination' => [
                    'total' => $appointments->total(),
                    'per_page' => $appointments->perPage(),
                    'current_page' => $appointments->currentPage(),
                    'last_page' => $appointments->lastPage(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Admin: Cập nhật trạng thái lịch khám
     */
    public function updateAppointmentStatus(Request $request, $maLichKham)
    {
        try {
            $validated = $request->validate([
                'trang_thai' => 'required|in:pending,confirmed,completed,cancelled,no-show',
                'trang_thai_thanh_toan' => 'nullable|in:unpaid,paid,partial',
            ]);

            $lichKham = LichKham::findOrFail($maLichKham);
            $lichKham->update([
                'TrangThai' => $validated['trang_thai'],
                'TrangThaiThanhToan' => $validated['trang_thai_thanh_toan'] ?? $lichKham->TrangThaiThanhToan,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật trạng thái thành công',
                'data' => $lichKham
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }
}
