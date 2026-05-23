import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/auth_controller.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:phongkhamfy/views/auth/login_view.dart';
import 'package:phongkhamfy/widgets/dialog_dang_xuat.dart';
import 'package:phongkhamfy/widgets/loading_dang_xuat.dart';
import 'package:phongkhamfy/views/cashier/xu_ly_thanh_toan_view.dart';
import 'package:dio/dio.dart';
import 'package:phongkhamfy/config/api_config.dart';

class CashierHomeView extends StatefulWidget {
  const CashierHomeView({super.key});

  @override
  State<CashierHomeView> createState() => _CashierHomeViewState();
}

class _CashierHomeViewState extends State<CashierHomeView> {
  int _selectedIndex = 0;
  final _authService = DichVuXacThuc();
  final _sessionManager = SessionManager();
  final _dio = Dio();

  static const _primary = Color(0xFF0D47A1);
  static const _accent = Color(0xFF1976D2);
  static const _bg = Color(0xFFF0F4F8);
  static const _success = Color(0xFF43A047);
  static const _warning = Color(0xFFFFA000);
  static const _text = Color(0xFF172033);
  static const _muted = Color(0xFF667085);

  String _userName = 'Thu ngân';
  int _totalPending = 0;
  int _totalPaid = 0;
  double _totalAmount = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadInvoiceStatistics();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _sessionManager.getUserInfo();
    if (mounted) {
      setState(() {
        _userName = userInfo?['ten'] ?? userInfo?['name'] ?? 'Thu ngân';
      });
    }
  }

  Future<void> _loadInvoiceStatistics() async {
    try {
      setState(() => _isLoading = true);

      final token = await _sessionManager.getToken();
      if (!mounted || token == null) return;

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/bacsi/invoices-today',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          final stats = data['data']['statistics'] ?? {};
          if (mounted) {
            setState(() {
              _totalPending = stats['total_pending'] ?? 0;
              _totalPaid = stats['total_paid'] ?? 0;
              _totalAmount = (stats['total_amount'] ?? 0.0).toDouble();
              _isLoading = false;
            });
          }
          return;
        }
      }
      throw Exception('Lỗi khi lấy thống kê');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalPending = 0;
          _totalPaid = 0;
          _totalAmount = 0.0;
        });
      }
    }
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Thanh toán',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment_rounded),
              label: 'Báo cáo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildDashboard();
    } else if (_selectedIndex == 1) {
      return _buildPaymentPage();
    } else if (_selectedIndex == 2) {
      return _buildReportPage();
    }
    return _buildAccountPlaceholder();
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
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
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -40,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                    ),
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
                              child: Icon(
                                Icons.attach_money_rounded,
                                color: _primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chào Thu ngân,',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _onLogout,
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildCashierBanner(),
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
                _buildTodayStats(),
                const SizedBox(height: 24),
                _buildSectionTitle('Truy cập nhanh'),
                const SizedBox(height: 16),
                _buildQuickActionCard(
                  'Xử lý thanh toán',
                  'Nhận thanh toán từ bệnh nhân và cập nhật trạng thái',
                  Icons.payment_rounded,
                  const Color(0xFF2196F3),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const XuLyThanhToanView()),
                  ),
                ),
                _buildQuickActionCard(
                  'Xem báo cáo',
                  'Thống kê doanh thu, thanh toán và các chỉ số tài chính',
                  Icons.bar_chart_rounded,
                  const Color(0xFF4CAF50),
                  () => setState(() => _selectedIndex = 2),
                ),
                _buildQuickActionCard(
                  'Danh sách hóa đơn',
                  'Tra cứu và in hóa đơn cho bệnh nhân',
                  Icons.receipt_long_rounded,
                  const Color(0xFFFFC107),
                  () => setState(() => _selectedIndex = 1),
                ),
                _buildQuickActionCard(
                  'Hoàn trả tiền',
                  'Xử lý yêu cầu hoàn trả và quản lý các giao dịch',
                  Icons.undo_rounded,
                  const Color(0xFFFF9800),
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

  Widget _buildCashierBanner() {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
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
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ngày làm việc hôm nay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  today,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Chờ thanh toán',
            _totalPending.toString(),
            Icons.pending_actions_rounded,
            _warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Đã thanh toán',
            _totalPaid.toString(),
            Icons.check_circle_rounded,
            _success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tổng tiền',
            '${(_totalAmount / 1000000).toStringAsFixed(1)}M',
            Icons.trending_up_rounded,
            _primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: _muted,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: _text,
      ),
    );
  }

  Widget _buildPaymentPage() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Xử lý thanh toán', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          foregroundColor: _text,
          elevation: 0,
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Chuyển đến màn hình thanh toán chi tiết', style: TextStyle(color: _muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportPage() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Báo cáo & Thống kê', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          foregroundColor: _text,
          elevation: 0,
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Chuyển đến trang báo cáo chi tiết', style: TextStyle(color: _muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountPlaceholder() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          foregroundColor: _text,
          elevation: 0,
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Chuyển đến trang tài khoản', style: TextStyle(color: _muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sliversFooter() {
    return const SliverToBoxAdapter(
      child: SizedBox(height: 40),
    );
  }
}
