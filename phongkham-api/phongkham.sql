-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 23, 2026 at 03:54 AM
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
(3, 10, 'Kiều', 'Vi', '2005-11-15', 'Nữ', 'Khoa Khám bệnh', 'Thạc sĩ', '1 năm'),
(4, 11, 'Thế', 'Vinh', '2004-10-24', 'Nam', 'Khoa Khám bệnh', 'Bác sĩ', '0 năm'),
(5, 13, 'Hoàng', 'Vy', '2004-11-20', 'Nam', 'Khoa Xét nghiệm', 'Tiến sĩ', '1 năm');

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

--
-- Dumping data for table `benh`
--

INSERT INTO `benh` (`MaBenh`, `TenBenh`, `MoTa`, `mabenhly`) VALUES
(1, 'Cảm lạnh thông thường', 'Người bệnh thường nghẹt mũi, chảy mũi, hắt hơi, đau họng nhẹ, ho ít, có thể sốt nhẹ. Thường tự khỏi sau vài ngày, hay gặp khi thay đổi thời tiết hoặc tiếp xúc người đang bệnh.', 'J00'),
(2, 'Viêm phế quản cấp', 'Viêm nhiễm niêm mạc ống phế quản.', 'J20'),
(3, 'Sốt xuất huyết Dengue', 'Bệnh truyền nhiễm do virus Dengue.', 'A90'),
(4, 'Tăng huyết áp vô căn', 'Huyết áp cao không rõ nguyên nhân.', 'I10'),
(5, 'Đái tháo đường tuýp 2', 'Rối loạn chuyển hóa đường.', 'E11'),
(6, 'Viêm dạ dày cấp', 'Viêm niêm mạc dạ dày.', 'K29'),
(7, 'Sỏi thận', 'Sự lắng đọng chất khoáng trong thận.', 'N20'),
(8, 'Viêm đa khớp dạng thấp', 'Bệnh tự miễn gây viêm các khớp.', 'M05'),
(9, 'Rối loạn lo âu lan tỏa', 'Trạng thái lo âu kéo dài không rõ nguyên nhân.', 'F41'),
(10, 'Viêm tai giữa cấp', 'Nhiễm trùng tai giữa, thường gặp ở trẻ em.', 'H66'),
(11, 'Bệnh phổi tắc nghẽn mạn tính (COPD)', 'Hội chứng tắc nghẽn đường thở.', 'J44'),
(12, 'Viêm Gan B mạn tính', 'Nhiễm virus viêm gan B kéo dài trên 6 tháng.', 'B18.1'),
(13, 'Thoát vị đĩa đệm cột sống cổ', 'Đĩa đệm chệch khỏi vị trí gây chèn ép dây thần kinh.', 'M50'),
(14, 'Hội chứng ống cổ tay', 'Chèn ép dây thần kinh giữa tại cổ tay.', 'G56.0'),
(15, 'Gout', 'Viêm khớp do lắng đọng tinh thể acid uric.', 'M10');

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

--
-- Dumping data for table `benhnhan`
--

INSERT INTO `benhnhan` (`MaBenhNhan`, `MaTaiKhoan`, `ho`, `ten`, `ngaysinh`, `gioitinh`, `cccd`, `diachi`, `BHYT`) VALUES
(1, 7, 'Thế', 'Long', '2004-11-24', 'Nam', '012345678', 'Bình Dương', '012345678'),
(2, 12, 'Thế', 'Vinh', '2004-11-24', 'Nam', '12345', 'phú yên', '12345'),
(3, 14, 'Phạm', 'Đức', '2000-01-22', 'Nam', '12345', 'Bình dương', '12345');

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
  `ThanhTien` decimal(18,2) DEFAULT NULL,
  `MOTA` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL,
  `TRANGTHAIDUYET` varchar(50) COLLATE utf8mb4_vietnamese_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `chitietlichkham`
--

INSERT INTO `chitietlichkham` (`MaChiTiet`, `MaLichKham`, `MaDichVu`, `SoLuong`, `DonGia`, `ThanhTien`, `MOTA`, `TRANGTHAIDUYET`) VALUES
(1, 1, 1, 1, 150000.00, 150000.00, 'Cần cập nhật thông tin', NULL),
(2, 2, 1, 1, 150000.00, 150000.00, NULL, 'confirmed'),
(3, 3, 1, 1, 150000.00, 150000.00, 'Cần cập nhật thông tin', 'rejected'),
(4, 4, 1, 1, 150000.00, 150000.00, NULL, NULL),
(5, 5, 1, 1, 150000.00, 150000.00, NULL, NULL),
(6, 6, 1, 1, 150000.00, 150000.00, NULL, 'confirmed'),
(7, 7, 1, 1, 150000.00, 150000.00, NULL, 'confirmed'),
(8, 8, 1, 1, 150000.00, 150000.00, NULL, 'confirmed'),
(9, 9, 1, 1, 150000.00, 150000.00, NULL, 'confirmed'),
(10, 10, 1, 1, 150000.00, 150000.00, NULL, 'confirmed'),
(11, 11, 1, 1, 150000.00, 150000.00, NULL, 'confirmed');

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

