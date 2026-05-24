<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BenhNhanController
{
    public function index(Request $request)
    {
        $query = DB::table('benhnhan')
            ->join('taikhoan', 'benhnhan.MaTaiKhoan', '=', 'taikhoan.MaTaiKhoan')
            ->select(
                'benhnhan.MaBenhNhan',
                'benhnhan.ho',
                'benhnhan.ten',
                'benhnhan.ngaysinh',
                'benhnhan.gioitinh',
                'benhnhan.cccd',
                'benhnhan.diachi',
                'benhnhan.BHYT',
                'taikhoan.MaTaiKhoan',
                'taikhoan.email',
                'taikhoan.sdt',
                'taikhoan.trangthaihoatdong',
                'taikhoan.ngaytao'
            );

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('benhnhan.ho', 'like', "%$search%")
                    ->orWhere('benhnhan.ten', 'like', "%$search%")
                    ->orWhere('taikhoan.email', 'like', "%$search%")
                    ->orWhere('taikhoan.sdt', 'like', "%$search%")
                    ->orWhere('benhnhan.cccd', 'like', "%$search%");
            });
        }

        $benhNhan = $query->orderBy('benhnhan.MaBenhNhan', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $benhNhan,
            'total' => $benhNhan->count(),
        ]);
    }

    public function show($id)
    {
        $benhNhan = DB::table('benhnhan')
            ->join('taikhoan', 'benhnhan.MaTaiKhoan', '=', 'taikhoan.MaTaiKhoan')
            ->select(
                'benhnhan.MaBenhNhan',
                'benhnhan.ho',
                'benhnhan.ten',
                'benhnhan.ngaysinh',
                'benhnhan.gioitinh',
                'benhnhan.cccd',
                'benhnhan.diachi',
                'benhnhan.BHYT',
                'taikhoan.MaTaiKhoan',
                'taikhoan.email',
                'taikhoan.sdt',
                'taikhoan.trangthaihoatdong',
                'taikhoan.ngaytao'
            )
            ->where('benhnhan.MaBenhNhan', $id)
            ->first();

        if (!$benhNhan) {
            return response()->json(['success' => false, 'message' => 'Không tìm thấy bệnh nhân'], 404);
        }

        $soLichKham = DB::table('lichkham')->where('MaBenhNhan', $id)->count();

        return response()->json([
            'success' => true,
            'data' => array_merge((array) $benhNhan, ['soLichKham' => $soLichKham]),
        ]);
    }

    public function updateStatus(Request $request, $id)
    {
        $benhNhan = DB::table('benhnhan')->where('MaBenhNhan', $id)->first();
        if (!$benhNhan) {
            return response()->json(['success' => false, 'message' => 'Không tìm thấy bệnh nhân'], 404);
        }

        $trangThai = $request->input('trangthaihoatdong');
        if (!in_array($trangThai, ['active', 'inactive'])) {
            return response()->json(['success' => false, 'message' => 'Trạng thái không hợp lệ'], 422);
        }

        DB::table('taikhoan')
            ->where('MaTaiKhoan', $benhNhan->MaTaiKhoan)
            ->update(['trangthaihoatdong' => $trangThai]);

        $message = $trangThai === 'active' ? 'Mở khóa tài khoản thành công' : 'Khóa tài khoản thành công';

        return response()->json(['success' => true, 'message' => $message]);
    }

    public function destroy($id)
    {
        $benhNhan = DB::table('benhnhan')->where('MaBenhNhan', $id)->first();
        if (!$benhNhan) {
            return response()->json(['success' => false, 'message' => 'Không tìm thấy bệnh nhân'], 404);
        }

        $hasAppointments = DB::table('lichkham')->where('MaBenhNhan', $id)->exists();
        if ($hasAppointments) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể xóa bệnh nhân đã có lịch khám',
            ], 422);
        }

        DB::table('benhnhan')->where('MaBenhNhan', $id)->delete();
        DB::table('taikhoan')->where('MaTaiKhoan', $benhNhan->MaTaiKhoan)->delete();

        return response()->json(['success' => true, 'message' => 'Xóa bệnh nhân thành công']);
    }
}
