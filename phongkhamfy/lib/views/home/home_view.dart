import 'package:flutter/material.dart';
import 'package:phongkhamfy/views/patient/dat_lich_kham_view.dart';

class HomeView extends StatefulWidget {
  final String tenNguoiDung;
  final String email;

  const HomeView({super.key, required this.tenNguoiDung, required this.email});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedBottomIndex = 0;
  int _currentNewsIndex = 0;

  static const Color _mauChinh = Color(0xFF1E88E5);
  static const Color _mauNen = Color(0xFFF5F7FA);
  static const Color _mauBeMat = Colors.white;
  static const Color _mauChuChinh = Color(0xFF1A2B3D);
  static const Color _mauChuPhu = Color(0xFF6B7C8A);

  final List<Map<String, String>> _tinTuc = [
    {
      'tieu_de': 'Xác nhận báo hiểm y tế ngay khi đặt khám trên UMC Care',
      'mo_ta': 'Giảm thời gian chờ tại bệnh viện',
      'hinh_anh': 'assets/news1.png',
    },
    {
      'tieu_de':
          'Chương trình sinh hoạt Câu lạc bộ Người bệnh "Bảo vệ thận – Giữ gìn môi trường"',
      'mo_ta': 'Cùng tham gia và bảo vệ sức khỏe',
      'hinh_anh': 'assets/news2.png',
    },
  ];

