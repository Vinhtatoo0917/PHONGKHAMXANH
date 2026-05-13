// ═══════════════════════════════════════════════════════════════
// FILE: man_hinh_xac_nhan_otp.dart
// MÔ TẢ: Màn hình xác nhận OTP và cập nhật mật khẩu mới
// ═══════════════════════════════════════════════════════════════

// Import thư viện Material Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import các widget tùy chỉnh
import '../../widgets/logo_phong_kham.dart';
import '../../widgets/o_nhap_lieu.dart';
import '../../widgets/nut_cap_nhat_mat_khau.dart';
import '../../widgets/hieu_ung_nen.dart';

// Import service xác nhận OTP
import '../../controllers/otp_controller.dart';

// ═══════════════════════════════════════════════════════════════
// CLASS: ManHinhXacNhanOTP
// MÔ TẢ: Màn hình xác nhận OTP và cập nhật mật khẩu
// LOẠI: StatefulWidget (có thể thay đổi trạng thái)
// ═══════════════════════════════════════════════════════════════
class ManHinhXacNhanOTP extends StatefulWidget {
  // Email được truyền từ màn hình quên mật khẩu
  final String email;

  const ManHinhXacNhanOTP({super.key, required this.email});

  @override
  State<ManHinhXacNhanOTP> createState() => _TrangThaiManHinhXacNhanOTP();
}

// ═══════════════════════════════════════════════════════════════
// CLASS: _TrangThaiManHinhXacNhanOTP
// MÔ TẢ: Quản lý trạng thái của màn hình xác nhận OTP
// ═══════════════════════════════════════════════════════════════
class _TrangThaiManHinhXacNhanOTP extends State<ManHinhXacNhanOTP> {
  // ─────────────────────────────────────────────────────────────
  // CÁC BIẾN TRẠNG THÁI
  // ─────────────────────────────────────────────────────────────

  // GlobalKey - Để truy cập và validate Form
  final _formKey = GlobalKey<FormState>();

  // TextEditingController - Quản lý nội dung TextField
  final _boQuanLyOTP = TextEditingController();
  final _boQuanLyMatKhauMoi = TextEditingController();
  final _boQuanLyXacNhanMatKhau = TextEditingController();

  // Biến boolean theo dõi trạng thái
  bool _dangTaiDuLieu = false; // Có đang loading không?
  bool _hienThiMatKhauMoi = false; // Có hiển thị mật khẩu mới không?
  bool _hienThiXacNhanMatKhau = false; // Có hiển thị xác nhận mật khẩu không?

