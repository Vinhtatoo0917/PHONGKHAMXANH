// ═══════════════════════════════════════════════════════════════
// FILE: home_view.dart
// MÔ TẢ: Màn hình trang chủ - ĐÃ TỐI ƯU HIỆU SUẤT
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../auth/login_view.dart';
import '../../widgets/dialog_dang_xuat.dart';
import '../../widgets/loading_dang_xuat.dart';

// ═══════════════════════════════════════════════════════════════
// WIDGET CHÍNH: Màn hình trang chủ
// ═══════════════════════════════════════════════════════════════
class ManHinhTrangChu extends StatefulWidget {
  final String tenNguoiDung;
  final String email;
  final String? vaiTro;

  const ManHinhTrangChu({
    super.key,
    required this.tenNguoiDung,
    required this.email,
    this.vaiTro,
  });

  @override
  State<ManHinhTrangChu> createState() => _TrangThaiManHinhTrangChu();
}

// ═══════════════════════════════════════════════════════════════
// STATE: Quản lý trạng thái
// ═══════════════════════════════════════════════════════════════
class _TrangThaiManHinhTrangChu extends State<ManHinhTrangChu> {
  int _selectedBottomIndex = 0;

  // Màu sắc
  static const Color _mauChinh = Color(0xFF00C896);
  static const Color _mauChinhDam = Color(0xFF00A67E);
  static const Color _mauNen = Color(0xFFF8FFFE);
  static const Color _mauBeMat = Colors.white;
  static const Color _mauChuChinh = Color(0xFF1A2B3D);
  static const Color _mauChuPhu = Color(0xFF6B7C8A);
  static const Color _mauError = Color(0xFFFF7043);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final laDienThoai = size.width < 600;

