// ═══════════════════════════════════════════════════════════════
// FILE: forgot_password_view.dart
// MÔ TẢ: Màn hình quên mật khẩu
// ═══════════════════════════════════════════════════════════════

// Import thư viện Material Design
import 'package:flutter/material.dart';

// Import các widget tùy chỉnh
import '../../widgets/logo_phong_kham.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/nut_gui_ma_xac_nhan.dart';
import '../../widgets/hieu_ung_nen.dart';

// Import controller quên mật khẩu
import '../../controllers/password_controller.dart';

// Import màn hình xác nhận OTP
import 'verify_otp_view.dart';

// ═══════════════════════════════════════════════════════════════
// CLASS: ManHinhQuenMatKhau
// MÔ TẢ: Màn hình quên mật khẩu
// LOẠI: StatefulWidget (có thể thay đổi trạng thái)
// ═══════════════════════════════════════════════════════════════
class ManHinhQuenMatKhau extends StatefulWidget {
  const ManHinhQuenMatKhau({super.key});

  @override
  State<ManHinhQuenMatKhau> createState() => _TrangThaiManHinhQuenMatKhau();
}

// ═══════════════════════════════════════════════════════════════
// CLASS: _TrangThaiManHinhQuenMatKhau
// MÔ TẢ: Quản lý trạng thái của màn hình quên mật khẩu
// ═══════════════════════════════════════════════════════════════
class _TrangThaiManHinhQuenMatKhau extends State<ManHinhQuenMatKhau> {
  // ─────────────────────────────────────────────────────────────
  // CÁC BIẾN TRẠNG THÁI
  // ─────────────────────────────────────────────────────────────

  // GlobalKey - Để truy cập và validate Form
  final _formKey = GlobalKey<FormState>();

  // TextEditingController - Quản lý nội dung TextField
  final _boQuanLyEmail = TextEditingController();

  // Biến boolean theo dõi trạng thái
  bool _dangTaiDuLieu = false; // Có đang loading không?
  bool _daGuiMa = false; // Đã gửi mã xác nhận chưa?

  // Khởi tạo service quên mật khẩu
  final _dichVuQuenMatKhau = DichVuQuenMatKhau();

  // ─────────────────────────────────────────────────────────────
  // MÀU SẮC
  // ─────────────────────────────────────────────────────────────
  static const Color _mauChinh = Color(0xFF3DAA70);
  static const Color _mauNen = Color(0xFFF0FAF5);
  static const Color _mauBeMat = Colors.white;
  static const Color _mauChuChinh = Color(0xFF1A3D2E);
  static const Color _mauChuPhu = Color(0xFF5A8A70);

