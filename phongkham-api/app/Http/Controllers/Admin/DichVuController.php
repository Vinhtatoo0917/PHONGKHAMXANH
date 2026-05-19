<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DichVuController extends Controller
{
    /**
     * Lấy danh sách tất cả dịch vụ
     * GET /admin/dich-vu
     */
    public function index(Request $request)
    {
        try {
            $search = $request->query('search');
            $maKhoa = $request->query('MaKhoa');
            
            $query = DB::table('dichvu')
                ->leftJoin('khoa', 'dichvu.MaKhoa', '=', 'khoa.MaKhoa')
                ->select('dichvu.*', 'khoa.TenKhoa');
            
            if ($search) {
                $query->where('TenDichVu', 'like', "%$search%")
                    ->orWhere('MaDichVu', 'like', "%$search%");
            }
            
            if ($maKhoa) {
                $query->where('dichvu.MaKhoa', $maKhoa);
            }
            
            $dichVuList = $query->get();
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách dịch vụ thành công',
                'data' => $dichVuList,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lấy chi tiết dịch vụ
     * GET /admin/dich-vu/{id}
     */
    public function show($maDichVu)
    {
        try {
            $dichVu = DB::table('dichvu')
                ->leftJoin('khoa', 'dichvu.MaKhoa', '=', 'khoa.MaKhoa')
                ->where('dichvu.MaDichVu', $maDichVu)
                ->select('dichvu.*', 'khoa.TenKhoa')
                ->first();
            
            if (!$dichVu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dịch vụ không tồn tại',
                ], 404);
            }
            
            // Lấy danh sách bệnh liên quan
            $benhLienQuan = DB::table('dichvu_benh')
                ->join('benh', 'dichvu_benh.MaBenh', '=', 'benh.MaBenh')
                ->where('dichvu_benh.MaDichVu', $maDichVu)
                ->select('benh.*')
                ->get();
            
            $dichVu->benhLienQuan = $benhLienQuan;
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết dịch vụ thành công',
                'data' => $dichVu,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Thêm dịch vụ mới
     * POST /admin/dich-vu
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'TenDichVu' => 'required|string|max:255',
                'Gia' => 'required|numeric|min:0',
                'MaKhoa' => 'nullable|integer|exists:khoa,MaKhoa',
                'madichvuyte' => 'required|string|max:50',
            ]);
            
            // Lấy mã dịch vụ tiếp theo (INT auto-increment)
            $lastDichVu = DB::table('dichvu')->max('MaDichVu');
            $nextMaDichVu = ($lastDichVu ?? 0) + 1;
            
            DB::table('dichvu')->insert([
                'MaDichVu' => $nextMaDichVu,
                'TenDichVu' => $validated['TenDichVu'],
                'Gia' => $validated['Gia'],
                'MaKhoa' => $validated['MaKhoa'] ?? null,
                'madichvuyte' => $validated['madichvuyte'],
            ]);
            
            $dichVu = DB::table('dichvu')
                ->leftJoin('khoa', 'dichvu.MaKhoa', '=', 'khoa.MaKhoa')
                ->where('dichvu.MaDichVu', $nextMaDichVu)
                ->select('dichvu.*', 'khoa.TenKhoa')
                ->first();
            
            return response()->json([
                'success' => true,
                'message' => 'Thêm dịch vụ thành công',
                'data' => $dichVu,
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cập nhật dịch vụ
     * PUT /admin/dich-vu/{id}
     */
    public function update(Request $request, $maDichVu)
    {
        try {
            $dichVu = DB::table('dichvu')
                ->where('MaDichVu', $maDichVu)
                ->first();
            
            if (!$dichVu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dịch vụ không tồn tại',
                ], 404);
            }
            
            $validated = $request->validate([
                'TenDichVu' => 'required|string|max:255',
                'Gia' => 'required|numeric|min:0',
                'MaKhoa' => 'nullable|string|exists:khoa,MaKhoa',
            ]);
            
            DB::table('dichvu')
                ->where('MaDichVu', $maDichVu)
                ->update([
                    'TenDichVu' => $validated['TenDichVu'],
                    'Gia' => $validated['Gia'],
                    'MaKhoa' => $validated['MaKhoa'] ?? null,
                ]);
            
            $updatedDichVu = DB::table('dichvu')
                ->leftJoin('khoa', 'dichvu.MaKhoa', '=', 'khoa.MaKhoa')
                ->where('dichvu.MaDichVu', $maDichVu)
                ->select('dichvu.*', 'khoa.TenKhoa')
                ->first();
            
            return response()->json([
                'success' => true,
                'message' => 'Cập nhật dịch vụ thành công',
                'data' => $updatedDichVu,
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Xóa dịch vụ
     * DELETE /admin/dich-vu/{id}
     */
    public function destroy($maDichVu)
    {
        try {
            $dichVu = DB::table('dichvu')
                ->where('MaDichVu', $maDichVu)
                ->first();
            
            if (!$dichVu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dịch vụ không tồn tại',
                ], 404);
            }
            
            // Kiểm tra xem dịch vụ có được sử dụng không
            $chiTietLichKhamCount = DB::table('chitietlichkham')
                ->where('MaDichVu', $maDichVu)
                ->count();
            
            $chiTietPhieuCount = DB::table('chitietphieuchidinh')
                ->where('MaDichVu', $maDichVu)
                ->count();
            
            if ($chiTietLichKhamCount > 0 || $chiTietPhieuCount > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không thể xóa dịch vụ vì có lịch khám hoặc phiếu chỉ định liên quan',
                ], 400);
            }
            
            // Xóa liên kết với bệnh
            DB::table('dichvu_benh')
                ->where('MaDichVu', $maDichVu)
                ->delete();
            
            // Xóa dịch vụ
            DB::table('dichvu')
                ->where('MaDichVu', $maDichVu)
                ->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Xóa dịch vụ thành công',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lấy danh sách dịch vụ theo khoa
     * GET /admin/dich-vu/khoa/{maKhoa}
     */
    public function getByKhoa($maKhoa)
    {
        try {
            $khoa = DB::table('khoa')
                ->where('MaKhoa', $maKhoa)
                ->first();
            
            if (!$khoa) {
                return response()->json([
                    'success' => false,
                    'message' => 'Khoa không tồn tại',
                ], 404);
            }
            
            $dichVuList = DB::table('dichvu')
                ->where('MaKhoa', $maKhoa)
                ->get();
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách dịch vụ theo khoa thành công',
                'data' => $dichVuList,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lấy danh sách dịch vụ theo bệnh
     * GET /admin/dich-vu/benh/{maBenh}
     */
    public function getByBenh($maBenh)
    {
        try {
            $benh = DB::table('benh')
                ->where('MaBenh', $maBenh)
                ->first();
            
            if (!$benh) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bệnh không tồn tại',
                ], 404);
            }
            
            $dichVuList = DB::table('dichvu_benh')
                ->join('dichvu', 'dichvu_benh.MaDichVu', '=', 'dichvu.MaDichVu')
                ->where('dichvu_benh.MaBenh', $maBenh)
                ->select('dichvu.*')
                ->get();
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách dịch vụ theo bệnh thành công',
                'data' => $dichVuList,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }
}
