// ═══════════════════════════════════════════════════════════════
// FILE: login_view.dart
// MÔ TẢ: Màn hình đăng nhập - PHIÊN BẢN VIỆT HÓA DỄ HIỂU
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../widgets/logo_phong_kham.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/nut_dang_nhap.dart';
import '../../widgets/hieu_ung_nen.dart';
import '../../controllers/auth_controller.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';
import '../home/home_view.dart';
import '../admin/admin_home_view.dart';

// ═══════════════════════════════════════════════════════════════
// WIDGET CHÍNH: Màn hình đăng nhập
// ═══════════════════════════════════════════════════════════════
class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({super.key});

  @override
  State<ManHinhDangNhap> createState() => _TrangThaiManHinhDangNhap();
}

// ═══════════════════════════════════════════════════════════════
// STATE: Quản lý trạng thái màn hình
// ═══════════════════════════════════════════════════════════════
class _TrangThaiManHinhDangNhap extends State<ManHinhDangNhap> {
  // ─────────────────────────────────────────────────────────────
  // PHẦN 1: KHAI BÁO BIẾN
  // ─────────────────────────────────────────────────────────────

  // Quản lý form (để validate)
  final _khoaForm = GlobalKey<FormState>();

  // Quản lý ô nhập liệu
  final _oNhapEmail = TextEditingController();
  final _oNhapMatKhau = TextEditingController();

  // Service xử lý đăng nhập
  final _dichVuDangNhap = DichVuXacThuc();

