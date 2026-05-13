// ═══════════════════════════════════════════════════════════════
// FILE: admin_home_view.dart
// MÔ TẢ: Màn hình chính dành cho Admin
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'quan_ly_lich_lam_viec_view.dart';
import 'quan_ly_bac_si_view.dart';
import 'quan_ly_phong_kham_view.dart';
import 'quan_ly_ca_kham_view.dart';
import 'quan_ly_khoa_view.dart';
import 'quan_ly_benh_view.dart';
import 'quan_ly_dich_vu_view.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_view.dart';

class AdminHomeView extends StatefulWidget {
  final String tenNguoiDung;
  final String email;

  const AdminHomeView({
    super.key,
    required this.tenNguoiDung,
    required this.email,
  });

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final _dichVuXacThuc = DichVuXacThuc();

  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);

  // ─────────────────────────────────────────────────────────────
  // ĐĂNG XUẤT
  // ─────────────────────────────────────────────────────────────
  Future<void> _xuLyDangXuat() async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (xacNhan == true) {
      await _dichVuXacThuc.dangXuat();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
          (route) => false,
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // GIAO DIỆN
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mauNen,
      appBar: AppBar(
        title: const Text(
          'Quản Trị Viên',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Thông báo
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(onPressed: _xuLyDangXuat, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với thông tin admin
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _mauXanh,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _mauTrang,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 35,
                          color: _mauXanh,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào, ${widget.tenNguoiDung}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _mauTrang,
                              ),
                            ),
                            Text(
                              widget.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: _mauTrang.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tiêu đề
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Quản lý hệ thống',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _mauChuDen,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Grid menu - 3 cột, các nút nhỏ hơn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _xayDungMenuCard(
                    icon: Icons.calendar_month,
                    tieude: 'Lịch làm việc',
                    mau: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuanLyLichLamViecView(),
                        ),
                      );
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.people,
                    tieude: 'Bác sĩ',
                    mau: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuanLyBacSiView(),
                        ),
                      );
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.person_outline,
                    tieude: 'Bệnh nhân',
                    mau: Colors.orange,
                    onTap: () {
                      // TODO: Màn hình quản lý bệnh nhân
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.meeting_room,
                    tieude: 'Phòng khám',
                    mau: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuanLyPhongKhamView(),
                        ),
                      );
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.access_time,
                    tieude: 'Ca khám',
                    mau: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuanLyCaKhamView(),
                        ),
                      );
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.school,
                    tieude: 'Khoa',
                    mau: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuanLyKhoaView(),
                        ),
                      );
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.local_hospital,
                    tieude: 'Bệnh',
                    mau: Colors.pink,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuanLyBenhView(),
                        ),
                      );
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.medical_services,
                    tieude: 'Dịch vụ',
                    mau: Colors.cyan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuanLyDichVuView(),
                        ),
                      );
                    },
                  ),
                  _xayDungMenuCard(
                    icon: Icons.bar_chart,
                    tieude: 'Thống kê',
                    mau: Colors.red,
                    onTap: () {
                      // TODO: Màn hình thống kê
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _xayDungMenuCard({
    required IconData icon,
    required String tieude,
    required Color mau,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: _mauTrang,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: mau.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: mau.withValues(alpha: 0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mau.withValues(alpha: 0.2),
                      mau.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: mau.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 28, color: mau),
              ),
              const SizedBox(height: 10),
              Text(
                tieude,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _mauChuDen,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
