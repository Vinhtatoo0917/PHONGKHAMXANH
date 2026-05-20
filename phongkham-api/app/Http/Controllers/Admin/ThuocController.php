<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Thuoc;
use Illuminate\Http\Request;

class ThuocController extends Controller
{
    public function index()
    {
        try {
            $list = Thuoc::all();
            return response()->json(['success' => true, 'data' => $list]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'TenThuoc' => 'required|string|max:255',
                'DonViTinh' => 'required|string|max:50',
                'HamLuong' => 'nullable|string|max:100',
                'Gia' => 'required|numeric|min:0',
                'MoTa' => 'nullable|string',
                'TrangThai' => 'nullable|string|max:50',
            ]);

            $thuoc = Thuoc::create($validated);
            return response()->json(['success' => true, 'data' => $thuoc]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        try {
            $thuoc = Thuoc::findOrFail($id);
            return response()->json(['success' => true, 'data' => $thuoc]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 404);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'TenThuoc' => 'sometimes|required|string|max:255',
                'DonViTinh' => 'sometimes|required|string|max:50',
                'HamLuong' => 'nullable|string|max:100',
                'Gia' => 'sometimes|required|numeric|min:0',
                'MoTa' => 'nullable|string',
                'TrangThai' => 'nullable|string|max:50',
            ]);

            $thuoc = Thuoc::findOrFail($id);
            $thuoc->update($validated);
            return response()->json(['success' => true, 'data' => $thuoc]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $thuoc = Thuoc::findOrFail($id);
            $thuoc->delete();
            return response()->json(['success' => true, 'message' => 'Xoa thuoc thanh cong']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
