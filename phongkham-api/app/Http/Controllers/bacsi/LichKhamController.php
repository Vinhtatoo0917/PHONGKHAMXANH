<?php

namespace App\Http\Controllers\bacsi;

use App\Http\Controllers\Controller;
use App\Models\LichKham;
use App\Models\LichLamViec;
use App\Models\Benh;
use App\Models\KetLuanKham;
use App\Models\DonThuoc;
use App\Models\CtDonThuoc;
use App\Models\Thuoc;
use App\Models\PhieuChiDinh;
use App\Models\ChiTietPhieuChiDinh;
use App\Models\BacSi;
use App\Models\DichVu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class LichKhamController extends Controller
{
    private function currentAccount(Request $request)
    {
        $token = $request->bearerToken();
        if (!$token) return null;

        return DB::table('taikhoan')->where('AccessToken', $token)->first();
    }

    private function currentDoctorId(Request $request): ?int
    {
        $account = $this->currentAccount($request);
        if (!$account) return null;

        return DB::table('bacsi')->where('MaTaiKhoan', $account->MaTaiKhoan)->value('MaBacSi');
    }

    public function index(Request $request)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            $validated = $request->validate([
                'ngay_bat_dau' => 'nullable|date',
                'ngay_ket_thuc' => 'nullable|date',
            ]);

            $query = LichLamViec::where('MaBacSi', $maBacSi)
                ->with(['caKham', 'phongKham', 'lichKham' => function($q) {
                    $q->whereIn('TrangThai', ['confirmed', 'examining', 'completed', 'no-show']);
                }, 'lichKham.benhNhan', 'lichKham.chiTietLichKham.dichVu', 'lichKham.ketLuanKham', 'lichKham.donThuoc.chiTiet.thuoc', 'lichKham.phieuChiDinh.bacSi', 'lichKham.phieuChiDinh.chiTiet.dichVu.khoa']);

            if (!empty($validated['ngay_bat_dau'])) {
                $query->where('Ngay', '>=', $validated['ngay_bat_dau']);
            }

            if (!empty($validated['ngay_ket_thuc'])) {
                $query->where('Ngay', '<=', $validated['ngay_ket_thuc']);
            }

            $schedules = $query->orderBy('Ngay', 'asc')
                ->get()
                ->map(function ($schedule) {
                    return [
                        'MaLichLamViec' => $schedule->MaLichLamViec,
                        'Ngay' => $schedule->Ngay->format('Y-m-d'),
                        'TenCa' => $schedule->caKham?->TenCa,
                        'GioBatDau' => $schedule->caKham?->GioBatDau,
                        'GioKetThuc' => $schedule->caKham?->GioKetThuc,
                        'TenPhong' => $schedule->phongKham?->TenPhong,
                        'LichKham' => $schedule->lichKham->map(function ($lich) {
                            return [
                                'MaLichKham' => $lich->MaLichKham,
                                'SoThuTu' => $lich->SoThuTu,
                                'TenBenhNhan' => $lich->benhNhan ? trim($lich->benhNhan->ho . ' ' . $lich->benhNhan->ten) : 'N/A',
                                'TrangThai' => $lich->TrangThai,
                                'ThoiDiemCheckIn' => $lich->ThoiDiemCheckIn,
                                'KetLuan' => $lich->ketLuanKham,
                                'DonThuoc' => $lich->donThuoc ? [
                                    'MaDonThuoc' => $lich->donThuoc->MaDonThuoc,
                                    'ChiTiet' => $lich->donThuoc->chiTiet->map(function($ct) {
                                        return [
                                            'MaThuoc' => $ct->MaThuoc,
                                            'TenThuoc' => $ct->thuoc?->TenThuoc,
                                            'HamLuong' => $ct->thuoc?->HamLuong,
                                            'DonViTinh' => $ct->thuoc?->DonViTinh,
                                            'SoLuong' => $ct->SoLuong,
                                            'LieuDung' => $ct->LieuDung,
                                        ];
                                    })
                                ] : null,
                                'PhieuChiDinh' => $lich->phieuChiDinh->map(function ($phieu) {
                                    return [
                                        'MaPhieu' => $phieu->MaPhieu,
                                        'TrangThai' => $phieu->TrangThai,
                                        'GhiChu' => $phieu->GhiChu,
                                        'NgayChiDinh' => $phieu->NgayChiDinh,
                                        'BacSiThucHien' => $phieu->bacSi ? trim($phieu->bacSi->ho . ' ' . $phieu->bacSi->ten) : null,
                                        'ChiTiet' => $phieu->chiTiet->map(function ($ct) {
                                            return [
                                                'MaChiTietPhieu' => $ct->MaChiTietPhieu,
                                                'TenDichVu' => $ct->dichVu?->TenDichVu,
                                                'TenKhoa' => $ct->dichVu?->khoa?->TenKhoa,
                                                'Gia' => $ct->dichVu?->Gia,
                                                'TrangThai' => $ct->TrangThai,
                                                'KetQua' => $ct->KetQua,
                                                'ChiSo' => $ct->ChiSo,
                                                'FileKetQua' => $ct->FileKetQua,
                                                'NgayCoKetQua' => $ct->NgayCoKetQua,
                                            ];
                                        })
                                    ];
                                }),
                            ];
                        })->values(),
                    ];
                });

            return response()->json(['success' => true, 'data' => $schedules]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function updateStatus(Request $request, $maLichKham)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            $validated = $request->validate([
                'trang_thai' => 'required|in:confirmed,completed,no-show',
            ]);

            $lichKham = LichKham::where('MaLichKham', $maLichKham)
                ->whereHas('lichLamViec', function($q) use ($maBacSi) {
                    $q->where('MaBacSi', $maBacSi);
                })
                ->firstOrFail();

            $lichKham->update(['TrangThai' => $validated['trang_thai']]);

            return response()->json([
                'success' => true,
                'message' => 'Cap nhat trang thai thanh cong',
                'trang_thai' => $validated['trang_thai']
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
    public function getBenhList()
    {
        try {
            $list = Benh::all(['MaBenh', 'TenBenh']);
            return response()->json(['success' => true, 'data' => $list]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function ketLuanKham(Request $request)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            $validated = $request->validate([
                'ma_lich_kham' => 'required|exists:lichkham,MaLichKham',
                'ma_benh' => 'required|exists:benh,MaBenh',
                'chan_doan' => 'required|string',
                'tinh_trang' => 'required|string',
                'huong_dieu_tri' => 'required|string',
            ]);

            $lichKham = LichKham::where('MaLichKham', $validated['ma_lich_kham'])
                ->whereHas('lichLamViec', function($q) use ($maBacSi) {
                    $q->where('MaBacSi', $maBacSi);
                })
                ->firstOrFail();

            DB::beginTransaction();
            try {
                $ketLuan = KetLuanKham::updateOrCreate(
                    ['MaLichKham' => $validated['ma_lich_kham']],
                    [
                        'MaBacSi' => $maBacSi,
                        'MaBenh' => $validated['ma_benh'],
                        'ChanDoan' => $validated['chan_doan'],
                        'TinhTrang' => $validated['tinh_trang'],
                        'HuongDieuTri' => $validated['huong_dieu_tri'],
                        'NgayKetLuan' => Carbon::now(),
                    ]
                );

                // Xu ly don thuoc neu co
                if ($request->has('don_thuoc') && is_array($request->don_thuoc)) {
                    // Xoa don thuoc cu neu co
                    $oldDonThuoc = DonThuoc::where('MaLichKham', $validated['ma_lich_kham'])->first();
                    if ($oldDonThuoc) {
                        CtDonThuoc::where('MaDonThuoc', $oldDonThuoc->MaDonThuoc)->delete();
                        $oldDonThuoc->delete();
                    }

                    $donThuoc = DonThuoc::create([
                        'MaLichKham' => $validated['ma_lich_kham'],
                        'MaBacSi' => $maBacSi,
                        'NgayKe' => Carbon::now(),
                    ]);

                    foreach ($request->don_thuoc as $item) {
                        CtDonThuoc::create([
                            'MaDonThuoc' => $donThuoc->MaDonThuoc,
                            'MaThuoc' => $item['ma_thuoc'],
                            'LieuDung' => $item['lieu_dung'],
                            'SoLuong' => $item['so_luong'],
                        ]);
                    }
                }

                // Cap nhat trang thai lich kham thanh completed
                $lichKham->update(['TrangThai' => 'completed']);

                // Tao hoa don tu cac dich vu da su dung
                $this->taoHoaDon($validated['ma_lich_kham'], $lichKham->MaBenhNhan);

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'Ket luan kham va ke don thanh cong',
                    'data' => $ketLuan
                ]);
            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function getServicesByBenh($maBenh)
    {
        try {
            $benh = Benh::with('dichVu')->where('MaBenh', $maBenh)->firstOrFail();
            return response()->json(['success' => true, 'data' => $benh->dichVu]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function getTestingDoctors($maLichKham)
    {
        try {
            // Lấy ca + ngày của lịch khám hiện tại để chỉ trả bác sĩ đang làm ca đó
            $lichKham = LichKham::with('lichLamViec')->where('MaLichKham', $maLichKham)->first();
            if (!$lichKham || !$lichKham->lichLamViec) {
                return response()->json([
                    'success' => false,
                    'message' => 'Khong tim thay lich kham hoac lich lam viec tuong ung'
                ], 404);
            }

            $ngay = $lichKham->lichLamViec->Ngay;
            $maCa = $lichKham->lichLamViec->MaCa;

            // Bác sĩ thuộc khoa Xét nghiệm VÀ có lịch làm việc cùng ngày + ca với lịch khám này
            $doctors = BacSi::where(function ($q) {
                    $q->where('ChuyenKhoa', 'like', '%Xét nghiệm%')
                      ->orWhere('ChuyenKhoa', 'like', '%XN%');
                })
                ->whereHas('lichLamViec', function ($q) use ($ngay, $maCa) {
                    $q->whereDate('Ngay', $ngay)->where('MaCa', $maCa);
                })
                ->get(['MaBacSi', 'ho', 'ten', 'ChuyenKhoa']);

            return response()->json(['success' => true, 'data' => $doctors]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function getAllServices()
    {
        try {
            // Chỉ lấy các dịch vụ thuộc các khoa cận lâm sàng/hỗ trợ (Xét nghiệm, CĐHA, ...)
            // Loại bỏ các dịch vụ thuộc Khoa Khám bệnh (ID 1)
            $services = DichVu::where('MaKhoa', '!=', 1)
                ->get(['MaDichVu', 'TenDichVu', 'Gia']);
            return response()->json(['success' => true, 'data' => $services]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function taoPhieuChiDinh(Request $request)
    {
        try {
            $maBacSiChiDinh = $this->currentDoctorId($request);
            if (!$maBacSiChiDinh) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            $validated = $request->validate([
                'ma_lich_kham' => 'required|exists:lichkham,MaLichKham',
                'ma_bac_si_thuc_hien' => 'required|exists:bacsi,MaBacSi',
                'ghi_chu' => 'nullable|string',
                'dich_vu' => 'required|array|min:1',
                'dich_vu.*.ma_dich_vu' => 'required|exists:dichvu,MaDichVu',
            ]);

            DB::beginTransaction();
            try {
                $phieu = PhieuChiDinh::create([
                    'MaLichKham' => $validated['ma_lich_kham'],
                    'MaBacSi' => $validated['ma_bac_si_thuc_hien'], // Ở đây gán cho bác sĩ thực hiện (xét nghiệm)
                    'NgayChiDinh' => Carbon::now(),
                    'TrangThai' => 'pending',
                    'GhiChu' => $validated['ghi_chu']
                ]);

                foreach ($validated['dich_vu'] as $item) {
                    ChiTietPhieuChiDinh::create([
                        'MaPhieu' => $phieu->MaPhieu,
                        'MaDichVu' => $item['ma_dich_vu'],
                        'TrangThai' => 'pending'
                    ]);
                }

                DB::commit();
                return response()->json(['success' => true, 'message' => 'Tao phieu chi dinh thanh cong', 'data' => $phieu]);
            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function phieuChiDinhCuaToi(Request $request)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            $validated = $request->validate([
                'ngay_bat_dau' => 'nullable|date',
                'ngay_ket_thuc' => 'nullable|date',
                'trang_thai' => 'nullable|in:pending,processing,completed',
            ]);

            $query = PhieuChiDinh::where('MaBacSi', $maBacSi)
                ->with([
                    'lichKham.benhNhan.taiKhoan',
                    'lichKham.ketLuanKham.benh',
                    'lichKham.lichLamViec.bacSi',
                    'lichKham.lichLamViec.caKham',
                    'lichKham.lichLamViec.phongKham',
                    'chiTiet.dichVu.khoa',
                ]);

            if (!empty($validated['trang_thai'])) {
                $query->where('TrangThai', $validated['trang_thai']);
            }

            if (!empty($validated['ngay_bat_dau'])) {
                $query->whereDate('NgayChiDinh', '>=', $validated['ngay_bat_dau']);
            }

            if (!empty($validated['ngay_ket_thuc'])) {
                $query->whereDate('NgayChiDinh', '<=', $validated['ngay_ket_thuc']);
            }

            $phieus = $query->orderBy('NgayChiDinh', 'desc')->get()->map(function ($phieu) {
                $lichKham = $phieu->lichKham;
                $benhNhan = $lichKham?->benhNhan;
                $taiKhoan = $benhNhan?->taiKhoan;
                $lichLamViec = $lichKham?->lichLamViec;
                $bacSiYC = $lichLamViec?->bacSi;
                $ketLuan = $lichKham?->ketLuanKham;

                $ngaySinh = $benhNhan?->ngaysinh;
                $tuoi = null;
                if ($ngaySinh) {
                    try {
                        $tuoi = Carbon::parse($ngaySinh)->age;
                    } catch (\Exception $e) {
                        $tuoi = null;
                    }
                }

                return [
                    'MaPhieu' => $phieu->MaPhieu,
                    'MaLichKham' => $phieu->MaLichKham,
                    'NgayChiDinh' => $phieu->NgayChiDinh,
                    'TrangThai' => $phieu->TrangThai,
                    'GhiChu' => $phieu->GhiChu,
                    'TenBenhNhan' => $benhNhan ? trim($benhNhan->ho . ' ' . $benhNhan->ten) : 'N/A',
                    'NgaySinh' => $ngaySinh ? Carbon::parse($ngaySinh)->format('d/m/Y') : null,
                    'Tuoi' => $tuoi,
                    'GioiTinh' => $benhNhan?->gioitinh,
                    'CCCD' => $benhNhan?->cccd,
                    'DiaChi' => $benhNhan?->diachi,
                    'BHYT' => $benhNhan?->BHYT,
                    'SoDienThoai' => $taiKhoan?->sdt,
                    'Email' => $taiKhoan?->email,
                    'SoThuTu' => $lichKham?->SoThuTu,
                    'BacSiYeuCau' => $bacSiYC ? trim($bacSiYC->ho . ' ' . $bacSiYC->ten) : null,
                    'ChuyenKhoaYeuCau' => $bacSiYC?->ChuyenKhoa,
                    'NgayKham' => $lichLamViec?->Ngay?->format('Y-m-d'),
                    'TenCa' => $lichLamViec?->caKham?->TenCa,
                    'GioBatDau' => $lichLamViec?->caKham?->GioBatDau,
                    'GioKetThuc' => $lichLamViec?->caKham?->GioKetThuc,
                    'TenPhong' => $lichLamViec?->phongKham?->TenPhong,
                    'ChanDoan' => $ketLuan?->ChanDoan,
                    'TinhTrang' => $ketLuan?->TinhTrang,
                    'HuongDieuTri' => $ketLuan?->HuongDieuTri,
                    'TenBenh' => $ketLuan?->benh?->TenBenh,
                    'ChiTiet' => $phieu->chiTiet->map(function ($ct) {
                        return [
                            'MaChiTietPhieu' => $ct->MaChiTietPhieu,
                            'MaDichVu' => $ct->dichVu?->MaDichVu,
                            'TenDichVu' => $ct->dichVu?->TenDichVu,
                            'MaDichVuYTe' => $ct->dichVu?->madichvuyte,
                            'Gia' => $ct->dichVu?->Gia,
                            'TenKhoa' => $ct->dichVu?->khoa?->TenKhoa,
                            'TrangThai' => $ct->TrangThai,
                            'KetQua' => $ct->KetQua,
                            'ChiSo' => $ct->ChiSo,
                            'NgayCoKetQua' => $ct->NgayCoKetQua,
                        ];
                    })->values(),
                ];
            });

            return response()->json(['success' => true, 'data' => $phieus]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function tiepNhanPhieuChiDinh(Request $request, $maPhieu)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            $phieu = PhieuChiDinh::where('MaPhieu', $maPhieu)
                ->where('MaBacSi', $maBacSi)
                ->first();

            if (!$phieu) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay phieu chi dinh hoac ban khong co quyen'], 404);
            }

            if ($phieu->TrangThai !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'Phieu nay khong o trang thai cho tiep nhan (hien tai: ' . $phieu->TrangThai . ')'
                ], 422);
            }

            DB::beginTransaction();
            try {
                $phieu->update(['TrangThai' => 'processing']);
                ChiTietPhieuChiDinh::where('MaPhieu', $maPhieu)
                    ->where('TrangThai', 'pending')
                    ->update(['TrangThai' => 'processing']);

                DB::commit();
                return response()->json([
                    'success' => true,
                    'message' => 'Da tiep nhan phieu chi dinh',
                    'trang_thai' => 'processing',
                ]);
            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function hoanTatPhieuChiDinh(Request $request, $maPhieu)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            $validated = $request->validate([
                'ket_qua' => 'required|array|min:1',
                'ket_qua.*.ma_chi_tiet_phieu' => 'required|integer',
                'ket_qua.*.ket_qua' => 'nullable|string',
                'ket_qua.*.chi_so' => 'nullable|string|max:100',
                'ket_qua.*.file_ket_qua' => 'nullable|string|max:255',
            ]);

            $phieu = PhieuChiDinh::where('MaPhieu', $maPhieu)
                ->where('MaBacSi', $maBacSi)
                ->first();

            if (!$phieu) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay phieu chi dinh hoac ban khong co quyen'], 404);
            }

            if (!in_array($phieu->TrangThai, ['processing', 'pending'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Phieu nay da o trang thai ' . $phieu->TrangThai . ', khong the cap nhat'
                ], 422);
            }

            $chiTietIds = ChiTietPhieuChiDinh::where('MaPhieu', $maPhieu)->pluck('MaChiTietPhieu')->all();
            foreach ($validated['ket_qua'] as $item) {
                if (!in_array($item['ma_chi_tiet_phieu'], $chiTietIds)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Chi tiet phieu ' . $item['ma_chi_tiet_phieu'] . ' khong thuoc phieu nay'
                    ], 422);
                }
            }

            DB::beginTransaction();
            try {
                $now = Carbon::now();
                foreach ($validated['ket_qua'] as $item) {
                    ChiTietPhieuChiDinh::where('MaChiTietPhieu', $item['ma_chi_tiet_phieu'])
                        ->update([
                            'KetQua' => $item['ket_qua'] ?? null,
                            'ChiSo' => $item['chi_so'] ?? null,
                            'FileKetQua' => $item['file_ket_qua'] ?? null,
                            'NgayCoKetQua' => $now,
                            'TrangThai' => 'completed',
                        ]);
                }

                $phieu->update(['TrangThai' => 'completed']);

                DB::commit();
                return response()->json([
                    'success' => true,
                    'message' => 'Da hoan tat xet nghiem va luu ket qua',
                    'trang_thai' => 'completed',
                ]);
            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Tạo hoá đơn từ các dịch vụ đã sử dụng
     */
    private function taoHoaDon($maLichKham, $maBenhNhan)
    {
        try {
            // Lấy các dịch vụ đã sử dụng trong lịch khám
            $chiTietLichKham = DB::table('chitietlichkham as ct')
                ->join('dichvu as dv', 'ct.MaDichVu', '=', 'dv.MaDichVu')
                ->where('ct.MaLichKham', $maLichKham)
                ->select(
                    'ct.MaChiTiet',
                    'ct.MaDichVu',
                    'dv.TenDichVu',
                    'ct.SoLuong',
                    DB::raw('COALESCE(ct.DonGia, dv.Gia) as DonGia'),
                    DB::raw('COALESCE(ct.ThanhTien, ct.SoLuong * COALESCE(ct.DonGia, dv.Gia)) as ThanhTien')
                )
                ->get();

            if ($chiTietLichKham->isEmpty()) {
                return; // Không có dịch vụ, không tạo hoá đơn
            }

            // Tính tổng tiền
            $tongTien = $chiTietLichKham->sum('ThanhTien');

            // Kiểm tra hoá đơn đã tồn tại chưa
            $hoaDonCu = DB::table('hoadon')
                ->where('MaLichKham', $maLichKham)
                ->first();

            if ($hoaDonCu) {
                // Xóa hoá đơn cũ và chi tiết
                DB::table('ct_hoadon')->where('MaHoaDon', $hoaDonCu->MaHoaDon)->delete();
                DB::table('hoadon')->where('MaHoaDon', $hoaDonCu->MaHoaDon)->delete();
            }

            // Tạo hoá đơn mới
            $maHoaDon = DB::table('hoadon')->insertGetId([
                'MaBenhNhan' => $maBenhNhan,
                'MaLichKham' => $maLichKham,
                'LoaiHoaDon' => 'khám_ngoại_trú',
                'TongTien' => $tongTien,
                'GiamBHYT' => 0,
                'SoTienPhaiTra' => $tongTien,
                'TrangThai' => 'pending',
                'NgayTao' => Carbon::now(),
            ]);

            // Tạo chi tiết hoá đơn
            foreach ($chiTietLichKham as $item) {
                DB::table('ct_hoadon')->insert([
                    'MaHoaDon' => $maHoaDon,
                    'Loai' => 'dich_vu',
                    'MaThamChieu' => $item->MaDichVu,
                    'TenHienThi' => $item->TenDichVu,
                    'SoLuong' => $item->SoLuong,
                    'DonGia' => $item->DonGia,
                    'ThanhTien' => $item->ThanhTien,
                ]);
            }
        } catch (\Exception $e) {
            // Log error but don't throw to avoid blocking appointment completion
            \Log::error('Tao hoa don that bai: ' . $e->getMessage());
        }
    }

    /**
     * Lấy hoá đơn của bác sĩ
     * GET /bacsi/hoa-don/{maLichKham}
     */
    public function getHoaDon(Request $request, $maLichKham)
    {
        try {
            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay thong tin bac si'], 401);
            }

            // Kiểm tra bác sĩ có phải là bác sĩ chủ trị
            $lichKham = LichKham::with('lichLamViec')
                ->where('MaLichKham', $maLichKham)
                ->first();

            if (!$lichKham || $lichKham->lichLamViec->MaBacSi !== $maBacSi) {
                return response()->json(['success' => false, 'message' => 'Bac si khong co quyen xem hoa don nay'], 403);
            }

            // Lấy hoá đơn
            $hoaDon = DB::table('hoadon as hd')
                ->leftJoin('benhnhan as bn', 'hd.MaBenhNhan', '=', 'bn.MaBenhNhan')
                ->where('hd.MaLichKham', $maLichKham)
                ->select(
                    'hd.MaHoaDon',
                    'hd.MaBenhNhan',
                    DB::raw("CONCAT(bn.ho, ' ', bn.ten) as TenBenhNhan"),
                    'bn.cccd',
                    'bn.diachi',
                    'hd.LoaiHoaDon',
                    'hd.TongTien',
                    'hd.GiamBHYT',
                    'hd.SoTienPhaiTra',
                    'hd.TrangThai',
                    'hd.NgayTao'
                )
                ->first();

            if (!$hoaDon) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay hoa don'], 404);
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
     * Doctor accepts patient (sets check-in time)
     * PATCH /bacsi/lich-kham/{maLichKham}/tiep-nhan
     */
    public function tiepNhanBenhNhan(Request $request, $maLichKham)
    {
        try {
            $validated = $request->validate([
                'accept' => 'required|boolean',
            ]);

            $maBacSi = $this->currentDoctorId($request);
            if (!$maBacSi) {
                return response()->json(['success' => false, 'message' => 'Không tìm thấy thông tin bác sĩ'], 401);
            }

            $lichKham = DB::table('lichkham')->where('MaLichKham', $maLichKham)->first();
            if (!$lichKham) {
                return response()->json(['success' => false, 'message' => 'Không tìm thấy lịch khám'], 404);
            }

            // Validate doctor owns this appointment
            $lichLamViec = DB::table('lichlamviec')->where('MaLichLamViec', $lichKham->MaLichLamViec)->first();
            if (!$lichLamViec || $lichLamViec->MaBacSi != $maBacSi) {
                return response()->json(['success' => false, 'message' => 'Bạn không có quyền với lịch khám này'], 403);
            }

            if ($validated['accept']) {
                // Accept patient - set check-in time to now and update status to examining
                DB::table('lichkham')
                    ->where('MaLichKham', $maLichKham)
                    ->update([
                        'ThoiDiemCheckIn' => now(),
                        'TrangThai' => 'examining',
                    ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Tiếp nhận bệnh nhân thành công',
                    'data' => [
                        'MaLichKham' => $maLichKham,
                        'ThoiDiemCheckIn' => now()->toDateTimeString(),
                    ]
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Từ chối tiếp nhận không hỗ trợ',
                ], 422);
            }
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Get doctor acceptance status (check ThoiDiemCheckIn)
     * GET /bacsi/lich-kham/{maLichKham}/tiep-nhan-status
     */
    public function getTiepNhanStatus(Request $request, $maLichKham)
    {
        try {
            $lichKham = DB::table('lichkham')
                ->where('MaLichKham', $maLichKham)
                ->first();

            if (!$lichKham) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không tìm thấy lịch khám'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'MaLichKham' => $maLichKham,
                    'TrangThaiTiepNhan' => $lichKham->ThoiDiemCheckIn ? 'accepted' : null,
                    'ThoiDiemCheckIn' => $lichKham->ThoiDiemCheckIn,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