  // Khởi tạo service xác nhận OTP
  final _dichVuXacNhanOTP = DichVuXacNhanOTP();

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
    // Giải phóng bộ nhớ của các controller
    _boQuanLyOTP.dispose();
    _boQuanLyMatKhauMoi.dispose();
    _boQuanLyXacNhanMatKhau.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM XỬ LÝ XÁC NHẬN OTP VÀ CẬP NHẬT MẬT KHẨU
  // ═══════════════════════════════════════════════════════════════
  Future<void> _xuLyXacNhanOTP() async {
    // ─────────────────────────────────────────────────────────────
    // BƯỚC 1: TẠO OBJECT THÔNG TIN XÁC NHẬN
    // ─────────────────────────────────────────────────────────────
    final thongTinXacNhan = ThongTinXacNhanOTP(
      email: widget.email,
      maOTP: _boQuanLyOTP.text,
      matKhauMoi: _boQuanLyMatKhauMoi.text,
      xacNhanMatKhau: _boQuanLyXacNhanMatKhau.text,
    );

    // ─────────────────────────────────────────────────────────────
    // BƯỚC 2: BẮT ĐẦU LOADING
    // ─────────────────────────────────────────────────────────────
    setState(() => _dangTaiDuLieu = true);

    try {
      // ─────────────────────────────────────────────────────────
      // BƯỚC 3: GỌI SERVICE XÁC NHẬN OTP
      // ─────────────────────────────────────────────────────────
      final ketQua = await _dichVuXacNhanOTP.xacNhanOTPVaCapNhatMatKhau(
        thongTinXacNhan,
      );

      // Tắt loading
      setState(() => _dangTaiDuLieu = false);

      // ─────────────────────────────────────────────────────────
      // BƯỚC 4: XỬ LÝ KẾT QUẢ
      // ─────────────────────────────────────────────────────────
      if (mounted) {
        if (ketQua.thanhCong) {
          // ✅ CẬP NHẬT THÀNH CÔNG
          _hienThiThongBao(ketQua.thongBao);
          _xoaForm(); // Xóa form

          // Chuyển về màn hình đăng nhập sau 3 giây
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              // Quay về màn hình đăng nhập (xóa tất cả màn hình trước đó)
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        } else {
          // ❌ CẬP NHẬT THẤT BẠI
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
  // HÀM XÓA FORM
  // ═══════════════════════════════════════════════════════════════
  void _xoaForm() {
    _boQuanLyOTP.clear();
    _boQuanLyMatKhauMoi.clear();
    _boQuanLyXacNhanMatKhau.clear();
    setState(() {
      _hienThiMatKhauMoi = false;
      _hienThiXacNhanMatKhau = false;
    });
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
                      // CARD XÁC NHẬN OTP
                      // ───────────────────────────────────────────────
                      _xayDungCardXacNhanOTP(laDienThoai),

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
  // HÀM XÂY DỰNG CARD XÁC NHẬN OTP
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungCardXacNhanOTP(bool laDienThoai) {
    // Tính toán kích thước responsive
    final paddingCard = laDienThoai ? 20.0 : 50.0; // Web: padding lớn hơn nhiều
    final kichThuocTieuDe = laDienThoai ? 22.0 : 32.0; // Web: tiêu đề lớn hơn
    final kichThuocMoTa = laDienThoai ? 13.0 : 16.0; // Web: mô tả lớn hơn
    final chieuCaoNut = laDienThoai ? 48.0 : 60.0; // Web: nút cao hơn
    final khoangCachField = laDienThoai
        ? 16.0
        : 24.0; // Web: khoảng cách lớn hơn

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
                    Icons.security_rounded,
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
                        'Xác Nhận OTP',
                        style: TextStyle(
                          fontSize: kichThuocTieuDe,
                          fontWeight: FontWeight.w800,
                          color: _mauChuChinh,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nhập mã và mật khẩu mới 🔐',
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
            // THÔNG TIN EMAIL
            // ───────────────────────────────────────────────────────
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
                    Icons.email_outlined,
                    color: _mauChinh,
                    size: laDienThoai ? 18 : 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã xác nhận đã được gửi đến:',
                          style: TextStyle(
                            fontSize: laDienThoai ? 12 : 14,
                            color: _mauChuPhu,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: laDienThoai ? 13 : 16,
                            fontWeight: FontWeight.w600,
                            color: _mauChuChinh,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: khoangCachField),

            // ───────────────────────────────────────────────────────
            // Ô NHẬP MÃ OTP
            // ───────────────────────────────────────────────────────
            _xayDungNhan('Mã xác nhận (6 số)', laDienThoai),
            SizedBox(height: laDienThoai ? 8 : 12),
            TextFormField(
              controller: _boQuanLyOTP,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: laDienThoai ? 20 : 24,
                fontWeight: FontWeight.w700,
                letterSpacing: laDienThoai ? 8 : 12,
                color: _mauChuChinh,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  color: _mauChuPhu.withValues(alpha: 0.3),
                  fontSize: laDienThoai ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: laDienThoai ? 8 : 12,
                ),
                filled: true,
                fillColor: _mauNen,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: laDienThoai ? 16 : 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _mauChinh.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _mauChinh.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _mauChinh, width: 2),
                ),
                counterText: '', // Ẩn counter text
              ),
            ),
            SizedBox(height: khoangCachField),

            // ───────────────────────────────────────────────────────
            // Ô NHẬP MẬT KHẨU MỚI
            // ───────────────────────────────────────────────────────
            _xayDungNhan('Mật khẩu mới', laDienThoai),
            SizedBox(height: laDienThoai ? 8 : 12),
            ONhapLieu(
              boQuanLy: _boQuanLyMatKhauMoi,
              goiY: '••••••••',
              iconTrai: Icons.lock_outline_rounded,
              laMatKhau: true,
              hienThiMatKhau: _hienThiMatKhauMoi,
              khiBatTatHienThiMatKhau: () {
                setState(() => _hienThiMatKhauMoi = !_hienThiMatKhauMoi);
              },
            ),
            SizedBox(height: khoangCachField),

            // ───────────────────────────────────────────────────────
            // Ô XÁC NHẬN MẬT KHẨU MỚI
            // ───────────────────────────────────────────────────────
            _xayDungNhan('Xác nhận mật khẩu mới', laDienThoai),
            SizedBox(height: laDienThoai ? 8 : 12),
            ONhapLieu(
              boQuanLy: _boQuanLyXacNhanMatKhau,
              goiY: '••••••••',
              iconTrai: Icons.lock_outline_rounded,
              laMatKhau: true,
              hienThiMatKhau: _hienThiXacNhanMatKhau,
              khiBatTatHienThiMatKhau: () {
                setState(
                  () => _hienThiXacNhanMatKhau = !_hienThiXacNhanMatKhau,
                );
              },
            ),
            SizedBox(height: laDienThoai ? 16 : 24),

            // ───────────────────────────────────────────────────────
            // HƯỚNG DẪN MẬT KHẨU
            // ───────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(laDienThoai ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(laDienThoai ? 12 : 16),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                    size: laDienThoai ? 16 : 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ cái và số',
                      style: TextStyle(
                        fontSize: laDienThoai ? 11 : 13,
                        color: Colors.blue.shade700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: laDienThoai ? 20 : 32),

            // ───────────────────────────────────────────────────────
            // NÚT CẬP NHẬT MẬT KHẨU
            // ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: chieuCaoNut,
              child: NutCapNhatMatKhau(
                dangTaiDuLieu: _dangTaiDuLieu,
                khiNhan: _xuLyXacNhanOTP,
              ),
            ),
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
            // Quay về màn hình đăng nhập (xóa tất cả màn hình trước đó)
            Navigator.of(context).popUntil((route) => route.isFirst);
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