  // ═══════════════════════════════════════════════════════════════
  // HÀM DISPOSE - Dọn dẹp khi widget bị hủy
  // ═══════════════════════════════════════════════════════════════
  @override
  void dispose() {
    // Giải phóng bộ nhớ của controller
    _boQuanLyEmail.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM XỬ LÝ GỬI MÃ XÁC NHẬN
  // ═══════════════════════════════════════════════════════════════
  Future<void> _xuLyGuiMaXacNhan() async {
    // ─────────────────────────────────────────────────────────────
    // BƯỚC 1: LẤY EMAIL TỪ TEXTFIELD
    // ─────────────────────────────────────────────────────────────
    final email = _boQuanLyEmail.text.trim();

    // ─────────────────────────────────────────────────────────────
    // BƯỚC 2: BẮT ĐẦU LOADING
    // ─────────────────────────────────────────────────────────────
    setState(() => _dangTaiDuLieu = true);

    try {
      // ─────────────────────────────────────────────────────────
      // BƯỚC 3: GỌI SERVICE GỬI MÃ XÁC NHẬN
      // ─────────────────────────────────────────────────────────
      final ketQua = await _dichVuQuenMatKhau.guiMaXacNhan(email);

      // Tắt loading
      setState(() => _dangTaiDuLieu = false);

      // ─────────────────────────────────────────────────────────
      // BƯỚC 4: XỬ LÝ KẾT QUẢ
      // ─────────────────────────────────────────────────────────
      if (mounted) {
        if (ketQua.thanhCong) {
          // ✅ GỬI MÃ THÀNH CÔNG
          setState(() => _daGuiMa = true);
          _hienThiThongBao(ketQua.thongBao);

          // Chuyển sang màn hình xác nhận OTP sau 2 giây
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManHinhXacNhanOTP(email: email),
                ),
              );
            }
          });
        } else {
          // ❌ GỬI MÃ THẤT BẠI
          _hienThiThongBao(ketQua.thongBao, laThatBai: true);
        }
      }
    } catch (e) {
      // ─────────────────────────────────────────────────────────
      // XỬ LÝ LỖI BẤT NGỜ
      // ─────────────────────────────────────────────────────────
      setState(() => _dangTaiDuLieu = false);

      if (mounted) {
        _hienThiThongBao('Có lỗi xảy ra: $e', laThatBai: true);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM HIỂN THỊ THÔNG BÁO
  // ═══════════════════════════════════════════════════════════════
  void _hienThiThongBao(String noiDung, {bool laThatBai = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung),
        backgroundColor: laThatBai ? Colors.redAccent : _mauChinh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(
          seconds: laThatBai ? 4 : 5,
        ), // Thông báo thành công hiện lâu hơn
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM BUILD - Xây dựng giao diện
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;

    // Xác định loại thiết bị dựa trên chiều rộng
    final laDienThoai = size.width < 600; // < 600px = điện thoại

    // Tính toán padding và kích thước responsive
    double paddingNgang;
    double paddingDoc;
    double maxWidth;

    if (laDienThoai) {
      paddingNgang = 16; // Điện thoại: padding nhỏ
      paddingDoc = 20;
      maxWidth = double.infinity;
    } else {
      paddingNgang = 100; // Web: padding lớn hơn nhiều
      paddingDoc = 60;
      maxWidth = 600; // Web: chiều rộng lớn hơn nhiều
    }

    return Scaffold(
      backgroundColor: _mauNen,
      // ─────────────────────────────────────────────────────────────
      // APP BAR (thanh tiêu đề)
      // ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _mauBeMat,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _mauChinh.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _mauChuChinh,
              size: laDienThoai ? 18 : 20,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ─────────────────────────────────────────────────────────
          // HIỆU ỨNG NỀN (Các vòng tròn trang trí)
          // ─────────────────────────────────────────────────────────
          const HieuUngNen(),

          // ─────────────────────────────────────────────────────────
          // NỘI DUNG CHÍNH
          // ─────────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minHeight: size.height - 200, // Đảm bảo chiều cao tối thiểu
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingNgang,
                    vertical: paddingDoc,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ───────────────────────────────────────────────
                      // LOGO VÀ TÊN PHÒNG KHÁM
                      // ───────────────────────────────────────────────
                      _xayDungLogo(laDienThoai),
                      SizedBox(height: laDienThoai ? 24 : 36),

                      // ───────────────────────────────────────────────
                      // CARD QUÊN MẬT KHẨU
                      // ───────────────────────────────────────────────
                      _xayDungCardQuenMatKhau(laDienThoai),

                      SizedBox(height: laDienThoai ? 16 : 24),

                      // ───────────────────────────────────────────────
                      // NÚT QUAY LẠI ĐĂNG NHẬP
                      // ───────────────────────────────────────────────
                      _xayDungNutQuayLaiDangNhap(laDienThoai),
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

  // ═══════════════════════════════════════════════════════════════
  // HÀM XÂY DỰNG LOGO RESPONSIVE
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungLogo(bool laDienThoai) {
    return Transform.scale(
      scale: laDienThoai ? 0.9 : 1.0, // Logo nhỏ hơn trên điện thoại
      child: const LogoPhongKham(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM XÂY DỰNG CARD QUÊN MẬT KHẨU
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungCardQuenMatKhau(bool laDienThoai) {
    // Tính toán kích thước responsive
    final paddingCard = laDienThoai ? 20.0 : 50.0; // Web: padding lớn hơn nhiều
    final kichThuocTieuDe = laDienThoai ? 22.0 : 32.0; // Web: tiêu đề lớn hơn
    final kichThuocMoTa = laDienThoai ? 13.0 : 16.0; // Web: mô tả lớn hơn
    final chieuCaoNut = laDienThoai ? 48.0 : 60.0; // Web: nút cao hơn

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(paddingCard),
      decoration: BoxDecoration(
        color: _mauBeMat,
        borderRadius: BorderRadius.circular(laDienThoai ? 20 : 28),
        boxShadow: [
          BoxShadow(
            color: _mauChinh.withValues(alpha: 0.10),
            blurRadius: laDienThoai ? 20 : 40,
            offset: Offset(0, laDienThoai ? 6 : 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: laDienThoai ? 5 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────────────────────────────────────────────────
            // ICON VÀ TIÊU ĐỀ
            // ───────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(laDienThoai ? 12 : 16),
                  decoration: BoxDecoration(
                    color: _mauChinh.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(laDienThoai ? 12 : 16),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: _mauChinh,
                    size: laDienThoai ? 24 : 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quên Mật Khẩu',
                        style: TextStyle(
                          fontSize: kichThuocTieuDe,
                          fontWeight: FontWeight.w800,
                          color: _mauChuChinh,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Khôi phục tài khoản của bạn 🔐',
                        style: TextStyle(
                          fontSize: kichThuocMoTa,
                          color: _mauChuPhu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: laDienThoai ? 20 : 32),

            // ───────────────────────────────────────────────────────
            // HƯỚNG DẪN
            // ───────────────────────────────────────────────────────
            if (!_daGuiMa) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(laDienThoai ? 12 : 20),
                decoration: BoxDecoration(
                  color: _mauChinh.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(laDienThoai ? 12 : 16),
                  border: Border.all(
                    color: _mauChinh.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: _mauChinh,
                      size: laDienThoai ? 18 : 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nhập email đã đăng ký để nhận mã xác nhận khôi phục mật khẩu',
                        style: TextStyle(
                          fontSize: laDienThoai ? 12 : 15,
                          color: _mauChuChinh,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: laDienThoai ? 16 : 24),
            ],

            // ───────────────────────────────────────────────────────
            // Ô NHẬP EMAIL
            // ───────────────────────────────────────────────────────
            _xayDungNhan('Email đã đăng ký', laDienThoai),
            SizedBox(height: laDienThoai ? 8 : 12),
            ONhapLieu(
              boQuanLy: _boQuanLyEmail,
              goiY: 'example@phongkham.vn',
              iconTrai: Icons.email_outlined,
              loaiBanPhim: TextInputType.emailAddress,
              kichHoat: !_daGuiMa, // Disable nếu đã gửi mã
            ),
            SizedBox(height: laDienThoai ? 20 : 32),

            // ───────────────────────────────────────────────────────
            // NÚT GỬI MÃ XÁC NHẬN
            // ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: chieuCaoNut,
              child: _daGuiMa
                  // Nếu đã gửi mã → hiển thị nút "Gửi lại mã"
                  ? OutlinedButton.icon(
                      onPressed: _dangTaiDuLieu
                          ? null
                          : () {
                              setState(() => _daGuiMa = false);
                              _xuLyGuiMaXacNhan();
                            },
                      icon: _dangTaiDuLieu
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: _mauChinh,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              size: laDienThoai ? 16 : 18,
                              color: _mauChinh,
                            ),
                      label: Text(
                        _dangTaiDuLieu ? 'Đang gửi...' : 'Gửi lại mã',
                        style: TextStyle(
                          fontSize: laDienThoai ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: _mauChinh,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _mauChinh, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            laDienThoai ? 12 : 16,
                          ),
                        ),
                      ),
                    )
                  // Nếu chưa gửi mã → hiển thị nút "Gửi mã xác nhận"
                  : NutGuiMaXacNhan(
                      dangTaiDuLieu: _dangTaiDuLieu,
                      khiNhan: _xuLyGuiMaXacNhan,
                    ),
            ),

            // ───────────────────────────────────────────────────────
            // THÔNG BÁO ĐÃ GỬI MÃ
            // ───────────────────────────────────────────────────────
            if (_daGuiMa) ...[
              SizedBox(height: laDienThoai ? 16 : 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(laDienThoai ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(laDienThoai ? 12 : 16),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: laDienThoai ? 18 : 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã xác nhận đã được gửi!',
                            style: TextStyle(
                              fontSize: laDienThoai ? 13 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vui lòng kiểm tra email và làm theo hướng dẫn để khôi phục mật khẩu.',
                            style: TextStyle(
                              fontSize: laDienThoai ? 11 : 12,
                              color: Colors.green.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM XÂY DỰNG NHÃN (Label)
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungNhan(String chuoi, bool laDienThoai) {
    return Text(
      chuoi,
      style: TextStyle(
        fontSize: laDienThoai ? 12 : 15, // Web: font lớn hơn
        fontWeight: FontWeight.w600,
        color: _mauChuChinh,
        letterSpacing: 0.2,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM XÂY DỰNG NÚT QUAY LẠI ĐĂNG NHẬP
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungNutQuayLaiDangNhap(bool laDienThoai) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nhớ lại mật khẩu? ',
          style: TextStyle(fontSize: laDienThoai ? 13 : 14, color: _mauChuPhu),
        ),
        TextButton(
          onPressed: () {
            // Quay lại màn hình đăng nhập
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Đăng nhập ngay',
            style: TextStyle(
              fontSize: laDienThoai ? 13 : 14,
              color: _mauChinh,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
