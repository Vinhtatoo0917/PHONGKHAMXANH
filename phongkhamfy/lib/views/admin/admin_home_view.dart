import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import 'quan_ly_lich_lam_viec_view.dart';
import 'quan_ly_lich_kham_view.dart';
import 'quan_ly_bac_si_view.dart';
import 'quan_ly_phong_kham_view.dart';
import 'quan_ly_ca_kham_view.dart';
import 'khoa_view.dart';
import 'benh_view.dart';
import 'dich_vu_view.dart';
import 'manage_thuoc_view.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/dialog_dang_xuat.dart';
import '../../widgets/loading_dang_xuat.dart';
import '../auth/login_view.dart';
import '../../theme/app_theme.dart';

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
  int _selectedIndex = 0;
  final _authService = DichVuXacThuc();
  final _dio = Dio();

  late Future<Map<String, dynamic>> _dashboardStats;
  late Future<bool> _hasNextDaySchedules;

  @override
  void initState() {
    super.initState();
    _dashboardStats = _fetchDashboardStats();
    _hasNextDaySchedules = _checkNextDaySchedules();
  }

  Future<Map<String, dynamic>> _fetchDashboardStats() async {
    try {
      final today = DateTime.now();
      final response = await _dio.get(
        ApiConfig.getFullUrl('/api/admin/dashboard-stats?date=${today.toIso8601String().split('T')[0]}'),
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        return response.data?['data'] ?? {};
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    }
    return {};
  }

  Future<bool> _checkNextDaySchedules() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final response = await _dio.get(
        ApiConfig.getFullUrl('/api/admin/doctor-schedules?date=${tomorrow.toIso8601String().split('T')[0]}'),
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final schedules = response.data?['data'] as List?;
        return schedules != null && schedules.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Error checking next day schedules: $e');
    }
    return true; // Mặc định true (không show warning) nếu không thể kiểm tra
  }

  void _onLogout() {
    DialogDangXuat.hienThi(
      context: context,
      onXacNhan: () async {
        LoadingDangXuat.hienThi(context: context);
        await _authService.dangXuat();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _selectedIndex == 0 ? _buildDashboard() : _buildAccountPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -1)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subLabel,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }

  // ─── DASHBOARD ─────────────────────────────────────────────────
  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            GreetingCard(
              greeting: 'Chào Quản trị viên,',
              name: widget.tenNguoiDung,
              subtitle: widget.email,
              trailing: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: _onLogout,
              ),
            ),

            const SizedBox(height: 20),
            _buildDashboardStats(),
            const SizedBox(height: 20),
            _buildNextDayWarning(),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('QUẢN LÝ HỆ THỐNG', style: AppText.caption.copyWith(
                color: AppColors.subLabel, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  IosMenuCard(
                    icon: Icons.event_available_rounded,
                    label: 'Lịch khám',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuanLyLichKhamView())),
                  ),
                  IosMenuCard(
                    icon: Icons.calendar_month_rounded,
                    label: 'Lịch làm việc',
                    color: AppColors.accent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuanLyLichLamViecView())),
                  ),
                  IosMenuCard(
                    icon: Icons.people_rounded,
                    label: 'Bác sĩ',
                    color: const Color(0xFF43A047),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuanLyBacSiView())),
                  ),
                  IosMenuCard(
                    icon: Icons.meeting_room_rounded,
                    label: 'Phòng khám',
                    color: const Color(0xFF7B1FA2),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuanLyPhongKhamView())),
                  ),
                  IosMenuCard(
                    icon: Icons.access_time_rounded,
                    label: 'Ca khám',
                    color: const Color(0xFF00897B),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuanLyCaKhamView())),
                  ),
                  IosMenuCard(
                    icon: Icons.school_rounded,
                    label: 'Khoa',
                    color: const Color(0xFF3949AB),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KhoaView())),
                  ),
                  IosMenuCard(
                    icon: Icons.local_hospital_rounded,
                    label: 'Bệnh',
                    color: const Color(0xFFE91E63),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BenhView())),
                  ),
                  IosMenuCard(
                    icon: Icons.medical_services_rounded,
                    label: 'Dịch vụ',
                    color: const Color(0xFF00ACC1),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DichVuView())),
                  ),
                  IosMenuCard(
                    icon: Icons.medication_rounded,
                    label: 'Thuốc',
                    color: const Color(0xFFF4511E),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageThuocView())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── ACCOUNT PAGE ──────────────────────────────────────────────
  Widget _buildAccountPage() {
    final today = DateFormat('EEEE, dd/MM/yyyy').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            InitialsAvatar(name: widget.tenNguoiDung, size: 80),
            const SizedBox(height: 12),
            Text(widget.tenNguoiDung, style: AppText.title3),
            const SizedBox(height: 4),
            StatusChip('Quản trị viên', AppColors.primary),
            const SizedBox(height: 4),
            Text(today, style: AppText.caption.copyWith(color: AppColors.subLabel)),

            const SizedBox(height: 28),

            IosSection(
              title: 'THÔNG TIN',
              children: [
                IosCell(
                  leading: _iconBox(Icons.email_rounded, AppColors.primary),
                  title: 'Email',
                  trailing: Text(widget.email,
                    style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  showSeparator: true,
                ),
                IosCell(
                  leading: _iconBox(Icons.shield_rounded, AppColors.primary),
                  title: 'Vai trò',
                  trailing: Text('Quản trị viên',
                    style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  showSeparator: false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: AppDecor.card,
                clipBehavior: Clip.hardEdge,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onLogout,
                    splashColor: AppColors.dangerBg,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          _iconBox(Icons.logout_rounded, AppColors.danger, bg: AppColors.dangerBg),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Đăng xuất', style: AppText.body.copyWith(color: AppColors.danger))),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.subLabel, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text('Phòng Khám FY v1.0', style: AppText.caption),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardStats,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};
        final lichKham = stats['lichKham'] ?? 0;
        final lichLamViec = stats['lichLamViec'] ?? 0;
        final bacSi = stats['bacSi'] ?? 0;
        final phongKham = stats['phongKham'] ?? 0;
        final caKham = stats['caKham'] ?? 0;
        final khoa = stats['khoa'] ?? 0;
        final benh = stats['benh'] ?? 0;
        final dichVu = stats['dichVu'] ?? 0;
        final thuoc = stats['thuoc'] ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HÔM NAY', style: AppText.caption.copyWith(
                color: AppColors.subLabel, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _statCard('Lịch khám', lichKham, Icons.event_available_rounded, AppColors.primary),
                  _statCard('Lịch làm việc', lichLamViec, Icons.calendar_month_rounded, AppColors.accent),
                  _statCard('Bác sĩ', bacSi, Icons.people_rounded, const Color(0xFF43A047)),
                  _statCard('Phòng khám', phongKham, Icons.meeting_room_rounded, const Color(0xFF7B1FA2)),
                  _statCard('Ca khám', caKham, Icons.access_time_rounded, const Color(0xFF00897B)),
                  _statCard('Khoa', khoa, Icons.school_rounded, const Color(0xFF3949AB)),
                  _statCard('Bệnh', benh, Icons.local_hospital_rounded, const Color(0xFFE91E63)),
                  _statCard('Dịch vụ', dichVu, Icons.medical_services_rounded, const Color(0xFF00ACC1)),
                  _statCard('Thuốc', thuoc, Icons.medication_rounded, const Color(0xFFF4511E)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(count.toString(), style: AppText.title3.copyWith(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: AppText.caption.copyWith(color: AppColors.subLabel), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNextDayWarning() {
    return FutureBuilder<bool>(
      future: _hasNextDaySchedules,
      builder: (context, snapshot) {
        final hasSchedules = snapshot.data ?? true;

        if (hasSchedules || snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final dateStr = DateFormat('dd/MM/yyyy').format(tomorrow);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.danger.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.danger, width: 1.5),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.danger.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.warning_rounded, color: AppColors.danger, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cần thêm lịch làm việc', style: AppText.footnote.copyWith(
                        color: AppColors.danger, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Ngày $dateStr chưa có lịch làm việc cho bác sĩ',
                        style: AppText.caption.copyWith(color: AppColors.danger.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBox(IconData icon, Color color, {Color? bg}) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: bg ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}
