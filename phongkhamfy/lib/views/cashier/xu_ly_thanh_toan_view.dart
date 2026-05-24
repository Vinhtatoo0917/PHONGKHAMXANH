import 'package:flutter/material.dart';
import 'package:phongkhamfy/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:phongkhamfy/services/session_manager.dart';

class XuLyThanhToanView extends StatefulWidget {
  const XuLyThanhToanView({super.key});

  @override
  State<XuLyThanhToanView> createState() => _XuLyThanhToanViewState();
}

class _XuLyThanhToanViewState extends State<XuLyThanhToanView> {
  final _dio = Dio();
  final _sessionManager = SessionManager();
  final _searchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _filteredInvoices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _searchController.addListener(_filterInvoices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    try {
      setState(() => _isLoading = true);

      final token = await _sessionManager.getToken();
      if (!mounted || token == null) return;

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/cashier/unpaid-invoices',
        queryParameters: {'date': dateStr},
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
          if (mounted) {
            setState(() {
              _invoices = invoiceList;
              _filteredInvoices = invoiceList;
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  void _filterInvoices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredInvoices = _invoices.where((inv) {
        final maHoaDon = inv['MaHoaDon'].toString();
        final tenBenhNhan = (inv['TenBenhNhan'] ?? '').toLowerCase();
        return maHoaDon.contains(query) || tenBenhNhan.contains(query);
      }).toList();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(title: 'Xử lý thanh toán'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelector(),
                  const SizedBox(height: 20),
                  _buildSearchBox(),
                  const SizedBox(height: 16),
                  Text(
                    'Danh sách hóa đơn chưa thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInvoicesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn ngày',
                        style: TextStyle(fontSize: 12, color: AppColors.subLabel),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: AppColors.primary),
              ],
            ),
          ),
        );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm mã hóa đơn hoặc tên bệnh nhân...',
          hintStyle: TextStyle(color: AppColors.subLabel),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (_filteredInvoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Không có hóa đơn chưa thanh toán',
                style: TextStyle(color: AppColors.label, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredInvoices.map((invoice) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildInvoiceCard(invoice),
      )).toList(),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPaymentOptions(invoice),
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
                            Text(
                              'Hóa đơn #${invoice['MaHoaDon']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppColors.label,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              invoice['TenBenhNhan'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.subLabel,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Chờ thanh toán',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.separator, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số tiền phải trả',
                              style: TextStyle(fontSize: 12, color: AppColors.subLabel)),
                          const SizedBox(height: 4),
                          Text(
                            _formatMoney(invoice['SoTienPhaiTra']),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => _showPaymentOptions(invoice),
                        icon: const Icon(Icons.payment_rounded, size: 20),
                        label: const Text('Thanh toán'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(Map<String, dynamic> invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPaymentSheet(invoice),
    );
  }

  Widget _buildPaymentSheet(Map<String, dynamic> invoice) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontSize: 20,
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
                const SizedBox(height: 8),
                Text(
                  'Hóa đơn #${invoice['MaHoaDon']} - ${invoice['TenBenhNhan']}',
                  style: const TextStyle(fontSize: 13, color: AppColors.subLabel),
                ),
                const SizedBox(height: 24),
                _buildPaymentMethodButton(
                  'Thanh toán ngân hàng',
                  'Quét mã QR hoặc chuyển khoản',
                  Icons.account_balance_rounded,
                  AppColors.primary,
                  () => _showBankPayment(invoice),
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodButton(
                  'Thanh toán tiền mặt',
                  'Nhân viên xác nhận thanh toán',
                  Icons.payments_rounded,
                  AppColors.success,
                  () => _showCashPayment(invoice),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.subLabel),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  void _showBankPayment(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thanh toán ngân hàng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin chuyển khoản',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBankInfo('Mã hoá đơn', '${invoice['MaHoaDon']}'),
                    _buildBankInfo('Bệnh nhân', '${invoice['TenBenhNhan']}'),
                    _buildBankInfo(
                      'Số tiền',
                      _formatMoney(invoice['SoTienPhaiTra']),
                      isAmount: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'INVOICE_${invoice['MaHoaDon']}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vui lòng sử dụng mã hoá đơn làm nội dung chuyển khoản',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              _updatePaymentStatus(invoice['MaHoaDon'], 'bank');
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Xác nhận thanh toán'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.subLabel),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isAmount ? 14 : 12,
              color: isAmount ? AppColors.primary : AppColors.label,
            ),
          ),
        ],
      ),
    );
  }

  void _showCashPayment(Map<String, dynamic> invoice) {
    Navigator.pop(context); // đóng sheet chọn phương thức
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CashPaymentSheet(
        invoice: invoice,
        onConfirm: () => _updatePaymentStatus(invoice['MaHoaDon'], 'cash'),
      ),
    );
  }

