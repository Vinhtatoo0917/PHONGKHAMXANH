<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;

Route::get('/', function () {
    return view('welcome');
});

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/logout', [AuthController::class, 'logout']);
Route::get('/me', [AuthController::class, 'me']);

Route::prefix('admin')->group(function () {

    Route::get('/bac-si', [AdminController::class, 'getDanhSachBacSi']);
    Route::get('/bac-si/{id}', [AdminController::class, 'getChiTietBacSi']);
    Route::post('/bac-si', [AdminController::class, 'themBacSi']);
    Route::put('/bac-si/{id}', [AdminController::class, 'capNhatBacSi']);
    Route::delete('/bac-si/{id}', [AdminController::class, 'xoaBacSi']);
    Route::patch('/bac-si/{id}/trang-thai', [AdminController::class, 'capNhatTrangThaiBacSi']);
    

    // ==================== QUẢN LÝ CA KHÁM ====================
    Route::get('/ca-kham', [AdminController::class, 'getDanhSachCaKham']);
    Route::get('/ca-kham/active', [AdminController::class, 'getDanhSachCaKhamActive']);
    Route::get('/ca-kham/{id}', [AdminController::class, 'getChiTietCaKham']);
    Route::post('/ca-kham', [AdminController::class, 'themCaKham']);
    Route::put('/ca-kham/{id}', [AdminController::class, 'capNhatCaKham']);
    Route::delete('/ca-kham/{id}', [AdminController::class, 'xoaCaKham']);

    // ==================== QUẢN LÝ LỊCH LÀM VIỆC ====================
    Route::get('/lich-lam-viec', [AdminController::class, 'getDanhSachLichLamViec']);
    Route::get('/lich-lam-viec/{id}', [AdminController::class, 'getChiTietLichLamViec']);
    Route::post('/lich-lam-viec', [AdminController::class, 'taoLichLamViec']);
    Route::put('/lich-lam-viec/{id}', [AdminController::class, 'capNhatLichLamViec']);
    Route::delete('/lich-lam-viec/{id}', [AdminController::class, 'xoaLichLamViec']);
    Route::get('/lich-lam-viec/bac-si/{MaBacSi}', [AdminController::class, 'getLichLamViecBacSi']);

    // ==================== PHÂN CÔNG LỊCH LÀM VIỆC ====================
    Route::post('/phan-cong-lich-lam-viec', [AdminController::class, 'phanCongLichLamViec']);
    Route::get('/lich-lam-viec-bac-si/{MaBacSi}', [AdminController::class, 'getDanhSachLichLamViecBacSi']);
    Route::delete('/huy-cong-viec/{id}', [AdminController::class, 'huyCongViec']);
    Route::get('/bac-si-lam-viec-ngay', [AdminController::class, 'getDanhSachBacSiLamViecNgay']);
    Route::get('/bac-si-lam-viec-ca', [AdminController::class, 'getDanhSachBacSiLamViecCa']);
    Route::put('/lich-lam-viec/{id}/phong', [AdminController::class, 'thayDoiPhongKham']);

    // ==================== PHÒNG KHÁM ====================
    Route::get('/phong-kham', [AdminController::class, 'getDanhSachPhongKham']);
    Route::get('/kiem-tra-phong', [AdminController::class, 'kiemTraPhongTrong']);
    Route::get('/phong-kham/danh-sach', [AdminController::class, 'getDanhSachPhongKhamAll']);
    Route::get('/phong-kham/khu/danh-sach', [AdminController::class, 'getDanhSachKhu']);
    Route::get('/phong-kham/thong-ke', [AdminController::class, 'getThongKePhongKham']);
    Route::get('/phong-kham/trong', [AdminController::class, 'getPhongKhamTrong']);
    Route::get('/phong-kham/dang-su-dung', [AdminController::class, 'getPhongKhamDangSuDung']);
    Route::get('/phong-kham/khu/{khu}', [AdminController::class, 'getPhongKhamTheoKhu']);
    Route::get('/phong-kham/{id}', [AdminController::class, 'getChiTietPhongKham']);
    Route::get('/phong-kham/{id}/lich-su', [AdminController::class, 'getLichSuPhongKham']);
    Route::get('/phong-kham/{id}/trang-thai', [AdminController::class, 'kiemTraTrangThaiPhongKham']);
    Route::post('/phong-kham', [AdminController::class, 'themPhongKham']);
    Route::put('/phong-kham/{id}', [AdminController::class, 'capNhatPhongKham']);
    Route::delete('/phong-kham/{id}', [AdminController::class, 'xoaPhongKham']);
});
