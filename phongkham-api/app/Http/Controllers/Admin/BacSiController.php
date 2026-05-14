<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class BacSiController extends Controller
{
    /**
     * Middleware kiểm tra quyền admin
     */
    private function checkAdmin(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token không hợp lệ'
            ], 401);
        }

        $taikhoan = DB::table('taikhoan')
            ->where('AccessToken', $token)
            ->first();

        if (!$taikhoan) {
            return response()->json([
                'success' => false,
                'message' => 'Tài khoản không tồn tại'
            ], 404);
        }

        if ($taikhoan->VaiTro !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền truy cập'
            ], 403);
        }

        return null;
    }

    /**
     * Lấy danh sách bác sĩ
     * GET /admin/bac-si
     */
    public function index(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $query = DB::table('bacsi as bs')
            ->join('taikhoan as tk', 'bs.MaTaiKhoan', '=', 'tk.MaTaiKhoan')
            ->select(
                'bs.MaBacSi',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as HoTen"),
                'bs.ho',
                'bs.ten',
                'bs.ngaysinh',
                'bs.gioitinh',
                'bs.ChuyenKhoa',
                'bs.BangCap',
                'bs.KinhNghiem',
                'tk.email',
                'tk.sdt',
                'tk.MaTaiKhoan',
                'tk.trangthaihoatdong'
            );

        // Tìm kiếm theo tên hoặc chuyên khoa
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where(DB::raw("CONCAT(bs.ho, ' ', bs.ten)"), 'like', "%{$search}%")
                  ->orWhere('bs.ChuyenKhoa', 'like', "%{$search}%");
            });
        }

        // Lọc theo giới tính
        if ($request->has('gioitinh')) {
            $query->where('bs.gioitinh', $request->gioitinh);
        }

        // Lọc theo chuyên khoa
        if ($request->has('ChuyenKhoa')) {
            $query->where('bs.ChuyenKhoa', 'like', "%{$request->ChuyenKhoa}%");
        }

        $bacsi = $query->orderBy('bs.MaBacSi', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $bacsi,
            'total' => count($bacsi)
        ], 200);
    }

    /**
     * Lấy chi tiết bác sĩ
     * GET /admin/bac-si/{id}
     */
    public function show(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $bacsi = DB::table('bacsi as bs')
            ->join('taikhoan as tk', 'bs.MaTaiKhoan', '=', 'tk.MaTaiKhoan')
            ->where('bs.MaBacSi', $id)
            ->select(
                'bs.MaBacSi',
                'bs.MaTaiKhoan',
                'bs.ho',
                'bs.ten',
                'bs.ngaysinh',
                'bs.gioitinh',
                'bs.ChuyenKhoa',
                'bs.BangCap',
                'bs.KinhNghiem',
                'tk.email',
                'tk.sdt',
                'tk.trangthaihoatdong'
            )
            ->first();

        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy bác sĩ'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $bacsi
        ], 200);
    }

    /**
     * Thêm bác sĩ mới
     * POST /admin/bac-si
     */
    public function store(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'ho' => 'required|string|max:50',
            'ten' => 'required|string|max:50',
            'ngaysinh' => 'required|date',
            'gioitinh' => 'required|in:Nam,Nữ',
            'ChuyenKhoa' => 'required|string|max:100',
            'BangCap' => 'required|string|max:100',
            'KinhNghiem' => 'nullable|string|max:255',
            'email' => 'required|email|unique:taikhoan,email',
            'sdt' => 'required|numeric|unique:taikhoan,sdt',
            'MatKhau' => 'required|min:6'
        ]);

        try {
            DB::beginTransaction();

            $token = bin2hex(random_bytes(32));
            $MaTaiKhoan = DB::table('taikhoan')->insertGetId([
                'sdt' => $request->sdt,
                'email' => $request->email,
                'MatKhau' => Hash::make($request->MatKhau),
                'VaiTro' => 'bacsi',
                'AccessToken' => $token,
                'trangthaihoatdong' => 'active',
                'ngaytao' => now(),
            ]);

            $MaBacSi = DB::table('bacsi')->insertGetId([
                'MaTaiKhoan' => $MaTaiKhoan,
                'ho' => $request->ho,
                'ten' => $request->ten,
                'ngaysinh' => $request->ngaysinh,
                'gioitinh' => $request->gioitinh,
                'ChuyenKhoa' => $request->ChuyenKhoa,
                'BangCap' => $request->BangCap,
                'KinhNghiem' => $request->KinhNghiem ?? '0 năm',
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Thêm bác sĩ thành công',
                'data' => [
                    'MaBacSi' => $MaBacSi,
                    'MaTaiKhoan' => $MaTaiKhoan
                ]
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Có lỗi xảy ra: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Cập nhật thông tin bác sĩ
     * PUT /admin/bac-si/{id}
     */
    public function update(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $bacsi = DB::table('bacsi')->where('MaBacSi', $id)->first();
        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy bác sĩ'
            ], 404);
        }

        $request->validate([
            'ho' => 'sometimes|required|string|max:50',
            'ten' => 'sometimes|required|string|max:50',
            'ngaysinh' => 'sometimes|required|date',
            'gioitinh' => 'sometimes|required|in:Nam,Nữ',
            'ChuyenKhoa' => 'sometimes|required|string|max:100',
            'BangCap' => 'sometimes|required|string|max:100',
            'KinhNghiem' => 'nullable|string|max:255',
            'email' => 'sometimes|required|email|unique:taikhoan,email,' . $bacsi->MaTaiKhoan . ',MaTaiKhoan',
            'sdt' => 'sometimes|required|numeric|unique:taikhoan,sdt,' . $bacsi->MaTaiKhoan . ',MaTaiKhoan',
        ]);

        try {
            DB::beginTransaction();

            $dataBacSi = [];
            if ($request->has('ho')) $dataBacSi['ho'] = $request->ho;
            if ($request->has('ten')) $dataBacSi['ten'] = $request->ten;
            if ($request->has('ngaysinh')) $dataBacSi['ngaysinh'] = $request->ngaysinh;
            if ($request->has('gioitinh')) $dataBacSi['gioitinh'] = $request->gioitinh;
            if ($request->has('ChuyenKhoa')) $dataBacSi['ChuyenKhoa'] = $request->ChuyenKhoa;
            if ($request->has('BangCap')) $dataBacSi['BangCap'] = $request->BangCap;
            if ($request->has('KinhNghiem')) $dataBacSi['KinhNghiem'] = $request->KinhNghiem;

            if (!empty($dataBacSi)) {
                DB::table('bacsi')->where('MaBacSi', $id)->update($dataBacSi);
            }

            $dataTaiKhoan = [];
            if ($request->has('email')) $dataTaiKhoan['email'] = $request->email;
            if ($request->has('sdt')) $dataTaiKhoan['sdt'] = $request->sdt;
            if ($request->has('MatKhau')) {
                $dataTaiKhoan['MatKhau'] = Hash::make($request->MatKhau);
            }

            if (!empty($dataTaiKhoan)) {
                DB::table('taikhoan')->where('MaTaiKhoan', $bacsi->MaTaiKhoan)->update($dataTaiKhoan);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Cập nhật thông tin bác sĩ thành công'
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Có lỗi xảy ra: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Xóa bác sĩ
     * DELETE /admin/bac-si/{id}
     */
    public function destroy(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $bacsi = DB::table('bacsi')->where('MaBacSi', $id)->first();
        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy bác sĩ'
            ], 404);
        }

        $coLichLamViec = DB::table('lichlamviec')->where('MaBacSi', $id)->exists();
        if ($coLichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể xóa bác sĩ đã có lịch làm việc. Vui lòng xóa lịch làm việc trước.'
            ], 422);
        }

        try {
            DB::beginTransaction();

            DB::table('bacsi')->where('MaBacSi', $id)->delete();
            DB::table('taikhoan')->where('MaTaiKhoan', $bacsi->MaTaiKhoan)->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Xóa bác sĩ thành công'
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Có lỗi xảy ra: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Khóa/Mở khóa tài khoản bác sĩ
     * PATCH /admin/bac-si/{id}/trang-thai
     */
    public function updateStatus(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'trangthaihoatdong' => 'required|in:active,inactive'
        ]);

        $bacsi = DB::table('bacsi')->where('MaBacSi', $id)->first();
        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy bác sĩ'
            ], 404);
        }

        DB::table('taikhoan')
            ->where('MaTaiKhoan', $bacsi->MaTaiKhoan)
            ->update(['trangthaihoatdong' => $request->trangthaihoatdong]);

        return response()->json([
            'success' => true,
            'message' => $request->trangthaihoatdong === 'active' 
                ? 'Đã mở khóa tài khoản bác sĩ' 
                : 'Đã khóa tài khoản bác sĩ'
        ], 200);
    }
}
