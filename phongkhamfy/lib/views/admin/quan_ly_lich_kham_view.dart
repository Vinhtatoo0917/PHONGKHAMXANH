import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';

class QuanLyLichKhamView extends StatefulWidget {
  const QuanLyLichKhamView({super.key});

  @override
  State<QuanLyLichKhamView> createState() => _QuanLyLichKhamViewState();
}

class _QuanLyLichKhamViewState extends State<QuanLyLichKhamView> {
  final controller = Get.put(LichKhamController());
  final _currency = NumberFormat('#,###', 'vi_VN');
  final _dateParam = DateFormat('yyyy-MM-dd');
  final _dateView = DateFormat('dd/MM/yyyy');

  final _primary = const Color(0xFF0F9F7A);
  final _ink = const Color(0xFF12312A);
  final _muted = const Color(0xFF64748B);
  final _surface = Colors.white;
  final _background = const Color(0xFFF5FBF8);

  String? selectedStatus;
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  final List<Map<String, String?>> _statusFilters = const [
    {'value': null, 'label': 'Tất cả trạng thái'},
    {'value': 'pending', 'label': 'Chờ duyệt'},
    {'value': 'confirmed', 'label': 'Đã xác nhận'},
    {'value': 'rejected', 'label': 'Không được phê duyệt'},
    {'value': 'completed', 'label': 'Đã hoàn thành'},
    {'value': 'cancelled', 'label': 'Đã hủy'},
    {'value': 'no-show', 'label': 'Không đến'},
  ];

  final List<String> _rejectReasons = const [
    'Cần cập nhật thông tin',
    'Thông tin bệnh nhân chưa chính xác',
    'Lịch khám đã hết chỗ',
    'Dịch vụ không phù hợp với lịch chọn',
    'Cần liên hệ phòng khám để xác nhận thêm',
  ];

  @override
  void initState() {
    super.initState();
    selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
    selectedEndDate = DateTime.now().add(const Duration(days: 14));
    _loadAppointments();
  }

