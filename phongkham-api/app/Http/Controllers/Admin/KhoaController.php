<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KhoaController extends Controller
{
    /**
     * Lấy danh sách tất cả khoa
     * GET /admin/khoa
     */
    public function index(Request $request)
    {
        try {
            $search = $request->query('search');
            
            $query = DB::table('khoa');
            
            if ($search) {
                $query->where('TenKhoa', 'like', "%$search%");
            }
            
            $khoaList = $query->get();
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách khoa thành công',
                'data' => $khoaList,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lấy chi tiết khoa
     * GET /admin/khoa/{id}
     */
    public function show($maKhoa)
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
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết khoa thành công',
                'data' => $khoa,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Thêm khoa mới
     * POST /admin/khoa
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'TenKhoa' => 'required|string|max:255',
                'machuyenkhoa' => 'required|string|max:50',
            ]);
            
            // Lấy mã khoa tiếp theo (INT auto-increment)
            $lastKhoa = DB::table('khoa')->max('MaKhoa');
            $nextMaKhoa = ($lastKhoa ?? 0) + 1;
            
            DB::table('khoa')->insert([
                'MaKhoa' => $nextMaKhoa,
                'TenKhoa' => $validated['TenKhoa'],
                'machuyenkhoa' => $validated['machuyenkhoa'],
            ]);
            
            $khoa = DB::table('khoa')
                ->where('MaKhoa', $nextMaKhoa)
                ->first();
            
            return response()->json([
                'success' => true,
                'message' => 'Thêm khoa thành công',
                'data' => $khoa,
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
     * Cập nhật khoa
     * PUT /admin/khoa/{id}
     */
    public function update(Request $request, $maKhoa)
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
            
            $validated = $request->validate([
                'TenKhoa' => 'required|string|max:255',
            ]);
            
            DB::table('khoa')
                ->where('MaKhoa', $maKhoa)
                ->update([
                    'TenKhoa' => $validated['TenKhoa'],
                ]);
            
            $updatedKhoa = DB::table('khoa')
                ->where('MaKhoa', $maKhoa)
                ->first();
            
            return response()->json([
                'success' => true,
                'message' => 'Cập nhật khoa thành công',
                'data' => $updatedKhoa,
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
     * Xóa khoa
     * DELETE /admin/khoa/{id}
     */
    public function destroy($maKhoa)
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
            
            // Kiểm tra xem khoa có dịch vụ không
            $dichVuCount = DB::table('dichvu')
                ->where('MaKhoa', $maKhoa)
                ->count();
            
            if ($dichVuCount > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không thể xóa khoa vì có dịch vụ liên quan',
                ], 400);
            }
            
            DB::table('khoa')
                ->where('MaKhoa', $maKhoa)
                ->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Xóa khoa thành công',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }
}
