import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/nut_cap_nhat_mat_khau.dart';
import '../../controllers/otp_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_overlay.dart';

class ManHinhXacNhanOTP extends StatefulWidget {
  final String email;
  const ManHinhXacNhanOTP({super.key, required this.email});

  @override
  State<ManHinhXacNhanOTP> createState() => _TrangThaiManHinhXacNhanOTP();
}

class _TrangThaiManHinhXacNhanOTP extends State<ManHinhXacNhanOTP> {
  final _formKey = GlobalKey<FormState>();
  final _boQuanLyOTP = TextEditingController();
  final _boQuanLyMatKhauMoi = TextEditingController();
  final _boQuanLyXacNhanMatKhau = TextEditingController();

  bool _dangTaiDuLieu = false;
  bool _hienThiMatKhauMoi = false;
  bool _hienThiXacNhanMatKhau = false;

  final _dichVuXacNhanOTP = DichVuXacNhanOTP();

  @override
  void dispose() {
    _boQuanLyOTP.dispose();
    _boQuanLyMatKhauMoi.dispose();
    _boQuanLyXacNhanMatKhau.dispose();
    super.dispose();
  }

  Future<void> _xuLyXacNhanOTP() async {
    final thongTinXacNhan = ThongTinXacNhanOTP(
      email: widget.email,
      maOTP: _boQuanLyOTP.text,
      matKhauMoi: _boQuanLyMatKhauMoi.text,
      xacNhanMatKhau: _boQuanLyXacNhanMatKhau.text,
    );

    setState(() => _dangTaiDuLieu = true);

    try {
      final ketQua = await _dichVuXacNhanOTP.xacNhanOTPVaCapNhatMatKhau(thongTinXacNhan);
      setState(() => _dangTaiDuLieu = false);

      if (mounted) {
        if (ketQua.thanhCong) {
          _hienThiThongBao(ketQua.thongBao);
          _xoaForm();
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
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

  void _xoaForm() {
    _boQuanLyOTP.clear();
    _boQuanLyMatKhauMoi.clear();
    _boQuanLyXacNhanMatKhau.clear();
    setState(() {
      _hienThiMatKhauMoi = false;
      _hienThiXacNhanMatKhau = false;
    });
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
        title: 'Xác nhận OTP',
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
                      child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 34),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text('Xác nhận & Đặt mật khẩu', style: AppText.title3)),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Nhập mã OTP và mật khẩu mới của bạn',
                      style: AppText.subhead.copyWith(color: AppColors.subLabel),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email info banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mã đã gửi đến:', style: AppText.caption.copyWith(color: AppColors.subLabel)),
                              const SizedBox(height: 2),
                              Text(widget.email, style: AppText.footnote.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OTP input section
                  IosSection(
                    title: 'Mã xác nhận',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nhập 6 chữ số từ email', style: AppText.footnote.copyWith(color: AppColors.subLabel)),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _boQuanLyOTP,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: AppText.title1.copyWith(letterSpacing: 10, color: AppColors.label),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                hintText: '000000',
                                hintStyle: AppText.title1.copyWith(
                                  letterSpacing: 10,
                                  color: AppColors.placeholder,
                                ),
                                filled: true,
                                fillColor: AppColors.fill,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                                counterText: '',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // New password section
                  IosSection(
                    title: 'Mật khẩu mới',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mật khẩu mới', style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.label2)),
                            const SizedBox(height: 8),
                            ONhapLieu(
                              boQuanLy: _boQuanLyMatKhauMoi,
                              goiY: '••••••••',
                              iconTrai: Icons.lock_outline_rounded,
                              laMatKhau: true,
                              hienThiMatKhau: _hienThiMatKhauMoi,
                              khiBatTatHienThiMatKhau: () => setState(() => _hienThiMatKhauMoi = !_hienThiMatKhauMoi),
                            ),
                            const SizedBox(height: 16),
                            Text('Xác nhận mật khẩu mới', style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.label2)),
                            const SizedBox(height: 8),
                            ONhapLieu(
                              boQuanLy: _boQuanLyXacNhanMatKhau,
                              goiY: '••••••••',
                              iconTrai: Icons.lock_outline_rounded,
                              laMatKhau: true,
                              hienThiMatKhau: _hienThiXacNhanMatKhau,
                              khiBatTatHienThiMatKhau: () => setState(() => _hienThiXacNhanMatKhau = !_hienThiXacNhanMatKhau),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.subLabel),
                                const SizedBox(width: 6),
                                Text(
                                  'Mật khẩu phải có chữ hoa, chữ thường và số',
                                  style: AppText.caption.copyWith(color: AppColors.subLabel, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  NutCapNhatMatKhau(dangTaiDuLieu: _dangTaiDuLieu, khiNhan: _xuLyXacNhanOTP),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nhớ lại mật khẩu? ', style: AppText.subhead.copyWith(color: AppColors.subLabel)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