--
-- Dumping data for table `chitietphieuchidinh`
--

INSERT INTO `chitietphieuchidinh` (`MaChiTietPhieu`, `MaPhieu`, `MaDichVu`, `TrangThai`, `KetQua`, `ChiSo`, `FileKetQua`, `NgayCoKetQua`) VALUES
(3, 2, 2, 'completed', 'ổn', 'bình thường', NULL, '2026-05-22 10:17:39'),
(4, 3, 2, 'completed', 'Chỉ số bình thường không đáng quan ngại', '120mg', NULL, '2026-05-22 10:10:33'),
(5, 4, 15, 'processing', NULL, NULL, NULL, NULL),
(6, 5, 2, 'completed', 'bình thường', 'ổn', NULL, '2026-05-22 10:16:57'),
(7, 6, 3, 'completed', 'Bình thường', '120mg', NULL, '2026-05-22 10:30:12'),
(8, 7, 4, 'pending', NULL, NULL, NULL, NULL),
(9, 8, 2, 'completed', 'kết quả cho ra tất cả đều bình thường', '120mg', NULL, '2026-05-22 13:15:03');

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

--
-- Dumping data for table `ct_donthuoc`
--

INSERT INTO `ct_donthuoc` (`MaChiTiet`, `MaDonThuoc`, `MaThuoc`, `LieuDung`, `SoLuong`) VALUES
(1, 1, 1, 'sáng 1v chiều 1v', 2),
(2, 2, 1, 'ngày uống 2v', 8),
(3, 3, 1, '2 lần 1 ngày', 10),
(4, 3, 5, '1 ngày 1 v', 5),
(5, 4, 1, '2 ngày', 2),
(6, 4, 5, '2 ngày', 2),
(7, 4, 6, '2 ngày', 2);

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

--
-- Dumping data for table `ct_hoadon`
--

INSERT INTO `ct_hoadon` (`MaChiTiet`, `MaHoaDon`, `Loai`, `MaThamChieu`, `TenHienThi`, `SoLuong`, `DonGia`, `ThanhTien`) VALUES
(1, 1, 'dich_vu', 1, 'Khám Nội tổng quát', 1, 150000.00, 150000.00);

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

--
-- Dumping data for table `dichvu`
--

INSERT INTO `dichvu` (`MaDichVu`, `TenDichVu`, `Gia`, `MaKhoa`, `madichvuyte`) VALUES
(1, 'Khám Nội tổng quát', 150000.00, 1, 'KB_NOI_TQ'),
(2, 'Tổng phân tích tế bào máu ngoại vi', 110000.00, 10, 'XN_HUYETHOC_01'),
(3, 'Định lượng Glucose', 45000.00, 10, 'XN_DUONG_HUYET'),
(4, 'Siêu âm ổ bụng tổng quát', 180000.00, 11, 'SA_BUNG'),
(5, 'X-Quang ngực thẳng', 140000.00, 11, 'XQ_NGUC'),
(6, 'Nội soi dạ dày không đau', 1200000.00, 2, 'NS_DADAY_ME'),
(7, 'Tổng phân tích nước tiểu (10 thông số)', 75000.00, 10, 'XN_NUOCTIEU_10'),
(8, 'Điện tâm đồ (ECG)', 100000.00, 2, 'ECG_01'),
(9, 'Nội soi đại tràng', 1500000.00, 2, 'NS_DAITRANG'),
(10, 'Định lượng Acid Uric', 60000.00, 10, 'XN_URIC'),
(11, 'Xét nghiệm chức năng Gan (ALAT, ASAT)', 100000.00, 10, 'XN_GAN'),
(12, 'Xét nghiệm chức năng Thận (Ure, Creatinin)', 100000.00, 10, 'XN_THAN'),
(13, 'Định lượng HbA1c', 155000.00, 10, 'XN_HBA1C'),
(14, 'XN tìm virus Viêm gan B (HBsAg)', 130000.00, 10, 'XN_HBSAG'),
(15, 'Xét nghiệm Lipid máu (Cholesterol, Triglycerid)', 180000.00, 10, 'XN_MORO_MAU'),
(16, 'Siêu âm tuyến giáp', 150000.00, 11, 'SA_GIAP'),
(17, 'Siêu âm Doppler tim', 450000.00, 11, 'SA_DOPPLER_TIM'),
(18, 'Chụp CT-Scanner lồng ngực', 1200000.00, 11, 'CT_NGUC'),
(19, 'Chụp MRI cột sống cổ', 2200000.00, 11, 'MRI_CO'),
(20, 'Thay băng vết thương nhỏ', 50000.00, 3, 'NGOAI_THAYBANG'),
(21, 'Cắt chỉ vết thương', 70000.00, 3, 'NGOAI_CATCHI'),
(22, 'Siêu âm thai 4D', 350000.00, 5, 'SA_THAI_4D'),
(23, 'Khám chuyên khoa Nhi', 150000.00, 4, 'KB_NHI');