  void _hienThiDialogDangXuat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mauNen,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_selectedBottomIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildNotificationTab();
      case 2:
        return _buildFeaturesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildNewsSection(),
          const SizedBox(height: 24),
          _buildFeaturesSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_mauChinh, _mauChinh.withOpacity(0.8)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: _mauChinh,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bệnh viện Đại học Y Dược TP. Hồ Chí Minh',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'UMC Care',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Ứng dụng dành cho Người bệnh',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tin tức nổi bật',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _mauChuChinh,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Xem thêm')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: PageView.builder(
              itemCount: _tinTuc.length,
              onPageChanged: (index) {
                setState(() => _currentNewsIndex = index);
              },
              itemBuilder: (context, index) {
                return _buildNewsCard(_tinTuc[index]);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _tinTuc.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentNewsIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentNewsIndex == index
                      ? _mauChinh
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, String> news) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: _mauBeMat,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.article_rounded,
                size: 48,
                color: _mauChinh.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    news['tieu_de'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _mauChuChinh,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news['mo_ta'] ?? '',
                    style: const TextStyle(fontSize: 11, color: _mauChuPhu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _mauChuPhu,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chức năng chính
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chức năng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _mauChuChinh,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: _mauBeMat,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                  children: [
                    _buildMainFeatureItem(
                      icon: Icons.calendar_month_rounded,
                      label: 'Đặt khám',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DatLichKhamView(),
                          ),
                        );
                      },
                    ),
                    _buildMainFeatureItem(
                      icon: Icons.history_rounded,
                      label: 'Lịch sử đặt khám',
                      color: const Color(0xFF4CAF50),
                      onTap: () {},
                    ),
                    _buildMainFeatureItem(
                      icon: Icons.payment_rounded,
                      label: 'Thanh toán viện phí',
                      color: const Color(0xFFFF9800),
                      onTap: () {},
                    ),
                    _buildMainFeatureItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Hóa đơn',
                      color: const Color(0xFFE91E63),
                      onTap: () {},
                    ),
                    _buildMainFeatureItem(
                      icon: Icons.medical_information_rounded,
                      label: 'Hồ sơ sức khỏe',
                      color: const Color(0xFF9C27B0),
                      onTap: () {},
                    ),
                    _buildMainFeatureItem(
                      icon: Icons.science_rounded,
                      label: 'Kết quả cận lâm sàng',
                      color: const Color(0xFF00BCD4),
                      onTap: () {},
                    ),
                    _buildMainFeatureItem(
                      icon: Icons.app_registration_rounded,
                      label: 'Đăng ký nhập viện',
                      color: const Color(0xFF3F51B5),
                      onTap: () {},
                    ),
                    _buildMainFeatureItem(
                      icon: Icons.headset_mic_rounded,
                      label: 'Lắng nghe khách hàng',
                      color: const Color(0xFFFF5722),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Chức năng khác
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chức năng khác',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _mauChuChinh,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildFeatureItem(
                    icon: Icons.book_rounded,
                    label: 'Hướng dẫn\nkhách hàng',
                    color: const Color(0xFF4CAF50),
                    onTap: () {},
                  ),
                  _buildFeatureItem(
                    icon: Icons.medical_services_rounded,
                    label: 'Dịch vụ\nnổi bật',
                    color: const Color(0xFF2196F3),
                    onTap: () {},
                  ),
                  _buildFeatureItem(
                    icon: Icons.attach_money_rounded,
                    label: 'Bảng giá\ndịch vụ',
                    color: const Color(0xFFFF9800),
                    onTap: () {},
                  ),
                  _buildFeatureItem(
                    icon: Icons.favorite_rounded,
                    label: 'Thư viện\nsức khỏe',
                    color: const Color(0xFFE91E63),
                    onTap: () {},
                  ),
                  _buildFeatureItem(
                    icon: Icons.article_rounded,
                    label: 'Tin tức -\nSự kiện',
                    color: const Color(0xFF9C27B0),
                    onTap: () {},
                  ),
                  _buildFeatureItem(
                    icon: Icons.phone_rounded,
                    label: 'Liên hệ',
                    color: const Color(0xFF00BCD4),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainFeatureItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: _mauChuChinh,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _mauBeMat,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: _mauChuChinh,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có thông báo',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            const Text(
              'Chức năng',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _mauChuChinh,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
              children: [
                _buildFullFeatureItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Đặt khám',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DatLichKhamView(),
                      ),
                    );
                  },
                ),
                _buildFullFeatureItem(
                  icon: Icons.history_rounded,
                  label: 'Lịch sử đặt khám',
                  color: const Color(0xFF4CAF50),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.payment_rounded,
                  label: 'Thanh toán viện phí',
                  color: const Color(0xFFFF9800),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Hóa đơn',
                  color: const Color(0xFFE91E63),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.medical_information_rounded,
                  label: 'Hồ sơ sức khỏe',
                  color: const Color(0xFF9C27B0),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.science_rounded,
                  label: 'Kết quả cận lâm sàng',
                  color: const Color(0xFF00BCD4),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.app_registration_rounded,
                  label: 'Đăng ký nhập viện',
                  color: const Color(0xFF3F51B5),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.headset_mic_rounded,
                  label: 'Lắng nghe khách hàng',
                  color: const Color(0xFFFF5722),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.book_rounded,
                  label: 'Hướng dẫn',
                  color: const Color(0xFF607D8B),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Theo dõi sức khỏe tại nhà',
                  color: const Color(0xFFE53935),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.search_rounded,
                  label: 'Tiềm chủng',
                  color: const Color(0xFF43A047),
                  onTap: () {},
                ),
                _buildFullFeatureItem(
                  icon: Icons.chat_rounded,
                  label: 'Hỏi - đáp (Chatbot)',
                  color: const Color(0xFF1E88E5),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullFeatureItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _mauBeMat,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: _mauChuChinh,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_mauChinh, _mauChinh.withOpacity(0.8)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded, size: 48, color: _mauChinh),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.tenNguoiDung,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Thông tin cá nhân',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.lock_outline_rounded,
            title: 'Đổi mật khẩu',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Trợ giúp',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'Về chúng tôi',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildProfileMenuItem(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            onTap: _hienThiDialogDangXuat,
            isDestructive: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _mauBeMat,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : _mauChinh),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : _mauChuChinh,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: isDestructive ? Colors.red : _mauChuPhu,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: _mauBeMat,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedBottomIndex,
        selectedItemColor: _mauChinh,
        unselectedItemColor: _mauChuPhu,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            icon: Icon(Icons.layers_rounded),
            label: 'Chức năng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
