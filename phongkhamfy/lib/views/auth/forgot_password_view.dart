import 'package:flutter/material.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/nut_gui_ma_xac_nhan.dart';
import '../../controllers/password_controller.dart';
import '../../theme/app_theme.dart';
import 'verify_otp_view.dart';
import '../../widgets/loading_overlay.dart';

class ManHinhQuenMatKhau extends StatefulWidget {
  const ManHinhQuenMatKhau({super.key});

  @override
  State<ManHinhQuenMatKhau> createState() => _TrangThaiManHinhQuenMatKhau();
}

class _TrangThaiManHinhQuenMatKhau extends State<ManHinhQuenMatKhau> {
  final _formKey = GlobalKey<FormState>();
  final _boQuanLyEmail = TextEditingController();
  bool _dangTaiDuLieu = false;
  bool _daGuiMa = false;
  final _dichVuQuenMatKhau = DichVuQuenMatKhau();

  @override
  void dispose() {
    _boQuanLyEmail.dispose();
    super.dispose();
  }

  Future<void> _xuLyGuiMaXacNhan() async {
    final email = _boQuanLyEmail.text.trim();
    setState(() => _dangTaiDuLieu = true);
    try {
      final ketQua = await _dichVuQuenMatKhau.guiMaXacNhan(email);
      setState(() => _dangTaiDuLieu = false);
      if (mounted) {
        if (ketQua.thanhCong) {
          setState(() => _daGuiMa = true);
          _hienThiThongBao(ketQua.thongBao);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ManHinhXacNhanOTP(email: email),
              ));
            }
          });
        } else {
          _hienThiThongBao(ketQua.thongBao, laThatBai: true);
        }
      }
    } catch (e) {
      setState(() => _dangTaiDuLieu = false);
      if (mounted) _hienThiThongBao('Có lỗi xảy ra: $e', laThatBai: true);
    }
  }

  void _hienThiThongBao(String noiDung, {bool laThatBai = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung, style: AppText.subhead.copyWith(color: Colors.white)),
        backgroundColor: laThatBai ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: laThatBai ? 4 : 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(
        title: 'Quên mật khẩu',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _dangTaiDuLieu,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Header icon + title
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 34),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text('Khôi phục mật khẩu', style: AppText.title3)),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Nhập email đã đăng ký để nhận mã xác nhận',
                      style: AppText.subhead.copyWith(color: AppColors.subLabel),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form card
                  IosSection(
                    title: 'Thông tin',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email đã đăng ký', style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.label2)),
                            const SizedBox(height: 8),
                            ONhapLieu(
                              boQuanLy: _boQuanLyEmail,
                              goiY: 'example@phongkham.vn',
                              iconTrai: Icons.email_outlined,
                              loaiBanPhim: TextInputType.emailAddress,
                              kichHoat: !_daGuiMa,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status banner
                  if (_daGuiMa)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Mã đã gửi! Kiểm tra email và làm theo hướng dẫn.',
                              style: AppText.footnote.copyWith(color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  NutGuiMaXacNhan(dangTaiDuLieu: _dangTaiDuLieu, khiNhan: _xuLyGuiMaXacNhan),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nhớ lại mật khẩu? ', style: AppText.subhead.copyWith(color: AppColors.subLabel)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Đăng nhập', style: AppText.subhead.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
