<?php

namespace App\Http\Controllers\benhnhan;

use App\Http\Controllers\Controller;
use App\Models\ChiTietLichKham;
use App\Models\DichVu;
use App\Models\LichKham;
use App\Models\LichLamViec;
use Illuminate\Http\Request;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LichKhamController extends Controller
{
    private function currentAccount(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return null;
        }

        return DB::table('taikhoan')
            ->where('AccessToken', $token)
            ->first();
    }

    private function currentPatientId(Request $request): ?int
    {
        $account = $this->currentAccount($request);

        if (!$account) {
            return null;
        }

        $patient = DB::table('benhnhan')
            ->where('MaTaiKhoan', $account->MaTaiKhoan)
            ->first();

        if ($patient) {
            return $patient->MaBenhNhan;
        }

        if (!in_array($account->VaiTro, ['BenhNhan', 'user'], true)) {
            return null;
        }

        return DB::table('benhnhan')->insertGetId([
            'MaTaiKhoan' => $account->MaTaiKhoan,
            'ho' => '',
            'ten' => $account->sdt ?? 'Benh nhan',
        ]);
    }

    private function currentDoctorId(Request $request): ?int
    {
        $account = $this->currentAccount($request);

        if (!$account) {
            return null;
        }

        $doctor = DB::table('bacsi')
            ->where('MaTaiKhoan', $account->MaTaiKhoan)
            ->first();

        return $doctor?->MaBacSi;
    }

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
            'ketLuanKham.benh',
            'donThuoc.chiTiet.thuoc',
            'phieuChiDinh.bacSi.lichLamViec.phongKham',
            'phieuChiDinh.chiTiet.dichVu.khoa'
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
            'KetLuan' => $lich->ketLuanKham ? [
                'MaKetLuan' => $lich->ketLuanKham->MaKetLuan,
                'MaBenh' => $lich->ketLuanKham->MaBenh,
                'TenBenh' => $lich->ketLuanKham->benh?->TenBenh,
                'ChanDoan' => $lich->ketLuanKham->ChanDoan,
                'TinhTrang' => $lich->ketLuanKham->TinhTrang,
                'HuongDieuTri' => $lich->ketLuanKham->HuongDieuTri,
                'NgayKetLuan' => $lich->ketLuanKham->NgayKetLuan,
            ] : null,
            'DonThuoc' => $lich->donThuoc ? [
                'MaDonThuoc' => $lich->donThuoc->MaDonThuoc,
                'NgayKe' => $lich->donThuoc->NgayKe,
                'ChiTiet' => $lich->donThuoc->chiTiet->map(fn ($ct) => [
                    'TenThuoc' => $ct->thuoc?->TenThuoc,
                    'HamLuong' => $ct->thuoc?->HamLuong,
                    'DonViTinh' => $ct->thuoc?->DonViTinh,
                    'SoLuong' => $ct->SoLuong,
                    'LieuDung' => $ct->LieuDung,
                ]),
            ] : null,
            'PhieuChiDinh' => $lich->phieuChiDinh->map(fn ($phieu) => [
                'MaPhieu' => $phieu->MaPhieu,
                'TrangThai' => $phieu->TrangThai,
                'NgayChiDinh' => $phieu->NgayChiDinh,
                'BacSiYeuCau' => $bacSi ? trim($bacSi->ho . ' ' . $bacSi->ten) : null,
                'ChuyenKhoaYeuCau' => $bacSi?->ChuyenKhoa,
                'BacSiThucHien' => $phieu->bacSi ? trim($phieu->bacSi->ho . ' ' . $phieu->bacSi->ten) : null,
                'ChuyenKhoaBacSiThucHien' => $phieu->bacSi?->ChuyenKhoa,
                'TenPhongXetNghiem' => $phieu->bacSi?->lichLamViec?->first()?->phongKham?->TenPhong,
                'KhuPhongXetNghiem' => $phieu->bacSi?->lichLamViec?->first()?->phongKham?->Khu,
                'GhiChu' => $phieu->GhiChu,
                'ChiTiet' => $phieu->chiTiet->map(fn ($ct) => [
                    'MaChiTietPhieu' => $ct->MaChiTietPhieu,
                    'TenDichVu' => $ct->dichVu?->TenDichVu,
                    'MaDichVu' => $ct->dichVu?->MaDichVu,
                    'TenKhoa' => $ct->dichVu?->khoa?->TenKhoa,
                    'Gia' => (float) ($ct->dichVu?->Gia ?? 0),
                    'TrangThai' => $ct->TrangThai,
                    'KetQua' => $ct->KetQua,
                    'ChiSo' => $ct->ChiSo,
                    'NgayCoKetQua' => $ct->NgayCoKetQua,
                ])->values(),
            ])->values(),
        ];
    }

    /**
     * Lay danh sach lich lam viec con cho trong de benh nhan chon.
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
                'lichKham',
            ])
                ->whereBetween('Ngay', [$validated['ngay_bat_dau'], $validated['ngay_ket_thuc']])
                ->whereHas('caKham', function ($q) {
                    $q->where(function ($subQuery) {
                        $subQuery->whereNull('TrangThai')
                            ->orWhere('TrangThai', '!=', 'inactive');
                    });
                });

            if (!empty($validated['ma_khoa'])) {
                $query->whereHas('bacSi', function ($q) use ($validated) {
                    $tenKhoa = DB::table('khoa')
                        ->where('MaKhoa', $validated['ma_khoa'])
                        ->value('TenKhoa');

                    $q->where('ChuyenKhoa', $tenKhoa);
                });
            }

            $schedules = $query
                ->orderBy('Ngay')
                ->orderBy('MaCa')
                ->get()
                ->map(function ($schedule) {
                    $khoa = $this->khoaTheoChuyenKhoa($schedule->bacSi?->ChuyenKhoa);
                    $soLuongDaDat = $schedule->lichKham
                        ->where('TrangThai', '!=', 'cancelled')
                        ->count();
                    $soLuongToiDa = (int) ($schedule->caKham?->SoLuongToiDa ?? 0);
                    $soChoTrong = max($soLuongToiDa - $soLuongDaDat, 0);

                    return [
                        'MaLichLamViec' => $schedule->MaLichLamViec,
                        'MaBacSi' => $schedule->MaBacSi,
                        'TenBacSi' => $schedule->bacSi ? trim($schedule->bacSi->ho . ' ' . $schedule->bacSi->ten) : null,
                        'MaKhoa' => $khoa?->MaKhoa,
                        'TenKhoa' => $khoa?->TenKhoa,
                        'ChuyenKhoa' => $schedule->bacSi?->ChuyenKhoa,
                        'Ngay' => $this->dateValue($schedule->Ngay),
                        'TenCa' => $schedule->caKham?->TenCa,
                        'GioBatDau' => $this->timeValue($schedule->caKham?->GioBatDau),
                        'GioKetThuc' => $this->timeValue($schedule->caKham?->GioKetThuc),
                        'TenPhong' => $schedule->phongKham?->TenPhong,
                        'SoChoTrong' => $soChoTrong,
                        'SoLuongToiDa' => $soLuongToiDa,
                    ];
                })
                ->filter(fn ($schedule) => $schedule['SoChoTrong'] > 0)
                ->values();

            return response()->json([
                'success' => true,
                'data' => $schedules,
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

    /**
     * Dat lich kham moi.
     */
    public function bookAppointment(Request $request)
    {
        try {
            $validated = $request->validate([
                'ma_benh_nhan' => 'nullable|integer|exists:benhnhan,MaBenhNhan',
                'ma_lich_lam_viec' => 'required|integer|exists:lichlamviec,MaLichLamViec',
                'dich_vu_ids' => 'nullable|array',
                'dich_vu_ids.*' => 'integer|distinct|exists:dichvu,MaDichVu',
            ]);

            $account = $this->currentAccount($request);
            $tokenPatientId = $this->currentPatientId($request);
            $maBenhNhan = $tokenPatientId ?? ($validated['ma_benh_nhan'] ?? null);

            if (!$maBenhNhan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Khong tim thay thong tin benh nhan',
                ], 401);
            }

            if ($tokenPatientId && !empty($validated['ma_benh_nhan']) && (int) $validated['ma_benh_nhan'] !== (int) $tokenPatientId) {
                return response()->json([
                    'success' => false,
                    'message' => 'Ban khong co quyen dat lich cho benh nhan nay',
                ], 403);
            }

            if ($account && !in_array($account->VaiTro, ['BenhNhan', 'user', 'admin'], true)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tai khoan nay khong duoc phep dat lich kham',
                ], 403);
            }

            $dichVuIds = $validated['dich_vu_ids'] ?? [];

            $lichKham = DB::transaction(function () use ($validated, $maBenhNhan, $dichVuIds) {
                $lichLamViec = LichLamViec::with(['bacSi', 'caKham'])
                    ->where('MaLichLamViec', $validated['ma_lich_lam_viec'])
                    ->lockForUpdate()
                    ->firstOrFail();
                $khoa = $this->khoaTheoChuyenKhoa($lichLamViec->bacSi?->ChuyenKhoa);

                if ($lichLamViec->caKham?->TrangThai === 'inactive') {
                    throw new HttpResponseException(response()->json([
                        'success' => false,
                        'message' => 'Ca kham nay dang tam ngung',
                    ], 422));
                }

                $lichTrongNgay = LichKham::where('MaBenhNhan', $maBenhNhan)
                    ->whereNotIn('TrangThai', ['cancelled', 'rejected'])
                    ->whereHas('lichLamViec', function ($q) use ($lichLamViec) {
                        $q->where('Ngay', $this->dateValue($lichLamViec->Ngay));
                    })
                    ->exists();

                if ($lichTrongNgay) {
                    throw new HttpResponseException(response()->json([
                        'success' => false,
                        'message' => 'Ban da co lich kham vao ngay nay',
                    ], 422));
                }

                $appointmentsCount = LichKham::where('MaLichLamViec', $validated['ma_lich_lam_viec'])
                    ->whereNotIn('TrangThai', ['cancelled', 'rejected'])
                    ->lockForUpdate()
                    ->count();

                $soLuongDaDat = $appointmentsCount;
                $soLuongToiDa = (int) ($lichLamViec->caKham?->SoLuongToiDa ?? 0);

                if ($soLuongToiDa <= 0 || $soLuongDaDat >= $soLuongToiDa) {
                    throw new HttpResponseException(response()->json([
                        'success' => false,
                        'message' => 'Lich kham nay da day',
                    ], 422));
                }

                $lichKham = LichKham::create([
                    'MaBenhNhan' => $maBenhNhan,
                    'MaLichLamViec' => $validated['ma_lich_lam_viec'],
                    'SoThuTu' => $appointmentsCount + 1,
                    'TrangThai' => 'pending',
                    'TrangThaiThanhToan' => 'unpaid',
                    'TongTien' => 0,
                ]);

                $tongTien = 0;
                if (!empty($dichVuIds)) {
                    if (!$khoa) {
                        throw new HttpResponseException(response()->json([
                            'success' => false,
                            'message' => 'Chua xac dinh khoa cua bac si da chon',
                        ], 422));
                    }

                    $dichVus = DichVu::whereIn('MaDichVu', $dichVuIds)->get()->keyBy('MaDichVu');

                    foreach ($dichVuIds as $dichVuId) {
                        $dichVu = $dichVus[$dichVuId];
                        if ($khoa && (int) $dichVu->MaKhoa !== (int) $khoa->MaKhoa) {
                            throw new HttpResponseException(response()->json([
                                'success' => false,
                                'message' => 'Dich vu khong thuoc khoa cua bac si da chon',
                            ], 422));
                        }

                        $donGia = (float) ($dichVu->Gia ?? 0);
                        $tongTien += $donGia;

                        ChiTietLichKham::create([
                            'MaLichKham' => $lichKham->MaLichKham,
                            'MaDichVu' => $dichVuId,
                            'SoLuong' => 1,
                            'DonGia' => $donGia,
                            'ThanhTien' => $donGia,
                        ]);
                    }
                }

                $lichKham->update(['TongTien' => $tongTien]);

                return $lichKham->fresh();
            });

            return response()->json([
                'success' => true,
                'message' => 'Dat lich kham thanh cong',
                'data' => $this->formatAppointment($lichKham),
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Du lieu khong hop le',
                'errors' => $e->errors(),
            ], 422);
        } catch (HttpResponseException $e) {
            return $e->getResponse();
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lay danh sach lich kham cua benh nhan dang dang nhap.
     */
    public function getMyAppointments(Request $request)
    {
        try {
            $maBenhNhan = $this->currentPatientId($request) ?? $request->query('ma_benh_nhan');

            if (!$maBenhNhan) {
                return response()->json([
                    'success' => false,
                    'message' => 'Khong tim thay thong tin benh nhan',
                ], 401);
            }

            $lichKhams = LichKham::where('MaBenhNhan', $maBenhNhan)
                ->with([
                    'lichLamViec.bacSi',
                    'lichLamViec.caKham',
                    'lichLamViec.phongKham',
                    'chiTietLichKham.dichVu',
                ])
                ->orderBy('MaLichKham', 'desc')
                ->get()
                ->map(fn ($lich) => $this->formatAppointment($lich));

            return response()->json([
                'success' => true,
                'data' => $lichKhams,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Huy lich kham.
     */
    public function cancelAppointment(Request $request, $maLichKham)
    {
        try {
            $account = $this->currentAccount($request);
            $maBenhNhan = $this->currentPatientId($request);

            if (!$account) {
                return response()->json([
                    'success' => false,
                    'message' => 'Token khong hop le',
                ], 401);
            }

            $lichKham = LichKham::findOrFail($maLichKham);

            if ((int) $lichKham->MaBenhNhan !== (int) $maBenhNhan && $account->VaiTro !== 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Ban khong co quyen huy lich nay',
                ], 403);
            }

            if (in_array($lichKham->TrangThai, ['completed', 'cancelled'], true)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Khong the huy lich o trang thai hien tai',
                ], 422);
            }

            $lichKham->update(['TrangThai' => 'cancelled']);

            return response()->json([
                'success' => true,
                'message' => 'Huy lich kham thanh cong',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lay danh sach lich kham cua bac si dang dang nhap.
     */
    public function getDoctorSchedule(Request $request)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);

            if (!$maBacSi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Khong tim thay thong tin bac si',
                ], 401);
            }

            $validated = $request->validate([
                'ngay_bat_dau' => 'nullable|date',
                'ngay_ket_thuc' => 'nullable|date',
            ]);

            $query = LichLamViec::where('MaBacSi', $maBacSi)
                ->with(['caKham', 'phongKham', 'lichKham.benhNhan', 'lichKham.chiTietLichKham.dichVu']);

            if (!empty($validated['ngay_bat_dau'])) {
                $query->where('Ngay', '>=', $validated['ngay_bat_dau']);
            }

            if (!empty($validated['ngay_ket_thuc'])) {
                $query->where('Ngay', '<=', $validated['ngay_ket_thuc']);
            }

            $schedules = $query->orderBy('Ngay', 'asc')
                ->orderBy('MaLichLamViec', 'asc')
                ->get()
                ->map(function ($schedule) {
                    return [
                        'MaLichLamViec' => $schedule->MaLichLamViec,
                        'Ngay' => $this->dateValue($schedule->Ngay),
                        'TenCa' => $schedule->caKham?->TenCa,
                        'GioBatDau' => $this->timeValue($schedule->caKham?->GioBatDau),
                        'GioKetThuc' => $this->timeValue($schedule->caKham?->GioKetThuc),
                        'TenPhong' => $schedule->phongKham?->TenPhong,
                        'SoLuongToiDa' => $schedule->caKham?->SoLuongToiDa,
                        'LichKham' => $schedule->lichKham->map(function ($lich) {
                            return [
                                'MaLichKham' => $lich->MaLichKham,
                                'SoThuTu' => $lich->SoThuTu,
                                'TenBenhNhan' => $lich->benhNhan ? trim($lich->benhNhan->ho . ' ' . $lich->benhNhan->ten) : null,
                                'TrangThai' => $lich->TrangThai,
                                'TongTien' => (float) ($lich->TongTien ?? 0),
                                'DichVu' => $lich->chiTietLichKham->map(fn ($ct) => [
                                    'TenDichVu' => $ct->dichVu?->TenDichVu,
                                    'Gia' => (float) ($ct->DonGia ?? 0),
                                ]),
                                'ThoiDiemCheckIn' => $lich->ThoiDiemCheckIn,
                            ];
                        })->values(),
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $schedules,
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

    /**
     * Lấy hoá đơn của bệnh nhân
     * GET /lich-kham/{maLichKham}/hoa-don
     */
    public function getHoaDon(Request $request, $maLichKham)
    {
        try {
            $maBenhNhan = $this->currentPatientId($request);
            if (!$maBenhNhan) {
                return response()->json(['success' => false, 'message' => 'Bệnh nhân không được xác định'], 401);
            }

            // Kiểm tra lịch khám thuộc về bệnh nhân
            $lichKham = DB::table('lichkham')
                ->where('MaLichKham', $maLichKham)
                ->where('MaBenhNhan', $maBenhNhan)
                ->first();

            if (!$lichKham) {
                return response()->json(['success' => false, 'message' => 'Lịch khám không tồn tại'], 404);
            }

            // Lấy hoá đơn
            $hoaDon = DB::table('hoadon as hd')
                ->leftJoin('benhnhan as bn', 'hd.MaBenhNhan', '=', 'bn.MaBenhNhan')
                ->leftJoin('lichkham as lk', 'hd.MaLichKham', '=', 'lk.MaLichKham')
                ->leftJoin('lichlamviec as llv', 'lk.MaLichLamViec', '=', 'llv.MaLichLamViec')
                ->leftJoin('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
                ->where('hd.MaLichKham', $maLichKham)
                ->select(
                    'hd.MaHoaDon',
                    'hd.MaBenhNhan',
                    DB::raw("CONCAT(bn.ho, ' ', bn.ten) as TenBenhNhan"),
                    'bn.cccd',
                    'bn.diachi',
                    'bn.BHYT',
                    DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                    'bs.ChuyenKhoa',
                    'hd.LoaiHoaDon',
                    'hd.TongTien',
                    'hd.GiamBHYT',
                    'hd.SoTienPhaiTra',
                    'hd.TrangThai',
                    'hd.NgayTao'
                )
                ->first();

            if (!$hoaDon) {
                return response()->json(['success' => false, 'message' => 'Hoá đơn không tồn tại'], 404);
            }

            // Lấy chi tiết hoá đơn
            $chiTiet = DB::table('ct_hoadon')
                ->where('MaHoaDon', $hoaDon->MaHoaDon)
                ->select('TenHienThi', 'SoLuong', 'DonGia', 'ThanhTien')
                ->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'hoaDon' => $hoaDon,
                    'chiTiet' => $chiTiet
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Lấy danh sách lịch khám hôm nay cho nhân viên check-in
     * GET /admin/lich-kham-hom-nay
     */
    public function getLichKhamHomNay(Request $request)
    {
        try {
            $token = $request->bearerToken();
            if (!$token) {
                return response()->json(['success' => false, 'message' => 'Token không hợp lệ'], 401);
            }

            $account = DB::table('taikhoan')->where('AccessToken', $token)->first();
            if (!$account || !in_array($account->VaiTro, ['admin', 'nhanvien', 'receptionist', 'checkin'], true)) {
                return response()->json(['success' => false, 'message' => 'Bạn không có quyền'], 403);
            }

            $today = now()->toDateString();
            $search = $request->query('search', '');
            $filter = $request->query('filter', 'all'); // all, not_checked_in, checked_in

            $query = DB::table('lichkham as lk')
                ->join('benhnhan as bn', 'lk.MaBenhNhan', '=', 'bn.MaBenhNhan')
                ->join('lichlamviec as llv', 'lk.MaLichLamViec', '=', 'llv.MaLichLamViec')
                ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
                ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
                ->leftJoin('taikhoan as tk', 'bn.MaTaiKhoan', '=', 'tk.MaTaiKhoan')
                ->where('llv.Ngay', $today)
                ->where('lk.TrangThai', 'confirmed')
                ->select(
                    'lk.MaLichKham',
                    'lk.SoThuTu',
                    DB::raw("CONCAT(bn.ho, ' ', bn.ten) as TenBenhNhan"),
                    'bn.cccd',
                    'bn.diachi',
                    'tk.sdt',
                    DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                    'bs.ChuyenKhoa',
                    'ck.TenCa',
                    'ck.GioBatDau',
                    'ck.GioKetThuc',
                    'lk.ThoiDiemCheckIn',
                    'lk.ThoiDiemCheckOut',
                    'lk.TrangThai'
                );

            // Áp dụng filter
            if ($filter === 'not_checked_in') {
                $query->whereNull('lk.ThoiDiemCheckIn');
            } elseif ($filter === 'checked_in') {
                $query->whereNotNull('lk.ThoiDiemCheckIn');
            }

            // Áp dụng tìm kiếm
            if (!empty($search)) {
                $query->where(function ($q) use ($search) {
                    $q->where('bn.ho', 'like', "%{$search}%")
                      ->orWhere('bn.ten', 'like', "%{$search}%")
                      ->orWhere('bn.cccd', 'like', "%{$search}%")
                      ->orWhere('bs.ho', 'like', "%{$search}%")
                      ->orWhere('bs.ten', 'like', "%{$search}%")
                      ->orWhere('lk.SoThuTu', $search);
                });
            }

            $lichKham = $query
                ->orderBy('lk.ThoiDiemCheckIn', 'desc')
                ->orderBy('lk.SoThuTu', 'asc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $lichKham,
                'total' => count($lichKham),
                'today' => $today
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Check-in bệnh nhân
     * POST /admin/lich-kham/{maLichKham}/check-in
     */
    public function checkIn(Request $request, $maLichKham)
    {
        try {
            $token = $request->bearerToken();
            if (!$token) {
                return response()->json(['success' => false, 'message' => 'Token không hợp lệ'], 401);
            }

            $account = DB::table('taikhoan')->where('AccessToken', $token)->first();
            if (!$account || !in_array($account->VaiTro, ['admin', 'nhanvien', 'receptionist', 'checkin'], true)) {
                return response()->json(['success' => false, 'message' => 'Bạn không có quyền'], 403);
            }

            $lichKham = DB::table('lichkham')->where('MaLichKham', $maLichKham)->first();
            if (!$lichKham) {
                return response()->json(['success' => false, 'message' => 'Không tìm thấy lịch khám'], 404);
            }

            if ($lichKham->ThoiDiemCheckIn) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bệnh nhân đã check-in rồi',
                    'ThoiDiemCheckIn' => $lichKham->ThoiDiemCheckIn
                ], 422);
            }

            // Update check-in time
            DB::table('lichkham')
                ->where('MaLichKham', $maLichKham)
                ->update([
                    'ThoiDiemCheckIn' => now(),
                    'MaNhanVienCheckIn' => 1,
                ]);

            $updated = DB::table('lichkham')->where('MaLichKham', $maLichKham)->first();

            return response()->json([
                'success' => true,
                'message' => 'Check-in thành công',
                'data' => [
                    'MaLichKham' => $updated->MaLichKham,
                    'ThoiDiemCheckIn' => $updated->ThoiDiemCheckIn,
                    'TrangThai' => $updated->TrangThai
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Check-out bệnh nhân
     * PATCH /admin/lich-kham/{maLichKham}/check-out
     */
    public function checkOut(Request $request, $maLichKham)
    {
        try {
            $token = $request->bearerToken();
            if (!$token) {
                return response()->json(['success' => false, 'message' => 'Token không hợp lệ'], 401);
            }

            $account = DB::table('taikhoan')->where('AccessToken', $token)->first();
            if (!$account || !in_array($account->VaiTro, ['admin', 'nhanvien', 'receptionist', 'checkin'], true)) {
                return response()->json(['success' => false, 'message' => 'Bạn không có quyền'], 403);
            }

            $lichKham = DB::table('lichkham')->where('MaLichKham', $maLichKham)->first();
            if (!$lichKham) {
                return response()->json(['success' => false, 'message' => 'Không tìm thấy lịch khám'], 404);
            }

            if (!$lichKham->ThoiDiemCheckIn) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bệnh nhân chưa check-in'
                ], 422);
            }

            // Update check-out time
            DB::table('lichkham')
                ->where('MaLichKham', $maLichKham)
                ->update([
                    'ThoiDiemCheckOut' => now(),
                ]);

            $updated = DB::table('lichkham')->where('MaLichKham', $maLichKham)->first();

            return response()->json([
                'success' => true,
                'message' => 'Check-out thành công',
                'data' => [
                    'MaLichKham' => $updated->MaLichKham,
                    'ThoiDiemCheckIn' => $updated->ThoiDiemCheckIn,
                    'ThoiDiemCheckOut' => $updated->ThoiDiemCheckOut,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}

