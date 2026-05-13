<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
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
     * Lấy danh sách tất cả lịch làm việc
     * GET /admin/lich-lam-viec
     */
    public function getDanhSachLichLamViec(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $query = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->select(
                'llv.MaLichLamViec',
                'llv.MaBacSi',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa',
                'llv.Ngay',
                'llv.MaCa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                'ck.SoLuongToiDa',
                'llv.MaPhong',
                'pk.TenPhong',
                'pk.Khu'
            );

        // Lọc theo ngày
        if ($request->has('ngay')) {
            $query->where('llv.Ngay', $request->ngay);
        }

        // Lọc theo bác sĩ
        if ($request->has('MaBacSi')) {
            $query->where('llv.MaBacSi', $request->MaBacSi);
        }

        // Lọc theo ca
        if ($request->has('MaCa')) {
            $query->where('llv.MaCa', $request->MaCa);
        }

        // Lọc theo phòng
        if ($request->has('MaPhong')) {
            $query->where('llv.MaPhong', $request->MaPhong);
        }

        // Lọc theo khoảng thời gian
        if ($request->has('tu_ngay') && $request->has('den_ngay')) {
            $query->whereBetween('llv.Ngay', [$request->tu_ngay, $request->den_ngay]);
        }

        $lichLamViec = $query->orderBy('llv.Ngay', 'desc')
            ->orderBy('ck.GioBatDau', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $lichLamViec
        ], 200);
    }

    /**
     * Lấy chi tiết một lịch làm việc
     * GET /admin/lich-lam-viec/{id}
     */
    public function getChiTietLichLamViec(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $lichLamViec = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->where('llv.MaLichLamViec', $id)
            ->select(
                'llv.MaLichLamViec',
                'llv.MaBacSi',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa',
                'bs.BangCap',
                'bs.KinhNghiem',
                'llv.Ngay',
                'llv.MaCa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                'ck.SoLuongToiDa',
                'ck.ThoiLuongKham',
                'llv.MaPhong',
                'pk.TenPhong',
                'pk.Khu'
            )
            ->first();

        if (!$lichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy lịch làm việc'
            ], 404);
        }

        // Đếm số lượng lịch khám đã đăng ký
        $soLuongDaDangKy = DB::table('lichkham')
            ->where('MaLichLamViec', $id)
            ->count();

        $lichLamViec->SoLuongDaDangKy = $soLuongDaDangKy;
        $lichLamViec->SoLuongConLai = $lichLamViec->SoLuongToiDa - $soLuongDaDangKy;

        return response()->json([
            'success' => true,
            'data' => $lichLamViec
        ], 200);
    }

    /**
     * Tạo lịch làm việc mới
     * POST /admin/lich-lam-viec
     */
    public function taoLichLamViec(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'MaBacSi' => 'required|integer',
            'Ngay' => 'required|date',
            'MaCa' => 'required|integer',
            'MaPhong' => 'required|integer'
        ]);

        // Kiểm tra bác sĩ có tồn tại
        $bacsi = DB::table('bacsi')->where('MaBacSi', $request->MaBacSi)->first();
        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Bác sĩ không tồn tại'
            ], 404);
        }

        // Kiểm tra ca khám có tồn tại
        $cakham = DB::table('cakham')->where('MaCa', $request->MaCa)->first();
        if (!$cakham) {
            return response()->json([
                'success' => false,
                'message' => 'Ca khám không tồn tại'
            ], 404);
        }

        // Kiểm tra phòng khám có tồn tại
        $phongkham = DB::table('phongkham')->where('MaPhong', $request->MaPhong)->first();
        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám không tồn tại'
            ], 404);
        }

        // Kiểm tra trùng lịch của bác sĩ (cùng ngày, cùng ca)
        $trungLichBacSi = DB::table('lichlamviec')
            ->where('MaBacSi', $request->MaBacSi)
            ->where('Ngay', $request->Ngay)
            ->where('MaCa', $request->MaCa)
            ->exists();

        if ($trungLichBacSi) {
            return response()->json([
                'success' => false,
                'message' => 'Bác sĩ đã có lịch làm việc trong ca này'
            ], 422);
        }

        // Kiểm tra trùng phòng (cùng ngày, cùng ca, cùng phòng)
        $trungPhong = DB::table('lichlamviec')
            ->where('Ngay', $request->Ngay)
            ->where('MaCa', $request->MaCa)
            ->where('MaPhong', $request->MaPhong)
            ->exists();

        if ($trungPhong) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám đã được sử dụng trong ca này'
            ], 422);
        }

        // Tạo lịch làm việc mới
        $MaLichLamViec = DB::table('lichlamviec')->insertGetId([
            'MaBacSi' => $request->MaBacSi,
            'Ngay' => $request->Ngay,
            'MaCa' => $request->MaCa,
            'MaPhong' => $request->MaPhong
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Tạo lịch làm việc thành công',
            'data' => [
                'MaLichLamViec' => $MaLichLamViec
            ]
        ], 201);
    }

    /**
     * Cập nhật lịch làm việc
     * PUT /admin/lich-lam-viec/{id}
     */
    public function capNhatLichLamViec(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        // Kiểm tra lịch làm việc có tồn tại
        $lichLamViec = DB::table('lichlamviec')->where('MaLichLamViec', $id)->first();
        if (!$lichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy lịch làm việc'
            ], 404);
        }

        // Kiểm tra đã có lịch khám nào đăng ký chưa
        $coLichKham = DB::table('lichkham')
            ->where('MaLichLamViec', $id)
            ->exists();

        if ($coLichKham) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể cập nhật lịch làm việc đã có bệnh nhân đăng ký'
            ], 422);
        }

        $dataUpdate = [];

        // Validate và cập nhật từng trường
        if ($request->has('MaBacSi')) {
            $bacsi = DB::table('bacsi')->where('MaBacSi', $request->MaBacSi)->first();
            if (!$bacsi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bác sĩ không tồn tại'
                ], 404);
            }
            $dataUpdate['MaBacSi'] = $request->MaBacSi;
        }

        if ($request->has('Ngay')) {
            $dataUpdate['Ngay'] = $request->Ngay;
        }

        if ($request->has('MaCa')) {
            $cakham = DB::table('cakham')->where('MaCa', $request->MaCa)->first();
            if (!$cakham) {
                return response()->json([
                    'success' => false,
                    'message' => 'Ca khám không tồn tại'
                ], 404);
            }
            $dataUpdate['MaCa'] = $request->MaCa;
        }

        if ($request->has('MaPhong')) {
            $phongkham = DB::table('phongkham')->where('MaPhong', $request->MaPhong)->first();
            if (!$phongkham) {
                return response()->json([
                    'success' => false,
                    'message' => 'Phòng khám không tồn tại'
                ], 404);
            }
            $dataUpdate['MaPhong'] = $request->MaPhong;
        }

        if (empty($dataUpdate)) {
            return response()->json([
                'success' => false,
                'message' => 'Không có dữ liệu để cập nhật'
            ], 422);
        }

        // Kiểm tra trùng lịch sau khi cập nhật
        $MaBacSi = $dataUpdate['MaBacSi'] ?? $lichLamViec->MaBacSi;
        $Ngay = $dataUpdate['Ngay'] ?? $lichLamViec->Ngay;
        $MaCa = $dataUpdate['MaCa'] ?? $lichLamViec->MaCa;
        $MaPhong = $dataUpdate['MaPhong'] ?? $lichLamViec->MaPhong;

        // Kiểm tra trùng lịch bác sĩ
        $trungLichBacSi = DB::table('lichlamviec')
            ->where('MaBacSi', $MaBacSi)
            ->where('Ngay', $Ngay)
            ->where('MaCa', $MaCa)
            ->where('MaLichLamViec', '!=', $id)
            ->exists();

        if ($trungLichBacSi) {
            return response()->json([
                'success' => false,
                'message' => 'Bác sĩ đã có lịch làm việc trong ca này'
            ], 422);
        }

        // Kiểm tra trùng phòng
        $trungPhong = DB::table('lichlamviec')
            ->where('Ngay', $Ngay)
            ->where('MaCa', $MaCa)
            ->where('MaPhong', $MaPhong)
            ->where('MaLichLamViec', '!=', $id)
            ->exists();

        if ($trungPhong) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám đã được sử dụng trong ca này'
            ], 422);
        }

        // Cập nhật
        DB::table('lichlamviec')
            ->where('MaLichLamViec', $id)
            ->update($dataUpdate);

        return response()->json([
            'success' => true,
            'message' => 'Cập nhật lịch làm việc thành công'
        ], 200);
    }

    /**
     * Xóa lịch làm việc
     * DELETE /admin/lich-lam-viec/{id}
     */
    public function xoaLichLamViec(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        // Kiểm tra lịch làm việc có tồn tại
        $lichLamViec = DB::table('lichlamviec')->where('MaLichLamViec', $id)->first();
        if (!$lichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy lịch làm việc'
            ], 404);
        }

        // Kiểm tra đã có lịch khám nào đăng ký chưa
        $coLichKham = DB::table('lichkham')
            ->where('MaLichLamViec', $id)
            ->exists();

        if ($coLichKham) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể xóa lịch làm việc đã có bệnh nhân đăng ký'
            ], 422);
        }

        // Xóa lịch làm việc
        DB::table('lichlamviec')->where('MaLichLamViec', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Xóa lịch làm việc thành công'
        ], 200);
    }

    /**
     * Lấy danh sách bác sĩ
     * GET /admin/bac-si
     */
    public function getDanhSachBacSi(Request $request)
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
            'data' => $bacsi
        ], 200);
    }

    /**
     * Lấy chi tiết bác sĩ
     * GET /admin/bac-si/{id}
     */
    public function getChiTietBacSi(Request $request, $id)
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
    public function themBacSi(Request $request)
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

            // Tạo tài khoản với trạng thái mặc định là active
            $token = bin2hex(random_bytes(32));
            $MaTaiKhoan = DB::table('taikhoan')->insertGetId([
                'sdt' => $request->sdt,
                'email' => $request->email,
                'MatKhau' => password_hash($request->MatKhau, PASSWORD_BCRYPT),
                'VaiTro' => 'bacsi',
                'AccessToken' => $token,
                'trangthaihoatdong' => 'active', // Mặc định active
                'ngaytao' => now(),
            ]);

            // Tạo bác sĩ với kinh nghiệm mặc định là "0 năm"
            $MaBacSi = DB::table('bacsi')->insertGetId([
                'MaTaiKhoan' => $MaTaiKhoan,
                'ho' => $request->ho,
                'ten' => $request->ten,
                'ngaysinh' => $request->ngaysinh,
                'gioitinh' => $request->gioitinh,
                'ChuyenKhoa' => $request->ChuyenKhoa,
                'BangCap' => $request->BangCap,
                'KinhNghiem' => $request->KinhNghiem ?? '0 năm', // Mặc định "0 năm"
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
    public function capNhatBacSi(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        // Kiểm tra bác sĩ có tồn tại
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

            // Cập nhật thông tin bác sĩ
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

            // Cập nhật tài khoản
            $dataTaiKhoan = [];
            if ($request->has('email')) $dataTaiKhoan['email'] = $request->email;
            if ($request->has('sdt')) $dataTaiKhoan['sdt'] = $request->sdt;
            if ($request->has('MatKhau')) {
                $dataTaiKhoan['MatKhau'] = password_hash($request->MatKhau, PASSWORD_BCRYPT);
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
    public function xoaBacSi(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        // Kiểm tra bác sĩ có tồn tại
        $bacsi = DB::table('bacsi')->where('MaBacSi', $id)->first();
        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy bác sĩ'
            ], 404);
        }

        // Kiểm tra bác sĩ có lịch làm việc không
        $coLichLamViec = DB::table('lichlamviec')->where('MaBacSi', $id)->exists();
        if ($coLichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể xóa bác sĩ đã có lịch làm việc. Vui lòng xóa lịch làm việc trước.'
            ], 422);
        }

        try {
            DB::beginTransaction();

            // Xóa bác sĩ (cascade sẽ xóa tài khoản)
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
    public function capNhatTrangThaiBacSi(Request $request, $id)
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

    // ==================== QUẢN LÝ CA KHÁM ====================

    /**
     * Lấy danh sách ca khám
     * GET /admin/ca-kham
     */
    public function getDanhSachCaKham(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')
            ->select('*')
            ->orderBy('GioBatDau', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $cakham,
            'total' => count($cakham)
        ], 200);
    }

    /**
     * Lấy chi tiết ca khám
     * GET /admin/ca-kham/{id}
     */
    public function getChiTietCaKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')
            ->where('MaCa', $id)
            ->first();

        if (!$cakham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy ca khám'
            ], 404);
        }

        // Đếm số lịch làm việc trong ca này
        $soLichLamViec = DB::table('lichlamviec')
            ->where('MaCa', $id)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'cakham' => $cakham,
                'soLichLamViec' => $soLichLamViec
            ]
        ], 200);
    }

    /**
     * Thêm ca khám mới
     * POST /admin/ca-kham
     */
    public function themCaKham(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'TenCa' => 'required|string|max:100',
            'SoLuongToiDa' => 'required|integer|min:1',
            'ThoiLuongKham' => 'required|integer|min:5',
            'GioBatDau' => 'required|date_format:H:i:s',
            'GioKetThuc' => 'required|date_format:H:i:s',
            'TrangThai' => 'required|in:active,inactive'
        ]);

        // Kiểm tra ca khám đã tồn tại chưa
        $caTonTai = DB::table('cakham')
            ->where('TenCa', $request->TenCa)
            ->exists();

        if ($caTonTai) {
            return response()->json([
                'success' => false,
                'message' => 'Ca khám này đã tồn tại'
            ], 422);
        }

        // Kiểm tra giờ bắt đầu < giờ kết thúc
        if ($request->GioBatDau >= $request->GioKetThuc) {
            return response()->json([
                'success' => false,
                'message' => 'Giờ bắt đầu phải nhỏ hơn giờ kết thúc'
            ], 422);
        }

        $MaCa = DB::table('cakham')->insertGetId([
            'TenCa' => $request->TenCa,
            'SoLuongToiDa' => $request->SoLuongToiDa,
            'ThoiLuongKham' => $request->ThoiLuongKham,
            'GioBatDau' => $request->GioBatDau,
            'GioKetThuc' => $request->GioKetThuc,
            'TrangThai' => $request->TrangThai
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Thêm ca khám thành công',
            'data' => [
                'MaCa' => $MaCa
            ]
        ], 201);
    }

    /**
     * Cập nhật ca khám
     * PUT /admin/ca-kham/{id}
     */
    public function capNhatCaKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')->where('MaCa', $id)->first();
        if (!$cakham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy ca khám'
            ], 404);
        }

        $request->validate([
            'TenCa' => 'sometimes|required|string|max:100',
            'SoLuongToiDa' => 'sometimes|required|integer|min:1',
            'ThoiLuongKham' => 'sometimes|required|integer|min:5',
            'GioBatDau' => 'sometimes|required|date_format:H:i:s',
            'GioKetThuc' => 'sometimes|required|date_format:H:i:s',
            'TrangThai' => 'sometimes|required|in:active,inactive'
        ]);

        $dataUpdate = [];
        if ($request->has('TenCa')) $dataUpdate['TenCa'] = $request->TenCa;
        if ($request->has('SoLuongToiDa')) $dataUpdate['SoLuongToiDa'] = $request->SoLuongToiDa;
        if ($request->has('ThoiLuongKham')) $dataUpdate['ThoiLuongKham'] = $request->ThoiLuongKham;
        if ($request->has('GioBatDau')) $dataUpdate['GioBatDau'] = $request->GioBatDau;
        if ($request->has('GioKetThuc')) $dataUpdate['GioKetThuc'] = $request->GioKetThuc;
        if ($request->has('TrangThai')) $dataUpdate['TrangThai'] = $request->TrangThai;

        if (empty($dataUpdate)) {
            return response()->json([
                'success' => false,
                'message' => 'Không có dữ liệu để cập nhật'
            ], 422);
        }

        // Kiểm tra giờ bắt đầu < giờ kết thúc
        $GioBatDau = $dataUpdate['GioBatDau'] ?? $cakham->GioBatDau;
        $GioKetThuc = $dataUpdate['GioKetThuc'] ?? $cakham->GioKetThuc;

        if ($GioBatDau >= $GioKetThuc) {
            return response()->json([
                'success' => false,
                'message' => 'Giờ bắt đầu phải nhỏ hơn giờ kết thúc'
            ], 422);
        }

        // Kiểm tra trùng tên ca
        if ($request->has('TenCa')) {
            $trungCa = DB::table('cakham')
                ->where('TenCa', $request->TenCa)
                ->where('MaCa', '!=', $id)
                ->exists();

            if ($trungCa) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tên ca khám này đã tồn tại'
                ], 422);
            }
        }

        DB::table('cakham')->where('MaCa', $id)->update($dataUpdate);

        return response()->json([
            'success' => true,
            'message' => 'Cập nhật ca khám thành công'
        ], 200);
    }

    /**
     * Xóa ca khám
     * DELETE /admin/ca-kham/{id}
     */
    public function xoaCaKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')->where('MaCa', $id)->first();
        if (!$cakham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy ca khám'
            ], 404);
        }

        // Kiểm tra ca khám có lịch làm việc không
        $coLichLamViec = DB::table('lichlamviec')
            ->where('MaCa', $id)
            ->exists();

        if ($coLichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể xóa ca khám đã có lịch làm việc. Vui lòng xóa lịch làm việc trước.'
            ], 422);
        }

        DB::table('cakham')->where('MaCa', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Xóa ca khám thành công'
        ], 200);
    }

    /**
     * Lấy danh sách ca khám hoạt động
     * GET /admin/ca-kham/active
     */
    public function getDanhSachCaKhamActive(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')
            ->where('TrangThai', 'active')
            ->orderBy('GioBatDau', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $cakham,
            'total' => count($cakham)
        ], 200);
    }

    // ==================== QUẢN LÝ LỊCH LÀM VIỆC CỦA BÁC SĨ ====================

    /**
     * Phân công lịch làm việc cho bác sĩ
     * POST /admin/phan-cong-lich-lam-viec
     */
    public function phanCongLichLamViec(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'MaBacSi' => 'required|integer',
            'Ngay' => 'required|date',
            'MaCa' => 'required|integer',
            'MaPhong' => 'required|integer'
        ]);

        // Kiểm tra bác sĩ có tồn tại
        $bacsi = DB::table('bacsi')->where('MaBacSi', $request->MaBacSi)->first();
        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Bác sĩ không tồn tại'
            ], 404);
        }

        // Kiểm tra ca khám có tồn tại
        $cakham = DB::table('cakham')->where('MaCa', $request->MaCa)->first();
        if (!$cakham) {
            return response()->json([
                'success' => false,
                'message' => 'Ca khám không tồn tại'
            ], 404);
        }

        // Kiểm tra phòng khám có tồn tại
        $phongkham = DB::table('phongkham')->where('MaPhong', $request->MaPhong)->first();
        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám không tồn tại'
            ], 404);
        }

        // Kiểm tra bác sĩ đã có lịch làm việc trong ca này chưa
        $trungLichBacSi = DB::table('lichlamviec')
            ->where('MaBacSi', $request->MaBacSi)
            ->where('Ngay', $request->Ngay)
            ->where('MaCa', $request->MaCa)
            ->exists();

        if ($trungLichBacSi) {
            return response()->json([
                'success' => false,
                'message' => 'Bác sĩ đã có lịch làm việc trong ca này'
            ], 422);
        }

        // Kiểm tra phòng khám đã được sử dụng trong ca này chưa
        $trungPhong = DB::table('lichlamviec')
            ->where('Ngay', $request->Ngay)
            ->where('MaCa', $request->MaCa)
            ->where('MaPhong', $request->MaPhong)
            ->exists();

        if ($trungPhong) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám đã được sử dụng trong ca này'
            ], 422);
        }

        // Tạo lịch làm việc
        $MaLichLamViec = DB::table('lichlamviec')->insertGetId([
            'MaBacSi' => $request->MaBacSi,
            'Ngay' => $request->Ngay,
            'MaCa' => $request->MaCa,
            'MaPhong' => $request->MaPhong
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Phân công lịch làm việc thành công',
            'data' => [
                'MaLichLamViec' => $MaLichLamViec
            ]
        ], 201);
    }

    /**
     * Lấy danh sách lịch làm việc của bác sĩ
     * GET /admin/lich-lam-viec-bac-si/{MaBacSi}
     */
    public function getDanhSachLichLamViecBacSi(Request $request, $MaBacSi)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        // Kiểm tra bác sĩ có tồn tại
        $bacsi = DB::table('bacsi')->where('MaBacSi', $MaBacSi)->first();
        if (!$bacsi) {
            return response()->json([
                'success' => false,
                'message' => 'Bác sĩ không tồn tại'
            ], 404);
        }

        $query = DB::table('lichlamviec as llv')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->where('llv.MaBacSi', $MaBacSi)
            ->select(
                'llv.MaLichLamViec',
                'llv.Ngay',
                'llv.MaCa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                'llv.MaPhong',
                'pk.TenPhong',
                'pk.Khu'
            );

        // Lọc theo khoảng thời gian
        if ($request->has('tu_ngay') && $request->has('den_ngay')) {
            $query->whereBetween('llv.Ngay', [$request->tu_ngay, $request->den_ngay]);
        }

        $lichLamViec = $query->orderBy('llv.Ngay', 'asc')
            ->orderBy('ck.GioBatDau', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $lichLamViec,
            'total' => count($lichLamViec)
        ], 200);
    }

    /**
     * Hủy lịch làm việc của bác sĩ
     * DELETE /admin/lich-lam-viec/{id}
     */
    public function huyCongViec(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $lichLamViec = DB::table('lichlamviec')->where('MaLichLamViec', $id)->first();
        if (!$lichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy lịch làm việc'
            ], 404);
        }

        // Kiểm tra đã có lịch khám nào đăng ký chưa
        $coLichKham = DB::table('lichkham')
            ->where('MaLichLamViec', $id)
            ->exists();

        if ($coLichKham) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể hủy lịch làm việc đã có bệnh nhân đăng ký'
            ], 422);
        }

        DB::table('lichlamviec')->where('MaLichLamViec', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Hủy lịch làm việc thành công'
        ], 200);
    }

    /**
     * Lấy danh sách bác sĩ làm việc trong ngày
     * GET /admin/bac-si-lam-viec-ngay
     */
    public function getDanhSachBacSiLamViecNgay(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'Ngay' => 'required|date'
        ]);

        $bacsiLamViec = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->where('llv.Ngay', $request->Ngay)
            ->select(
                'llv.MaLichLamViec',
                'bs.MaBacSi',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                'pk.TenPhong',
                'pk.Khu'
            )
            ->orderBy('ck.GioBatDau', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $bacsiLamViec,
            'total' => count($bacsiLamViec)
        ], 200);
    }

    /**
     * Lấy danh sách bác sĩ làm việc trong ca
     * GET /admin/bac-si-lam-viec-ca
     */
    public function getDanhSachBacSiLamViecCa(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'Ngay' => 'required|date',
            'MaCa' => 'required|integer'
        ]);

        $bacsiLamViec = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->where('llv.Ngay', $request->Ngay)
            ->where('llv.MaCa', $request->MaCa)
            ->select(
                'llv.MaLichLamViec',
                'bs.MaBacSi',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                'pk.TenPhong',
                'pk.Khu'
            )
            ->get();

        return response()->json([
            'success' => true,
            'data' => $bacsiLamViec,
            'total' => count($bacsiLamViec)
        ], 200);
    }

    /**
     * Thay đổi phòng khám cho lịch làm việc
     * PUT /admin/lich-lam-viec/{id}/phong
     */
    public function thayDoiPhongKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'MaPhong' => 'required|integer'
        ]);

        $lichLamViec = DB::table('lichlamviec')->where('MaLichLamViec', $id)->first();
        if (!$lichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy lịch làm việc'
            ], 404);
        }

        // Kiểm tra phòng khám có tồn tại
        $phongkham = DB::table('phongkham')->where('MaPhong', $request->MaPhong)->first();
        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám không tồn tại'
            ], 404);
        }

        // Kiểm tra phòng khám đã được sử dụng trong ca này chưa
        $trungPhong = DB::table('lichlamviec')
            ->where('Ngay', $lichLamViec->Ngay)
            ->where('MaCa', $lichLamViec->MaCa)
            ->where('MaPhong', $request->MaPhong)
            ->where('MaLichLamViec', '!=', $id)
            ->exists();

        if ($trungPhong) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám đã được sử dụng trong ca này'
            ], 422);
        }

        DB::table('lichlamviec')->where('MaLichLamViec', $id)->update([
            'MaPhong' => $request->MaPhong
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Thay đổi phòng khám thành công'
        ], 200);
    }

    /**
     * Lấy danh sách phòng khám
     * GET /admin/phong-kham
     */
    public function getDanhSachPhongKham(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $phongkham = DB::table('phongkham')
            ->select('*')
            ->orderBy('Khu', 'asc')
            ->orderBy('TenPhong', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $phongkham
        ], 200);
    }

    /**
     * Kiểm tra phòng khám có trống không
     * GET /admin/kiem-tra-phong
     */
    public function kiemTraPhongTrong(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'Ngay' => 'required|date',
            'MaCa' => 'required|integer'
        ]);

        $phongDaSuDung = DB::table('lichlamviec')
            ->where('Ngay', $request->Ngay)
            ->where('MaCa', $request->MaCa)
            ->pluck('MaPhong')
            ->toArray();

        $phongTrong = DB::table('phongkham')
            ->whereNotIn('MaPhong', $phongDaSuDung)
            ->select('*')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $phongTrong
        ], 200);
    }

    /**
     * Lấy lịch làm việc của bác sĩ theo tuần/tháng
     * GET /admin/lich-lam-viec/bac-si/{MaBacSi}
     */
    public function getLichLamViecBacSi(Request $request, $MaBacSi)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $query = DB::table('lichlamviec as llv')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->where('llv.MaBacSi', $MaBacSi)
            ->select(
                'llv.MaLichLamViec',
                'llv.Ngay',
                'llv.MaCa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                'llv.MaPhong',
                'pk.TenPhong',
                'pk.Khu'
            );

        // Lọc theo khoảng thời gian
        if ($request->has('tu_ngay') && $request->has('den_ngay')) {
            $query->whereBetween('llv.Ngay', [$request->tu_ngay, $request->den_ngay]);
        }

        $lichLamViec = $query->orderBy('llv.Ngay', 'asc')
            ->orderBy('ck.GioBatDau', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $lichLamViec
        ], 200);
    }

    // ==================== QUẢN LÝ PHÒNG KHÁM ====================

    /**
     * Lấy danh sách tất cả phòng khám
     * GET /admin/phong-kham/danh-sach
     */
    public function getDanhSachPhongKhamAll(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $query = DB::table('phongkham');

        // Tìm kiếm theo tên phòng
        if ($request->has('search')) {
            $search = $request->search;
            $query->where('TenPhong', 'like', "%{$search}%")
                  ->orWhere('Khu', 'like', "%{$search}%");
        }

        // Lọc theo khu
        if ($request->has('Khu')) {
            $query->where('Khu', $request->Khu);
        }

        $phongkham = $query->orderBy('Khu', 'asc')
            ->orderBy('TenPhong', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $phongkham,
            'total' => count($phongkham)
        ], 200);
    }

    /**
     * Lấy chi tiết phòng khám
     * GET /admin/phong-kham/{id}
     */
    public function getChiTietPhongKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $phongkham = DB::table('phongkham')
            ->where('MaPhong', $id)
            ->first();

        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy phòng khám'
            ], 404);
        }

        // Lấy thông tin lịch làm việc trong phòng này
        $lichLamViec = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->where('llv.MaPhong', $id)
            ->where('llv.Ngay', '>=', now()->toDateString())
            ->select(
                'llv.MaLichLamViec',
                'llv.Ngay',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa'
            )
            ->orderBy('llv.Ngay', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'phongkham' => $phongkham,
                'lichlamviec' => $lichLamViec
            ]
        ], 200);
    }

    /**
     * Thêm phòng khám mới
     * POST /admin/phong-kham
     */
    public function themPhongKham(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'TenPhong' => 'required|string|max:255',
            'Khu' => 'required|string|max:100'
        ]);

        // Kiểm tra phòng khám đã tồn tại chưa
        $phongTonTai = DB::table('phongkham')
            ->where('TenPhong', $request->TenPhong)
            ->where('Khu', $request->Khu)
            ->exists();

        if ($phongTonTai) {
            return response()->json([
                'success' => false,
                'message' => 'Phòng khám này đã tồn tại'
            ], 422);
        }

        $MaPhong = DB::table('phongkham')->insertGetId([
            'TenPhong' => $request->TenPhong,
            'Khu' => $request->Khu
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Thêm phòng khám thành công',
            'data' => [
                'MaPhong' => $MaPhong
            ]
        ], 201);
    }

    /**
     * Cập nhật thông tin phòng khám
     * PUT /admin/phong-kham/{id}
     */
    public function capNhatPhongKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $phongkham = DB::table('phongkham')->where('MaPhong', $id)->first();
        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy phòng khám'
            ], 404);
        }

        $request->validate([
            'TenPhong' => 'sometimes|required|string|max:255',
            'Khu' => 'sometimes|required|string|max:100'
        ]);

        $dataUpdate = [];
        if ($request->has('TenPhong')) $dataUpdate['TenPhong'] = $request->TenPhong;
        if ($request->has('Khu')) $dataUpdate['Khu'] = $request->Khu;

        if (empty($dataUpdate)) {
            return response()->json([
                'success' => false,
                'message' => 'Không có dữ liệu để cập nhật'
            ], 422);
        }

        // Kiểm tra trùng tên phòng
        if ($request->has('TenPhong') || $request->has('Khu')) {
            $TenPhong = $dataUpdate['TenPhong'] ?? $phongkham->TenPhong;
            $Khu = $dataUpdate['Khu'] ?? $phongkham->Khu;

            $trungPhong = DB::table('phongkham')
                ->where('TenPhong', $TenPhong)
                ->where('Khu', $Khu)
                ->where('MaPhong', '!=', $id)
                ->exists();

            if ($trungPhong) {
                return response()->json([
                    'success' => false,
                    'message' => 'Phòng khám này đã tồn tại'
                ], 422);
            }
        }

        DB::table('phongkham')->where('MaPhong', $id)->update($dataUpdate);

        return response()->json([
            'success' => true,
            'message' => 'Cập nhật phòng khám thành công'
        ], 200);
    }

    /**
     * Xóa phòng khám
     * DELETE /admin/phong-kham/{id}
     */
    public function xoaPhongKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $phongkham = DB::table('phongkham')->where('MaPhong', $id)->first();
        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy phòng khám'
            ], 404);
        }

        // Kiểm tra phòng khám có lịch làm việc không
        $coLichLamViec = DB::table('lichlamviec')
            ->where('MaPhong', $id)
            ->exists();

        if ($coLichLamViec) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể xóa phòng khám đã có lịch làm việc. Vui lòng xóa lịch làm việc trước.'
            ], 422);
        }

        DB::table('phongkham')->where('MaPhong', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Xóa phòng khám thành công'
        ], 200);
    }

    /**
     * Lấy danh sách các khu trong phòng khám
     * GET /admin/phong-kham/khu/danh-sach
     */
    public function getDanhSachKhu(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $khuList = DB::table('phongkham')
            ->distinct()
            ->pluck('Khu')
            ->filter()
            ->values();

        return response()->json([
            'success' => true,
            'data' => $khuList
        ], 200);
    }

    /**
     * Lấy thống kê phòng khám
     * GET /admin/phong-kham/thong-ke
     */
    public function getThongKePhongKham(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        // Tổng số phòng khám
        $tongPhong = DB::table('phongkham')->count();

        // Số phòng khám theo khu
        $phongTheoKhu = DB::table('phongkham')
            ->select('Khu', DB::raw('COUNT(*) as SoPhong'))
            ->groupBy('Khu')
            ->get();

        // Phòng khám có lịch làm việc hôm nay
        $phongHomNay = DB::table('lichlamviec')
            ->where('Ngay', now()->toDateString())
            ->distinct()
            ->count('MaPhong');

        // Phòng khám sắp có lịch (7 ngày tới)
        $phongSapCo = DB::table('lichlamviec')
            ->whereBetween('Ngay', [now()->toDateString(), now()->addDays(7)->toDateString()])
            ->distinct()
            ->count('MaPhong');

        return response()->json([
            'success' => true,
            'data' => [
                'tongPhong' => $tongPhong,
                'phongTheoKhu' => $phongTheoKhu,
                'phongHomNay' => $phongHomNay,
                'phongSapCo' => $phongSapCo
            ]
        ], 200);
    }

    /**
     * Lấy lịch sử sử dụng phòng khám
     * GET /admin/phong-kham/{id}/lich-su
     */
    public function getLichSuPhongKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $phongkham = DB::table('phongkham')->where('MaPhong', $id)->first();
        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy phòng khám'
            ], 404);
        }

        $query = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->where('llv.MaPhong', $id)
            ->select(
                'llv.MaLichLamViec',
                'llv.Ngay',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa'
            );

        // Lọc theo khoảng thời gian
        if ($request->has('tu_ngay') && $request->has('den_ngay')) {
            $query->whereBetween('llv.Ngay', [$request->tu_ngay, $request->den_ngay]);
        }

        $lichSu = $query->orderBy('llv.Ngay', 'desc')
            ->orderBy('ck.GioBatDau', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $lichSu
        ], 200);
    }

    /**
     * Kiểm tra tình trạng phòng khám (trống/đang sử dụng)
     * GET /admin/phong-kham/{id}/trang-thai
     */
    public function kiemTraTrangThaiPhongKham(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'Ngay' => 'required|date',
            'MaCa' => 'required|integer'
        ]);

        $phongkham = DB::table('phongkham')->where('MaPhong', $id)->first();
        if (!$phongkham) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy phòng khám'
            ], 404);
        }

        // Kiểm tra phòng có được sử dụng trong ca này không
        $lichLamViec = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->where('llv.MaPhong', $id)
            ->where('llv.Ngay', $request->Ngay)
            ->where('llv.MaCa', $request->MaCa)
            ->select(
                'llv.MaLichLamViec',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc'
            )
            ->first();

        $trangThai = $lichLamViec ? 'dang_su_dung' : 'trong';

        return response()->json([
            'success' => true,
            'data' => [
                'MaPhong' => $id,
                'TenPhong' => $phongkham->TenPhong,
                'Khu' => $phongkham->Khu,
                'Ngay' => $request->Ngay,
                'MaCa' => $request->MaCa,
                'TrangThai' => $trangThai,
                'ChiTiet' => $lichLamViec
            ]
        ], 200);
    }

    // ==================== QUẢN LÝ PHÒNG BỆNH ====================

    /**
     * Lấy danh sách tất cả phòng bệnh
     * GET /admin/phong-benh/danh-sach
     */
    /**
     * Lấy phòng khám trống trong ca nào đó
     * GET /admin/phong-kham/trong
     */
    public function getPhongKhamTrong(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'Ngay' => 'required|date',
            'MaCa' => 'required|integer'
        ]);

        $phongDaSuDung = DB::table('lichlamviec')
            ->where('Ngay', $request->Ngay)
            ->where('MaCa', $request->MaCa)
            ->pluck('MaPhong')
            ->toArray();

        $phongTrong = DB::table('phongkham')
            ->whereNotIn('MaPhong', $phongDaSuDung)
            ->select('*')
            ->orderBy('Khu', 'asc')
            ->orderBy('TenPhong', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $phongTrong,
            'total' => count($phongTrong)
        ], 200);
    }

    /**
     * Lấy phòng khám đang sử dụng trong ca nào đó
     * GET /admin/phong-kham/dang-su-dung
     */
    public function getPhongKhamDangSuDung(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $request->validate([
            'Ngay' => 'required|date',
            'MaCa' => 'required|integer'
        ]);

        $phongDangSuDung = DB::table('lichlamviec as llv')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->where('llv.Ngay', $request->Ngay)
            ->where('llv.MaCa', $request->MaCa)
            ->select(
                'pk.MaPhong',
                'pk.TenPhong',
                'pk.Khu',
                'llv.MaLichLamViec',
                DB::raw("CONCAT(bs.ho, ' ', bs.ten) as TenBacSi"),
                'bs.ChuyenKhoa',
                'ck.TenCa',
                'ck.GioBatDau',
                'ck.GioKetThuc'
            )
            ->orderBy('pk.Khu', 'asc')
            ->orderBy('pk.TenPhong', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $phongDangSuDung,
            'total' => count($phongDangSuDung)
        ], 200);
    }

    /**
     * Lấy danh sách phòng khám theo khu
     * GET /admin/phong-kham/khu/{khu}
     */
    public function getPhongKhamTheoKhu(Request $request, $khu)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $phongkham = DB::table('phongkham')
            ->where('Khu', $khu)
            ->orderBy('TenPhong', 'asc')
            ->get();

        if ($phongkham->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy phòng khám trong khu này'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $phongkham,
            'total' => count($phongkham)
        ], 200);
    }
}