<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\benhnhan\LichKhamController as BenhNhanLichKhamController;
use App\Http\Controllers\Admin\BacSiController;
use App\Http\Controllers\Admin\LichKhamController as AdminLichKhamController;
use App\Http\Controllers\Admin\CaKhamController;
use App\Http\Controllers\Admin\LichLamViecController;
use App\Http\Controllers\Admin\PhongKhamController;
use App\Http\Controllers\Admin\KhoaController;
use App\Http\Controllers\Admin\BenhController;
use App\Http\Controllers\Admin\DichVuController;
use App\Http\Controllers\Admin\ThuocController;
use App\Http\Controllers\benhnhan\ProfileController;
use App\Http\Controllers\bacsi\LichKhamController as BacSiLichKhamController;

Route::get('/', function () {
    return view('welcome');
});

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/logout', [AuthController::class, 'logout']);
Route::get('/me', [AuthController::class, 'me']);

// ==================== LỊCH KHÁM ====================
Route::get('/lich-kham/available', [BenhNhanLichKhamController::class, 'getAvailableSchedules']);
Route::get('/lich-kham/my-appointments', [BenhNhanLichKhamController::class, 'getMyAppointments']);
Route::post('/lich-kham/book', [BenhNhanLichKhamController::class, 'bookAppointment']);
Route::delete('/lich-kham/{maLichKham}/cancel', [BenhNhanLichKhamController::class, 'cancelAppointment']);
Route::get('/lich-kham/doctor-schedule', [BenhNhanLichKhamController::class, 'getDoctorSchedule']);
Route::get('/lich-kham/{maLichKham}/hoa-don', [BenhNhanLichKhamController::class, 'getHoaDon']);
Route::get('/benhnhan/my-invoices', [BenhNhanLichKhamController::class, 'getMyInvoices']);

// ==================== CHECK-IN / CHECK-OUT ====================
Route::get('/admin/lich-kham-hom-nay', [BenhNhanLichKhamController::class, 'getLichKhamHomNay']);
Route::post('/admin/lich-kham/{maLichKham}/check-in', [BenhNhanLichKhamController::class, 'checkIn']);
Route::patch('/admin/lich-kham/{maLichKham}/check-out', [BenhNhanLichKhamController::class, 'checkOut']);
Route::post('/admin/lich-kham/{maLichKham}/generate-otp', [BenhNhanLichKhamController::class, 'generateOtp']);
Route::post('/admin/lich-kham/{maLichKham}/verify-otp', [BenhNhanLichKhamController::class, 'verifyOtp']);

// ==================== THÔNG TIN CÁ NHÂN ====================
Route::get('/profile', [ProfileController::class, 'show']);
Route::post('/profile/update', [ProfileController::class, 'update']);

Route::prefix('admin')->group(function () {
    // ==================== QUẢN LÝ LỊCH KHÁM ====================
    Route::get('/lich-kham', [AdminLichKhamController::class, 'index']);
    Route::patch('/lich-kham/{maLichKham}/status', [AdminLichKhamController::class, 'updateStatus']);

    // ==================== QUẢN LÝ KHOA ====================
    Route::get('/khoa', [KhoaController::class, 'index']);
    Route::get('/khoa/{id}', [KhoaController::class, 'show']);
    Route::post('/khoa', [KhoaController::class, 'store']);
    Route::put('/khoa/{id}', [KhoaController::class, 'update']);
    Route::delete('/khoa/{id}', [KhoaController::class, 'destroy']);

    // ==================== QUẢN LÝ BỆNH ====================
    Route::get('/benh', [BenhController::class, 'index']);
    Route::get('/benh/{id}', [BenhController::class, 'show']);
    Route::post('/benh', [BenhController::class, 'store']);
    Route::put('/benh/{id}', [BenhController::class, 'update']);
    Route::delete('/benh/{id}', [BenhController::class, 'destroy']);
    Route::post('/benh/{id}/dich-vu', [BenhController::class, 'linkService']);
    Route::delete('/benh/{id}/dich-vu/{maDichVu}', [BenhController::class, 'unlinkService']);

    // ==================== QUẢN LÝ DỊCH VỤ ====================
    Route::get('/dich-vu', [DichVuController::class, 'index']);
    Route::get('/dich-vu/{id}', [DichVuController::class, 'show']);
    Route::post('/dich-vu', [DichVuController::class, 'store']);
    Route::put('/dich-vu/{id}', [DichVuController::class, 'update']);
    Route::delete('/dich-vu/{id}', [DichVuController::class, 'destroy']);
    Route::get('/dich-vu/khoa/{maKhoa}', [DichVuController::class, 'getByKhoa']);
    Route::get('/dich-vu/benh/{maBenh}', [DichVuController::class, 'getByBenh']);

    // ==================== QUẢN LÝ THUỐC ====================
    Route::get('/thuoc', [ThuocController::class, 'index']);
    Route::get('/thuoc/{id}', [ThuocController::class, 'show']);
    Route::post('/thuoc', [ThuocController::class, 'store']);
    Route::put('/thuoc/{id}', [ThuocController::class, 'update']);
    Route::delete('/thuoc/{id}', [ThuocController::class, 'destroy']);

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
    Route::post('/phong-kham/khu/tao-moi', [PhongKhamController::class, 'createKhu']);
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

Route::prefix('bacsi')->group(function () {
    Route::get('/lich-kham', [BacSiLichKhamController::class, 'index']);
    Route::patch('/lich-kham/{maLichKham}/status', [BacSiLichKhamController::class, 'updateStatus']);
    Route::patch('/lich-kham/{maLichKham}/tiep-nhan', [BacSiLichKhamController::class, 'tiepNhanBenhNhan']);
    Route::get('/lich-kham/{maLichKham}/tiep-nhan-status', [BacSiLichKhamController::class, 'getTiepNhanStatus']);
    Route::get('/benh', [BacSiLichKhamController::class, 'getBenhList']);
    Route::get('/benh/{maBenh}/dich-vu', [BacSiLichKhamController::class, 'getServicesByBenh']);
    Route::post('/ket-luan', [BacSiLichKhamController::class, 'ketLuanKham']);
    Route::get('/thuoc', [ThuocController::class, 'index']);

    // ==================== HOÁ ĐƠN ====================
    Route::get('/hoa-don/{maLichKham}', [BacSiLichKhamController::class, 'getHoaDon']);

    // ==================== PHIẾU CHỈ ĐỊNH ====================
    Route::get('/testing-doctors/{maLichKham}', [BacSiLichKhamController::class, 'getTestingDoctors']);
    Route::get('/all-services', [BacSiLichKhamController::class, 'getAllServices']);
    Route::post('/tao-phieu-chi-dinh', [BacSiLichKhamController::class, 'taoPhieuChiDinh']);
    Route::get('/phieu-chi-dinh-cua-toi', [BacSiLichKhamController::class, 'phieuChiDinhCuaToi']);
    Route::patch('/phieu-chi-dinh/{maPhieu}/tiep-nhan', [BacSiLichKhamController::class, 'tiepNhanPhieuChiDinh']);
    Route::post('/phieu-chi-dinh/{maPhieu}/hoan-tat', [BacSiLichKhamController::class, 'hoanTatPhieuChiDinh']);
});
