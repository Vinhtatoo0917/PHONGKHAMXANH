<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class ThuNganController extends Controller
{
    private function getAdmin(Request $request)
    {
        $token = $request->bearerToken();
        if (!$token) return null;
        $tk = DB::table('taikhoan')->where('Accesstoken', $token)->first();
        if (!$tk || strtolower($tk->VaiTro) !== 'admin') return null;
        return $tk;
    }

    private function unauthorized()
    {
        return response()->json(['success' => false, 'message' => 'Không có quyền truy cập'], 403);
    }

    // GET /admin/thu-ngan
    public function index(Request $request)
    {
        if (!$this->getAdmin($request)) return $this->unauthorized();

        $search = $request->query('search', '');

        $query = DB::table('nhanvienthungan as nt')
            ->join('taikhoan as tk', 'nt.MaTaiKhoan', '=', 'tk.MaTaiKhoan')
            ->select(
                'nt.MaThuNgan',
                'nt.Ho',
                'nt.Ten',
                'nt.SDT',
                'nt.Email',
                'nt.TrangThai',
                'nt.NgayBatDauLam',
                'tk.MaTaiKhoan',
                'tk.trangthaihoatdong',
                'tk.ngaytao',
                'tk.dangnhaplancuoi'
            );

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('nt.Ho', 'like', "%$search%")
                  ->orWhere('nt.Ten', 'like', "%$search%")
                  ->orWhere('nt.Email', 'like', "%$search%")
                  ->orWhere('nt.SDT', 'like', "%$search%");
            });
        }

        $list = $query->orderByDesc('nt.MaThuNgan')->get();

        return response()->json(['success' => true, 'data' => $list]);
    }

    // POST /admin/thu-ngan
    public function store(Request $request)
    {
        if (!$this->getAdmin($request)) return $this->unauthorized();

        $request->validate([
            'ho'       => 'required|string|max:50',
            'ten'      => 'required|string|max:50',
            'email'    => 'required|email|unique:taikhoan,email',
            'sdt'      => 'required|string|unique:taikhoan,sdt',
            'mat_khau' => 'required|string|min:6',
        ]);

        try {
            DB::transaction(function () use ($request) {
                $maTaiKhoan = DB::table('taikhoan')->insertGetId([
                    'sdt'                => $request->sdt,
                    'email'              => $request->email,
                    'MatKhau'            => Hash::make($request->mat_khau),
                    'VaiTro'             => 'thungan',
                    'trangthaihoatdong'  => 'active',
                    'ngaytao'            => now(),
                ]);

                DB::table('nhanvienthungan')->insert([
                    'MaTaiKhoan'    => $maTaiKhoan,
                    'Ho'            => $request->ho,
                    'Ten'           => $request->ten,
                    'SDT'           => $request->sdt,
                    'Email'         => $request->email,
                    'TrangThai'     => 'active',
                    'NgayBatDauLam' => $request->ngay_bat_dau_lam ?? now(),
                ]);
            });

            return response()->json(['success' => true, 'message' => 'Thêm thu ngân thành công']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Lỗi: ' . $e->getMessage()], 500);
        }
    }

    // GET /admin/thu-ngan/{id}
    public function show(Request $request, $id)
    {
        if (!$this->getAdmin($request)) return $this->unauthorized();

        $tn = DB::table('nhanvienthungan as nt')
            ->join('taikhoan as tk', 'nt.MaTaiKhoan', '=', 'tk.MaTaiKhoan')
            ->where('nt.MaThuNgan', $id)
            ->select('nt.*', 'tk.trangthaihoatdong', 'tk.ngaytao', 'tk.dangnhaplancuoi')
            ->first();

        if (!$tn) return response()->json(['success' => false, 'message' => 'Không tìm thấy'], 404);

        return response()->json(['success' => true, 'data' => $tn]);
    }

    // PUT /admin/thu-ngan/{id}
    public function update(Request $request, $id)
    {
        if (!$this->getAdmin($request)) return $this->unauthorized();

        $tn = DB::table('nhanvienthungan')->where('MaThuNgan', $id)->first();
        if (!$tn) return response()->json(['success' => false, 'message' => 'Không tìm thấy'], 404);

        DB::table('nhanvienthungan')->where('MaThuNgan', $id)->update([
            'Ho'  => $request->ho  ?? $tn->Ho,
            'Ten' => $request->ten ?? $tn->Ten,
            'SDT' => $request->sdt ?? $tn->SDT,
        ]);

        if ($request->mat_khau) {
            DB::table('taikhoan')
                ->where('MaTaiKhoan', $tn->MaTaiKhoan)
                ->update(['MatKhau' => Hash::make($request->mat_khau)]);
        }

        return response()->json(['success' => true, 'message' => 'Cập nhật thành công']);
    }

    // PATCH /admin/thu-ngan/{id}/trang-thai
    public function updateStatus(Request $request, $id)
    {
        if (!$this->getAdmin($request)) return $this->unauthorized();

        $tn = DB::table('nhanvienthungan')->where('MaThuNgan', $id)->first();
        if (!$tn) return response()->json(['success' => false, 'message' => 'Không tìm thấy'], 404);

        $status = $request->trang_thai === 'active' ? 'active' : 'inactive';

        DB::table('taikhoan')
            ->where('MaTaiKhoan', $tn->MaTaiKhoan)
            ->update(['trangthaihoatdong' => $status]);

        DB::table('nhanvienthungan')
            ->where('MaThuNgan', $id)
            ->update(['TrangThai' => $status]);

        return response()->json(['success' => true, 'message' => 'Cập nhật trạng thái thành công']);
    }

    // DELETE /admin/thu-ngan/{id}
    public function destroy(Request $request, $id)
    {
        if (!$this->getAdmin($request)) return $this->unauthorized();

        $tn = DB::table('nhanvienthungan')->where('MaThuNgan', $id)->first();
        if (!$tn) return response()->json(['success' => false, 'message' => 'Không tìm thấy'], 404);

        DB::transaction(function () use ($tn, $id) {
            DB::table('nhanvienthungan')->where('MaThuNgan', $id)->delete();
            DB::table('taikhoan')->where('MaTaiKhoan', $tn->MaTaiKhoan)->delete();
        });

        return response()->json(['success' => true, 'message' => 'Xóa thu ngân thành công']);
    }

    // PATCH /admin/thu-ngan/{id}/reset-mat-khau
    public function resetPassword(Request $request, $id)
    {
        if (!$this->getAdmin($request)) return $this->unauthorized();

        $request->validate(['mat_khau_moi' => 'required|string|min:6']);

        $tn = DB::table('nhanvienthungan')->where('MaThuNgan', $id)->first();
        if (!$tn) return response()->json(['success' => false, 'message' => 'Không tìm thấy'], 404);

        DB::table('taikhoan')
            ->where('MaTaiKhoan', $tn->MaTaiKhoan)
            ->update(['MatKhau' => Hash::make($request->mat_khau_moi)]);

        return response()->json(['success' => true, 'message' => 'Đặt lại mật khẩu thành công']);
    }
}