    return Scaffold(
      backgroundColor: _mauNen,
      appBar: _xayDungAppBar(laDienThoai),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(laDienThoai ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin người dùng
            _xayDungThongTinNguoiDung(laDienThoai),
            const SizedBox(height: 24),

            // Thống kê
            _xayDungThongKe(laDienThoai),
            const SizedBox(height: 24),

            // Chức năng
            _xayDungChucNang(laDienThoai),
          ],
        ),
      ),
      bottomNavigationBar: _xayDungBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _hienThongBao('Hỗ trợ khẩn cấp'),
        backgroundColor: _mauError,
        child: const Icon(Icons.emergency_rounded, color: Colors.white),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════
  PreferredSizeWidget _xayDungAppBar(bool laDienThoai) {
    return AppBar(
      backgroundColor: _mauChinh,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phòng Khám Xanh',
            style: TextStyle(
              fontSize: laDienThoai ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            'Chăm sóc sức khỏe',
            style: TextStyle(
              fontSize: laDienThoai ? 12 : 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
        ),
        IconButton(
          onPressed: _hienDialogDangXuat,
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // THÔNG TIN NGƯỜI DÙNG
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungThongTinNguoiDung(bool laDienThoai) {
    return Container(
      padding: EdgeInsets.all(laDienThoai ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_mauChinh, _mauChinhDam],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: laDienThoai ? 24 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${widget.tenNguoiDung}! 👋',
                  style: TextStyle(
                    fontSize: laDienThoai ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _layMoTaVaiTro(),
                  style: TextStyle(
                    fontSize: laDienThoai ? 13 : 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // THỐNG KÊ
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungThongKe(bool laDienThoai) {
    final thongKe = _layThongKe();

    return Row(
      children: thongKe.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: EdgeInsets.all(laDienThoai ? 12 : 16),
            decoration: BoxDecoration(
              color: _mauBeMat,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: item['mau'].withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(item['icon'], color: item['mau'], size: 24),
                const SizedBox(height: 8),
                Text(
                  item['giaTri'],
                  style: TextStyle(
                    fontSize: laDienThoai ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: _mauChuChinh,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['donVi'],
                  style: TextStyle(
                    fontSize: laDienThoai ? 10 : 11,
                    color: _mauChuPhu,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CHỨC NĂNG
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungChucNang(bool laDienThoai) {
    final chucNang = _layChucNang();

    return Container(
      padding: EdgeInsets.all(laDienThoai ? 16 : 20),
      decoration: BoxDecoration(
        color: _mauBeMat,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dịch vụ y tế',
            style: TextStyle(
              fontSize: laDienThoai ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: _mauChuChinh,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: laDienThoai ? 3 : 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: chucNang.length,
            itemBuilder: (context, index) {
              final item = chucNang[index];
              return InkWell(
                onTap: () => _hienThongBao(item['ten']),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item['mau'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], color: item['mau'], size: 28),
                      const SizedBox(height: 8),
                      Text(
                        item['ten'],
                        style: TextStyle(
                          fontSize: laDienThoai ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: _mauChuChinh,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM NAVIGATION
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: _mauBeMat,
      selectedItemColor: _mauChinh,
      unselectedItemColor: _mauChuPhu,
      currentIndex: _selectedBottomIndex,
      onTap: (index) => setState(() => _selectedBottomIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Lịch hẹn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DỮ LIỆU
  // ═══════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _layThongKe() {
    final vaiTro = widget.vaiTro ?? 'benh_nhan';

    if (vaiTro == 'bac_si') {
      return [
        {
          'giaTri': '8',
          'donVi': 'bệnh nhân',
          'icon': Icons.people_rounded,
          'mau': _mauChinh,
        },
        {
          'giaTri': '2',
          'donVi': 'ca cấp cứu',
          'icon': Icons.emergency_rounded,
          'mau': _mauError,
        },
        {
          'giaTri': '5',
          'donVi': 'đơn thuốc',
          'icon': Icons.medication_rounded,
          'mau': const Color(0xFF6C5CE7),
        },
      ];
    } else {
      return [
        {
          'giaTri': '2',
          'donVi': 'lịch hẹn',
          'icon': Icons.calendar_today_rounded,
          'mau': _mauChinh,
        },
        {
          'giaTri': '1',
          'donVi': 'kết quả mới',
          'icon': Icons.new_releases_rounded,
          'mau': const Color(0xFF6C5CE7),
        },
        {
          'giaTri': '3',
          'donVi': 'thông báo',
          'icon': Icons.notifications_rounded,
          'mau': const Color(0xFFFFB74D),
        },
      ];
    }
  }

  List<Map<String, dynamic>> _layChucNang() {
    final vaiTro = widget.vaiTro ?? 'benh_nhan';

    if (vaiTro == 'bac_si') {
      return [
        {'ten': 'Lịch khám', 'icon': Icons.today_rounded, 'mau': _mauChinh},
        {
          'ten': 'Bệnh nhân',
          'icon': Icons.people_alt_rounded,
          'mau': const Color(0xFF4ECDC4),
        },
        {
          'ten': 'Kê đơn',
          'icon': Icons.medication_liquid_rounded,
          'mau': const Color(0xFF45B7D1),
        },
        {
          'ten': 'Chẩn đoán',
          'icon': Icons.medical_services_rounded,
          'mau': const Color(0xFFFF9500),
        },
        {
          'ten': 'Hồ sơ',
          'icon': Icons.folder_shared_rounded,
          'mau': const Color(0xFF5AC8FA),
        },
        {
          'ten': 'Xét nghiệm',
          'icon': Icons.biotech_rounded,
          'mau': const Color(0xFF6C5CE7),
        },
      ];
    } else {
      return [
        {
          'ten': 'Đặt lịch',
          'icon': Icons.calendar_today_rounded,
          'mau': _mauChinh,
        },
        {
          'ten': 'Hồ sơ',
          'icon': Icons.folder_copy_rounded,
          'mau': const Color(0xFF4ECDC4),
        },
        {
          'ten': 'Xét nghiệm',
          'icon': Icons.science_rounded,
          'mau': const Color(0xFF45B7D1),
        },
        {
          'ten': 'Thanh toán',
          'icon': Icons.payment_rounded,
          'mau': const Color(0xFFFF9500),
        },
        {
          'ten': 'Lịch sử',
          'icon': Icons.history_rounded,
          'mau': const Color(0xFF5AC8FA),
        },
        {
          'ten': 'Tư vấn',
          'icon': Icons.video_call_rounded,
          'mau': const Color(0xFF6C5CE7),
        },
      ];
    }
  }

  String _layMoTaVaiTro() {
    final vaiTro = widget.vaiTro ?? 'benh_nhan';
    switch (vaiTro) {
      case 'bac_si':
        return 'Bác sĩ';
      case 'admin':
        return 'Quản trị viên';
      default:
        return 'Bệnh nhân';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HIỂN THỊ THÔNG BÁO
  // ═══════════════════════════════════════════════════════════════
  void _hienThongBao(String noiDung) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang truy cập: $noiDung'),
        backgroundColor: _mauChinh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DIALOG ĐĂNG XUẤT
  // ═══════════════════════════════════════════════════════════════
  void _hienDialogDangXuat() {
    DialogDangXuat.hienThi(
      context: context,
      onXacNhan: _dangXuat,
      mauChinh: _mauChinh,
      mauError: _mauError,
      mauBeMat: _mauBeMat,
      mauChuChinh: _mauChuChinh,
      mauChuPhu: _mauChuPhu,
      mauVien: const Color(0xFFE8F4F1),
    );
  }

  void _dangXuat() {
    LoadingDangXuat.hienThi(
      context: context,
      mauChinh: _mauChinh,
      mauBeMat: _mauBeMat,
      mauChuChinh: _mauChuChinh,
      mauChuPhu: _mauChuPhu,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
          (route) => false,
        );
      }
    });
  }
}
