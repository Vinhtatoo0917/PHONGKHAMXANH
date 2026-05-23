<?php

namespace App\Http\Controllers\benhnhan;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    private function currentAccount(Request $request)
    {
        $token = $request->bearerToken();
        if (!$token) return null;

        return DB::table('taikhoan')
            ->where('AccessToken', $token)
            ->first();
    }

    public function show(Request $request)
    {
        $account = $this->currentAccount($request);
        if (!$account) {
            return response()->json(['success' => false, 'message' => 'Token khong hop le'], 401);
        }

        $patient = DB::table('benhnhan')
            ->where('MaTaiKhoan', $account->MaTaiKhoan)
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'MaTaiKhoan' => $account->MaTaiKhoan,
                'sdt' => $account->sdt,
                'email' => $account->email,
                'VaiTro' => $account->VaiTro,
                'BenhNhan' => $patient ? [
                    'MaBenhNhan' => $patient->MaBenhNhan,
                    'ho' => $patient->ho,
                    'ten' => $patient->ten,
                    'ngaysinh' => $patient->ngaysinh,
                    'gioitinh' => $patient->gioitinh,
                    'cccd' => $patient->cccd,
                    'diachi' => $patient->diachi,
                    'BHYT' => $patient->BHYT,
                ] : null
            ]
        ]);
    }

    public function update(Request $request)
    {
        $account = $this->currentAccount($request);
        if (!$account) {
            return response()->json(['success' => false, 'message' => 'Token khong hop le'], 401);
        }

        $validated = $request->validate([
            'ho' => 'required|string|max:50',
            'ten' => 'required|string|max:50',
            'email' => [
                'required',
                'email',
                'max:100',
                Rule::unique('taikhoan', 'email')->ignore($account->MaTaiKhoan, 'MaTaiKhoan')
            ],
            'ngaysinh' => 'nullable|date',
            'gioitinh' => 'nullable|string|max:10',
            'cccd' => 'nullable|string|max:20',
            'diachi' => 'nullable|string|max:255',
            'BHYT' => 'nullable|string|max:50',
            'current_password' => 'nullable|string|min:6',
            'new_password' => 'nullable|string|min:6|confirmed',
        ]);

        try {
            DB::transaction(function () use ($account, $validated) {
                // Update TaiKhoan
                $updateData = ['email' => $validated['email']];
                
                if (!empty($validated['current_password']) && !empty($validated['new_password'])) {
                    if (!Hash::check($validated['current_password'], $account->MatKhau)) {
                        throw new \Exception('Mat khau hien tai khong dung');
                    }
                    $updateData['MatKhau'] = Hash::make($validated['new_password']);
                }

                DB::table('taikhoan')
                    ->where('MaTaiKhoan', $account->MaTaiKhoan)
                    ->update($updateData);

                // Update BenhNhan
                DB::table('benhnhan')
                    ->where('MaTaiKhoan', $account->MaTaiKhoan)
                    ->update([
                        'ho' => $validated['ho'],
                        'ten' => $validated['ten'],
                        'ngaysinh' => $validated['ngaysinh'],
                        'gioitinh' => $validated['gioitinh'],
                        'cccd' => $validated['cccd'],
                        'diachi' => $validated['diachi'],
                        'BHYT' => $validated['BHYT'],
                    ]);
            });

            return response()->json([
                'success' => true,
                'message' => 'Cap nhat thong tin thanh cong'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }
}
