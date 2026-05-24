import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/views/patient/vnpay_payment_view.dart';
import 'package:phongkhamfy/theme/app_theme.dart';

class HoaDonCuaToiView extends StatefulWidget {
  const HoaDonCuaToiView({super.key});

  @override
  State<HoaDonCuaToiView> createState() => _HoaDonCuaToiViewState();
}

class _HoaDonCuaToiViewState extends State<HoaDonCuaToiView> {
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
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(title: 'Hoá đơn của tôi'),
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
                          color: AppColors.label,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Quản lý và thanh toán các hóa đơn từ các lần khám',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subLabel,
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
    final totalAmount = _invoices.fold<double>(0, (sum, inv) {
      final amount = inv['SoTienPhaiTra'];
      final value = amount is String ? double.parse(amount) : (amount as num).toDouble();
      return sum + value;
    });

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng hóa đơn',
            totalInvoices.toString(),
            Icons.receipt_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Đã thanh toán',
            paidInvoices.toString(),
            Icons.check_circle_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tổng tiền',
            '${(totalAmount / 1000000).toStringAsFixed(1)}M',
            Icons.trending_up_rounded,
            AppColors.warning,
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
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBg : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.separator,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primary : AppColors.subLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecor.card,
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
              color: AppColors.subLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Không có hóa đơn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label,
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
                  color: AppColors.subLabel,
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
    final statusColor = isPaid ? AppColors.success : AppColors.warning;
    final statusLabel = isPaid ? 'Đã thanh toán' : 'Chờ thanh toán';

    return Container(
          decoration: AppDecor.card,
          clipBehavior: Clip.hardEdge,
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
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.receipt_rounded,
                                      color: AppColors.primary,
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
                                            color: AppColors.label,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm')
                                              .format(invoice['NgayTao'] as DateTime),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.subLabel,
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
                      color: AppColors.primary.withValues(alpha: 0.1),
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
                                color: AppColors.subLabel,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (context) {
                                final amount = invoice['SoTienPhaiTra'];
                                final value = amount is String ? double.parse(amount) : (amount as num).toDouble();
                                return Text(
                                  _moneyFormat.format(value),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: () => _showInvoiceDetail(invoice),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
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
    final statusColor = isPaid ? AppColors.success : AppColors.warning;

    final tongTien = invoice['TongTien'];
    final tongTienValue = tongTien is String ? double.parse(tongTien) : (tongTien as num).toDouble();

    final giamBHYT = invoice['GiamBHYT'];
    final giamBHYTValue = giamBHYT is String ? double.parse(giamBHYT) : (giamBHYT as num).toDouble();

    final soTienPhaiTra = invoice['SoTienPhaiTra'];
    final soTienPhaiTraValue = soTienPhaiTra is String ? double.parse(soTienPhaiTra) : (soTienPhaiTra as num).toDouble();

    return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                        color: AppColors.label,
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
                if ((invoice['TenBacSi'] ?? '').toString().trim().isNotEmpty)
                  _buildDetailRow('Bác sĩ', invoice['TenBacSi'].toString().trim()),
                if ((invoice['ChuyenKhoa'] ?? '').toString().trim().isNotEmpty)
                  _buildDetailRow('Chuyên khoa', invoice['ChuyenKhoa'].toString().trim()),
                const SizedBox(height: 16),
                Divider(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  height: 1,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chi tiết chi phí',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 12),
                ...(invoice['ChiTiet'] as List).map((item) =>
                  _buildCostItem(Map<String, dynamic>.from(item as Map)),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  height: 1,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Tổng tiền',
                  _moneyFormat.format(tongTienValue),
                  isBold: true,
                ),
                if (giamBHYTValue > 0) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Giảm BHYT',
                    '-${_moneyFormat.format(giamBHYTValue)}',
                    valueColor: AppColors.success,
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng phải trả',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label,
                        ),
                      ),
                      Text(
                        _moneyFormat.format(soTienPhaiTraValue),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
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
                      onPressed: () async {
                        final maHoaDonRaw = invoice['MaHoaDon'];
                        final maHoaDon = maHoaDonRaw is int ? maHoaDonRaw.toString() : maHoaDonRaw as String;
                        final soTien = invoice['SoTienPhaiTra'];
                        final amount = soTien is String ? double.parse(soTien) : (soTien as num).toDouble();

                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          barrierDismissible: false,
                        );

                        try {
                          final token = await _sessionManager.getToken();
                          final response = await _dio.post(
                            '${ApiConfig.baseUrl}/vnpay/create-payment',
                            data: {
                              'maHoaDon': maHoaDon,
                              'soTien': amount,
                              if (kIsWeb) 'app_return_url': Uri.base.origin,
                            },
                            options: Options(
                              headers: {
                                'Authorization': 'Bearer $token',
                                'Content-Type': 'application/json',
                              },
                            ),
                          );

                          Get.back();

                          if (response.statusCode == 200 && response.data['success'] == true) {
                            final paymentUrl = response.data['data']['payment_url'] as String;

                            if (!mounted) return;

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VNPayPaymentView(
                                  paymentUrl: paymentUrl,
                                  maHoaDon: maHoaDon,
                                ),
                              ),
                            );

                            if (!mounted) return;

                            if (result == true) {
                              Navigator.pop(context);
                              _loadInvoices();
                            }
                          } else {
                            Get.back();
                            Get.snackbar(
                              'Lỗi',
                              'Không thể tạo link thanh toán',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        } catch (e) {
                          Get.back();
                          Get.snackbar(
                            'Lỗi',
                            e.toString(),
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
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
    );
  }

  Widget _buildCostItem(Map<String, dynamic> item) {
    final label = (item['TenHienThi'] ?? 'Dịch vụ').toString();
    final soLuong = item['SoLuong'] is String
        ? int.tryParse(item['SoLuong'] as String) ?? 1
        : (item['SoLuong'] as num?)?.toInt() ?? 1;
    final donGia = item['DonGia'] is String
        ? double.tryParse(item['DonGia'] as String) ?? 0
        : (item['DonGia'] as num?)?.toDouble() ?? 0;
    final thanhTien = item['ThanhTien'] is String
        ? double.tryParse(item['ThanhTien'] as String) ?? 0
        : (item['ThanhTien'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.label),
                ),
                if (soLuong > 0 && donGia > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$soLuong × ${_moneyFormat.format(donGia)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.subLabel),
                  ),
                ],
              ],
            ),
          ),
          Text(
            _moneyFormat.format(thanhTien),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
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
              color: AppColors.subLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              color: valueColor ?? AppColors.label,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
