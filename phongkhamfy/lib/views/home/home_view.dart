import 'package:flutter/material.dart';
import 'package:phongkhamfy/controllers/auth_controller.dart';
import 'package:phongkhamfy/views/auth/login_view.dart';
import 'package:phongkhamfy/views/patient/dat_lich_kham_view.dart';
import 'package:phongkhamfy/views/patient/lich_kham_cua_toi_view.dart';
import 'package:phongkhamfy/views/patient/hoa_don_cua_toi_view.dart';
import 'package:phongkhamfy/views/patient/change_password_view.dart';
import 'package:phongkhamfy/widgets/dialog_dang_xuat.dart';
import 'package:phongkhamfy/widgets/loading_dang_xuat.dart';
import 'package:phongkhamfy/views/patient/edit_profile_view.dart';
import 'package:phongkhamfy/theme/app_theme.dart';

class HomeView extends StatefulWidget {
  final String tenNguoiDung;
  final String email;

  const HomeView({super.key, required this.tenNguoiDung, required this.email});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedBottomIndex = 0;
  int _currentBannerIndex = 0;
  final _dichVuXacThuc = DichVuXacThuc();

  final List<Map<String, dynamic>> _banners = [
    {
      'icon': Icons.favorite_rounded,
      'title': 'Chăm sóc sức khỏe',
      'subtitle': 'Khám bệnh định kỳ giúp phòng ngừa bệnh tật',
      'color': const Color(0xFF2196F3),
    },
    {
      'icon': Icons.local_pharmacy_rounded,
      'title': 'Tư vấn thuốc',
      'subtitle': 'Được bác sĩ tư vấn đầy đủ trước khi dùng thuốc',
      'color': const Color(0xFF4CAF50),
    },
  ];

  void _hienThiDialogDangXuat() {
    DialogDangXuat.hienThi(context: context, onXacNhan: _dangXuat);
  }

