-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 15, 2026 at 09:39 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `phongkham`
--

-- --------------------------------------------------------

--
-- Table structure for table `bacsi`
--

CREATE TABLE `bacsi` (
  `MaBacSi` int NOT NULL,
  `MaTaiKhoan` int DEFAULT NULL,
  `ho` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `ten` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `ngaysinh` date DEFAULT NULL,
  `gioitinh` varchar(10) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `ChuyenKhoa` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `BangCap` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `KinhNghiem` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `bacsi`
--

INSERT INTO `bacsi` (`MaBacSi`, `MaTaiKhoan`, `ho`, `ten`, `ngaysinh`, `gioitinh`, `ChuyenKhoa`, `BangCap`, `KinhNghiem`) VALUES
(3, 10, 'Kiều', 'Vi', '2005-11-15', 'Nữ', 'Tim mạch', 'Thạc sĩ', '1 năm');

-- --------------------------------------------------------

--
-- Table structure for table `benh`
--

CREATE TABLE `benh` (
  `MaBenh` int NOT NULL,
  `TenBenh` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `MoTa` text COLLATE utf8mb4_vietnamese_ci,
  `mabenhly` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `benhnhan`
--

CREATE TABLE `benhnhan` (
  `MaBenhNhan` int NOT NULL,
  `MaTaiKhoan` int DEFAULT NULL,
  `ho` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `ten` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `ngaysinh` date DEFAULT NULL,
  `gioitinh` varchar(10) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `cccd` varchar(20) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `diachi` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `BHYT` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bhyt`
--

CREATE TABLE `bhyt` (
  `MaBHYT` int NOT NULL,
  `MaBenhNhan` int NOT NULL,
  `SoTheBHYT` varchar(20) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `HoTenTrenThe` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NgaySinhTrenThe` date DEFAULT NULL,
  `DiaChiDangKy` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NoiDangKyKCB` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NgayBatDau` date DEFAULT NULL,
  `NgayHetHan` date DEFAULT NULL,
  `MucHuong` int DEFAULT NULL,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NguonDuLieu` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cakham`
--

CREATE TABLE `cakham` (
  `MaCa` int NOT NULL,
  `TenCa` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `SoLuongToiDa` int DEFAULT NULL,
  `ThoiLuongKham` int DEFAULT NULL,
  `GioBatDau` time DEFAULT NULL,
  `GioKetThuc` time DEFAULT NULL,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `cakham`
--

INSERT INTO `cakham` (`MaCa`, `TenCa`, `SoLuongToiDa`, `ThoiLuongKham`, `GioBatDau`, `GioKetThuc`, `TrangThai`) VALUES
(2, 'Ca Chiều', 20, 15, '13:00:00', '17:30:00', 'active'),
(3, 'Ca Tối', 15, 15, '18:00:00', '21:00:00', 'active'),
(4, 'Ca Đêm', 10, 20, '21:00:00', '23:59:00', 'inactive'),
(5, 'ca sáng', 30, 15, '07:00:00', '11:00:00', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `chitietlichkham`
--

CREATE TABLE `chitietlichkham` (
  `MaChiTiet` int NOT NULL,
  `MaLichKham` int NOT NULL,
  `MaDichVu` int NOT NULL,
  `SoLuong` int NOT NULL DEFAULT '1',
  `DonGia` decimal(18,2) DEFAULT NULL,
  `ThanhTien` decimal(18,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chitietphieuchidinh`
--

CREATE TABLE `chitietphieuchidinh` (
  `MaChiTietPhieu` int NOT NULL,
  `MaPhieu` int NOT NULL,
  `MaDichVu` int NOT NULL,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `KetQua` text COLLATE utf8mb4_vietnamese_ci,
  `ChiSo` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `FileKetQua` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NgayCoKetQua` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ct_donthuoc`
--

CREATE TABLE `ct_donthuoc` (
  `MaChiTiet` int NOT NULL,
  `MaDonThuoc` int NOT NULL,
  `MaThuoc` int NOT NULL,
  `LieuDung` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `SoLuong` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ct_hoadon`
--

CREATE TABLE `ct_hoadon` (
  `MaChiTiet` int NOT NULL,
  `MaHoaDon` int NOT NULL,
  `Loai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `MaThamChieu` int DEFAULT NULL,
  `TenHienThi` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `SoLuong` int DEFAULT NULL,
  `DonGia` decimal(18,2) DEFAULT NULL,
  `ThanhTien` decimal(18,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dichvu`
--

CREATE TABLE `dichvu` (
  `MaDichVu` int NOT NULL,
  `TenDichVu` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `Gia` decimal(18,2) DEFAULT NULL,
  `MaKhoa` int DEFAULT NULL,
  `madichvuyte` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dichvu_benh`
--

CREATE TABLE `dichvu_benh` (
  `MaDichVu` int NOT NULL,
  `MaBenh` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `donthuoc`
--

CREATE TABLE `donthuoc` (
  `MaDonThuoc` int NOT NULL,
  `MaLichKham` int NOT NULL,
  `MaBacSi` int NOT NULL,
  `NgayKe` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `giuongbenh`
--

CREATE TABLE `giuongbenh` (
  `MaGiuong` int NOT NULL,
  `MaPhong` int DEFAULT NULL,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hoadon`
--

CREATE TABLE `hoadon` (
  `MaHoaDon` int NOT NULL,
  `MaBenhNhan` int NOT NULL,
  `MaLichKham` int DEFAULT NULL,
  `MaNhapVien` int DEFAULT NULL,
  `LoaiHoaDon` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TongTien` decimal(18,2) DEFAULT NULL,
  `GiamBHYT` decimal(18,2) DEFAULT NULL,
  `SoTienPhaiTra` decimal(18,2) DEFAULT NULL,
  `TrangThai` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NgayTao` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ketluankham`
--

CREATE TABLE `ketluankham` (
  `MaKetLuanKham` int NOT NULL,
  `MaLichKham` int NOT NULL,
  `MaBacSi` int NOT NULL,
  `MaBenh` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `ChanDoan` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TinhTrang` text COLLATE utf8mb4_vietnamese_ci,
  `HuongDieuTri` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NgayKetLuan` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ketluannoitru`
--

CREATE TABLE `ketluannoitru` (
  `MaKetLuanNoiTru` int NOT NULL,
  `MaNhapVien` int NOT NULL,
  `MaBacSi` int NOT NULL,
  `NgayKetLuan` datetime DEFAULT CURRENT_TIMESTAMP,
  `DienBienBenh` text COLLATE utf8mb4_vietnamese_ci,
  `HuongDieuTriTiepTheo` text COLLATE utf8mb4_vietnamese_ci,
  `GhiChu` text COLLATE utf8mb4_vietnamese_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `khoa`
--

CREATE TABLE `khoa` (
  `MaKhoa` int NOT NULL,
  `TenKhoa` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `machuyenkhoa` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lichkham`
--

CREATE TABLE `lichkham` (
  `MaLichKham` int NOT NULL,
  `MaBenhNhan` int DEFAULT NULL,
  `SoThuTu` int DEFAULT NULL,
  `TrangThai` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TrangThaiThanhToan` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TongTien` decimal(10,2) DEFAULT NULL,
  `ThoiDiemCheckIn` datetime DEFAULT NULL,
  `ThoiDiemCheckOut` datetime DEFAULT NULL,
  `MaNhanVienCheckIn` int DEFAULT NULL,
  `MaLichLamViec` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lichlamviec`
--

CREATE TABLE `lichlamviec` (
  `MaLichLamViec` int NOT NULL,
  `MaBacSi` int NOT NULL,
  `Ngay` date NOT NULL,
  `MaCa` int NOT NULL,
  `MaPhong` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `lichlamviec`
--

INSERT INTO `lichlamviec` (`MaLichLamViec`, `MaBacSi`, `Ngay`, `MaCa`, `MaPhong`) VALUES
(1, 3, '2026-05-14', 2, 1),
(2, 3, '2026-05-15', 5, 3),
(4, 3, '2026-05-14', 5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `nhanviencheckin`
--

CREATE TABLE `nhanviencheckin` (
  `MaNhanVien` int NOT NULL,
  `MaTaiKhoan` int DEFAULT NULL,
  `Ho` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `Ten` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `SDT` varchar(15) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `Email` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `nhanvienthungan`
--

CREATE TABLE `nhanvienthungan` (
  `MaThuNgan` int NOT NULL,
  `MaTaiKhoan` int DEFAULT NULL,
  `Ho` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `Ten` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `SDT` varchar(15) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `Email` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NgayBatDauLam` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `nhapvien`
--

CREATE TABLE `nhapvien` (
  `MaNhapVien` int NOT NULL,
  `MaLichKham` int NOT NULL,
  `MaGiuong` int DEFAULT NULL,
  `NgayNhap` datetime DEFAULT CURRENT_TIMESTAMP,
  `LyDo` text COLLATE utf8mb4_vietnamese_ci,
  `TrangThai` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phauthuat`
--

CREATE TABLE `phauthuat` (
  `MaPhauThuat` int NOT NULL,
  `MaKetLuanKham` int NOT NULL,
  `MaNhapVien` int DEFAULT NULL,
  `TenPhauThuat` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `LoaiPhauThuat` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TrangThai` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `NgayThucHien` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phieuchidinh`
--

CREATE TABLE `phieuchidinh` (
  `MaPhieu` int NOT NULL,
  `MaLichKham` int NOT NULL,
  `MaBacSi` int NOT NULL,
  `NgayChiDinh` datetime DEFAULT CURRENT_TIMESTAMP,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `GhiChu` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phongbenh`
--

CREATE TABLE `phongbenh` (
  `MaPhong` int NOT NULL,
  `TenPhong` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `LoaiPhong` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `GiaPhong` decimal(18,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phongkham`
--

CREATE TABLE `phongkham` (
  `MaPhong` int NOT NULL,
  `TenPhong` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `Khu` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `phongkham`
--

INSERT INTO `phongkham` (`MaPhong`, `TenPhong`, `Khu`) VALUES
(1, 'Phong 101', 'Tầng 1 - Phòng Khám Ngoại Trú'),
(3, 'Phong 102', 'Tầng 1 - Phòng Khám Ngoại Trú');

-- --------------------------------------------------------

--
-- Table structure for table `taikhoan`
--

CREATE TABLE `taikhoan` (
  `MaTaiKhoan` int NOT NULL,
  `sdt` int NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `MatKhau` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `VaiTro` varchar(50) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `AccessToken` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `trangthaihoatdong` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `dangnhaplancuoi` datetime DEFAULT NULL,
  `ngaytao` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `taikhoan`
--

INSERT INTO `taikhoan` (`MaTaiKhoan`, `sdt`, `email`, `MatKhau`, `VaiTro`, `AccessToken`, `trangthaihoatdong`, `dangnhaplancuoi`, `ngaytao`) VALUES
(1, 967287418, 'admin@gmail.com', '$2y$12$k2jZ8Hom.gigcfO1EA4r4.GXhzbcNFh9wJfW6ghZKa2uhYq/Cpq6y', 'admin', '2e9000d390bc238cdd82c611aebb05c5fa4f414d0413d776c713b7fbe9ca44ed', 'active', '2026-05-14 07:26:47', '2026-05-02 10:38:38'),
(2, 912345678, 'bacsi1@gmail.com', '123456', 'bacsi', 'token_bs1', 'active', '2026-05-02 10:38:38', '2026-05-02 10:38:38'),
(3, 923456789, 'benhnhan1@gmail.com', '123456', 'user', 'token_bn1', 'active', '2026-05-02 10:38:38', '2026-05-02 10:38:38'),
(4, 934567890, 'checkin@gmail.com', '123456', 'checkin', 'token_ci', 'active', '2026-05-02 10:38:38', '2026-05-02 10:38:38'),
(5, 945678901, 'thungan@gmail.com', '123456', 'thungan', 'token_tn', 'active', '2026-05-02 10:38:38', '2026-05-02 10:38:38'),
(7, 363455205, 'vinhtatoo0917@gmail.com', '$2y$12$k2jZ8Hom.gigcfO1EA4r4.GXhzbcNFh9wJfW6ghZKa2uhYq/Cpq6y', 'BenhNhan', '93f1dfe0f475e516807561e655d99c5d27160ecfed3639d03fc00a37803575f3', 'active', '2026-05-07 00:44:51', '2026-05-06 07:41:26'),
(10, 363455203, 'kieuvi15112005@gmail.com', '$2y$10$uaqn27Bf45x16dzbjdkkGuB3JiM6F3Xgwdtbyk3SyFJy7g5THfeQW', 'bacsi', 'c4f3f0b0274c7b4e930c2a0b79c6ddb406c66b7062db086f13c287435940d61e', 'active', NULL, '2026-05-09 16:19:09');

-- --------------------------------------------------------

--
-- Table structure for table `teamphauthuat`
--

CREATE TABLE `teamphauthuat` (
  `MaPhauThuat` int NOT NULL,
  `MaBacSi` int NOT NULL,
  `VaiTro` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `thanhtoan`
--

CREATE TABLE `thanhtoan` (
  `MaThanhToan` int NOT NULL,
  `MaHoaDon` int NOT NULL,
  `MaThuNgan` int NOT NULL,
  `SoTien` decimal(18,2) NOT NULL,
  `PhuongThuc` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TrangThai` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `ThoiDiem` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `theodoinoitru`
--

CREATE TABLE `theodoinoitru` (
  `MaTheoDoi` int NOT NULL,
  `MaNhapVien` int NOT NULL,
  `MaBacSi` int NOT NULL,
  `NgayGio` datetime DEFAULT CURRENT_TIMESTAMP,
  `TinhTrang` text COLLATE utf8mb4_vietnamese_ci,
  `GhiChu` text COLLATE utf8mb4_vietnamese_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `thuoc`
--

CREATE TABLE `thuoc` (
  `MaThuoc` int NOT NULL,
  `TenThuoc` varchar(255) COLLATE utf8mb4_vietnamese_ci NOT NULL,
  `DonViTinh` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `HamLuong` varchar(100) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `Gia` decimal(18,2) NOT NULL,
  `MoTa` text COLLATE utf8mb4_vietnamese_ci,
  `TrangThai` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `xuatvien`
--

CREATE TABLE `xuatvien` (
  `MaXuatVien` int NOT NULL,
  `MaNhapVien` int NOT NULL,
  `NgayXuatVien` datetime DEFAULT CURRENT_TIMESTAMP,
  `TinhTrangRaVien` varchar(255) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `LoiCanDan` text COLLATE utf8mb4_vietnamese_ci,
  `MaBacSiChoRaVien` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bacsi`
--
ALTER TABLE `bacsi`
  ADD PRIMARY KEY (`MaBacSi`),
  ADD KEY `fk_bacsi_taikhoan` (`MaTaiKhoan`);

--
-- Indexes for table `benh`
--
ALTER TABLE `benh`
  ADD PRIMARY KEY (`MaBenh`);

--
-- Indexes for table `benhnhan`
--
ALTER TABLE `benhnhan`
  ADD PRIMARY KEY (`MaBenhNhan`),
  ADD KEY `fk_benhnhan_taikhoan` (`MaTaiKhoan`);

--
-- Indexes for table `bhyt`
--
ALTER TABLE `bhyt`
  ADD PRIMARY KEY (`MaBHYT`),
  ADD KEY `FK_BHYT_benhnhan` (`MaBenhNhan`);

--
-- Indexes for table `cakham`
--
ALTER TABLE `cakham`
  ADD PRIMARY KEY (`MaCa`);

--
-- Indexes for table `chitietlichkham`
--
ALTER TABLE `chitietlichkham`
  ADD PRIMARY KEY (`MaChiTiet`),
  ADD KEY `MaDichVu` (`MaDichVu`);

--
-- Indexes for table `chitietphieuchidinh`
--
ALTER TABLE `chitietphieuchidinh`
  ADD PRIMARY KEY (`MaChiTietPhieu`),
  ADD KEY `FK_CTPhieu_Phieu` (`MaPhieu`),
  ADD KEY `MaDichVu` (`MaDichVu`);

--
-- Indexes for table `ct_donthuoc`
--
ALTER TABLE `ct_donthuoc`
  ADD PRIMARY KEY (`MaChiTiet`),
  ADD KEY `FK_CTDonThuoc_DonThuoc` (`MaDonThuoc`),
  ADD KEY `FK_CTDonThuoc_Thuoc` (`MaThuoc`);

--
-- Indexes for table `ct_hoadon`
--
ALTER TABLE `ct_hoadon`
  ADD PRIMARY KEY (`MaChiTiet`),
  ADD KEY `FK_CTHoaDon_HoaDon` (`MaHoaDon`);

--
-- Indexes for table `dichvu`
--
ALTER TABLE `dichvu`
  ADD PRIMARY KEY (`MaDichVu`),
  ADD KEY `MaKhoa` (`MaKhoa`);

--
-- Indexes for table `dichvu_benh`
--
ALTER TABLE `dichvu_benh`
  ADD KEY `MaBenh` (`MaBenh`),
  ADD KEY `MaDichVu` (`MaDichVu`);

--
-- Indexes for table `donthuoc`
--
ALTER TABLE `donthuoc`
  ADD PRIMARY KEY (`MaDonThuoc`),
  ADD KEY `FK_DonThuoc_LichKham` (`MaLichKham`);

--
-- Indexes for table `giuongbenh`
--
ALTER TABLE `giuongbenh`
  ADD PRIMARY KEY (`MaGiuong`),
  ADD KEY `FK_Giuong_PhongBenh` (`MaPhong`);

--
-- Indexes for table `hoadon`
--
ALTER TABLE `hoadon`
  ADD PRIMARY KEY (`MaHoaDon`),
  ADD KEY `FK_HoaDon_benhnhan` (`MaBenhNhan`),
  ADD KEY `FK_HoaDon_LichKham` (`MaLichKham`),
  ADD KEY `FK_HoaDon_NhapVien` (`MaNhapVien`);

--
-- Indexes for table `ketluankham`
--
ALTER TABLE `ketluankham`
  ADD PRIMARY KEY (`MaKetLuanKham`),
  ADD KEY `FK_KetLuan_LichKham` (`MaLichKham`),
  ADD KEY `FK_KetLuan_Benh` (`MaBenh`);

--
-- Indexes for table `ketluannoitru`
--
ALTER TABLE `ketluannoitru`
  ADD PRIMARY KEY (`MaKetLuanNoiTru`),
  ADD KEY `FK_KLNT_NhapVien` (`MaNhapVien`),
  ADD KEY `FK_KLNT_BacSi` (`MaBacSi`);

--
-- Indexes for table `khoa`
--
ALTER TABLE `khoa`
  ADD PRIMARY KEY (`MaKhoa`);

--
-- Indexes for table `lichkham`
--
ALTER TABLE `lichkham`
  ADD PRIMARY KEY (`MaLichKham`),
  ADD KEY `MaBenhNhan` (`MaBenhNhan`),
  ADD KEY `MaNhanVienCheckIn` (`MaNhanVienCheckIn`),
  ADD KEY `MaLichLamViec` (`MaLichLamViec`);

--
-- Indexes for table `lichlamviec`
--
ALTER TABLE `lichlamviec`
  ADD PRIMARY KEY (`MaLichLamViec`),
  ADD KEY `FK_LichLamViec_CaKham` (`MaCa`),
  ADD KEY `FK_LichLamViec_PhongKham` (`MaPhong`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `nhanviencheckin`
--
ALTER TABLE `nhanviencheckin`
  ADD PRIMARY KEY (`MaNhanVien`),
  ADD KEY `fk_nhanvien_taikhoan` (`MaTaiKhoan`);

--
-- Indexes for table `nhanvienthungan`
--
ALTER TABLE `nhanvienthungan`
  ADD PRIMARY KEY (`MaThuNgan`),
  ADD UNIQUE KEY `Email` (`Email`),
  ADD KEY `fk_thungan_taikhoan` (`MaTaiKhoan`);

--
-- Indexes for table `nhapvien`
--
ALTER TABLE `nhapvien`
  ADD PRIMARY KEY (`MaNhapVien`),
  ADD KEY `FK_NhapVien_LichKham` (`MaLichKham`),
  ADD KEY `FK_NhapVien_Giuong` (`MaGiuong`);

--
-- Indexes for table `phauthuat`
--
ALTER TABLE `phauthuat`
  ADD PRIMARY KEY (`MaPhauThuat`),
  ADD KEY `FK_PhauThuat_KetLuan` (`MaKetLuanKham`),
  ADD KEY `FK_PhauThuat_NhapVien` (`MaNhapVien`);

--
-- Indexes for table `phieuchidinh`
--
ALTER TABLE `phieuchidinh`
  ADD PRIMARY KEY (`MaPhieu`),
  ADD KEY `FK_PhieuChiDinh_LichKham` (`MaLichKham`);

--
-- Indexes for table `phongbenh`
--
ALTER TABLE `phongbenh`
  ADD PRIMARY KEY (`MaPhong`);

--
-- Indexes for table `phongkham`
--
ALTER TABLE `phongkham`
  ADD PRIMARY KEY (`MaPhong`);

--
-- Indexes for table `taikhoan`
--
ALTER TABLE `taikhoan`
  ADD PRIMARY KEY (`MaTaiKhoan`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `teamphauthuat`
--
ALTER TABLE `teamphauthuat`
  ADD PRIMARY KEY (`MaPhauThuat`,`MaBacSi`);

--
-- Indexes for table `thanhtoan`
--
ALTER TABLE `thanhtoan`
  ADD PRIMARY KEY (`MaThanhToan`),
  ADD KEY `FK_ThanhToan_HoaDon` (`MaHoaDon`);

--
-- Indexes for table `theodoinoitru`
--
ALTER TABLE `theodoinoitru`
  ADD PRIMARY KEY (`MaTheoDoi`),
  ADD KEY `FK_TheoDoi_NhapVien` (`MaNhapVien`);

--
-- Indexes for table `thuoc`
--
ALTER TABLE `thuoc`
  ADD PRIMARY KEY (`MaThuoc`);

--
-- Indexes for table `xuatvien`
--
ALTER TABLE `xuatvien`
  ADD PRIMARY KEY (`MaXuatVien`),
  ADD KEY `FK_XV_NhapVien` (`MaNhapVien`),
  ADD KEY `FK_XV_BacSi` (`MaBacSiChoRaVien`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bacsi`
--
ALTER TABLE `bacsi`
  MODIFY `MaBacSi` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `benh`
--
ALTER TABLE `benh`
  MODIFY `MaBenh` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `benhnhan`
--
ALTER TABLE `benhnhan`
  MODIFY `MaBenhNhan` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bhyt`
--
ALTER TABLE `bhyt`
  MODIFY `MaBHYT` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cakham`
--
ALTER TABLE `cakham`
  MODIFY `MaCa` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `chitietlichkham`
--
ALTER TABLE `chitietlichkham`
  MODIFY `MaChiTiet` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chitietphieuchidinh`
--
ALTER TABLE `chitietphieuchidinh`
  MODIFY `MaChiTietPhieu` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ct_donthuoc`
--
ALTER TABLE `ct_donthuoc`
  MODIFY `MaChiTiet` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ct_hoadon`
--
ALTER TABLE `ct_hoadon`
  MODIFY `MaChiTiet` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `donthuoc`
--
ALTER TABLE `donthuoc`
  MODIFY `MaDonThuoc` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `giuongbenh`
--
ALTER TABLE `giuongbenh`
  MODIFY `MaGiuong` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hoadon`
--
ALTER TABLE `hoadon`
  MODIFY `MaHoaDon` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ketluankham`
--
ALTER TABLE `ketluankham`
  MODIFY `MaKetLuanKham` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ketluannoitru`
--
ALTER TABLE `ketluannoitru`
  MODIFY `MaKetLuanNoiTru` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lichkham`
--
ALTER TABLE `lichkham`
  MODIFY `MaLichKham` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lichlamviec`
--
ALTER TABLE `lichlamviec`
  MODIFY `MaLichLamViec` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `nhanviencheckin`
--
ALTER TABLE `nhanviencheckin`
  MODIFY `MaNhanVien` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `nhanvienthungan`
--
ALTER TABLE `nhanvienthungan`
  MODIFY `MaThuNgan` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `nhapvien`
--
ALTER TABLE `nhapvien`
  MODIFY `MaNhapVien` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phauthuat`
--
ALTER TABLE `phauthuat`
  MODIFY `MaPhauThuat` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phieuchidinh`
--
ALTER TABLE `phieuchidinh`
  MODIFY `MaPhieu` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phongbenh`
--
ALTER TABLE `phongbenh`
  MODIFY `MaPhong` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phongkham`
--
ALTER TABLE `phongkham`
  MODIFY `MaPhong` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `taikhoan`
--
ALTER TABLE `taikhoan`
  MODIFY `MaTaiKhoan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `thanhtoan`
--
ALTER TABLE `thanhtoan`
  MODIFY `MaThanhToan` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `theodoinoitru`
--
ALTER TABLE `theodoinoitru`
  MODIFY `MaTheoDoi` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `thuoc`
--
ALTER TABLE `thuoc`
  MODIFY `MaThuoc` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `xuatvien`
--
ALTER TABLE `xuatvien`
  MODIFY `MaXuatVien` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bacsi`
--
ALTER TABLE `bacsi`
  ADD CONSTRAINT `fk_bacsi_taikhoan` FOREIGN KEY (`MaTaiKhoan`) REFERENCES `taikhoan` (`MaTaiKhoan`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `benhnhan`
--
ALTER TABLE `benhnhan`
  ADD CONSTRAINT `fk_benhnhan_taikhoan` FOREIGN KEY (`MaTaiKhoan`) REFERENCES `taikhoan` (`MaTaiKhoan`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `bhyt`
--
ALTER TABLE `bhyt`
  ADD CONSTRAINT `FK_BHYT_benhnhan` FOREIGN KEY (`MaBenhNhan`) REFERENCES `benhnhan` (`MaBenhNhan`);

--
-- Constraints for table `chitietlichkham`
--
ALTER TABLE `chitietlichkham`
  ADD CONSTRAINT `chitietlichkham_ibfk_1` FOREIGN KEY (`MaDichVu`) REFERENCES `dichvu` (`MaDichVu`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `chitietphieuchidinh`
--
ALTER TABLE `chitietphieuchidinh`
  ADD CONSTRAINT `chitietphieuchidinh_ibfk_1` FOREIGN KEY (`MaDichVu`) REFERENCES `dichvu` (`MaDichVu`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_CTPhieu_Phieu` FOREIGN KEY (`MaPhieu`) REFERENCES `phieuchidinh` (`MaPhieu`) ON DELETE CASCADE;

--
-- Constraints for table `ct_donthuoc`
--
ALTER TABLE `ct_donthuoc`
  ADD CONSTRAINT `FK_CTDonThuoc_DonThuoc` FOREIGN KEY (`MaDonThuoc`) REFERENCES `donthuoc` (`MaDonThuoc`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_CTDonThuoc_Thuoc` FOREIGN KEY (`MaThuoc`) REFERENCES `thuoc` (`MaThuoc`);

--
-- Constraints for table `ct_hoadon`
--
ALTER TABLE `ct_hoadon`
  ADD CONSTRAINT `FK_CTHoaDon_HoaDon` FOREIGN KEY (`MaHoaDon`) REFERENCES `hoadon` (`MaHoaDon`) ON DELETE CASCADE;

--
-- Constraints for table `dichvu`
--
ALTER TABLE `dichvu`
  ADD CONSTRAINT `dichvu_ibfk_1` FOREIGN KEY (`MaKhoa`) REFERENCES `khoa` (`MaKhoa`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `dichvu_benh`
--
ALTER TABLE `dichvu_benh`
  ADD CONSTRAINT `dichvu_benh_ibfk_1` FOREIGN KEY (`MaBenh`) REFERENCES `benh` (`MaBenh`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `dichvu_benh_ibfk_2` FOREIGN KEY (`MaDichVu`) REFERENCES `dichvu` (`MaDichVu`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `donthuoc`
--
ALTER TABLE `donthuoc`
  ADD CONSTRAINT `FK_DonThuoc_LichKham` FOREIGN KEY (`MaLichKham`) REFERENCES `lichkham` (`MaLichKham`);

--
-- Constraints for table `giuongbenh`
--
ALTER TABLE `giuongbenh`
  ADD CONSTRAINT `FK_Giuong_PhongBenh` FOREIGN KEY (`MaPhong`) REFERENCES `phongbenh` (`MaPhong`);

--
-- Constraints for table `hoadon`
--
ALTER TABLE `hoadon`
  ADD CONSTRAINT `FK_HoaDon_benhnhan` FOREIGN KEY (`MaBenhNhan`) REFERENCES `benhnhan` (`MaBenhNhan`),
  ADD CONSTRAINT `FK_HoaDon_LichKham` FOREIGN KEY (`MaLichKham`) REFERENCES `lichkham` (`MaLichKham`),
  ADD CONSTRAINT `FK_HoaDon_NhapVien` FOREIGN KEY (`MaNhapVien`) REFERENCES `nhapvien` (`MaNhapVien`);

--
-- Constraints for table `ketluankham`
--
ALTER TABLE `ketluankham`
  ADD CONSTRAINT `FK_KetLuan_LichKham` FOREIGN KEY (`MaLichKham`) REFERENCES `lichkham` (`MaLichKham`);

--
-- Constraints for table `ketluannoitru`
--
ALTER TABLE `ketluannoitru`
  ADD CONSTRAINT `FK_KLNT_BacSi` FOREIGN KEY (`MaBacSi`) REFERENCES `bacsi` (`MaBacSi`),
  ADD CONSTRAINT `FK_KLNT_NhapVien` FOREIGN KEY (`MaNhapVien`) REFERENCES `nhapvien` (`MaNhapVien`) ON DELETE CASCADE;

--
-- Constraints for table `lichkham`
--
ALTER TABLE `lichkham`
  ADD CONSTRAINT `lichkham_ibfk_1` FOREIGN KEY (`MaBenhNhan`) REFERENCES `benhnhan` (`MaBenhNhan`),
  ADD CONSTRAINT `lichkham_ibfk_2` FOREIGN KEY (`MaNhanVienCheckIn`) REFERENCES `nhanviencheckin` (`MaNhanVien`),
  ADD CONSTRAINT `lichkham_ibfk_3` FOREIGN KEY (`MaLichLamViec`) REFERENCES `lichlamviec` (`MaLichLamViec`);

--
-- Constraints for table `lichlamviec`
--
ALTER TABLE `lichlamviec`
  ADD CONSTRAINT `FK_LichLamViec_CaKham` FOREIGN KEY (`MaCa`) REFERENCES `cakham` (`MaCa`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_LichLamViec_PhongKham` FOREIGN KEY (`MaPhong`) REFERENCES `phongkham` (`MaPhong`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `nhanviencheckin`
--
ALTER TABLE `nhanviencheckin`
  ADD CONSTRAINT `fk_nhanvien_taikhoan` FOREIGN KEY (`MaTaiKhoan`) REFERENCES `taikhoan` (`MaTaiKhoan`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `nhanvienthungan`
--
ALTER TABLE `nhanvienthungan`
  ADD CONSTRAINT `fk_thungan_taikhoan` FOREIGN KEY (`MaTaiKhoan`) REFERENCES `taikhoan` (`MaTaiKhoan`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `nhapvien`
--
ALTER TABLE `nhapvien`
  ADD CONSTRAINT `FK_NhapVien_Giuong` FOREIGN KEY (`MaGiuong`) REFERENCES `giuongbenh` (`MaGiuong`),
  ADD CONSTRAINT `FK_NhapVien_LichKham` FOREIGN KEY (`MaLichKham`) REFERENCES `lichkham` (`MaLichKham`);

--
-- Constraints for table `phauthuat`
--
ALTER TABLE `phauthuat`
  ADD CONSTRAINT `FK_PhauThuat_KetLuan` FOREIGN KEY (`MaKetLuanKham`) REFERENCES `ketluankham` (`MaKetLuanKham`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_PhauThuat_NhapVien` FOREIGN KEY (`MaNhapVien`) REFERENCES `nhapvien` (`MaNhapVien`) ON UPDATE CASCADE;

--
-- Constraints for table `phieuchidinh`
--
ALTER TABLE `phieuchidinh`
  ADD CONSTRAINT `FK_PhieuChiDinh_LichKham` FOREIGN KEY (`MaLichKham`) REFERENCES `lichkham` (`MaLichKham`);

--
-- Constraints for table `teamphauthuat`
--
ALTER TABLE `teamphauthuat`
  ADD CONSTRAINT `FK_Team_PhauThuat` FOREIGN KEY (`MaPhauThuat`) REFERENCES `phauthuat` (`MaPhauThuat`) ON DELETE CASCADE;

--
-- Constraints for table `thanhtoan`
--
ALTER TABLE `thanhtoan`
  ADD CONSTRAINT `FK_ThanhToan_HoaDon` FOREIGN KEY (`MaHoaDon`) REFERENCES `hoadon` (`MaHoaDon`);

--
-- Constraints for table `theodoinoitru`
--
ALTER TABLE `theodoinoitru`
  ADD CONSTRAINT `FK_TheoDoi_NhapVien` FOREIGN KEY (`MaNhapVien`) REFERENCES `nhapvien` (`MaNhapVien`);

--
-- Constraints for table `xuatvien`
--
ALTER TABLE `xuatvien`
  ADD CONSTRAINT `FK_XV_BacSi` FOREIGN KEY (`MaBacSiChoRaVien`) REFERENCES `bacsi` (`MaBacSi`),
  ADD CONSTRAINT `FK_XV_NhapVien` FOREIGN KEY (`MaNhapVien`) REFERENCES `nhapvien` (`MaNhapVien`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