  Future<void> _updatePaymentStatus(int maHoaDon, String method) async {
    try {
      final token = await _sessionManager.getToken();
      if (token == null) return;

      await _dio.post(
        '${ApiConfig.baseUrl}/cashier/invoices/$maHoaDon/mark-paid',
        data: {'payment_method': method},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thanh toán thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadInvoices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  String _formatMoney(dynamic amount) {
    final value = amount is String ? double.parse(amount) : (amount as num).toDouble();
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);
  }
}

// ─────────────────────────────────────────────────────────────
// Sheet thanh toán tiền mặt
// ─────────────────────────────────────────────────────────────
class _CashPaymentSheet extends StatefulWidget {
  final Map<String, dynamic> invoice;
  final VoidCallback onConfirm;

  const _CashPaymentSheet({required this.invoice, required this.onConfirm});

  @override
  State<_CashPaymentSheet> createState() => _CashPaymentSheetState();
}

class _CashPaymentSheetState extends State<_CashPaymentSheet> {
  static final _fmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  late final double _soTienPhaiTra;
  late final double _tongTien;
  late final double _giamBHYT;
  double _khachDua = 0;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _soTienPhaiTra = _parse(widget.invoice['SoTienPhaiTra']);
    _tongTien = _parse(widget.invoice['TongTien']);
    _giamBHYT = _parse(widget.invoice['GiamBHYT']);
    _khachDua = _soTienPhaiTra;
    _ctrl = TextEditingController(text: _soTienPhaiTra.toInt().toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _parse(dynamic v) {
    if (v == null) return 0;
    if (v is String) return double.tryParse(v) ?? 0;
    return (v as num).toDouble();
  }

  void _setAmount(double amount) {
    setState(() {
      _khachDua = amount;
      _ctrl.text = amount.toInt().toString();
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tienThua = _khachDua - _soTienPhaiTra;
    final canConfirm = _khachDua >= _soTienPhaiTra && _khachDua > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.payments_rounded, color: AppColors.success, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thanh toán tiền mặt',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.label)),
                          Text('HĐ #${widget.invoice['MaHoaDon']} · ${widget.invoice['TenBenhNhan']}',
                              style: const TextStyle(fontSize: 12, color: AppColors.subLabel)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Invoice summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Tổng tiền dịch vụ', _tongTien, Colors.black87),
                      if (_giamBHYT > 0) ...[
                        const SizedBox(height: 8),
                        _summaryRow('Giảm BHYT', -_giamBHYT, AppColors.success),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Colors.grey.withValues(alpha: 0.25), height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Số tiền phải trả',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.label)),
                          Text(_fmt.format(_soTienPhaiTra),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Customer amount input
                const Text('Tiền khách đưa',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.label)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 12)],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.label),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                          onChanged: (v) {
                            final parsed = double.tryParse(v.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
                            setState(() => _khachDua = parsed);
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Text('đ',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick amount buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickBtn('Đúng tiền', () => _setAmount(_soTienPhaiTra), filled: true),
                    _quickBtn('+50k', () => _setAmount(_khachDua + 50000)),
                    _quickBtn('+100k', () => _setAmount(_khachDua + 100000)),
                    _quickBtn('+200k', () => _setAmount(_khachDua + 200000)),
                    _quickBtn('+500k', () => _setAmount(_khachDua + 500000)),
                    _quickBtn('+1M', () => _setAmount(_khachDua + 1000000)),
                  ],
                ),
                const SizedBox(height: 20),

                // Change display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: tienThua >= 0
                        ? AppColors.success.withValues(alpha: 0.08)
                        : Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: tienThua >= 0
                          ? AppColors.success.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            tienThua >= 0 ? Icons.check_circle_rounded : Icons.warning_rounded,
                            color: tienThua >= 0 ? AppColors.success : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tienThua >= 0 ? 'Tiền thừa trả lại' : 'Tiền còn thiếu',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: tienThua >= 0 ? AppColors.success : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _fmt.format(tienThua.abs()),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: tienThua >= 0 ? AppColors.success : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: canConfirm
                        ? () {
                            Navigator.pop(context);
                            widget.onConfirm();
                          }
                        : null,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(
                      canConfirm
                          ? 'Xác nhận thu ${_fmt.format(_soTienPhaiTra)}'
                          : 'Nhập tiền khách đưa',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _summaryRow(String label, double amount, Color color) {
    final display = amount < 0
        ? '-${_fmt.format(amount.abs())}'
        : _fmt.format(amount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.subLabel)),
        Text(display, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _quickBtn(String label, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: filled ? AppColors.primary : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : AppColors.label,
          ),
        ),
      ),
    );
  }
}
