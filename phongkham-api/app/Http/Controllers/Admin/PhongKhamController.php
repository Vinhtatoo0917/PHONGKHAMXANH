<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PhongKhamController extends Controller
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
     * Lấy danh sách phòng khám
     * GET /admin/phong-kham
     */
    public function index(Request $request)
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
     * Lấy danh sách tất cả phòng khám (có tìm kiếm, lọc)
     * GET /admin/phong-kham/danh-sach
     */
    public function getAll(Request $request)
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
    public function show(Request $request, $id)
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
    public function store(Request $request)
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
    public function update(Request $request, $id)
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
    public function destroy(Request $request, $id)
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
     * Lấy danh sách các khu
     * GET /admin/phong-kham/khu/danh-sach
     */
    public function getKhuList(Request $request)
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
    public function getStatistics(Request $request)
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
     * Lấy phòng khám trống trong ca nào đó
     * GET /admin/phong-kham/trong
     */
    public function getPhongTrong(Request $request)
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
    public function getPhongDangSuDung(Request $request)
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
    public function getPhongTheoKhu(Request $request, $khu)
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

    /**
     * Lấy lịch sử sử dụng phòng khám
     * GET /admin/phong-kham/{id}/lich-su
     */
    public function getLichSu(Request $request, $id)
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
    public function checkStatus(Request $request, $id)
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
}
