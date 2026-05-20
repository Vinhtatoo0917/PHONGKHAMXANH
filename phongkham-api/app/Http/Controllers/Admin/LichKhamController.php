<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ChiTietLichKham;
use App\Models\LichKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LichKhamController extends Controller
{
    private function timeValue($value): ?string
    {
        if ($value === null) {
            return null;
        }

        return is_string($value) ? $value : $value->format('H:i:s');
    }

    private function dateValue($value): ?string
    {
        if ($value === null) {
            return null;
        }

        return is_string($value) ? substr($value, 0, 10) : $value->format('Y-m-d');
    }

    private function khoaTheoChuyenKhoa(?string $chuyenKhoa)
    {
        if (!$chuyenKhoa) {
            return null;
        }

        return DB::table('khoa')
            ->where('TenKhoa', $chuyenKhoa)
            ->first();
    }

    private function formatAppointment(LichKham $lich): array
    {
        $lich->loadMissing([
            'benhNhan.taiKhoan',
            'lichLamViec.bacSi',
            'lichLamViec.caKham',
            'lichLamViec.phongKham',
            'chiTietLichKham.dichVu',
        ]);

        $benhNhan = $lich->benhNhan;
        $taiKhoan = $benhNhan?->taiKhoan;
        $lichLamViec = $lich->lichLamViec;
        $bacSi = $lichLamViec?->bacSi;
        $khoa = $this->khoaTheoChuyenKhoa($bacSi?->ChuyenKhoa);
        $caKham = $lichLamViec?->caKham;
        $phongKham = $lichLamViec?->phongKham;

        return [
            'MaLichKham' => $lich->MaLichKham,
            'MaBenhNhan' => $lich->MaBenhNhan,
            'MaLichLamViec' => $lich->MaLichLamViec,
            'SoThuTu' => $lich->SoThuTu,
            'TrangThai' => $lich->TrangThai,
            'TrangThaiThanhToan' => $lich->TrangThaiThanhToan,
            'TongTien' => (float) ($lich->TongTien ?? 0),
            'BenhNhan' => $benhNhan ? [
                'MaBenhNhan' => $benhNhan->MaBenhNhan,
                'HoTen' => trim($benhNhan->ho . ' ' . $benhNhan->ten),
                'Ho' => $benhNhan->ho,
                'Ten' => $benhNhan->ten,
                'NgaySinh' => $this->dateValue($benhNhan->ngaysinh),
                'GioiTinh' => $benhNhan->gioitinh,
                'CCCD' => $benhNhan->cccd,
                'DiaChi' => $benhNhan->diachi,
                'BHYT' => $benhNhan->BHYT,
                'Email' => $taiKhoan?->email,
                'SoDienThoai' => $taiKhoan?->sdt,
            ] : null,
            'Ngay' => $this->dateValue($lichLamViec?->Ngay),
            'TenCa' => $caKham?->TenCa,
            'GioBatDau' => $this->timeValue($caKham?->GioBatDau),
            'GioKetThuc' => $this->timeValue($caKham?->GioKetThuc),
            'TenBacSi' => $bacSi ? trim($bacSi->ho . ' ' . $bacSi->ten) : null,
            'MaKhoa' => $khoa?->MaKhoa,
            'TenKhoa' => $khoa?->TenKhoa,
            'ChuyenKhoa' => $bacSi?->ChuyenKhoa,
            'TenPhong' => $phongKham?->TenPhong,
            'DichVu' => $lich->chiTietLichKham->map(fn ($ct) => [
                'MaChiTiet' => $ct->MaChiTiet,
                'MaDichVu' => $ct->MaDichVu,
                'TenDichVu' => $ct->dichVu?->TenDichVu,
                'SoLuong' => $ct->SoLuong,
                'Gia' => (float) ($ct->DonGia ?? 0),
                'ThanhTien' => (float) ($ct->ThanhTien ?? 0),
                'MoTa' => $ct->MOTA,
                'TrangThaiDuyet' => $ct->TRANGTHAIDUYET,
            ])->values(),
            'ThoiDiemCheckIn' => $lich->ThoiDiemCheckIn,
            'ThoiDiemCheckOut' => $lich->ThoiDiemCheckOut,
        ];
    }

    public function index(Request $request)
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
                'benhNhan.taiKhoan',
                'lichLamViec.bacSi',
                'lichLamViec.caKham',
                'lichLamViec.phongKham',
                'chiTietLichKham.dichVu',
            ]);

            if (!empty($validated['trang_thai'])) {
                $query->where('TrangThai', $validated['trang_thai']);
            }

            if (!empty($validated['ngay_bat_dau'])) {
                $query->whereHas('lichLamViec', function ($q) use ($validated) {
                    $q->where('Ngay', '>=', $validated['ngay_bat_dau']);
                });
            }

            if (!empty($validated['ngay_ket_thuc'])) {
                $query->whereHas('lichLamViec', function ($q) use ($validated) {
                    $q->where('Ngay', '<=', $validated['ngay_ket_thuc']);
                });
            }

            if (!empty($validated['ma_bac_si'])) {
                $query->whereHas('lichLamViec', function ($q) use ($validated) {
                    $q->where('MaBacSi', $validated['ma_bac_si']);
                });
            }

            $appointments = $query->orderBy('MaLichKham', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => collect($appointments->items())->map(fn ($lich) => $this->formatAppointment($lich)),
                'pagination' => [
                    'total' => $appointments->total(),
                    'per_page' => $appointments->perPage(),
                    'current_page' => $appointments->currentPage(),
                    'last_page' => $appointments->lastPage(),
                ],
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Du lieu khong hop le',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function updateStatus(Request $request, $maLichKham)
    {
        try {
            $validated = $request->validate([
                'trang_thai' => 'required|in:pending,confirmed,rejected,completed,cancelled,no-show',
                'trang_thai_thanh_toan' => 'nullable|in:unpaid,paid,partial',
                'ly_do_tu_choi' => 'nullable|string|max:50',
            ]);

            $lichKham = LichKham::findOrFail($maLichKham);

            DB::transaction(function () use ($lichKham, $validated) {
                $lichKham->update([
                    'TrangThai' => $validated['trang_thai'],
                    'TrangThaiThanhToan' => $validated['trang_thai_thanh_toan'] ?? $lichKham->TrangThaiThanhToan,
                ]);

                if (!empty($validated['ly_do_tu_choi'])) {
                    ChiTietLichKham::where('MaLichKham', $lichKham->MaLichKham)
                        ->update(['MOTA' => $validated['ly_do_tu_choi']]);
                }

                if ($validated['trang_thai'] === 'rejected') {
                    ChiTietLichKham::where('MaLichKham', $lichKham->MaLichKham)
                        ->update(['TRANGTHAIDUYET' => 'rejected']);
                } else if ($validated['trang_thai'] === 'confirmed') {
                    ChiTietLichKham::where('MaLichKham', $lichKham->MaLichKham)
                        ->update(['TRANGTHAIDUYET' => 'confirmed']);
                }
            });

            return response()->json([
                'success' => true,
                'message' => 'Cap nhat trang thai thanh cong',
                'data' => $this->formatAppointment($lichKham->fresh()),
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Du lieu khong hop le',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
