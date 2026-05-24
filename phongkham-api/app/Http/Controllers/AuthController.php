<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use App\Mail\OtpResetPasswordMail;

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

        $maBenhNhan = DB::table('benhnhan')
            ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
            ->value('MaBenhNhan');

        // Nếu là bác sĩ thì join bảng bacsi để lấy chuyên khoa (vd: "Khoa Xét nghiệm")
        $bacSiInfo = null;
        if (strtolower((string) $taikhoan->VaiTro) === 'bacsi') {
            $bacSiInfo = DB::table('bacsi')
                ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
                ->select('MaBacSi', 'ChuyenKhoa', 'ho', 'ten')
                ->first();
        }

        return response()->json([
            'success' => true,
            'message' => 'Đăng nhập thành công',
            'data' => [
                'token' => $token,
                'user' => [
                    'MaTaiKhoan' => $taikhoan->MaTaiKhoan,
                    'MaBenhNhan' => $maBenhNhan,
                    'email' => $taikhoan->email,
                    'sdt' => $taikhoan->sdt,
                    'VaiTro' => $taikhoan->VaiTro,
                    // Bổ sung cho bác sĩ để Flutter nhận diện đúng tab "Công việc xét nghiệm của tôi"
                    'MaBacSi' => $bacSiInfo->MaBacSi ?? null,
                    'ChuyenKhoa' => $bacSiInfo->ChuyenKhoa ?? null,
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
        $MaTaiKhoan = DB::transaction(function () use ($request, $token) {
            $maTaiKhoan = DB::table('taikhoan')->insertGetId([
                'sdt' => $request->sdt,
                'email' => $request->email,
                'MatKhau' => Hash::make($request->MatKhau),
                'VaiTro' => 'BenhNhan', // Mặc định là Bệnh Nhân
                'Accesstoken' => $token,
                'trangthaihoatdong' => 'active',
                'ngaytao' => now(),
            ]);

            DB::table('benhnhan')->insert([
                'MaTaiKhoan' => $maTaiKhoan,
                'ho' => '',
                'ten' => $request->sdt,
            ]);

            return $maTaiKhoan;
        });

        $maBenhNhan = DB::table('benhnhan')
            ->where('MaTaiKhoan', $MaTaiKhoan)
            ->value('MaBenhNhan');

        return response()->json([
            'success' => true,
            'message' => 'Đăng ký thành công',
            'data' => [
                'token' => $token,
                'user' => [
                    'MaTaiKhoan' => $MaTaiKhoan,
                    'MaBenhNhan' => $maBenhNhan,
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
     * Gửi OTP đặt lại mật khẩu qua email
     */
    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $taikhoan = DB::table('taikhoan')->where('email', $request->email)->first();

        if (!$taikhoan) {
            return response()->json([
                'success' => false,
                'message' => 'Email này chưa được đăng ký trong hệ thống',
            ], 404);
        }

        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = now()->addMinutes(10);

        DB::table('taikhoan')
            ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
            ->update([
                'otp_reset_code' => $otp,
                'otp_reset_expires_at' => $expiresAt,
            ]);

        Mail::to($request->email)->send(new OtpResetPasswordMail($otp));

        return response()->json([
            'success' => true,
            'message' => 'Mã xác nhận đã được gửi đến email của bạn',
        ]);
    }

    /**
     * Xác nhận OTP và cập nhật mật khẩu mới
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'otp'      => 'required|string|size:6',
            'password' => 'required|string|min:6',
        ]);

        $taikhoan = DB::table('taikhoan')->where('email', $request->email)->first();

        if (!$taikhoan) {
            return response()->json([
                'success' => false,
                'message' => 'Email không tồn tại trong hệ thống',
            ], 404);
        }

        if ($taikhoan->otp_reset_code !== $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'Mã xác nhận không đúng',
            ], 422);
        }

        if (!$taikhoan->otp_reset_expires_at || now()->isAfter($taikhoan->otp_reset_expires_at)) {
            return response()->json([
                'success' => false,
                'message' => 'Mã xác nhận đã hết hạn, vui lòng yêu cầu mã mới',
            ], 422);
        }

        DB::table('taikhoan')
            ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
            ->update([
                'MatKhau'              => Hash::make($request->password),
                'otp_reset_code'       => null,
                'otp_reset_expires_at' => null,
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Đặt lại mật khẩu thành công. Bạn có thể đăng nhập với mật khẩu mới.',
        ]);
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

        $maBenhNhan = DB::table('benhnhan')
            ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
            ->value('MaBenhNhan');

        // Nếu là bác sĩ thì join bảng bacsi để lấy chuyên khoa (vd: "Khoa Xét nghiệm")
        $bacSiInfo = null;
        if (strtolower((string) $taikhoan->VaiTro) === 'bacsi') {
            $bacSiInfo = DB::table('bacsi')
                ->where('MaTaiKhoan', $taikhoan->MaTaiKhoan)
                ->select('MaBacSi', 'ChuyenKhoa', 'ho', 'ten')
                ->first();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'MaTaiKhoan' => $taikhoan->MaTaiKhoan,
                'MaBenhNhan' => $maBenhNhan,
                'email' => $taikhoan->email,
                'sdt' => $taikhoan->sdt,
                'VaiTro' => $taikhoan->VaiTro,
                'trangthaihoatdong' => $taikhoan->trangthaihoatdong,
                'MaBacSi' => $bacSiInfo->MaBacSi ?? null,
                'ChuyenKhoa' => $bacSiInfo->ChuyenKhoa ?? null,
            ]
        ], 200);
    }
}