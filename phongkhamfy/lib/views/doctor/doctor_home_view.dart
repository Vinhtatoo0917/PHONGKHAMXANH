import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/controllers/auth_controller.dart';
import 'package:phongkhamfy/views/auth/login_view.dart';
import 'package:phongkhamfy/views/doctor/lich_kham_bac_si_view.dart';
import 'package:phongkhamfy/widgets/dialog_dang_xuat.dart';
import 'package:phongkhamfy/widgets/loading_dang_xuat.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';
import 'package:intl/intl.dart';

class DoctorHomeView extends StatefulWidget {
  final String tenNguoiDung;
  final String email;

  const DoctorHomeView({super.key, required this.tenNguoiDung, required this.email});

  @override
  State<DoctorHomeView> createState() => _DoctorHomeViewState();
}

class _DoctorHomeViewState extends State<DoctorHomeView> {
  int _selectedIndex = 0;
  final _authService = DichVuXacThuc();
  final controller = Get.put(LichKhamController());

  static const _primary = Color(0xFF0D47A1);
  static const _accent = Color(0xFF1976D2);
  static const _bg = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _loadTodayStats();
  }

  void _loadTodayStats() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controller.getDoctorSchedule(ngayBatDau: today, ngayKetThuc: today);
  }

  void _onLogout() {
    DialogDangXuat.hienThi(
      context: context,
      onXacNhan: () async {
        LoadingDangXuat.hienThi(
          context: context,
          mauChinh: _primary,
          mauBeMat: Colors.white,
          mauChuChinh: const Color(0xFF2C3E50),
          mauChuPhu: Colors.grey,
        );
        await _authService.dangXuat();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
            (route) => false,
          );
        }
      },
      mauChinh: _primary,
      mauError: Colors.redAccent,
      mauBeMat: Colors.white,
      mauChuChinh: const Color(0xFF2C3E50),
      mauChuPhu: Colors.grey,
      mauVien: Colors.grey.withValues(alpha: 0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _selectedIndex == 0 ? _buildDashboard() : const LichKhamBacSiView(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: _primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_ind_rounded), label: 'Công việc'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: _primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -50,
                    top: -50,
                    child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withValues(alpha: 0.05)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.medical_services_rounded, color: _primary, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chào Bác sĩ,',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                                  ),
                                  Text(
                                    widget.tenNguoiDung,
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _onLogout,
                              icon: const Icon(Icons.logout_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thống kê hôm nay'),
                const SizedBox(height: 16),
                Obx(() {
                  final schedules = controller.doctorSchedules;
                  int total = 0;
                  int completed = 0;
                  
                  if (schedules.isNotEmpty) {
                    final patients = schedules[0]['LichKham'] as List? ?? [];
                    total = patients.length;
                    completed = patients.where((p) => p['TrangThai'] == 'completed').length;
                  }

                  return Row(
                    children: [
                      Expanded(child: _buildStatCard('Bệnh nhân', total.toString(), Icons.people_rounded, Colors.orange)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Hoàn thành', completed.toString(), Icons.check_circle_rounded, Colors.green)),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                _buildSectionTitle('Truy cập nhanh'),
                const SizedBox(height: 16),
                _buildQuickAction(
                  'Công việc khám của tôi',
                  'Xem danh sách bệnh nhân đang chờ và đã khám',
                  Icons.assignment_ind_rounded,
                  Colors.blue,
                  () => setState(() => _selectedIndex = 1),
                ),
                _buildQuickAction(
                  'Hồ sơ bệnh nhân',
                  'Tra cứu lịch sử bệnh án và các kết quả',
                  Icons.folder_shared_rounded,
                  Colors.purple,
                  () {},
                ),
                _buildQuickAction(
                  'Tin nhắn & Hỗ trợ',
                  'Liên hệ với điều phối viên hoặc bệnh nhân',
                  Icons.chat_rounded,
                  Colors.teal,
                  () {},
                ),
              ],
            ),
          ),
        ),
       slivers_footer(), // Placeholder for end of scroll
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50)),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget slivers_footer() => const SliverPadding(padding: EdgeInsets.only(bottom: 30));
}
