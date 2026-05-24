import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/auth_controller.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:phongkhamfy/views/auth/login_view.dart';
import 'package:phongkhamfy/views/doctor/lich_kham_bac_si_view.dart';
import 'package:phongkhamfy/views/doctor/xet_nghiem_view.dart';
import 'package:phongkhamfy/widgets/dialog_dang_xuat.dart';
import 'package:phongkhamfy/widgets/loading_dang_xuat.dart';
import 'package:phongkhamfy/theme/app_theme.dart';

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
        .replaceAll('á', 'a').replaceAll('à', 'a').replaceAll('ả', 'a').replaceAll('ã', 'a').replaceAll('ạ', 'a')
        .replaceAll('ă', 'a').replaceAll('ắ', 'a').replaceAll('ằ', 'a').replaceAll('ẳ', 'a').replaceAll('ẵ', 'a').replaceAll('ặ', 'a')
        .replaceAll('â', 'a').replaceAll('ấ', 'a').replaceAll('ầ', 'a').replaceAll('ẩ', 'a').replaceAll('ẫ', 'a').replaceAll('ậ', 'a')
        .replaceAll('é', 'e').replaceAll('è', 'e').replaceAll('ẻ', 'e').replaceAll('ẽ', 'e').replaceAll('ẹ', 'e')
        .replaceAll('ê', 'e').replaceAll('ế', 'e').replaceAll('ề', 'e').replaceAll('ể', 'e').replaceAll('ễ', 'e').replaceAll('ệ', 'e')
        .replaceAll('í', 'i').replaceAll('ì', 'i').replaceAll('ỉ', 'i').replaceAll('ĩ', 'i').replaceAll('ị', 'i')
        .replaceAll('ó', 'o').replaceAll('ò', 'o').replaceAll('ỏ', 'o').replaceAll('õ', 'o').replaceAll('ọ', 'o')
        .replaceAll('ô', 'o').replaceAll('ố', 'o').replaceAll('ồ', 'o').replaceAll('ổ', 'o').replaceAll('ỗ', 'o').replaceAll('ộ', 'o')
        .replaceAll('ơ', 'o').replaceAll('ớ', 'o').replaceAll('ờ', 'o').replaceAll('ở', 'o').replaceAll('ỡ', 'o').replaceAll('ợ', 'o')
        .replaceAll('ú', 'u').replaceAll('ù', 'u').replaceAll('ủ', 'u').replaceAll('ũ', 'u').replaceAll('ụ', 'u')
        .replaceAll('ư', 'u').replaceAll('ứ', 'u').replaceAll('ừ', 'u').replaceAll('ử', 'u').replaceAll('ữ', 'u').replaceAll('ự', 'u')
        .replaceAll('ý', 'y').replaceAll('ỳ', 'y').replaceAll('ỷ', 'y').replaceAll('ỹ', 'y').replaceAll('ỵ', 'y')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
            MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
            (route) => false,
          );
        }
      },
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
      backgroundColor: AppColors.bg,
      body: _buildBody(),
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
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) return _buildDashboard();

    if (_isTestingSpecialist) {
      if (_selectedIndex == 1) return _buildTestingWorkView();
      return _buildAccountPage();
    }

    if (_selectedIndex == 1) return const LichKhamBacSiView();
    return _buildAccountPage();
  }

  // ─── DASHBOARD ─────────────────────────────────────────────────
  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Greeting
            GreetingCard(
              greeting: 'Chào Bác sĩ,',
              name: widget.tenNguoiDung,
              subtitle: _isTestingSpecialist ? 'Bác sĩ xét nghiệm' : 'Bác sĩ khám bệnh',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isTestingSpecialist)
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: _loadTodayStats,
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: _onLogout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats (only for non-testing specialist)
            if (!_isTestingSpecialist) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('THỐNG KÊ HÔM NAY', style: AppText.caption.copyWith(
                  color: AppColors.subLabel, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final schedules = controller.doctorSchedules;
                int total = 0;
                int completed = 0;

                if (schedules.isNotEmpty) {
                  final patients = schedules[0]['LichKham'] as List? ?? [];
                  total = patients.length;
                  completed = patients.where((p) => p['TrangThai'] == 'completed').length;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: StatCard(
                        value: total.toString(),
                        label: 'Bệnh nhân hôm nay',
                        color: AppColors.warning,
                        icon: Icons.people_rounded,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(
                        value: completed.toString(),
                        label: 'Đã hoàn thành',
                        color: AppColors.success,
                        icon: Icons.check_circle_rounded,
                      )),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Specialty banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isTestingSpecialist ? Icons.biotech_rounded : Icons.medical_information_rounded,
                        color: AppColors.primary, size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isTestingSpecialist ? 'Bác sĩ xét nghiệm' : 'Bác sĩ khám bệnh',
                            style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _isTestingSpecialist
                                ? 'Nhận chỉ định, theo dõi bệnh nhân và cập nhật kết quả xét nghiệm.'
                                : 'Xem lịch khám và tiếp nhận bệnh nhân trong ngày.',
                            style: AppText.caption.copyWith(color: AppColors.label2, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('TRUY CẬP NHANH', style: AppText.caption.copyWith(
                color: AppColors.subLabel, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            ),
            const SizedBox(height: 10),
            IosSection(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (!_isTestingSpecialist)
                  IosCell(
                    leading: _iconBox(Icons.assignment_ind_rounded, const Color(0xFF2196F3)),
                    title: 'Lịch khám của tôi',
                    subtitle: 'Xem danh sách bệnh nhân đang chờ và đã khám',
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                if (_isTestingSpecialist)
                  IosCell(
                    leading: _iconBox(Icons.biotech_rounded, const Color(0xFF1565C0)),
                    title: 'Công việc xét nghiệm',
                    subtitle: 'Quản lý chỉ định và cập nhật kết quả',
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                IosCell(
                  leading: _iconBox(Icons.folder_shared_rounded, const Color(0xFF9C27B0)),
                  title: 'Hồ sơ bệnh nhân',
                  subtitle: 'Tra cứu lịch sử bệnh án và kết quả',
                  onTap: () {},
                ),
                IosCell(
                  leading: _iconBox(Icons.chat_rounded, const Color(0xFF00897B)),
                  title: 'Tin nhắn & Hỗ trợ',
                  subtitle: 'Liên hệ với điều phối viên hoặc bệnh nhân',
                  onTap: () {},
                  showSeparator: false,
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTestingWorkView() {
    return const XetNghiemView();
  }

  // ─── ACCOUNT PAGE ──────────────────────────────────────────────
  Widget _buildAccountPage() {
    final today = DateFormat('EEEE, dd/MM/yyyy').format(DateTime.now());
    final role = _isTestingSpecialist ? 'Bác sĩ xét nghiệm' : 'Bác sĩ khám bệnh';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            InitialsAvatar(name: widget.tenNguoiDung, size: 80),
            const SizedBox(height: 12),
            Text(widget.tenNguoiDung, style: AppText.title3),
            const SizedBox(height: 4),
            StatusChip(role, AppColors.primary),
            const SizedBox(height: 4),
            Text(today, style: AppText.caption.copyWith(color: AppColors.subLabel)),

            const SizedBox(height: 28),

            IosSection(
              title: 'THÔNG TIN',
              children: [
                IosCell(
                  leading: _iconBox(Icons.email_rounded, AppColors.primary),
                  title: 'Email',
                  trailing: Flexible(child: Text(widget.email,
                    style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis)),
                  showSeparator: true,
                ),
                IosCell(
                  leading: _iconBox(Icons.badge_rounded, AppColors.primary),
                  title: 'Vai trò',
                  trailing: Text(role,
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