  Future<void> _dangXuat() async {
    LoadingDangXuat.hienThi(context: context);
    await _dichVuXacThuc.dangXuat();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedBottomIndex) {
      case 0: return _buildHomeTab();
      case 1: return _buildFeaturesTab();
      case 2: return _buildProfileTab();
      default: return _buildHomeTab();
    }
  }

  // ─── HOME TAB ──────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            GreetingCard(
              greeting: 'Xin chào,',
              name: widget.tenNguoiDung,
              subtitle: 'Chúc bạn một ngày sức khỏe tốt',
            ),
            const SizedBox(height: 16),
            _buildBannerCarousel(),
            const SizedBox(height: 20),
            _buildMainFeaturesSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.92),
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentBannerIndex = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: _buildBannerCard(_banners[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _currentBannerIndex == i ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: _currentBannerIndex == i ? AppColors.primary : AppColors.separator,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> banner) {
    return Container(
      decoration: AppDecor.card,
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (banner['color'] as Color).withValues(alpha: 0.8),
              (banner['color'] as Color).withValues(alpha: 0.4),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                banner['icon'] as IconData,
                size: 120,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          banner['icon'] as IconData,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title'] as String,
                              style: AppText.footnote.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              banner['subtitle'] as String,
                              style: AppText.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CHỨC NĂNG', style: AppText.caption.copyWith(
            color: AppColors.subLabel, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Container(
            decoration: AppDecor.card,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 4,
              childAspectRatio: 0.75,
              children: [
                _featureItem(Icons.calendar_month_rounded, 'Đặt khám', const Color(0xFF2196F3),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => DatLichKhamView()))),
                _featureItem(Icons.history_rounded, 'Lịch sử khám', const Color(0xFF4CAF50),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LichKhamCuaToiView()))),
                _featureItem(Icons.receipt_long_rounded, 'Hóa đơn', const Color(0xFFE91E63),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HoaDonCuaToiView()))),
                _featureItem(Icons.payment_rounded, 'Thanh toán', const Color(0xFFFF9800), () {}),
                _featureItem(Icons.medical_information_rounded, 'Hồ sơ SK', const Color(0xFF9C27B0), () {}),
                _featureItem(Icons.science_rounded, 'Kết quả', const Color(0xFF00BCD4), () {}),
                _featureItem(Icons.app_registration_rounded, 'Nhập viện', const Color(0xFF3F51B5), () {}),
                _featureItem(Icons.headset_mic_rounded, 'Hỗ trợ', const Color(0xFFFF5722), () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: AppColors.label, height: 1.2),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ─── FEATURES TAB ──────────────────────────────────────────────
  Widget _buildFeaturesTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Chức năng', style: AppText.largeTitle),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                IosMenuCard(icon: Icons.calendar_month_rounded, label: 'Đặt khám', color: const Color(0xFF2196F3),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DatLichKhamView()))),
                IosMenuCard(icon: Icons.history_rounded, label: 'Lịch sử khám', color: const Color(0xFF4CAF50),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LichKhamCuaToiView()))),
                IosMenuCard(icon: Icons.receipt_long_rounded, label: 'Hóa đơn', color: const Color(0xFFE91E63),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HoaDonCuaToiView()))),
                IosMenuCard(icon: Icons.payment_rounded, label: 'Thanh toán', color: const Color(0xFFFF9800), onTap: () {}),
                IosMenuCard(icon: Icons.medical_information_rounded, label: 'Hồ sơ SK', color: const Color(0xFF9C27B0), onTap: () {}),
                IosMenuCard(icon: Icons.science_rounded, label: 'Kết quả XN', color: const Color(0xFF00BCD4), onTap: () {}),
                IosMenuCard(icon: Icons.app_registration_rounded, label: 'Nhập viện', color: const Color(0xFF3F51B5), onTap: () {}),
                IosMenuCard(icon: Icons.headset_mic_rounded, label: 'Hỗ trợ', color: const Color(0xFFFF5722), onTap: () {}),
                IosMenuCard(icon: Icons.book_rounded, label: 'Hướng dẫn', color: const Color(0xFF607D8B), onTap: () {}),
                IosMenuCard(icon: Icons.favorite_rounded, label: 'Thư viện SK', color: const Color(0xFFE91E63), onTap: () {}),
                IosMenuCard(icon: Icons.article_rounded, label: 'Tin tức', color: const Color(0xFF9C27B0), onTap: () {}),
                IosMenuCard(icon: Icons.phone_rounded, label: 'Liên hệ', color: const Color(0xFF00BCD4), onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── PROFILE TAB ───────────────────────────────────────────────
  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar header
            InitialsAvatar(name: widget.tenNguoiDung, size: 80),
            const SizedBox(height: 12),
            Text(widget.tenNguoiDung, style: AppText.title3),
            const SizedBox(height: 4),
            Text(widget.email, style: AppText.subhead.copyWith(color: AppColors.subLabel)),
            const SizedBox(height: 6),
            StatusChip('Bệnh nhân', AppColors.primary),
            const SizedBox(height: 28),

            // Tài khoản
            IosSection(
              title: 'TÀI KHOẢN',
              children: [
                IosCell(
                  leading: _menuIcon(Icons.person_outline_rounded, AppColors.primary),
                  title: 'Thông tin cá nhân',
                  subtitle: 'Cập nhật hồ sơ và thông tin y tế',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileView())),
                ),
                IosCell(
                  leading: _menuIcon(Icons.lock_outline_rounded, AppColors.primary),
                  title: 'Đổi mật khẩu',
                  subtitle: 'Bảo mật tài khoản của bạn',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordView())),
                  showSeparator: false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ứng dụng
            IosSection(
              title: 'ỨNG DỤNG',
              children: [
                IosCell(
                  leading: _menuIcon(Icons.settings_outlined, AppColors.subLabel),
                  title: 'Cài đặt',
                  subtitle: 'Thông báo, ngôn ngữ và giao diện',
                  onTap: () {},
                ),
                IosCell(
                  leading: _menuIcon(Icons.help_outline_rounded, AppColors.subLabel),
                  title: 'Trợ giúp',
                  subtitle: 'Câu hỏi thường gặp và hỗ trợ',
                  onTap: () {},
                  showSeparator: false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Đăng xuất
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: AppDecor.card,
                clipBehavior: Clip.hardEdge,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _hienThiDialogDangXuat,
                    splashColor: AppColors.dangerBg,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          _menuIcon(Icons.logout_rounded, AppColors.danger, bg: AppColors.dangerBg),
                          const SizedBox(width: 12),
                          Text('Đăng xuất', style: AppText.body.copyWith(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('© 2025 Phòng Khám FY', style: AppText.caption),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _menuIcon(IconData icon, Color color, {Color? bg}) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: bg ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -1)),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedBottomIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subLabel,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        backgroundColor: Colors.transparent,
        elevation: 0,
        onTap: (index) => setState(() => _selectedBottomIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.apps_rounded), label: 'Chức năng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
