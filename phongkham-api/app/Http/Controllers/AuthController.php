<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'sdt' => 'required|string',
            'MatKhau' => 'required',
        ]);

        // Tìm tài khoản theo số điện thoại
        $taikhoan = DB::table('taikhoan')
            ->where('sdt', $request->sdt)
            ->first();

        if (!$taikhoan) {
            return response()->json([
                'success' => false,
                'message' => 'Số điện thoại hoặc mật khẩu không đúng'
            ], 401);
        }

        // Kiểm tra mật khẩu (hỗ trợ cả plain text và hash)
        $passwordMatch = false;
        
        // Kiểm tra xem mật khẩu có được hash không
        if (strlen($taikhoan->MatKhau) === 60 && str_starts_with($taikhoan->MatKhau, '$2y$')) {
            // Mật khẩu đã hash, dùng Hash::check
            $passwordMatch = Hash::check($request->MatKhau, $taikhoan->MatKhau);
        } else {
            // Mật khẩu chưa hash (plain text), so sánh trực tiếp
            $passwordMatch = ($request->MatKhau === $taikhoan->MatKhau);
        }

        if (!$passwordMatch) {
            return response()->json([
                'success' => false,
                'message' => 'Số điện thoại hoặc mật khẩu không đúng'
            ], 401);
        }

        if ($taikhoan->trangthaihoatdong !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Tài khoản đã bị khóa'
            ], 403);
        }

        $token = bin2hex(random_bytes(32));

        DB::table('taikhoan')
            ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
            ->update([
                'Accesstoken' => $token,
                'dangnhaplancuoi' => now()
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Đăng nhập thành công',
            'data' => [
                'token' => $token,
                'user' => [
                    'MaTaiKhoan' => $taikhoan->MaTaiKhoan,
                    'email' => $taikhoan->email,
                    'sdt' => $taikhoan->sdt,
                    'VaiTro' => $taikhoan->VaiTro,
                ]
            ]
        ], 200);
    }

    /**
     * Đăng ký tài khoản mới
     */
    public function register(Request $request)
    {
        $request->validate([
            'sdt' => 'required|string',
            'email' => 'required|email',
            'MatKhau' => 'required|min:6',
        ]);

        // Kiểm tra số điện thoại đã tồn tại
        $existingSdt = DB::table('taikhoan')
            ->where('sdt', $request->sdt)
            ->exists();

        if ($existingSdt) {
            return response()->json([
                'success' => false,
                'message' => 'Số điện thoại đã được sử dụng'
            ], 422);
        }

        // Kiểm tra email đã tồn tại
        $existingEmail = DB::table('taikhoan')
            ->where('email', $request->email)
            ->exists();

        if ($existingEmail) {
            return response()->json([
                'success' => false,
                'message' => 'Email đã được sử dụng'
            ], 422);
        }

        // Tạo token
        $token = bin2hex(random_bytes(32));

        // Thêm tài khoản mới với vai trò mặc định là BenhNhan
        $MaTaiKhoan = DB::table('taikhoan')->insertGetId([
            'sdt' => $request->sdt,
            'email' => $request->email,
            'MatKhau' => Hash::make($request->MatKhau),
            'VaiTro' => 'BenhNhan', // Mặc định là Bệnh Nhân
            'Accesstoken' => $token,
            'trangthaihoatdong' => 'active',
            'ngaytao' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Đăng ký thành công',
            'data' => [
                'token' => $token,
                'user' => [
                    'MaTaiKhoan' => $MaTaiKhoan,
                    'sdt' => $request->sdt,
                    'email' => $request->email,
                    'VaiTro' => 'BenhNhan',
                ]
            ]
        ], 201);
    }

    /**
     * Đăng xuất
     */
    public function logout(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token không hợp lệ'
            ], 401);
        }

        // Xóa token
        DB::table('taikhoan')
            ->where('Accesstoken', $token)
            ->update(['Accesstoken' => null]);

        return response()->json([
            'success' => true,
            'message' => 'Đăng xuất thành công'
        ], 200);
    }

    /**
     * Lấy thông tin user hiện tại
     */
    public function me(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token không hợp lệ'
            ], 401);
        }

        $taikhoan = DB::table('taikhoan')
            ->where('Accesstoken', $token)
            ->first();

        if (!$taikhoan) {
            return response()->json([
                'success' => false,
                'message' => 'Tài khoản không tồn tại'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'MaTaiKhoan' => $taikhoan->MaTaiKhoan,
                'email' => $taikhoan->email,
                'sdt' => $taikhoan->sdt,
                'VaiTro' => $taikhoan->VaiTro,
                'trangthaihoatdong' => $taikhoan->trangthaihoatdong,
            ]
        ], 200);
    }

}
