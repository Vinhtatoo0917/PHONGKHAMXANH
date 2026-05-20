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
                    $q->whereIn('TrangThai', ['confirmed', 'completed', 'no-show']);
                }, 'lichKham.benhNhan', 'lichKham.chiTietLichKham.dichVu', 'lichKham.ketLuanKham', 'lichKham.donThuoc.chiTiet.thuoc']);

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

    public function getTestingDoctors()
    {
        try {
            // Lấy danh sách bác sĩ thuộc khoa Xét nghiệm hoặc Chuyên khoa có chữ 'Xét nghiệm'
            $doctors = BacSi::where('ChuyenKhoa', 'like', '%Xét nghiệm%')
                ->orWhere('ChuyenKhoa', 'like', '%XN%')
                ->get(['MaBacSi', 'ho', 'ten', 'ChuyenKhoa']);
            
            return response()->json(['success' => true, 'data' => $doctors]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function getAllServices()
    {
        try {
            $services = DichVu::all(['MaDichVu', 'TenDichVu', 'Gia']);
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
}
