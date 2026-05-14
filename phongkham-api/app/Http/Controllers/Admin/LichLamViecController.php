<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LichLamViecController extends Controller
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
     * Lấy danh sách lịch làm việc
     * GET /admin/lich-lam-viec
     */
    public function index(Request $request)
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
            'data' => $lichLamViec,
            'total' => count($lichLamViec)
        ], 200);
    }

    /**
     * Lấy chi tiết lịch làm việc
     * GET /admin/lich-lam-viec/{id}
     */
    public function show(Request $request, $id)
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

        return response()->json([
            'success' => true,
            'data' => $lichLamViec
        ], 200);
    }

    /**
     * Tạo lịch làm việc mới
     * POST /admin/lich-lam-viec
     */
    public function store(Request $request)
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
    public function update(Request $request, $id)
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
    public function destroy(Request $request, $id)
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

        // Xóa lịch làm việc
        DB::table('lichlamviec')->where('MaLichLamViec', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Xóa lịch làm việc thành công'
        ], 200);
    }

    /**
     * Lấy lịch làm việc của bác sĩ
     * GET /admin/lich-lam-viec/bac-si/{MaBacSi}
     */
    public function getLichBacSi(Request $request, $MaBacSi)
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
     * Lấy danh sách bác sĩ làm việc trong ngày
     * GET /admin/lich-lam-viec/ngay/{ngay}
     */
    public function getLichNgay(Request $request, $ngay)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $bacsiLamViec = DB::table('lichlamviec as llv')
            ->join('bacsi as bs', 'llv.MaBacSi', '=', 'bs.MaBacSi')
            ->join('cakham as ck', 'llv.MaCa', '=', 'ck.MaCa')
            ->join('phongkham as pk', 'llv.MaPhong', '=', 'pk.MaPhong')
            ->where('llv.Ngay', $ngay)
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
     * GET /admin/lich-lam-viec/ca/{maCa}
     */
    public function getLichCa(Request $request, $maCa)
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
            ->where('llv.MaCa', $maCa)
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
}
