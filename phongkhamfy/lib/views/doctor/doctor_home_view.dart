import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/controllers/auth_controller.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:phongkhamfy/views/auth/login_view.dart';
import 'package:phongkhamfy/views/doctor/lich_kham_bac_si_view.dart';
import 'package:phongkhamfy/views/doctor/xet_nghiem_view.dart';
import 'package:phongkhamfy/widgets/dialog_dang_xuat.dart';
import 'package:phongkhamfy/widgets/loading_dang_xuat.dart';
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
  final _sessionManager = SessionManager();

  bool _isTestingSpecialist = false;

  static const _primary = Color(0xFF0D47A1);
  static const _accent = Color(0xFF1976D2);
  static const _bg = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _loadDoctorSpecialty();
  }

  void _loadTodayStats() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controller.getDoctorSchedule(ngayBatDau: today, ngayKetThuc: today);
  }

  Future<void> _loadDoctorSpecialty() async {
    final userInfo = await _sessionManager.getUserInfo();
    final rawSpecialty =
        (userInfo?['ChuyenKhoa'] ?? userInfo?['chuyenKhoa'] ?? userInfo?['TenKhoa'] ?? '').toString();
    final normalized = _normalizeText(rawSpecialty);
    final isTesting = normalized.contains('xet nghiem');

    if (!mounted) return;
    setState(() {
      _isTestingSpecialist = isTesting;
    });

    if (!isTesting) {
      _loadTodayStats();
    }
  }

  String _normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll('đ', 'd')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ả', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ạ', 'a')
        .replaceAll('ă', 'a')
        .replaceAll('ắ', 'a')
        .replaceAll('ằ', 'a')
        .replaceAll('ẳ', 'a')
        .replaceAll('ẵ', 'a')
        .replaceAll('ặ', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ấ', 'a')
        .replaceAll('ầ', 'a')
        .replaceAll('ẩ', 'a')
        .replaceAll('ẫ', 'a')
        .replaceAll('ậ', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ẻ', 'e')
        .replaceAll('ẽ', 'e')
        .replaceAll('ẹ', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ế', 'e')
        .replaceAll('ề', 'e')
        .replaceAll('ể', 'e')
        .replaceAll('ễ', 'e')
        .replaceAll('ệ', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ỉ', 'i')
        .replaceAll('ĩ', 'i')
        .replaceAll('ị', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ỏ', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ọ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ố', 'o')
        .replaceAll('ồ', 'o')
        .replaceAll('ổ', 'o')
        .replaceAll('ỗ', 'o')
        .replaceAll('ộ', 'o')
        .replaceAll('ơ', 'o')
        .replaceAll('ớ', 'o')
        .replaceAll('ờ', 'o')
        .replaceAll('ở', 'o')
        .replaceAll('ỡ', 'o')
        .replaceAll('ợ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ủ', 'u')
        .replaceAll('ũ', 'u')
        .replaceAll('ụ', 'u')
        .replaceAll('ư', 'u')
        .replaceAll('ứ', 'u')
        .replaceAll('ừ', 'u')
        .replaceAll('ử', 'u')
        .replaceAll('ữ', 'u')
        .replaceAll('ự', 'u')
        .replaceAll('ý', 'y')
        .replaceAll('ỳ', 'y')
        .replaceAll('ỷ', 'y')
        .replaceAll('ỹ', 'y')
        .replaceAll('ỵ', 'y')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
      if (!_isTestingSpecialist)
        const BottomNavigationBarItem(icon: Icon(Icons.assignment_ind_rounded), label: 'Lịch khám'),
      if (_isTestingSpecialist)
        const BottomNavigationBarItem(icon: Icon(Icons.biotech_rounded), label: 'Xét nghiệm'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: _buildBody(),
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
          items: navItems,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildDashboard();
    }

    if (_isTestingSpecialist) {
      if (_selectedIndex == 1) {
        return _buildTestingWorkView();
      }
      return _buildAccountPlaceholder();
    }

    if (_selectedIndex == 1) {
      return const LichKhamBacSiView();
    }

    return _buildAccountPlaceholder();
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 310,
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
                  Positioned(
                    left: -30,
                    bottom: -40,
                    child: CircleAvatar(radius: 70, backgroundColor: Colors.white.withValues(alpha: 0.04)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(height: 24),
                        _buildSpecialtyBanner(),
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
                if (!_isTestingSpecialist) ...[
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
                        Expanded(
                          child: _buildStatCard('Hoàn thành', completed.toString(), Icons.check_circle_rounded, Colors.green),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                ],
                _buildSectionTitle('Truy cập nhanh'),
                const SizedBox(height: 16),
                if (!_isTestingSpecialist)
                  _buildQuickActionCard(
                    'Lịch khám của tôi',
                    'Xem danh sách bệnh nhân đang chờ và đã khám trong ngày',
                    Icons.assignment_ind_rounded,
                    const Color(0xFF2196F3),
                    () => setState(() => _selectedIndex = 1),
                  ),
                if (_isTestingSpecialist) _buildQuickActionCard(
                  'Công việc xét nghiệm của tôi',
                  'Quản lý chỉ định, theo dõi bệnh nhân và cập nhật kết quả xét nghiệm.',
                  Icons.biotech_rounded,
                  const Color(0xFF1565C0),
                  () => setState(() => _selectedIndex = 1),
                ),
                _buildQuickActionCard(
                  'Hồ sơ bệnh nhân',
                  'Tra cứu lịch sử bệnh án và các kết quả',
                  Icons.folder_shared_rounded,
                  const Color(0xFF9C27B0),
                  () {},
                ),
                _buildQuickActionCard(
                  'Tin nhắn & Hỗ trợ',
                  'Liên hệ với điều phối viên hoặc bệnh nhân',
                  Icons.chat_rounded,
                  const Color(0xFF00897B),
                  () {},
                ),
              ],
            ),
          ),
        ),
        _sliversFooter(),
      ],
    );
  }

  Widget _buildSpecialtyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _isTestingSpecialist ? Icons.biotech_rounded : Icons.medical_information_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTestingSpecialist ? 'Bác sĩ xét nghiệm' : 'Bác sĩ khám bệnh',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  _isTestingSpecialist
                      ? 'Khu vực làm việc của bạn tập trung vào công việc xét nghiệm: nhận chỉ định, theo dõi bệnh nhân và cập nhật kết quả.'
                      : 'Bạn vẫn sử dụng đầy đủ lịch khám của mình, hệ thống chỉ ẩn các chức năng không thuộc chuyên khoa.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.86), fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTestingWorkView() {
    return const XetNghiemView();
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

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    const textPrimary = Color(0xFF1F2937);
    const textSecondary = Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountPlaceholder() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_rounded, size: 36, color: _primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thông tin tài khoản',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliversFooter() => const SliverPadding(padding: EdgeInsets.only(bottom: 30));
}