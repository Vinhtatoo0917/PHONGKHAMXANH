<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CaKhamController extends Controller
{
    private function checkAdmin(Request $request)
    {
        $token = $request->bearerToken();
        if (!$token) {
            return response()->json(['success' => false, 'message' => 'Token không hợp lệ'], 401);
        }
        $taikhoan = DB::table('taikhoan')->where('AccessToken', $token)->first();
        if (!$taikhoan) {
            return response()->json(['success' => false, 'message' => 'Tài khoản không tồn tại'], 404);
        }
        if ($taikhoan->VaiTro !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Bạn không có quyền truy cập'], 403);
        }
        return null;
    }

    public function index(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $query = DB::table('cakham');
        if ($request->has('TrangThai')) $query->where('TrangThai', $request->TrangThai);
        if ($request->has('search')) $query->where('TenCa', 'like', "%{$request->search}%");

        $cakham = $query->orderBy('GioBatDau', 'asc')->get();
        return response()->json(['success' => true, 'data' => $cakham, 'total' => count($cakham)], 200);
    }

    public function show(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')->where('MaCa', $id)->first();
        if (!$cakham) {
            return response()->json(['success' => false, 'message' => 'Không tìm thấy ca khám'], 404);
        }

        $soLichLamViec = DB::table('lichlamviec')->where('MaCa', $id)->count();
        return response()->json(['success' => true, 'data' => ['cakham' => $cakham, 'soLichLamViec' => $soLichLamViec]], 200);
    }

    public function store(Request $request)
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

        if (DB::table('cakham')->where('TenCa', $request->TenCa)->exists()) {
            return response()->json(['success' => false, 'message' => 'Ca khám này đã tồn tại'], 422);
        }

        if ($request->GioBatDau >= $request->GioKetThuc) {
            return response()->json(['success' => false, 'message' => 'Giờ bắt đầu phải nhỏ hơn giờ kết thúc'], 422);
        }

        $MaCa = DB::table('cakham')->insertGetId([
            'TenCa' => $request->TenCa,
            'SoLuongToiDa' => $request->SoLuongToiDa,
            'ThoiLuongKham' => $request->ThoiLuongKham,
            'GioBatDau' => $request->GioBatDau,
            'GioKetThuc' => $request->GioKetThuc,
            'TrangThai' => $request->TrangThai
        ]);

        return response()->json(['success' => true, 'message' => 'Thêm ca khám thành công', 'data' => ['MaCa' => $MaCa]], 201);
    }

    public function update(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')->where('MaCa', $id)->first();
        if (!$cakham) {
            return response()->json(['success' => false, 'message' => 'Không tìm thấy ca khám'], 404);
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
            return response()->json(['success' => false, 'message' => 'Không có dữ liệu để cập nhật'], 422);
        }

        $GioBatDau = $dataUpdate['GioBatDau'] ?? $cakham->GioBatDau;
        $GioKetThuc = $dataUpdate['GioKetThuc'] ?? $cakham->GioKetThuc;

        if ($GioBatDau >= $GioKetThuc) {
            return response()->json(['success' => false, 'message' => 'Giờ bắt đầu phải nhỏ hơn giờ kết thúc'], 422);
        }

        if ($request->has('TenCa') && DB::table('cakham')->where('TenCa', $request->TenCa)->where('MaCa', '!=', $id)->exists()) {
            return response()->json(['success' => false, 'message' => 'Tên ca khám này đã tồn tại'], 422);
        }

        DB::table('cakham')->where('MaCa', $id)->update($dataUpdate);
        return response()->json(['success' => true, 'message' => 'Cập nhật ca khám thành công'], 200);
    }

    public function destroy(Request $request, $id)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')->where('MaCa', $id)->first();
        if (!$cakham) {
            return response()->json(['success' => false, 'message' => 'Không tìm thấy ca khám'], 404);
        }

        if (DB::table('lichlamviec')->where('MaCa', $id)->exists()) {
            return response()->json(['success' => false, 'message' => 'Không thể xóa ca khám đã có lịch làm việc'], 422);
        }

        DB::table('cakham')->where('MaCa', $id)->delete();
        return response()->json(['success' => true, 'message' => 'Xóa ca khám thành công'], 200);
    }

    public function getActive(Request $request)
    {
        $checkAdmin = $this->checkAdmin($request);
        if ($checkAdmin) return $checkAdmin;

        $cakham = DB::table('cakham')->where('TrangThai', 'active')->orderBy('GioBatDau', 'asc')->get();
        return response()->json(['success' => true, 'data' => $cakham, 'total' => count($cakham)], 200);
    }
}
