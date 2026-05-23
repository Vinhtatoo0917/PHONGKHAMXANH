// ═══════════════════════════════════════════════════════════════
// FILE: register_view.dart
// MÔ TẢ: Màn hình đăng ký tài khoản
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../widgets/logo_phong_kham.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/hieu_ung_nen.dart';
import '../../controllers/register_controller.dart';
import 'login_view.dart';
import '../../widgets/loading_overlay.dart';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _TrangThaiManHinhDangKy();
}

class _TrangThaiManHinhDangKy extends State<ManHinhDangKy> {
  // ─────────────────────────────────────────────────────────────
  // KHAI BÁO BIẾN
  // ─────────────────────────────────────────────────────────────
  final _khoaForm = GlobalKey<FormState>();

  final _oNhapSdt = TextEditingController();
  final _oNhapEmail = TextEditingController();
  final _oNhapMatKhau = TextEditingController();
  final _oNhapXacNhanMatKhau = TextEditingController();

  final _dichVuDangKy = DichVuDangKy();

  bool _coHienMatKhau = false;
  bool _coHienXacNhanMatKhau = false;
  bool _dangXuLy = false;

  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);
  final _mauChuXam = const Color(0xFF5A8A70);
  final _mauVien = const Color(0xFFB2DFC8);

  @override
  void dispose() {
    _oNhapSdt.dispose();
    _oNhapEmail.dispose();
    _oNhapMatKhau.dispose();
    _oNhapXacNhanMatKhau.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // XỬ LÝ ĐĂNG KÝ
  // ─────────────────────────────────────────────────────────────
  Future<void> _xuLyKhiNhanNutDangKy() async {
    setState(() => _dangXuLy = true);

    try {
      final ketQua = await _dichVuDangKy.dangKy(
        sdt: _oNhapSdt.text,
        email: _oNhapEmail.text,
        matKhau: _oNhapMatKhau.text,
        xacNhanMatKhau: _oNhapXacNhanMatKhau.text,
      );

      setState(() => _dangXuLy = false);

      if (mounted) {
        if (ketQua.thanhCong) {
          _hienThongBaoThanhCong('Đăng ký thành công! Vui lòng đăng nhập.');
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) _chuyenVeManHinhDangNhap();
        } else {
          _hienThongBaoLoi(ketQua.thongBaoLoi!);
        }
      }
    } catch (loi) {
      setState(() => _dangXuLy = false);
      if (mounted) {
        _hienThongBaoLoi('Có lỗi xảy ra. Vui lòng thử lại.');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HÀM PHỤ TRỢ
  // ─────────────────────────────────────────────────────────────
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

  void _chuyenVeManHinhDangNhap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // XÂY DỰNG GIAO DIỆN
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final kichThuocManHinh = MediaQuery.of(context).size;
    final chieuRongManHinh = kichThuocManHinh.width;
    final laDienThoai = chieuRongManHinh < 600;

    return Scaffold(
      backgroundColor: _mauNen,
      body: LoadingOverlay(
        isLoading: _dangXuLy,
        child: Stack(
          children: [
            const HieuUngNen(),
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
                        const SizedBox(height: 24),
  
                        // Card đăng ký
                        _xayDungCardDangKy(laDienThoai),
  
                        const SizedBox(height: 16),
  
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
      ),
    );
  }

  Widget _xayDungCardDangKy(bool laDienThoai) {
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
              'Đăng Ký Tài Khoản',
              style: TextStyle(
                fontSize: laDienThoai ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: _mauChuDen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tạo tài khoản mới để sử dụng dịch vụ 🎉',
              style: TextStyle(
                fontSize: laDienThoai ? 14 : 16,
                color: _mauChuXam,
              ),
            ),
            const SizedBox(height: 24),

            // Số điện thoại
            _xayDungNhan('Số điện thoại'),
            const SizedBox(height: 8),
            ONhapLieu(
              boQuanLy: _oNhapSdt,
              goiY: '0901234567',
              iconTrai: Icons.phone_outlined,
              loaiBanPhim: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Email
            _xayDungNhan('Email'),
            const SizedBox(height: 8),
            ONhapLieu(
              boQuanLy: _oNhapEmail,
              goiY: 'example@email.com',
              iconTrai: Icons.email_outlined,
              loaiBanPhim: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Mật khẩu
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
            const SizedBox(height: 4),
            Text(
              'Mật khẩu phải có chữ hoa, chữ thường và số',
              style: TextStyle(
                fontSize: 11,
                color: _mauChuXam.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Nhập lại mật khẩu
            _xayDungNhan('Nhập lại mật khẩu'),
            const SizedBox(height: 8),
            ONhapLieu(
              boQuanLy: _oNhapXacNhanMatKhau,
              goiY: '••••••••',
              iconTrai: Icons.lock_outline_rounded,
              laMatKhau: true,
              hienThiMatKhau: _coHienXacNhanMatKhau,
              khiBatTatHienThiMatKhau: () {
                setState(() => _coHienXacNhanMatKhau = !_coHienXacNhanMatKhau);
              },
            ),
            const SizedBox(height: 24),

            // Nút Đăng ký
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _dangXuLy ? null : _xuLyKhiNhanNutDangKy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mauXanh,
                  foregroundColor: _mauTrang,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _dangXuLy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Đăng Ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

            // Nút Đăng nhập
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _chuyenVeManHinhDangNhap,
                icon: Icon(Icons.login, color: _mauXanh),
                label: const Text('Đã có tài khoản? Đăng nhập'),
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

  Widget _xayDungFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: _mauChuXam),
            const SizedBox(width: 6),
            Text(
              'Thông tin của bạn được bảo mật',
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