-- --------------------------------------------------------

--
-- Table structure for table `dichvu_benh`
--

CREATE TABLE `dichvu_benh` (
  `MaDichVu` int NOT NULL,
  `MaBenh` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `dichvu_benh`
--

INSERT INTO `dichvu_benh` (`MaDichVu`, `MaBenh`) VALUES
(1, 1),
(2, 3),
(1, 3),
(3, 5),
(7, 5),
(6, 6),
(4, 6),
(8, 4),
(5, 2),
(2, 2),
(5, 3),
(12, 4),
(17, 4),
(13, 5),
(4, 7),
(12, 7),
(7, 7),
(10, 15),
(2, 15),
(14, 12),
(11, 12),
(4, 12),
(19, 13);

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

--
-- Dumping data for table `donthuoc`
--

INSERT INTO `donthuoc` (`MaDonThuoc`, `MaLichKham`, `MaBacSi`, `NgayKe`) VALUES
(1, 6, 4, '2026-05-20 12:30:34'),
(2, 2, 4, '2026-05-20 14:06:56'),
(3, 8, 3, '2026-05-22 10:36:36'),
(4, 9, 3, '2026-05-22 13:16:48');

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

--
-- Dumping data for table `hoadon`
--

INSERT INTO `hoadon` (`MaHoaDon`, `MaBenhNhan`, `MaLichKham`, `MaNhapVien`, `LoaiHoaDon`, `TongTien`, `GiamBHYT`, `SoTienPhaiTra`, `TrangThai`, `NgayTao`) VALUES
(1, 1, 9, NULL, 'khám_ngoại_trú', 150000.00, 0.00, 150000.00, 'pending', '2026-05-22 13:16:48');

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

--
-- Dumping data for table `ketluankham`
--

INSERT INTO `ketluankham` (`MaKetLuanKham`, `MaLichKham`, `MaBacSi`, `MaBenh`, `ChanDoan`, `TinhTrang`, `HuongDieuTri`, `NgayKetLuan`) VALUES
(1, 6, 4, '1', 'cảm thông thường', 'nhiệt độ cao', 'Kê đơn thuốc', '2026-05-20 12:30:34'),
(2, 2, 4, '1', 'cảm lạnh', 'nhiệt độ hiện tại 28 độ', 'Kê đơn thuốc', '2026-05-20 14:06:56'),
(3, 8, 3, '1', 'cảm lạnh thông thường', 'sốt 38 độ', 'Kê đơn thuốc', '2026-05-22 10:36:36'),
(4, 9, 3, '1', 'Cảm lạnh có thể uống thuốc và chuyền nước', 'Sốt 38 độ', 'Kê đơn thuốc', '2026-05-22 13:16:48');

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

--
-- Dumping data for table `khoa`
--

INSERT INTO `khoa` (`MaKhoa`, `TenKhoa`, `machuyenkhoa`) VALUES
(1, 'Khoa Khám bệnh', 'KB'),
(2, 'Khoa Nội', 'NOI'),
(3, 'Khoa Ngoại', 'NGOAI'),
(4, 'Khoa Nhi', 'NHI'),
(5, 'Khoa Sản phụ khoa', 'SAN'),
(6, 'Khoa Mắt', 'MAT'),
(7, 'Khoa Tai Mũi Họng', 'TMH'),
(8, 'Khoa Răng Hàm Mặt', 'RHM'),
(9, 'Khoa Da liễu', 'DL'),
(10, 'Khoa Xét nghiệm', 'XN'),
(11, 'Khoa Chẩn đoán hình ảnh', 'CDHA'),
(12, 'Khoa Cấp cứu', 'CC'),
(13, 'Khoa Dinh dưỡng', 'DD'),
(14, 'Khoa Phục hồi chức năng', 'PHCN');

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
  `MaLichLamViec` int DEFAULT NULL,
  `MAOTP` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `lichkham`
--

INSERT INTO `lichkham` (`MaLichKham`, `MaBenhNhan`, `SoThuTu`, `TrangThai`, `TrangThaiThanhToan`, `TongTien`, `ThoiDiemCheckIn`, `ThoiDiemCheckOut`, `MaNhanVienCheckIn`, `MaLichLamViec`, `MAOTP`) VALUES
(1, 1, 1, 'rejected', 'unpaid', 150000.00, NULL, NULL, NULL, 5, NULL),
(2, 1, 2, 'completed', 'unpaid', 150000.00, NULL, NULL, NULL, 5, NULL),
(3, 2, 2, 'rejected', 'unpaid', 150000.00, NULL, NULL, NULL, 5, NULL),
(4, 2, 2, 'cancelled', 'unpaid', 150000.00, NULL, NULL, NULL, 5, NULL),
(5, 2, 2, 'cancelled', 'unpaid', 150000.00, NULL, NULL, NULL, 5, NULL),
(6, 2, 2, 'completed', 'unpaid', 150000.00, NULL, NULL, NULL, 5, NULL),
(7, 2, 1, 'confirmed', 'unpaid', 150000.00, NULL, NULL, NULL, 6, NULL),
(8, 2, 1, 'completed', 'unpaid', 150000.00, NULL, NULL, NULL, 8, NULL),
(9, 1, 2, 'completed', 'unpaid', 150000.00, NULL, NULL, NULL, 8, NULL),
(10, 3, 3, 'confirmed', 'unpaid', 150000.00, NULL, NULL, NULL, 8, NULL),
(11, 2, 1, 'confirmed', 'unpaid', 150000.00, NULL, NULL, NULL, 9, NULL);

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
(4, 3, '2026-05-14', 5, 1),
(5, 4, '2026-05-20', 5, 1),
(6, 3, '2026-05-21', 5, 1),
(7, 5, '2026-05-22', 5, 1),
(8, 3, '2026-05-22', 5, 3),
(9, 3, '2026-05-23', 5, 1);

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

--
-- Dumping data for table `phieuchidinh`
--

INSERT INTO `phieuchidinh` (`MaPhieu`, `MaLichKham`, `MaBacSi`, `NgayChiDinh`, `TrangThai`, `GhiChu`) VALUES
(2, 7, 5, '2026-05-21 12:27:16', 'completed', 'Bệnh nhân có dấu hiệu không đông máu'),
(3, 8, 5, '2026-05-22 08:58:48', 'completed', 'cần xét nghiệm máu'),
(4, 8, 5, '2026-05-22 10:11:56', 'processing', 'check đi bạn có gì gửi tôi dữ liệu'),
(5, 8, 5, '2026-05-22 10:16:01', 'completed', NULL),
(6, 8, 5, '2026-05-22 10:18:12', 'completed', NULL),
(7, 8, 5, '2026-05-22 10:31:30', 'pending', NULL),
(8, 9, 5, '2026-05-22 13:13:25', 'completed', 'bệnh nhân cần xét nghiệm máu');

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
(3, 'Phong 102', 'Tầng 1 - Phòng Khám Ngoại Trú'),
(4, 'Phòng 201', 'Tầng 2 - Phòng Khám Khoa Nội');

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
(1, 967287418, 'admin@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'admin', NULL, 'active', '2026-05-23 03:34:34', '2026-05-02 10:38:38'),
(4, 934567890, 'checkin@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'checkin', 'bc0a8b9a3823d1ce6711727a27d22f6f8be009e32580958593e4093991c881ed', 'active', '2026-05-23 03:41:31', '2026-05-02 10:38:38'),
(5, 945678901, 'thungan@gmail.com', '123456', 'thungan', 'token_tn', 'active', '2026-05-02 10:38:38', '2026-05-02 10:38:38'),
(7, 363455205, 'vinhtatoo0917@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'BenhNhan', '6ad6adb1615ef4fdd22ab178f8a625404d6c43cd43e1327084079365295f2805', 'active', '2026-05-22 13:10:02', '2026-05-06 07:41:26'),
(10, 363455203, 'kieuvi15112005@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'bacsi', '49d817160bd8f42ddab0c8f44e5d76c5ebfb9d5d82439382f18e112cef161204', 'active', '2026-05-23 03:41:57', '2026-05-09 16:19:09'),
(11, 967287419, 'vinhtatoo0911@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'bacsi', NULL, 'active', '2026-05-20 15:00:15', '2026-05-19 17:09:17'),
(12, 393653190, 'vinh123456@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'BenhNhan', '017232215c37b0dc0ccccb1f8846d7f9dca3a275eab723ae0267f26314fb5c7f', 'active', '2026-05-23 03:41:06', '2026-05-20 10:49:29'),
(13, 987654321, 'hoangvy@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'bacsi', NULL, 'active', '2026-05-22 13:41:02', '2026-05-20 15:37:40'),
(14, 123456789, 'dwadwad@gmail.com', '$2y$12$RiZER9gFTVPgGWFgvjW7LuPSkTUJZQe7N5rySokraR8FPYuiwXXiq', 'BenhNhan', NULL, 'active', '2026-05-22 13:42:22', '2026-05-22 13:41:35');

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

--
-- Dumping data for table `thuoc`
--

INSERT INTO `thuoc` (`MaThuoc`, `TenThuoc`, `DonViTinh`, `HamLuong`, `Gia`, `MoTa`, `TrangThai`) VALUES
(1, 'Paracetamol', 'Viên', '500mg', 2500.00, 'Thuốc giảm đau hạ sốt', 'Kinh doanh'),
(5, 'Paracetamol', 'Viên', '500mg', 1500.00, 'Thuốc giảm đau hạ sốt', 'Còn hàng'),
(6, 'Efferalgan', 'Viên sủi', '500mg', 4500.00, 'Hạ sốt giảm đau', 'Còn hàng'),
(7, 'Panadol Extra', 'Viên', '500mg', 3000.00, 'Giảm đau cảm cúm', 'Còn hàng'),
(8, 'Aspirin', 'Viên', '81mg', 1800.00, 'Ngừa tim mạch', 'Còn hàng'),
(9, 'Ibuprofen', 'Viên', '400mg', 3200.00, 'Kháng viêm giảm đau', 'Còn hàng'),
(10, 'Diclofenac', 'Viên', '50mg', 2800.00, 'Giảm đau xương khớp', 'Còn hàng'),
(11, 'Meloxicam', 'Viên', '7.5mg', 3500.00, 'Kháng viêm', 'Còn hàng'),
(12, 'Celecoxib', 'Viên', '200mg', 6500.00, 'Điều trị viêm khớp', 'Còn hàng'),
(13, 'Tramadol', 'Viên', '50mg', 5200.00, 'Giảm đau thần kinh', 'Còn hàng'),
(14, 'Morphine', 'Ống', '10mg/ml', 45000.00, 'Giảm đau mạnh', 'Còn hàng'),
(15, 'Amoxicillin', 'Viên', '500mg', 3500.00, 'Kháng sinh nhiễm khuẩn', 'Còn hàng'),
(16, 'Augmentin', 'Viên', '625mg', 12000.00, 'Kháng sinh phổ rộng', 'Còn hàng'),
(17, 'Azithromycin', 'Viên', '500mg', 9500.00, 'Kháng sinh hô hấp', 'Còn hàng'),
(18, 'Cefixime', 'Viên', '200mg', 8500.00, 'Kháng sinh cephalosporin', 'Còn hàng'),
(19, 'Cefuroxime', 'Viên', '500mg', 11000.00, 'Điều trị nhiễm khuẩn', 'Còn hàng'),
(20, 'Levofloxacin', 'Viên', '500mg', 12500.00, 'Kháng sinh mạnh', 'Còn hàng'),
(21, 'Ciprofloxacin', 'Viên', '500mg', 9200.00, 'Điều trị nhiễm khuẩn tiết niệu', 'Còn hàng'),
(22, 'Clarithromycin', 'Viên', '500mg', 13500.00, 'Kháng sinh macrolid', 'Còn hàng'),
(23, 'Metronidazole', 'Viên', '250mg', 2500.00, 'Kháng khuẩn đường ruột', 'Còn hàng'),
(24, 'Doxycycline', 'Viên', '100mg', 4200.00, 'Điều trị nhiễm khuẩn', 'Còn hàng'),
(25, 'Cetirizine', 'Viên', '10mg', 2200.00, 'Chống dị ứng', 'Còn hàng'),
(26, 'Loratadine', 'Viên', '10mg', 2500.00, 'Điều trị viêm mũi dị ứng', 'Còn hàng'),
(27, 'Clorpheniramin', 'Viên', '4mg', 1200.00, 'Kháng histamin', 'Còn hàng'),
(28, 'Fexofenadine', 'Viên', '180mg', 6500.00, 'Điều trị dị ứng', 'Còn hàng'),
(29, 'Prednisolone', 'Viên', '5mg', 3000.00, 'Kháng viêm corticoid', 'Còn hàng'),
(30, 'Dexamethasone', 'Ống', '4mg/ml', 6000.00, 'Kháng viêm mạnh', 'Còn hàng'),
(31, 'Hydrocortisone', 'Tuýp', '1%', 15000.00, 'Kem chống viêm da', 'Còn hàng'),
(32, 'Methylprednisolone', 'Viên', '16mg', 7200.00, 'Điều trị dị ứng nặng', 'Còn hàng'),
(33, 'Salbutamol', 'Ống hít', '100mcg', 85000.00, 'Điều trị hen suyễn', 'Còn hàng'),
(34, 'Ventolin', 'Ống hít', '100mcg', 92000.00, 'Giãn phế quản', 'Còn hàng'),
(35, 'Acetylcysteine', 'Gói', '200mg', 2500.00, 'Tiêu đờm', 'Còn hàng'),
(36, 'Bromhexine', 'Viên', '8mg', 1800.00, 'Long đờm', 'Còn hàng'),
(37, 'Terpin Codein', 'Viên', 'Codein 10mg', 3200.00, 'Giảm ho', 'Còn hàng'),
(38, 'Tiffy', 'Viên', '500mg', 3500.00, 'Thuốc cảm cúm', 'Còn hàng'),
(39, 'Decolgen', 'Viên', '500mg', 3000.00, 'Điều trị cảm lạnh', 'Còn hàng'),
(40, 'Strepsils', 'Vỉ', '24 viên', 28000.00, 'Ngậm đau họng', 'Còn hàng'),
(41, 'Alpha Choay', 'Viên', '4200IU', 5200.00, 'Chống phù nề', 'Còn hàng'),
(42, 'Medrol', 'Viên', '16mg', 8000.00, 'Kháng viêm', 'Còn hàng'),
(43, 'Natri Clorid', 'Chai', '500ml', 12000.00, 'Dung dịch truyền', 'Còn hàng'),
(44, 'Glucose 5%', 'Chai', '500ml', 15000.00, 'Dung dịch truyền', 'Còn hàng'),
(45, 'Omeprazole', 'Viên', '20mg', 4000.00, 'Điều trị đau dạ dày', 'Còn hàng'),
(46, 'Esomeprazole', 'Viên', '40mg', 8500.00, 'Điều trị trào ngược', 'Còn hàng'),
(47, 'Pantoprazole', 'Viên', '40mg', 7500.00, 'Điều trị viêm loét dạ dày', 'Còn hàng'),
(48, 'Smecta', 'Gói', '3g', 3500.00, 'Điều trị tiêu chảy', 'Còn hàng'),
(49, 'Berberin', 'Viên', '10mg', 1200.00, 'Rối loạn tiêu hóa', 'Còn hàng'),
(50, 'Domperidone', 'Viên', '10mg', 2200.00, 'Chống nôn', 'Còn hàng'),
(51, 'Metoclopramide', 'Ống', '10mg/2ml', 4500.00, 'Điều trị buồn nôn', 'Còn hàng'),
(52, 'ORS', 'Gói', '27.9g', 2500.00, 'Bù điện giải', 'Còn hàng'),
(53, 'Loperamide', 'Viên', '2mg', 1800.00, 'Cầm tiêu chảy', 'Còn hàng'),
(54, 'Phosphalugel', 'Gói', '20g', 3200.00, 'Trung hòa acid dạ dày', 'Còn hàng'),
(55, 'Metformin', 'Viên', '500mg', 3200.00, 'Điều trị tiểu đường', 'Còn hàng'),
(56, 'Gliclazide', 'Viên', '30mg', 5000.00, 'Điều trị đái tháo đường', 'Còn hàng'),
(57, 'Insulin Mixtard', 'Lọ', '100IU/ml', 185000.00, 'Tiêm insulin', 'Còn hàng'),
(58, 'Losartan', 'Viên', '50mg', 4200.00, 'Điều trị tăng huyết áp', 'Còn hàng'),
(59, 'Amlodipine', 'Viên', '5mg', 3800.00, 'Điều trị huyết áp', 'Còn hàng'),
(60, 'Bisoprolol', 'Viên', '5mg', 4500.00, 'Điều trị tim mạch', 'Còn hàng'),
(61, 'Atorvastatin', 'Viên', '20mg', 6200.00, 'Giảm cholesterol', 'Còn hàng'),
(62, 'Rosuvastatin', 'Viên', '10mg', 9800.00, 'Điều trị mỡ máu', 'Còn hàng'),
(63, 'Clopidogrel', 'Viên', '75mg', 7500.00, 'Ngừa đột quỵ', 'Còn hàng'),
(64, 'Nitroglycerin', 'Viên', '0.5mg', 5200.00, 'Điều trị đau thắt ngực', 'Còn hàng'),
(65, 'Vitamin C', 'Viên', '1000mg', 2500.00, 'Tăng đề kháng', 'Còn hàng'),
(66, 'Vitamin B1', 'Viên', '100mg', 1200.00, 'Bổ sung vitamin B1', 'Còn hàng'),
(67, 'Vitamin B6', 'Viên', '250mg', 1500.00, 'Bổ sung vitamin B6', 'Còn hàng'),
(68, 'Vitamin B12', 'Ống', '500mcg', 5000.00, 'Điều trị thiếu máu', 'Còn hàng'),
(69, 'Vitamin E', 'Viên', '400IU', 3200.00, 'Làm đẹp da', 'Còn hàng'),
(70, 'Canxi Corbiere', 'Ống', '10ml', 7000.00, 'Bổ sung canxi', 'Còn hàng'),
(71, 'Ferrovit', 'Viên', 'Sắt + Acid folic', 3200.00, 'Bổ sung sắt', 'Còn hàng'),
(72, 'Zinc', 'Viên', '20mg', 2200.00, 'Bổ sung kẽm', 'Còn hàng'),
(73, 'Magnesi B6', 'Viên', '470mg', 4500.00, 'Bổ sung magie', 'Còn hàng'),
(74, 'Omega 3', 'Viên', '1000mg', 8500.00, 'Bổ sung dầu cá', 'Còn hàng'),
(75, 'Diazepam', 'Viên', '5mg', 1800.00, 'An thần', 'Còn hàng'),
(76, 'Phenobarbital', 'Viên', '100mg', 2500.00, 'Chống co giật', 'Còn hàng'),
(77, 'Seduxen', 'Ống', '10mg/2ml', 5200.00, 'An thần tiêm', 'Còn hàng'),
(78, 'Haloperidol', 'Viên', '1.5mg', 3500.00, 'Điều trị tâm thần', 'Còn hàng'),
(79, 'Olanzapine', 'Viên', '10mg', 15000.00, 'Điều trị rối loạn tâm thần', 'Còn hàng'),
(80, 'Quetiapine', 'Viên', '100mg', 13500.00, 'Thuốc an thần', 'Còn hàng'),
(81, 'Carbamazepine', 'Viên', '200mg', 4500.00, 'Chống động kinh', 'Còn hàng'),
(82, 'Valproate', 'Viên', '500mg', 8500.00, 'Điều trị động kinh', 'Còn hàng'),
(83, 'Piracetam', 'Viên', '800mg', 3200.00, 'Tăng tuần hoàn não', 'Còn hàng'),
(84, 'Cinnarizine', 'Viên', '25mg', 2200.00, 'Chống chóng mặt', 'Còn hàng'),
(85, 'Betadine', 'Chai', '10%', 35000.00, 'Sát khuẩn ngoài da', 'Còn hàng'),
(86, 'Oxy già', 'Chai', '3%', 12000.00, 'Sát trùng vết thương', 'Còn hàng'),
(87, 'Cồn 70 độ', 'Chai', '500ml', 18000.00, 'Sát khuẩn', 'Còn hàng'),
(88, 'Povidine', 'Chai', '10%', 28000.00, 'Dung dịch sát khuẩn', 'Còn hàng'),
(89, 'Bông y tế', 'Gói', '100g', 15000.00, 'Dùng trong y tế', 'Còn hàng'),
(90, 'Gạc y tế', 'Hộp', '50 miếng', 25000.00, 'Băng bó vết thương', 'Còn hàng'),
(91, 'Thuốc đỏ', 'Chai', '20ml', 8000.00, 'Sát trùng ngoài da', 'Còn hàng'),
(92, 'Kem nghệ', 'Tuýp', '20g', 18000.00, 'Hỗ trợ liền sẹo', 'Còn hàng'),
(93, 'Silver Sulfadiazine', 'Tuýp', '1%', 42000.00, 'Điều trị bỏng', 'Còn hàng'),
(94, 'Mupirocin', 'Tuýp', '2%', 65000.00, 'Kháng sinh ngoài da', 'Còn hàng'),
(95, 'Eye Drops Natri Clorid', 'Lọ', '10ml', 18000.00, 'Nước nhỏ mắt', 'Còn hàng'),
(96, 'Tobradex', 'Lọ', '5ml', 85000.00, 'Thuốc nhỏ mắt kháng sinh', 'Còn hàng'),
(97, 'Refresh Tears', 'Lọ', '15ml', 95000.00, 'Nước mắt nhân tạo', 'Còn hàng'),
(98, 'Ofloxacin Eye Drops', 'Lọ', '5ml', 65000.00, 'Kháng sinh nhỏ mắt', 'Còn hàng'),
(99, 'Ear Drops Otipax', 'Lọ', '16g', 78000.00, 'Thuốc nhỏ tai', 'Còn hàng'),
(100, 'Naphazoline', 'Lọ', '15ml', 22000.00, 'Thuốc nhỏ mũi', 'Còn hàng'),
(101, 'Xisat', 'Lọ', '75ml', 45000.00, 'Xịt mũi', 'Còn hàng'),
(102, 'Oracortia', 'Tuýp', '5g', 32000.00, 'Điều trị nhiệt miệng', 'Còn hàng'),
(103, 'Kamistad', 'Tuýp', '10g', 55000.00, 'Gel giảm đau răng miệng', 'Còn hàng'),
(104, 'Daktarin Oral Gel', 'Tuýp', '10g', 68000.00, 'Điều trị nấm miệng', 'Còn hàng'),
(105, 'Fluconazole', 'Viên', '150mg', 8500.00, 'Điều trị nấm', 'Còn hàng'),
(106, 'Ketoconazole', 'Tuýp', '2%', 32000.00, 'Kem trị nấm', 'Còn hàng'),
(107, 'Itraconazole', 'Viên', '100mg', 15000.00, 'Kháng nấm', 'Còn hàng'),
(108, 'Acyclovir', 'Viên', '400mg', 7500.00, 'Điều trị herpes', 'Còn hàng'),
(109, 'Tamiflu', 'Viên', '75mg', 45000.00, 'Điều trị cúm', 'Còn hàng'),
(110, 'Oseltamivir', 'Viên', '75mg', 42000.00, 'Kháng virus cúm', 'Còn hàng'),
(111, 'Albendazole', 'Viên', '400mg', 5000.00, 'Tẩy giun', 'Còn hàng'),
(112, 'Mebendazole', 'Viên', '500mg', 4500.00, 'Điều trị giun sán', 'Còn hàng'),
(113, 'Praziquantel', 'Viên', '600mg', 18000.00, 'Điều trị sán', 'Còn hàng'),
(114, 'Artesunate', 'Viên', '50mg', 22000.00, 'Điều trị sốt rét', 'Còn hàng');

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
  MODIFY `MaBacSi` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `benh`
--
ALTER TABLE `benh`
  MODIFY `MaBenh` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `benhnhan`
--
ALTER TABLE `benhnhan`
  MODIFY `MaBenhNhan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
  MODIFY `MaChiTiet` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `chitietphieuchidinh`
--
ALTER TABLE `chitietphieuchidinh`
  MODIFY `MaChiTietPhieu` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `ct_donthuoc`
--
ALTER TABLE `ct_donthuoc`
  MODIFY `MaChiTiet` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `ct_hoadon`
--
ALTER TABLE `ct_hoadon`
  MODIFY `MaChiTiet` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `donthuoc`
--
ALTER TABLE `donthuoc`
  MODIFY `MaDonThuoc` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `giuongbenh`
--
ALTER TABLE `giuongbenh`
  MODIFY `MaGiuong` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hoadon`
--
ALTER TABLE `hoadon`
  MODIFY `MaHoaDon` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ketluankham`
--
ALTER TABLE `ketluankham`
  MODIFY `MaKetLuanKham` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ketluannoitru`
--
ALTER TABLE `ketluannoitru`
  MODIFY `MaKetLuanNoiTru` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lichkham`
--
ALTER TABLE `lichkham`
  MODIFY `MaLichKham` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `lichlamviec`
--
ALTER TABLE `lichlamviec`
  MODIFY `MaLichLamViec` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `MaPhieu` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `phongbenh`
--
ALTER TABLE `phongbenh`
  MODIFY `MaPhong` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phongkham`
--
ALTER TABLE `phongkham`
  MODIFY `MaPhong` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `taikhoan`
--
ALTER TABLE `taikhoan`
  MODIFY `MaTaiKhoan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

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
  MODIFY `MaThuoc` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;

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
