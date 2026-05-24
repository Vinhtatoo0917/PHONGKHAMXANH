import 'package:flutter/material.dart';
import '../../widgets/logo_phong_kham.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/loading_overlay.dart';
import '../../controllers/register_controller.dart';
import '../../theme/app_theme.dart';
import 'login_view.dart';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _TrangThaiManHinhDangKy();
}

class _TrangThaiManHinhDangKy extends State<ManHinhDangKy> {
  final _khoaForm = GlobalKey<FormState>();
  final _oNhapSdt = TextEditingController();
  final _oNhapEmail = TextEditingController();
  final _oNhapMatKhau = TextEditingController();
  final _oNhapXacNhanMatKhau = TextEditingController();
  final _dichVuDangKy = DichVuDangKy();

  bool _coHienMatKhau = false;
  bool _coHienXacNhanMatKhau = false;
  bool _dangXuLy = false;

  @override
  void dispose() {
    _oNhapSdt.dispose();
    _oNhapEmail.dispose();
    _oNhapMatKhau.dispose();
    _oNhapXacNhanMatKhau.dispose();
    super.dispose();
  }

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
          _hienThongBao('Đăng ký thành công! Vui lòng đăng nhập.', isError: false);
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) _chuyenVeManHinhDangNhap();
        } else {
          _hienThongBao(ketQua.thongBaoLoi!, isError: true);
        }
      }
    } catch (_) {
      setState(() => _dangXuLy = false);
      if (mounted) _hienThongBao('Có lỗi xảy ra. Vui lòng thử lại.', isError: true);
    }
  }

  void _hienThongBao(String noiDung, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung, style: AppText.subhead.copyWith(color: Colors.white)),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _chuyenVeManHinhDangNhap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LoadingOverlay(
        isLoading: _dangXuLy,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _khoaForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  const Center(child: LogoPhongKham()),

                  const SizedBox(height: 32),

                  // Form card
                  Container(
                    decoration: AppDecor.card,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tạo Tài Khoản', style: AppText.title2),
                        const SizedBox(height: 4),
                        Text('Điền thông tin để bắt đầu 🎉', style: AppText.subhead.copyWith(color: AppColors.subLabel)),

                        const SizedBox(height: 24),

                        _label('Số điện thoại'),
                        const SizedBox(height: 6),
                        ONhapLieu(
                          boQuanLy: _oNhapSdt,
                          goiY: '0901234567',
                          iconTrai: Icons.phone_outlined,
                          loaiBanPhim: TextInputType.phone,
                        ),

                        const SizedBox(height: 16),

                        _label('Email'),
                        const SizedBox(height: 6),
                        ONhapLieu(
                          boQuanLy: _oNhapEmail,
                          goiY: 'example@email.com',
                          iconTrai: Icons.email_outlined,
                          loaiBanPhim: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        _label('Mật khẩu'),
                        const SizedBox(height: 6),
                        ONhapLieu(
                          boQuanLy: _oNhapMatKhau,
                          goiY: '••••••••',
                          iconTrai: Icons.lock_outline_rounded,
                          laMatKhau: true,
                          hienThiMatKhau: _coHienMatKhau,
                          khiBatTatHienThiMatKhau: () => setState(() => _coHienMatKhau = !_coHienMatKhau),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mật khẩu phải có chữ hoa, chữ thường và số',
                          style: AppText.caption.copyWith(color: AppColors.subLabel, fontStyle: FontStyle.italic),
                        ),

                        const SizedBox(height: 16),

                        _label('Nhập lại mật khẩu'),
                        const SizedBox(height: 6),
                        ONhapLieu(
                          boQuanLy: _oNhapXacNhanMatKhau,
                          goiY: '••••••••',
                          iconTrai: Icons.lock_outline_rounded,
                          laMatKhau: true,
                          hienThiMatKhau: _coHienXacNhanMatKhau,
                          khiBatTatHienThiMatKhau: () => setState(() => _coHienXacNhanMatKhau = !_coHienXacNhanMatKhau),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _dangXuLy ? null : _xuLyKhiNhanNutDangKy,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _dangXuLy
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text('Đăng Ký', style: AppText.headline.copyWith(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Đã có tài khoản? ', style: AppText.subhead.copyWith(color: AppColors.subLabel)),
                      GestureDetector(
                        onTap: _chuyenVeManHinhDangNhap,
                        child: Text('Đăng nhập', style: AppText.subhead.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 12, color: AppColors.placeholder),
                        const SizedBox(width: 4),
                        Text('Thông tin của bạn được bảo mật', style: AppText.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text('© 2025 Phòng Khám FY', style: AppText.caption)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.label2),
  );
}
