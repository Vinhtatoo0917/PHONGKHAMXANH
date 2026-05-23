import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:phongkhamfy/config/api_config.dart';

class HoaDonCuaToiView extends StatefulWidget {
  const HoaDonCuaToiView({super.key});

  @override
  State<HoaDonCuaToiView> createState() => _HoaDonCuaToiViewState();
}

class _HoaDonCuaToiViewState extends State<HoaDonCuaToiView> {
  static const _primary = Color(0xFF1565C0);
  static const _background = Color(0xFFF4F7FB);
  static const _text = Color(0xFF172033);
  static const _muted = Color(0xFF667085);
  static const _success = Color(0xFF43A047);
  static const _warning = Color(0xFFFFB020);

  final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  final _sessionManager = SessionManager();
  final _dio = Dio();
  String _filterStatus = 'all'; // 'all', 'pending', 'paid'
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await _sessionManager.getToken();
      if (!mounted || token == null) return;

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/benhnhan/my-invoices',
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
          final invoiceList = (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          // Convert date strings to DateTime objects
          final processedInvoices = invoiceList.map((inv) {
            return {
              ...inv,
              'NgayTao': inv['NgayTao'] is String
                  ? DateTime.parse(inv['NgayTao'] as String)
                  : (inv['NgayTao'] as DateTime? ?? DateTime.now()),
              'ChiTiet': (inv['ChiTiet'] as List?)
                  ?.map((item) => Map<String, dynamic>.from(item as Map))
                  .toList() ?? [],
            };
          }).toList();

          if (mounted) {
            setState(() {
              _invoices = processedInvoices;
              _isLoading = false;
            });
          }
          return;
        }
      }

      throw Exception(response.data['message'] ?? 'Lỗi khi lấy hóa đơn');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
          _invoices = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Thanh toán hoá đơn', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadInvoices,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatistics(),
                      const SizedBox(height: 24),
                      _buildFilterButtons(),
                      const SizedBox(height: 16),
                      Text(
                        'Lịch sử hoá đơn của tôi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Quản lý và thanh toán các hóa đơn từ các lần khám',
                        style: TextStyle(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInvoicesList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatistics() {
    final totalInvoices = _invoices.length;
    final paidInvoices = _invoices.where((inv) => inv['TrangThai'] == 'paid').length;
    final totalAmount = _invoices.fold<double>(0, (sum, inv) => sum + (inv['SoTienPhaiTra'] as num).toDouble());

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng hóa đơn',
            totalInvoices.toString(),
            Icons.receipt_rounded,
            _primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Đã thanh toán',
            paidInvoices.toString(),
            Icons.check_circle_rounded,
            _success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tổng tiền',
            '${(totalAmount / 1000000).toStringAsFixed(1)}M',
            Icons.trending_up_rounded,
            _warning,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Tất cả', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Chưa thanh toán', 'pending'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã thanh toán', 'paid'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _filterStatus = value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        _primary.withValues(alpha: 0.2),
                        _primary.withValues(alpha: 0.1),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white.withValues(alpha: 0.4),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _primary.withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? _primary : _muted,
              ),
            ),
          ),
        ),
      ),
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

  Widget _buildInvoicesList() {
    List<Map<String, dynamic>> filteredInvoices = _invoices;

    if (_filterStatus == 'pending') {
      filteredInvoices = _invoices.where((inv) => inv['TrangThai'] == 'pending').toList();
    } else if (_filterStatus == 'paid') {
      filteredInvoices = _invoices.where((inv) => inv['TrangThai'] == 'paid').toList();
    }

    if (filteredInvoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 40,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Không có hóa đơn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _filterStatus == 'pending'
                    ? 'Bạn không có hóa đơn chưa thanh toán'
                    : _filterStatus == 'paid'
                        ? 'Bạn không có hóa đơn đã thanh toán'
                        : 'Chọn bộ lọc khác để xem hóa đơn',
                style: TextStyle(
                  fontSize: 13,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...filteredInvoices.map((invoice) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInvoiceCard(invoice),
        )),
      ],
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final isPaid = invoice['TrangThai'] == 'paid';
    final statusColor = isPaid ? _success : _warning;
    final statusLabel = isPaid ? 'Đã thanh toán' : 'Chờ thanh toán';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showInvoiceDetail(invoice),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.receipt_rounded,
                                      color: _primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hóa đơn #${invoice['MaHoaDon']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                            color: _text,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm')
                                              .format(invoice['NgayTao'] as DateTime),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _muted,
                                            fontWeight: FontWeight.w600,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: _primary.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Số tiền phải trả',
                              style: TextStyle(
                                fontSize: 12,
                                color: _muted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _moneyFormat.format(invoice['SoTienPhaiTra']),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: () => _showInvoiceDetail(invoice),
                              style: FilledButton.styleFrom(
                                backgroundColor: _primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Xem chi tiết',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetail(Map<String, dynamic> invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInvoiceDetailSheet(invoice),
    );
  }

  Widget _buildInvoiceDetailSheet(Map<String, dynamic> invoice) {
    final isPaid = invoice['TrangThai'] == 'paid';
    final statusColor = isPaid ? _success : _warning;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.98),
                Colors.white.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: _primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chi tiết hóa đơn',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Mã hóa đơn', '#${invoice['MaHoaDon']}'),
                _buildDetailRow(
                  'Ngày tạo',
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(invoice['NgayTao'] as DateTime),
                ),
                _buildDetailRow(
                  'Trạng thái',
                  isPaid ? 'Đã thanh toán' : 'Chờ thanh toán',
                  valueColor: statusColor,
                ),
                const SizedBox(height: 16),
                Divider(
                  color: _primary.withValues(alpha: 0.1),
                  height: 1,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chi tiết chi phí',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 12),
                ...(invoice['ChiTiet'] as List).map((item) => _buildCostItem(
                  item['TenHienThi'] ?? 'Dịch vụ',
                  item['ThanhTien'] ?? 0.0,
                  Icons.receipt_rounded,
                )),
                const SizedBox(height: 16),
                Divider(
                  color: _primary.withValues(alpha: 0.1),
                  height: 1,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Tổng tiền',
                  _moneyFormat.format(invoice['TongTien']),
                  isBold: true,
                ),
                if ((invoice['GiamBHYT'] as double) > 0) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Giảm BHYT',
                    '-${_moneyFormat.format(invoice['GiamBHYT'])}',
                    valueColor: _success,
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primary.withValues(alpha: 0.1),
                        _primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng phải trả',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      Text(
                        _moneyFormat.format(invoice['SoTienPhaiTra']),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (!isPaid)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: _success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Thanh toán ngay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostItem(String label, double amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: _text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            _moneyFormat.format(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              color: valueColor ?? _text,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
