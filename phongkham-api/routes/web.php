<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Admin\BacSiController;
use App\Http\Controllers\Admin\CaKhamController;
use App\Http\Controllers\Admin\LichLamViecController;
use App\Http\Controllers\Admin\PhongKhamController;

Route::get('/', function () {
    return view('welcome');
});

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/logout', [AuthController::class, 'logout']);
Route::get('/me', [AuthController::class, 'me']);

Route::prefix('admin')->group(function () {

    // ==================== QUẢN LÝ BÁC SĨ ====================
    Route::get('/bac-si', [BacSiController::class, 'index']);
    Route::get('/bac-si/{id}', [BacSiController::class, 'show']);
    Route::post('/bac-si', [BacSiController::class, 'store']);
    Route::put('/bac-si/{id}', [BacSiController::class, 'update']);
    Route::delete('/bac-si/{id}', [BacSiController::class, 'destroy']);
    Route::patch('/bac-si/{id}/trang-thai', [BacSiController::class, 'updateStatus']);
    
    // ==================== QUẢN LÝ CA KHÁM ====================
    Route::get('/ca-kham', [CaKhamController::class, 'index']);
    Route::get('/ca-kham/active', [CaKhamController::class, 'getActive']);
    Route::get('/ca-kham/{id}', [CaKhamController::class, 'show']);
    Route::post('/ca-kham', [CaKhamController::class, 'store']);
    Route::put('/ca-kham/{id}', [CaKhamController::class, 'update']);
    Route::delete('/ca-kham/{id}', [CaKhamController::class, 'destroy']);

    // ==================== QUẢN LÝ LỊCH LÀM VIỆC ====================
    Route::get('/lich-lam-viec', [LichLamViecController::class, 'index']);
    Route::get('/lich-lam-viec/{id}', [LichLamViecController::class, 'show']);
    Route::post('/lich-lam-viec', [LichLamViecController::class, 'store']);
    Route::put('/lich-lam-viec/{id}', [LichLamViecController::class, 'update']);
    Route::delete('/lich-lam-viec/{id}', [LichLamViecController::class, 'destroy']);
    Route::get('/lich-lam-viec/bac-si/{MaBacSi}', [LichLamViecController::class, 'getLichBacSi']);
    Route::get('/lich-lam-viec/ngay/{ngay}', [LichLamViecController::class, 'getLichNgay']);
    Route::get('/lich-lam-viec/ca/{maCa}', [LichLamViecController::class, 'getLichCa']);

    // ==================== PHÒNG KHÁM ====================
    Route::get('/phong-kham', [PhongKhamController::class, 'index']);
    Route::get('/phong-kham/danh-sach', [PhongKhamController::class, 'getAll']);
    Route::get('/phong-kham/khu/danh-sach', [PhongKhamController::class, 'getKhuList']);
    Route::get('/phong-kham/thong-ke', [PhongKhamController::class, 'getStatistics']);
    Route::get('/phong-kham/trong', [PhongKhamController::class, 'getPhongTrong']);
    Route::get('/phong-kham/dang-su-dung', [PhongKhamController::class, 'getPhongDangSuDung']);
    Route::get('/phong-kham/khu/{khu}', [PhongKhamController::class, 'getPhongTheoKhu']);
    Route::get('/phong-kham/{id}', [PhongKhamController::class, 'show']);
    Route::get('/phong-kham/{id}/lich-su', [PhongKhamController::class, 'getLichSu']);
    Route::get('/phong-kham/{id}/trang-thai', [PhongKhamController::class, 'checkStatus']);
    Route::post('/phong-kham', [PhongKhamController::class, 'store']);
    Route::put('/phong-kham/{id}', [PhongKhamController::class, 'update']);
    Route::delete('/phong-kham/{id}', [PhongKhamController::class, 'destroy']);
});
