import 'package:flutter/material.dart';
import '../../widgets/logo_phong_kham.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/nut_dang_nhap.dart';
import '../../widgets/loading_overlay.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';
import '../home/home_view.dart';
import '../admin/admin_home_view.dart';
import '../doctor/doctor_home_view.dart';
import '../cashier/cashier_home_view.dart';

class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({super.key});

  @override
  State<ManHinhDangNhap> createState() => _TrangThaiManHinhDangNhap();
}

class _TrangThaiManHinhDangNhap extends State<ManHinhDangNhap> {
  final _khoaForm = GlobalKey<FormState>();
  final _oNhapEmail = TextEditingController();
  final _oNhapMatKhau = TextEditingController();
  final _dichVuDangNhap = DichVuXacThuc();

  bool _coHienMatKhau = false;
  bool _dangXuLy = false;
  bool _coGhiNho = false;

  @override
  void dispose() {
    _oNhapEmail.dispose();
    _oNhapMatKhau.dispose();
    super.dispose();
  }

  Future<void> _xuLyKhiNhanNutDangNhap() async {
    setState(() => _dangXuLy = true);
    try {
      final ketQua = await _dichVuDangNhap.dangNhap(
        _oNhapEmail.text,
        _oNhapMatKhau.text,
      );
      setState(() => _dangXuLy = false);
      if (mounted) {
        if (ketQua.thanhCong) {
          final thongTinUser = ketQua.thongTinNguoiDung!;
          final tenHienThi = thongTinUser['ten'] ?? thongTinUser['name'] ?? thongTinUser['sdt'] ?? 'Người dùng';
          _hienThongBao('Đăng nhập thành công! Chào $tenHienThi', isError: false);
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) _chuyenSangManHinhChinh(thongTinUser);
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

  void _chuyenSangManHinhChinh(Map<String, dynamic> thongTinNguoiDung) {
    final vaiTro = thongTinNguoiDung['VaiTro'] ?? 'BenhNhan';
    print('🔍 [DEBUG] VaiTro từ API: "$vaiTro"');

    if (vaiTro.toString().toLowerCase() == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => AdminHomeView(
          tenNguoiDung: thongTinNguoiDung['email'] ?? thongTinNguoiDung['sdt'] ?? 'Admin',
          email: thongTinNguoiDung['email'] ?? thongTinNguoiDung['sdt'] ?? '',
        ),
      ));
    } else if (vaiTro.toString().toLowerCase() == 'bacsi') {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => DoctorHomeView(
          tenNguoiDung: thongTinNguoiDung['ten'] ?? thongTinNguoiDung['name'] ?? 'Bác sĩ',
          email: thongTinNguoiDung['email'] ?? thongTinNguoiDung['sdt'] ?? '',
        ),
      ));
    } else if (vaiTro.toString().toLowerCase() == 'thungan') {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => const CashierHomeView(),
      ));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => HomeView(
          tenNguoiDung: thongTinNguoiDung['ten'] ?? thongTinNguoiDung['name'] ?? 'Người dùng',
          email: thongTinNguoiDung['email'] ?? thongTinNguoiDung['sdt'] ?? '',
        ),
      ));
    }
  }

  void _hienDialogThongTinTaiKhoan() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thông tin đăng nhập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SĐT: 9012345678', style: AppText.body),
            const SizedBox(height: 4),
            Text('Mật khẩu: 123456', style: AppText.body),
          ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tự động điền', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                  const SizedBox(height: 48),

                  // Logo
                  const Center(child: LogoPhongKham()),

                  const SizedBox(height: 40),

                  // Form card
                  _buildFormCard(),

                  const SizedBox(height: 20),

                  // Đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Chưa có tài khoản? ', style: AppText.subhead.copyWith(color: AppColors.subLabel)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManHinhDangKy())),
                        child: Text('Đăng ký', style: AppText.subhead.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Demo info
                  Center(
                    child: TextButton.icon(
                      onPressed: _hienDialogThongTinTaiKhoan,
                      icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.subLabel),
                      label: Text('Xem tài khoản demo', style: AppText.footnote.copyWith(color: AppColors.subLabel)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.placeholder),
                        const SizedBox(width: 4),
                        Text('Kết nối bảo mật SSL', style: AppText.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text('© 2025 Phòng Khám FY', style: AppText.caption)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: AppDecor.card,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đăng Nhập', style: AppText.title2),
          const SizedBox(height: 4),
          Text('Chào mừng bạn quay trở lại 👋', style: AppText.subhead.copyWith(color: AppColors.subLabel)),

          const SizedBox(height: 24),

          // SĐT
          Text('Số điện thoại', style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.label2)),
          const SizedBox(height: 6),
          ONhapLieu(
            boQuanLy: _oNhapEmail,
            goiY: '0901234567',
            iconTrai: Icons.phone_outlined,
            loaiBanPhim: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          // Mật khẩu
          Text('Mật khẩu', style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.label2)),
          const SizedBox(height: 6),
          ONhapLieu(
            boQuanLy: _oNhapMatKhau,
            goiY: '••••••••',
            iconTrai: Icons.lock_outline_rounded,
            laMatKhau: true,
            hienThiMatKhau: _coHienMatKhau,
            khiBatTatHienThiMatKhau: () => setState(() => _coHienMatKhau = !_coHienMatKhau),
          ),

          const SizedBox(height: 12),

          // Ghi nhớ & Quên MK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.scale(
                    scale: 0.85,
                    child: Checkbox(
                      value: _coGhiNho,
                      onChanged: (v) => setState(() => _coGhiNho = v!),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  Text('Ghi nhớ', style: AppText.footnote.copyWith(color: AppColors.label)),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManHinhQuenMatKhau())),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text('Quên mật khẩu?', style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Nút đăng nhập
          NutDangNhap(dangTaiDuLieu: _dangXuLy, khiNhan: _xuLyKhiNhanNutDangNhap),
        ],
      ),
    );
  }
}
