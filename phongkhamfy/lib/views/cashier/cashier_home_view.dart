import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/auth_controller.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:phongkhamfy/views/auth/login_view.dart';
import 'package:phongkhamfy/widgets/dialog_dang_xuat.dart';
import 'package:phongkhamfy/widgets/loading_dang_xuat.dart';
import 'package:phongkhamfy/views/cashier/xu_ly_thanh_toan_view.dart';
import 'package:phongkhamfy/theme/app_theme.dart';
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

  final NumberFormat _moneyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  String _userName = 'Thu ngân';
  String _userHo = '';
  String _userEmail = '';
  int _totalPending = 0;
  int _totalPaid = 0;
  double _totalAmount = 0.0;

  List<Map<String, dynamic>> _allInvoices = [];
  bool _invoicesLoading = false;
  String _filterStatus = 'all';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadInvoiceStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _sessionManager.getUserInfo();
    if (mounted) {
      setState(() {
        _userName = userInfo?['ten'] ?? userInfo?['name'] ?? 'Thu ngân';
        _userHo = userInfo?['ho'] ?? '';
        _userEmail = userInfo?['email'] ?? '';
      });
    }
  }

  Future<void> _loadInvoiceStatistics() async {
    try {
      final token = await _sessionManager.getToken();
      if (!mounted || token == null) return;

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/cashier/today-statistics',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          final stats = data['data'] ?? {};
          if (mounted) {
            setState(() {
              _totalPending = stats['total_pending'] ?? 0;
              _totalPaid = stats['total_paid'] ?? 0;
              _totalAmount = (stats['total_amount'] ?? 0.0).toDouble();
            });
          }
          return;
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
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
          onTap: (i) {
            setState(() => _selectedIndex = i);
            if (i == 2) _loadAllInvoices();
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subLabel,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Thanh toán'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Danh sách HĐ'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) return _buildDashboard();
    if (_selectedIndex == 1) return _buildPaymentPage();
    if (_selectedIndex == 2) return _buildAllInvoicesPage();
    return _buildAccountPage();
  }

  // ─── DASHBOARD ─────────────────────────────────────────────────
  Widget _buildDashboard() {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            GreetingCard(
              greeting: 'Chào Thu ngân,',
              name: _userName,
              subtitle: 'Ngày làm việc: $today',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    onPressed: _loadInvoiceStatistics,
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: _onLogout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('THỐNG KÊ HÔM NAY', style: AppText.caption.copyWith(
                color: AppColors.subLabel, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: StatCard(
                    value: _totalPending.toString(),
                    label: 'Chờ thanh toán',
                    color: AppColors.warning,
                    icon: Icons.pending_actions_rounded,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(
                    value: _totalPaid.toString(),
                    label: 'Đã thanh toán',
                    color: AppColors.success,
                    icon: Icons.check_circle_rounded,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(
                    value: '${(_totalAmount / 1000000).toStringAsFixed(1)}M',
                    label: 'Tổng tiền',
                    color: AppColors.primary,
                    icon: Icons.trending_up_rounded,
                  )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('TRUY CẬP NHANH', style: AppText.caption.copyWith(
                color: AppColors.subLabel, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            ),
            const SizedBox(height: 10),

            IosSection(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                IosCell(
                  leading: _iconBox(Icons.payment_rounded, AppColors.accent),
                  title: 'Xử lý thanh toán',
                  subtitle: 'Nhận thanh toán từ bệnh nhân và cập nhật trạng thái',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const XuLyThanhToanView()),
                    );
                    _loadInvoiceStatistics();
                  },
                ),
                IosCell(
                  leading: _iconBox(Icons.list_alt_rounded, AppColors.success),
                  title: 'Danh sách hóa đơn',
                  subtitle: 'Tra cứu tất cả hóa đơn theo ngày và trạng thái',
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                    _loadAllInvoices();
                  },
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

  // ─── PAYMENT PAGE ──────────────────────────────────────────────
  Widget _buildPaymentPage() {
    return const XuLyThanhToanView();
  }

  // ─── ALL INVOICES ──────────────────────────────────────────────
  Future<void> _loadAllInvoices() async {
    if (_invoicesLoading) return;
    setState(() => _invoicesLoading = true);
    try {
      final token = await _sessionManager.getToken();
      if (!mounted || token == null) return;

      final params = <String, dynamic>{'status': _filterStatus};
      if (_filterDateFrom != null) params['date_from'] = DateFormat('yyyy-MM-dd').format(_filterDateFrom!);
      if (_filterDateTo != null) params['date_to'] = DateFormat('yyyy-MM-dd').format(_filterDateTo!);
      if (_searchController.text.trim().isNotEmpty) params['search'] = _searchController.text.trim();

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/cashier/all-invoices',
        queryParameters: params,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['data'] as List).cast<Map<String, dynamic>>();
        if (mounted) setState(() => _allInvoices = list);
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _invoicesLoading = false);
    }
  }

  Widget _buildAllInvoicesPage() {
    return Column(
      children: [
        // Header
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16, right: 16, bottom: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Danh sách hóa đơn', style: AppText.title3),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadAllInvoices,
                    icon: _invoicesLoading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                        : const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Search
              Container(
                decoration: AppDecor.input,
                child: TextField(
                  controller: _searchController,
                  style: AppText.subhead,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên bệnh nhân hoặc mã HĐ...',
                    hintStyle: AppText.subhead.copyWith(color: AppColors.placeholder),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.subLabel),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel, size: 18, color: AppColors.subLabel),
                            onPressed: () { _searchController.clear(); _loadAllInvoices(); },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  ),
                  onSubmitted: (_) => _loadAllInvoices(),
                  onChanged: (v) { if (v.isEmpty) _loadAllInvoices(); },
                ),
              ),
              const SizedBox(height: 8),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Tất cả', 'all'),
                    const SizedBox(width: 8),
                    _filterChip('Chờ TT', 'pending'),
                    const SizedBox(width: 8),
                    _filterChip('Đã TT', 'paid'),
                    const SizedBox(width: 12),
                    _datePickerBtn(
                      _filterDateFrom == null ? 'Từ ngày' : DateFormat('dd/MM/yy').format(_filterDateFrom!),
                      Icons.calendar_today_rounded,
                      () async {
                        final d = await showDatePicker(context: context,
                          initialDate: _filterDateFrom ?? DateTime.now(),
                          firstDate: DateTime(2024), lastDate: DateTime.now());
                        if (d != null) { setState(() => _filterDateFrom = d); _loadAllInvoices(); }
                      },
                    ),
                    const SizedBox(width: 8),
                    _datePickerBtn(
                      _filterDateTo == null ? 'Đến ngày' : DateFormat('dd/MM/yy').format(_filterDateTo!),
                      Icons.calendar_month_rounded,
                      () async {
                        final d = await showDatePicker(context: context,
                          initialDate: _filterDateTo ?? DateTime.now(),
                          firstDate: DateTime(2024), lastDate: DateTime.now().add(const Duration(days: 1)));
                        if (d != null) { setState(() => _filterDateTo = d); _loadAllInvoices(); }
                      },
                    ),
                    if (_filterDateFrom != null || _filterDateTo != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() { _filterDateFrom = null; _filterDateTo = null; });
                          _loadAllInvoices();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Xóa ngày', style: AppText.caption.copyWith(
                            color: AppColors.danger, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 0.5, thickness: 0.5, color: AppColors.separator),
        // Invoice list
        Expanded(
          child: _invoicesLoading && _allInvoices.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _allInvoices.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Không có hóa đơn',
                      subtitle: 'Thử thay đổi bộ lọc hoặc tải lại',
                      action: TextButton(
                        onPressed: _loadAllInvoices,
                        child: Text('Tải lại', style: AppText.callout.copyWith(color: AppColors.primary)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAllInvoices,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _allInvoices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildInvoiceRow(_allInvoices[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filterStatus == value;
    return GestureDetector(
      onTap: () { setState(() => _filterStatus = value); _loadAllInvoices(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.separator),
        ),
        child: Text(label,
          style: AppText.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.subLabel)),
      ),
    );
  }

  Widget _datePickerBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.separator),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.subLabel),
            const SizedBox(width: 6),
            Text(label, style: AppText.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.label)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(Map<String, dynamic> invoice) {
    final isPaid = invoice['TrangThai'] == 'paid';
    final statusColor = isPaid ? AppColors.success : AppColors.warning;
    final amount = invoice['SoTienPhaiTra'];
    final amountVal = amount is String ? double.tryParse(amount) ?? 0 : (amount as num).toDouble();
    final ngayTao = invoice['NgayTao'] is String
        ? DateTime.tryParse(invoice['NgayTao']) ?? DateTime.now()
        : DateTime.now();

    return Container(
      decoration: AppDecor.card,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('HĐ #${invoice['MaHoaDon']}',
                      style: AppText.footnote.copyWith(color: AppColors.label, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    StatusChip(isPaid ? 'Đã TT' : 'Chờ TT', statusColor, fontSize: 10),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${invoice['TenBenhNhan'] ?? 'Bệnh nhân'}', style: AppText.caption.copyWith(color: AppColors.subLabel)),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(ngayTao),
                  style: AppText.caption.copyWith(color: AppColors.placeholder)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_moneyFormat.format(amountVal),
                style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              if (!isPaid) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const XuLyThanhToanView()));
                    _loadAllInvoices();
                    _loadInvoiceStatistics();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Thu tiền', style: AppText.caption.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── ACCOUNT PAGE ──────────────────────────────────────────────
  Widget _buildAccountPage() {
    final fullName = [_userHo, _userName].where((s) => s.isNotEmpty).join(' ');
    final today = DateFormat('EEEE, dd/MM/yyyy').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            InitialsAvatar(name: fullName.isEmpty ? 'Thu ngân' : fullName, size: 80),
            const SizedBox(height: 12),
            Text(fullName.isEmpty ? 'Thu ngân' : fullName, style: AppText.title3),
            const SizedBox(height: 4),
            StatusChip('Thu ngân', AppColors.primary),
            const SizedBox(height: 4),
            Text(today, style: AppText.caption.copyWith(color: AppColors.subLabel)),

            const SizedBox(height: 28),

            // Today's stats
            IosSection(
              title: 'HÔM NAY',
              children: [
                IosCell(
                  leading: _iconBox(Icons.pending_actions_rounded, AppColors.warning),
                  title: 'Hóa đơn chờ thanh toán',
                  trailing: Text('$_totalPending HĐ',
                    style: AppText.footnote.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
                  showSeparator: true,
                ),
                IosCell(
                  leading: _iconBox(Icons.check_circle_rounded, AppColors.success),
                  title: 'Đã thanh toán hôm nay',
                  trailing: Text('$_totalPaid HĐ',
                    style: AppText.footnote.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                  showSeparator: true,
                ),
                IosCell(
                  leading: _iconBox(Icons.trending_up_rounded, AppColors.primary),
                  title: 'Tổng tiền thu',
                  trailing: Text(_moneyFormat.format(_totalAmount),
                    style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  showSeparator: false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_userEmail.isNotEmpty) ...[
              IosSection(
                title: 'TÀI KHOẢN',
                children: [
                  IosCell(
                    leading: _iconBox(Icons.email_rounded, AppColors.primary),
                    title: 'Email',
                    trailing: Flexible(child: Text(_userEmail,
                      style: AppText.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
                    showSeparator: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Actions
            IosSection(
              title: 'TÁC VỤ',
              children: [
                IosCell(
                  leading: _iconBox(Icons.refresh_rounded, AppColors.primary),
                  title: 'Làm mới thống kê',
                  onTap: () {
                    _loadInvoiceStatistics();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật thống kê'), duration: Duration(seconds: 1)));
                  },
                ),
                IosCell(
                  leading: _iconBox(Icons.logout_rounded, AppColors.danger, bg: AppColors.dangerBg),
                  title: 'Đăng xuất',
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.subLabel, size: 18),
                  onTap: _onLogout,
                  showSeparator: false,
                ),
              ],
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