  // Trạng thái hiển thị
  bool _coHienMatKhau = false; // Có hiện mật khẩu không?
  bool _dangXuLy = false; // Có đang xử lý không?
  bool _coGhiNho = false; // Có ghi nhớ đăng nhập không?

  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);
  final _mauChuXam = const Color(0xFF5A8A70);
  final _mauVien = const Color(0xFFB2DFC8);

  // ─────────────────────────────────────────────────────────────
  // PHẦN 2: DỌN DẸP KHI ĐÓNG MÀN HÌNH
  // ─────────────────────────────────────────────────────────────
  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _oNhapEmail.dispose();
    _oNhapMatKhau.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // PHẦN 3: HÀM XỬ LÝ ĐĂNG NHẬP (QUAN TRỌNG NHẤT)
  // ─────────────────────────────────────────────────────────────
  Future<void> _xuLyKhiNhanNutDangNhap() async {
    // Bước 1: Lấy dữ liệu người dùng nhập
    final emailNguoiDungNhap = _oNhapEmail.text;
    final matKhauNguoiDungNhap = _oNhapMatKhau.text;

    // Bước 2: Bật trạng thái "đang xử lý"
    setState(() {
      _dangXuLy = true; // Nút sẽ hiện loading
    });

    // Bước 3: Gọi service để kiểm tra đăng nhập
    try {
      // Gọi hàm đăng nhập và đợi kết quả
      final ketQua = await _dichVuDangNhap.dangNhap(
        emailNguoiDungNhap,
        matKhauNguoiDungNhap,
      );

      // Bước 4: Tắt trạng thái "đang xử lý"
      setState(() {
        _dangXuLy = false;
      });

      // Bước 5: Xử lý kết quả
      if (mounted) {
        if (ketQua.thanhCong) {
          // ✅ ĐĂNG NHẬP THÀNH CÔNG
          final thongTinUser = ketQua.thongTinNguoiDung!;
          final tenHienThi =
              thongTinUser['ten'] ??
              thongTinUser['name'] ??
              thongTinUser['sdt'] ??
              'Người dùng';

          _hienThongBaoThanhCong('Đăng nhập thành công! Chào $tenHienThi');

          // Đợi 1 giây rồi chuyển màn hình
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            _chuyenSangManHinhChinh(thongTinUser);
          }
        } else {
          // ❌ ĐĂNG NHẬP THẤT BẠI
          _hienThongBaoLoi(ketQua.thongBaoLoi!);
        }
      }
    } catch (loi) {
      // Bước 6: Xử lý khi có lỗi bất ngờ
      setState(() {
        _dangXuLy = false;
      });

      if (mounted) {
        _hienThongBaoLoi('Có lỗi xảy ra. Vui lòng thử lại.');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PHẦN 4: CÁC HÀM PHỤ TRỢ
  // ─────────────────────────────────────────────────────────────

  // Hiển thị thông báo thành công (màu xanh)
  void _hienThongBaoThanhCong(String noiDung) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung),
        backgroundColor: _mauXanh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Hiển thị thông báo lỗi (màu đỏ)
  void _hienThongBaoLoi(String noiDung) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Chuyển sang màn hình chính
  void _chuyenSangManHinhChinh(Map<String, dynamic> thongTinNguoiDung) {
    final vaiTro = thongTinNguoiDung['VaiTro'] ?? 'BenhNhan';

    // DEBUG: In ra vai trò để kiểm tra
    print('🔍 [DEBUG] VaiTro từ API: "$vaiTro"');
    print('🔍 [DEBUG] Toàn bộ thông tin user: $thongTinNguoiDung');

    // So sánh không phân biệt hoa thường
    if (vaiTro.toString().toLowerCase() == 'admin') {
      print('✅ [DEBUG] Đang chuyển đến màn hình Admin');
      // Chuyển đến màn hình Admin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHomeView(
            tenNguoiDung:
                thongTinNguoiDung['email'] ??
                thongTinNguoiDung['sdt'] ??
                'Admin',
            email: thongTinNguoiDung['email'] ?? thongTinNguoiDung['sdt'] ?? '',
          ),
        ),
      );
    } else {
      print(
        '❌ [DEBUG] Vai trò không phải admin, chuyển đến màn hình bệnh nhân',
      );
      // Chuyển đến màn hình bệnh nhân
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeView(
            tenNguoiDung:
                thongTinNguoiDung['ten'] ??
                thongTinNguoiDung['name'] ??
                'Người dùng',
            email: thongTinNguoiDung['email'] ?? thongTinNguoiDung['sdt'] ?? '',
          ),
        ),
      );
    }
  }

  // Chuyển sang màn hình đăng ký
  void _chuyenSangManHinhDangKy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhDangKy()),
    );
  }

  // Chuyển sang màn hình quên mật khẩu
  void _chuyenSangManHinhQuenMatKhau() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhQuenMatKhau()),
    );
  }

  // Hiển thị dialog thông tin tài khoản demo
  void _hienDialogThongTinTaiKhoan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔑 Thông tin đăng nhập'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sử dụng tài khoản demo:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _mauNen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _mauVien),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản demo:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('SĐT: 9012345678'),
                    Text('Mật khẩu: 123456'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              _oNhapEmail.text = '9012345678';
              _oNhapMatKhau.text = '123456';
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _mauXanh),
            child: const Text('Tự động điền'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PHẦN 5: XÂY DỰNG GIAO DIỆN
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final kichThuocManHinh = MediaQuery.of(context).size;
    final chieuRongManHinh = kichThuocManHinh.width;

    // Kiểm tra loại thiết bị
    final laDienThoai = chieuRongManHinh < 600;

    return Scaffold(
      backgroundColor: _mauNen,
      body: Stack(
        children: [
          // Hiệu ứng nền
          const HieuUngNen(),

          // Nội dung chính
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(laDienThoai ? 16 : 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      const LogoPhongKham(),
                      const SizedBox(height: 32),

                      // Card đăng nhập
                      _xayDungCardDangNhap(laDienThoai),

                      const SizedBox(height: 16),

                      // Nút xem thông tin tài khoản
                      _xayDungNutXemThongTin(),

                      const SizedBox(height: 8),

                      // Footer
                      _xayDungFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng card đăng nhập
  Widget _xayDungCardDangNhap(bool laDienThoai) {
    return Container(
      padding: EdgeInsets.all(laDienThoai ? 24 : 32),
      decoration: BoxDecoration(
        color: _mauTrang,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _mauXanh.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _khoaForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              'Đăng Nhập',
              style: TextStyle(
                fontSize: laDienThoai ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: _mauChuDen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chào mừng bạn quay trở lại 👋',
              style: TextStyle(
                fontSize: laDienThoai ? 14 : 16,
                color: _mauChuXam,
              ),
            ),
            const SizedBox(height: 24),

            // Ô nhập SĐT
            _xayDungNhan('Số điện thoại'),
            const SizedBox(height: 8),
            ONhapLieu(
              boQuanLy: _oNhapEmail,
              goiY: '0901234567',
              iconTrai: Icons.phone_outlined,
              loaiBanPhim: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Ô nhập Mật khẩu
            _xayDungNhan('Mật khẩu'),
            const SizedBox(height: 8),
            ONhapLieu(
              boQuanLy: _oNhapMatKhau,
              goiY: '••••••••',
              iconTrai: Icons.lock_outline_rounded,
              laMatKhau: true,
              hienThiMatKhau: _coHienMatKhau,
              khiBatTatHienThiMatKhau: () {
                setState(() => _coHienMatKhau = !_coHienMatKhau);
              },
            ),
            const SizedBox(height: 12),

            // Ghi nhớ & Quên mật khẩu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Checkbox ghi nhớ
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _coGhiNho,
                        onChanged: (giaTri) {
                          setState(() => _coGhiNho = giaTri!);
                        },
                        activeColor: _mauXanh,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Ghi nhớ', style: TextStyle(fontSize: 13)),
                  ],
                ),
                // Nút quên mật khẩu
                TextButton(
                  onPressed: _chuyenSangManHinhQuenMatKhau,
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: _mauXanh,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nút Đăng nhập
            SizedBox(
              width: double.infinity,
              height: 52,
              child: NutDangNhap(
                dangTaiDuLieu: _dangXuLy,
                khiNhan: _xuLyKhiNhanNutDangNhap,
              ),
            ),

            const SizedBox(height: 16),

            // Đường phân cách
            Row(
              children: [
                Expanded(child: Divider(color: _mauVien)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('hoặc', style: TextStyle(fontSize: 12)),
                ),
                Expanded(child: Divider(color: _mauVien)),
              ],
            ),

            const SizedBox(height: 16),

            // Nút Tạo tài khoản
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _chuyenSangManHinhDangKy,
                icon: Icon(Icons.person_add_outlined, color: _mauXanh),
                label: const Text('Tạo tài khoản mới'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _mauVien),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Xây dựng nhãn (label)
  Widget _xayDungNhan(String chuoi) {
    return Text(
      chuoi,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _mauChuDen,
      ),
    );
  }

  // Xây dựng nút xem thông tin
  Widget _xayDungNutXemThongTin() {
    return TextButton.icon(
      onPressed: _hienDialogThongTinTaiKhoan,
      icon: Icon(Icons.info_outline, size: 16, color: _mauXanh),
      label: Text(
        'Xem thông tin đăng nhập',
        style: TextStyle(
          fontSize: 13,
          color: _mauXanh,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Xây dựng footer
  Widget _xayDungFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: _mauChuXam),
            const SizedBox(width: 6),
            Text(
              'Kết nối bảo mật SSL',
              style: TextStyle(fontSize: 12, color: _mauChuXam),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '© 2025 Phòng Khám FY',
          style: TextStyle(
            fontSize: 11,
            color: _mauChuXam.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