  Future<void> _loadAppointments({int page = 1}) {
    return controller.getAllAppointments(
      trangThai: selectedStatus,
      ngayBatDau: _dateParam.format(selectedStartDate),
      ngayKetThuc: _dateParam.format(selectedEndDate),
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Quản lý lịch khám',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: _surface,
        foregroundColor: _ink,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _loadAppointments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _loadAppointments,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildFilters(),
                  const SizedBox(height: 16),
                  Obx(_buildStatistics),
                  const SizedBox(height: 16),
                  _buildSectionTitle(),
                  const SizedBox(height: 12),
                  _buildAppointmentsList(),
                  const SizedBox(height: 12),
                  Obx(_buildPagination),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.event_available, color: _primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duyệt lịch khám trong ngày',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xem chi tiết bệnh nhân, xác nhận hoặc không phê duyệt lịch khám.',
                  style: TextStyle(color: _muted, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Bộ lọc lịch khám',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 680;
              final fields = [
                _dateField(
                  label: 'Từ ngày',
                  value: selectedStartDate,
                  onTap: () => _selectDate(true),
                ),
                _dateField(
                  label: 'Đến ngày',
                  value: selectedEndDate,
                  onTap: () => _selectDate(false),
                ),
                _statusDropdown(),
              ];

              if (narrow) {
                return Column(
                  children: [
                    for (final field in fields) ...[
                      SizedBox(width: double.infinity, child: field),
                      if (field != fields.last) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 12),
                  Expanded(child: fields[1]),
                  const SizedBox(width: 12),
                  Expanded(child: fields[2]),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loadAppointments,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text(
                'Tìm kiếm',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.calendar_today_outlined),
        child: Text(
          _dateView.format(value),
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _statusDropdown() {
    return DropdownButtonFormField<String?>(
      initialValue: selectedStatus,
      isExpanded: true,
      decoration: _inputDecoration('Trạng thái', Icons.flag_outlined),
      items: _statusFilters
          .map(
            (item) => DropdownMenuItem<String?>(
              value: item['value'],
              child: Text(item['label'] ?? ''),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => selectedStatus = value),
    );
  }

  Widget _buildStatistics() {
    final appointments = controller.allAppointments
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final pending = appointments
        .where((a) => a['TrangThai'] == 'pending')
        .length;
    final confirmed = appointments
        .where((a) => a['TrangThai'] == 'confirmed')
        .length;
    final rejected = appointments
        .where((a) => a['TrangThai'] == 'rejected')
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final cards = [
          _statCard(
            'Tổng lịch',
            '${appointments.length}',
            Icons.event_note,
            const Color(0xFF2563EB),
          ),
          _statCard(
            'Chờ duyệt',
            '$pending',
            Icons.pending_actions,
            const Color(0xFFF59E0B),
          ),
          _statCard(
            'Đã xác nhận',
            '$confirmed',
            Icons.verified_outlined,
            _primary,
          ),
          _statCard(
            'Không duyệt',
            '$rejected',
            Icons.block_outlined,
            const Color(0xFFDC2626),
          ),
        ];

        if (compact) {
          return Wrap(spacing: 10, runSpacing: 10, children: cards);
        }
        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(title, style: TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Text(
          'Danh sách lịch khám',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Obx(
          () => Text(
            'Trang ${controller.currentPage.value}/${controller.totalPages.value}',
            style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    return Obx(() {
      if (controller.isLoadingAllAppointments.value) {
        return _panel(
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 34),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (controller.allAppointments.isEmpty) {
        return _emptyState();
      }

      return Column(
        children: controller.allAppointments
            .whereType<Map>()
            .map((item) => _appointmentCard(Map<String, dynamic>.from(item)))
            .toList(),
      );
    });
  }

  Widget _appointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['TrangThai']?.toString();
    final statusColor = _statusColor(status);
    final patient = _patient(appointment);
    final services = _services(appointment);
    final time = _appointmentTime(appointment);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _panel(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_statusIcon(status), color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch khám #${appointment['MaLichKham'] ?? '--'}',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _chip(_statusLabel(status), statusColor),
                          _chip(
                            _paymentStatusLabel(
                              appointment['TrangThaiThanhToan']?.toString(),
                            ),
                            const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Chi tiết',
                  onPressed: () => _showDetailDialog(appointment),
                  icon: const Icon(Icons.open_in_new),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.black.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 640;
                final items = [
                  _infoTile(
                    Icons.person_outline,
                    'Bệnh nhân',
                    _text(patient['HoTen']),
                  ),
                  _infoTile(
                    Icons.phone_outlined,
                    'Số điện thoại',
                    _text(patient['SoDienThoai']),
                  ),
                  _infoTile(Icons.schedule, 'Thời gian', time),
                  _infoTile(
                    Icons.medical_services_outlined,
                    'Dịch vụ',
                    services.isEmpty
                        ? 'Chưa chọn dịch vụ'
                        : '${services.length} dịch vụ',
                  ),
                  _infoTile(
                    Icons.payments_outlined,
                    'Tổng tiền',
                    '${_currency.format(_toNum(appointment['TongTien']))} đ',
                  ),
                ];

                if (narrow) {
                  return Column(children: items);
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: items
                      .map((item) => SizedBox(width: 210, child: item))
                      .toList(),
                );
              },
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _updateStatus(appointment, 'confirmed'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Xác nhận'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(appointment),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.block_outlined),
                      label: const Text('Không duyệt'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primary, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: _muted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return _panel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined, color: _primary, size: 50),
            const SizedBox(height: 10),
            Text(
              'Không có lịch khám nào',
              style: TextStyle(
                color: _ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thử đổi khoảng ngày hoặc trạng thái để xem thêm lịch.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (controller.totalPages.value <= 1) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.currentPage.value <= 1
                ? null
                : () =>
                      _loadAppointments(page: controller.currentPage.value - 1),
            icon: const Icon(Icons.chevron_left),
            label: const Text('Trang trước'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed:
                controller.currentPage.value >= controller.totalPages.value
                ? null
                : () =>
                      _loadAppointments(page: controller.currentPage.value + 1),
            icon: const Icon(Icons.chevron_right),
            label: const Text('Trang sau'),
          ),
        ),
      ],
    );
  }

  Widget _panel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primary, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FCFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  void _showDetailDialog(Map<String, dynamic> appointment) {
    final patient = _patient(appointment);
    final services = _services(appointment);
    final status = appointment['TrangThai']?.toString();
    final reason = services
        .map(
          (item) => item['MoTa']?.toString() ?? item['MOTA']?.toString() ?? '',
        )
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _statusIcon(status),
                          color: _statusColor(status),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiết lịch #${appointment['MaLichKham'] ?? '--'}',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              _statusLabel(status),
                              style: TextStyle(color: _muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        onPressed: Get.back,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailSection('Thông tin lịch khám', [
                    _detailRow(
                      'Mã lịch khám',
                      '#${appointment['MaLichKham'] ?? '--'}',
                    ),
                    _detailRow('Số thứ tự', _text(appointment['SoThuTu'])),
                    _detailRow('Ngày khám', _dateText(appointment['Ngay'])),
                    _detailRow('Ca khám', _text(appointment['TenCa'])),
                    _detailRow('Giờ khám', _appointmentTime(appointment)),
                    _detailRow('Phòng khám', _text(appointment['TenPhong'])),
                    _detailRow('Trạng thái', _statusLabel(status)),
                    _detailRow(
                      'Thanh toán',
                      _paymentStatusLabel(
                        appointment['TrangThaiThanhToan']?.toString(),
                      ),
                    ),
                    _detailRow(
                      'Tổng tiền',
                      '${_currency.format(_toNum(appointment['TongTien']))} đ',
                    ),
                    if (reason.isNotEmpty)
                      _detailRow('Lý do không duyệt', reason),
                  ]),
                  _detailSection('Thông tin bệnh nhân', [
                    _detailRow('Mã bệnh nhân', _text(patient['MaBenhNhan'])),
                    _detailRow('Họ tên', _text(patient['HoTen'])),
                    _detailRow('Số điện thoại', _text(patient['SoDienThoai'])),
                    _detailRow('Email', _text(patient['Email'])),
                    _detailRow('Ngày sinh', _dateText(patient['NgaySinh'])),
                    _detailRow('Giới tính', _text(patient['GioiTinh'])),
                    _detailRow('CCCD', _text(patient['CCCD'])),
                    _detailRow('BHYT', _text(patient['BHYT'])),
                    _detailRow('Địa chỉ', _text(patient['DiaChi'])),
                  ]),
                  _detailSection('Bác sĩ và chuyên khoa', [
                    _detailRow('Bác sĩ', _text(appointment['TenBacSi'])),
                    _detailRow('Khoa', _text(appointment['TenKhoa'])),
                    _detailRow('Chuyên khoa', _text(appointment['ChuyenKhoa'])),
                  ]),
                  _servicesSection(services),
                  if (status == 'pending') ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Get.back();
                              _updateStatus(appointment, 'confirmed');
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Xác nhận lịch'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              _showRejectDialog(appointment);
                            },
                            icon: const Icon(Icons.block_outlined),
                            label: const Text('Không duyệt'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: _muted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicesSection(List<Map<String, dynamic>> services) {
    return _detailSection(
      'Dịch vụ đã chọn',
      services.isEmpty
          ? [_detailRow('Dịch vụ', 'Chưa có dịch vụ')]
          : services
                .map(
                  (service) => _detailRow(
                    service['TenDichVu']?.toString() ?? 'Dịch vụ',
                    '${_currency.format(_toNum(service['ThanhTien'] ?? service['Gia']))} đ',
                  ),
                )
                .toList(),
    );
  }

  Future<void> _showRejectDialog(Map<String, dynamic> appointment) async {
    var selectedReason = _rejectReasons.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text('Không phê duyệt lịch khám'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn lý do để lưu vào mô tả chi tiết lịch khám.'),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    isExpanded: true,
                    decoration: _inputDecoration('Lý do', Icons.notes_outlined),
                    items: _rejectReasons
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedReason = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                  child: const Text('Không duyệt'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _updateStatus(appointment, 'rejected', lyDoTuChoi: selectedReason);
    }
  }

  Future<void> _updateStatus(
    Map<String, dynamic> appointment,
    String status, {
    String? lyDoTuChoi,
  }) async {
    final id = _toInt(appointment['MaLichKham']);
    if (id == null) return;

    await controller.updateAppointmentStatus(
      maLichKham: id,
      trangThai: status,
      lyDoTuChoi: lyDoTuChoi,
      refresh: false,
    );
    await _loadAppointments(page: controller.currentPage.value);
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isStartDate) {
        selectedStartDate = picked;
        if (selectedStartDate.isAfter(selectedEndDate)) {
          selectedEndDate = selectedStartDate;
        }
      } else {
        selectedEndDate = picked;
        if (selectedEndDate.isBefore(selectedStartDate)) {
          selectedStartDate = selectedEndDate;
        }
      }
    });
  }

  Map<String, dynamic> _patient(Map<String, dynamic> appointment) {
    final raw = appointment['BenhNhan'];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {
      'MaBenhNhan': appointment['MaBenhNhan'],
      'HoTen': appointment['MaBenhNhan'] == null
          ? 'Chưa cập nhật'
          : 'Bệnh nhân #${appointment['MaBenhNhan']}',
    };
  }

  List<Map<String, dynamic>> _services(Map<String, dynamic> appointment) {
    final raw = appointment['DichVu'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  String _appointmentTime(Map<String, dynamic> appointment) {
    final date = _dateText(appointment['Ngay']);
    final start = appointment['GioBatDau']?.toString();
    final end = appointment['GioKetThuc']?.toString();
    final range = [
      if (start != null && start.isNotEmpty) _shortTime(start),
      if (end != null && end.isNotEmpty) _shortTime(end),
    ].join(' - ');
    if (range.isEmpty) return date;
    return '$date, $range';
  }

  String _dateText(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Chưa cập nhật';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return _dateView.format(parsed);
  }

  String _shortTime(String value) {
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  String _text(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? 'Chưa cập nhật' : text;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  num _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF2563EB);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'completed':
        return _primary;
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'no-show':
        return const Color(0xFF64748B);
      default:
        return _muted;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'confirmed':
        return Icons.verified_outlined;
      case 'rejected':
        return Icons.block_outlined;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'no-show':
        return Icons.person_off_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'rejected':
        return 'Không được phê duyệt';
      case 'completed':
        return 'Đã hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'no-show':
        return 'Không đến';
      default:
        return 'Không xác định';
    }
  }

  String _paymentStatusLabel(String? status) {
    switch (status) {
      case 'paid':
        return 'Đã thanh toán';
      case 'partial':
        return 'Thanh toán một phần';
      case 'unpaid':
        return 'Chưa thanh toán';
      default:
        return 'Chưa xác định';
    }
  }
}
