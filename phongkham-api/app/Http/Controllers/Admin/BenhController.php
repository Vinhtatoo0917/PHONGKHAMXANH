<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BenhController extends Controller
{
    /**
     * Lấy danh sách tất cả bệnh
     * GET /admin/benh
     */
    public function index(Request $request)
    {
        try {
            $search = $request->query('search');
            
            $query = DB::table('benh');
            
            if ($search) {
                $query->where('TenBenh', 'like', "%$search%")
                    ->orWhere('MaBenh', 'like', "%$search%");
            }
            
            $benhList = $query->get();
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy danh sách bệnh thành công',
                'data' => $benhList,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lấy chi tiết bệnh
     * GET /admin/benh/{id}
     */
    public function show($maBenh)
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
            
            // Lấy danh sách dịch vụ liên quan
            $dichVuLienQuan = DB::table('dichvu_benh')
                ->join('dichvu', 'dichvu_benh.MaDichVu', '=', 'dichvu.MaDichVu')
                ->where('dichvu_benh.MaBenh', $maBenh)
                ->select('dichvu.*')
                ->get();
            
            $benh->dichVuLienQuan = $dichVuLienQuan;
            
            return response()->json([
                'success' => true,
                'message' => 'Lấy chi tiết bệnh thành công',
                'data' => $benh,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Thêm bệnh mới
     * POST /admin/benh
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'TenBenh' => 'required|string|max:255',
                'MoTa' => 'nullable|string',
                'mabenhly' => 'required|string|max:50',
            ]);
            
            // Lấy mã bệnh tiếp theo (INT auto-increment)
            $lastBenh = DB::table('benh')->max('MaBenh');
            $nextMaBenh = ($lastBenh ?? 0) + 1;
            
            DB::table('benh')->insert([
                'MaBenh' => $nextMaBenh,
                'TenBenh' => $validated['TenBenh'],
                'MoTa' => $validated['MoTa'] ?? null,
                'mabenhly' => $validated['mabenhly'],
            ]);
            
            $benh = DB::table('benh')
                ->where('MaBenh', $nextMaBenh)
                ->first();
            
            return response()->json([
                'success' => true,
                'message' => 'Thêm bệnh thành công',
                'data' => $benh,
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
     * Cập nhật bệnh
     * PUT /admin/benh/{id}
     */
    public function update(Request $request, $maBenh)
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
            
            $validated = $request->validate([
                'TenBenh' => 'required|string|max:255',
                'MoTa' => 'nullable|string',
            ]);
            
            DB::table('benh')
                ->where('MaBenh', $maBenh)
                ->update([
                    'TenBenh' => $validated['TenBenh'],
                    'MoTa' => $validated['MoTa'] ?? null,
                ]);
            
            $updatedBenh = DB::table('benh')
                ->where('MaBenh', $maBenh)
                ->first();
            
            return response()->json([
                'success' => true,
                'message' => 'Cập nhật bệnh thành công',
                'data' => $updatedBenh,
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
     * Xóa bệnh
     * DELETE /admin/benh/{id}
     */
    public function destroy($maBenh)
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
            
            // Kiểm tra xem bệnh có được sử dụng không
            $ketLuanCount = DB::table('ketluankham')
                ->where('MaBenh', $maBenh)
                ->count();
            
            if ($ketLuanCount > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không thể xóa bệnh vì có kết luận khám liên quan',
                ], 400);
            }
            
            // Xóa liên kết với dịch vụ
            DB::table('dichvu_benh')
                ->where('MaBenh', $maBenh)
                ->delete();
            
            // Xóa bệnh
            DB::table('benh')
                ->where('MaBenh', $maBenh)
                ->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Xóa bệnh thành công',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Liên kết bệnh với dịch vụ
     * POST /admin/benh/{id}/dich-vu
     */
    public function linkService(Request $request, $maBenh)
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
            
            $validated = $request->validate([
                'MaDichVu' => 'required|string|exists:dichvu,MaDichVu',
            ]);
            
            // Kiểm tra xem liên kết đã tồn tại chưa
            $existing = DB::table('dichvu_benh')
                ->where('MaBenh', $maBenh)
                ->where('MaDichVu', $validated['MaDichVu'])
                ->first();
            
            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dịch vụ đã được liên kết với bệnh này',
                ], 400);
            }
            
            DB::table('dichvu_benh')->insert([
                'MaBenh' => $maBenh,
                'MaDichVu' => $validated['MaDichVu'],
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Liên kết dịch vụ thành công',
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
     * Hủy liên kết bệnh với dịch vụ
     * DELETE /admin/benh/{id}/dich-vu/{maDichVu}
     */
    public function unlinkService($maBenh, $maDichVu)
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
            
            $existing = DB::table('dichvu_benh')
                ->where('MaBenh', $maBenh)
                ->where('MaDichVu', $maDichVu)
                ->first();
            
            if (!$existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Liên kết không tồn tại',
                ], 404);
            }
            
            DB::table('dichvu_benh')
                ->where('MaBenh', $maBenh)
                ->where('MaDichVu', $maDichVu)
                ->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Hủy liên kết dịch vụ thành công',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }
}
