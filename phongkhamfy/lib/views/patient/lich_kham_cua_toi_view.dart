import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';
import 'package:phongkhamfy/widgets/loading_view.dart';

extension _AppointmentMap on Map<String, dynamic> {
  int? get maLichKham => _toInt(this['MaLichKham']);
  int? get soThuTu => _toInt(this['SoThuTu']);
  double? get tongTien => _toDouble(this['TongTien']);
  String? get trangThai => this['TrangThai']?.toString();
  String? get trangThaiThanhToan => this['TrangThaiThanhToan']?.toString();
  String? get ngay => this['Ngay']?.toString();
  String? get gioBatDau => this['GioBatDau']?.toString();
  String? get gioKetThuc => this['GioKetThuc']?.toString();
  String? get tenBacSi => this['TenBacSi']?.toString();
  String? get chuyenKhoa => this['ChuyenKhoa']?.toString();
  String? get tenPhong => this['TenPhong']?.toString();
  List<Map<String, dynamic>> get dichVu {
    final raw = this['DichVu'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  String? get reason {
    for (final item in dichVu) {
      final m = item['MoTa']?.toString() ?? item['MOTA']?.toString();
      if (m != null && m.isNotEmpty) return m;
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

extension _ServiceMap on Map<String, dynamic> {
  String? get tenDichVu => this['TenDichVu']?.toString();
}

class LichKhamCuaToiView extends StatefulWidget {
  const LichKhamCuaToiView({super.key});

  @override
  State<LichKhamCuaToiView> createState() => _LichKhamCuaToiViewState();
}

class _LichKhamCuaToiViewState extends State<LichKhamCuaToiView> {
  static const _primary = Color(0xFF1565C0);
  static const _secondary = Color(0xFF00A6A6);
  static const _surface = Colors.white;
  static const _background = Color(0xFFF4F7FB);
  static const _text = Color(0xFF172033);
  static const _muted = Color(0xFF667085);
  static const _line = Color(0xFFE4E9F2);
  static const _warning = Color(0xFFFFB020);
  static const _danger = Color(0xFFE5484D);

  final LichKhamController controller = Get.put(LichKhamController());
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  @override
  void initState() {
    super.initState();
    controller.getMyAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          return RefreshIndicator(
            color: _primary,
            onRefresh: controller.getMyAppointments,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                if (controller.isLoadingMyAppointments.value)
                  _buildLoadingList()
                else if (controller.myAppointments.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else ...[
                  SliverToBoxAdapter(child: _buildOverview()),
                  SliverToBoxAdapter(child: _buildSectionTitle()),
                  _buildAppointmentList(),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, Color(0xFF0E8A9A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.maybePop(context),
              ),
              const Spacer(),
              _IconButton(
                icon: Icons.add_rounded,
                onTap: () => Get.toNamed('/dat-lich-kham'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Lịch khám của tôi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Theo dõi lịch hẹn, phòng khám, dịch vụ và trạng thái thanh toán trong một nơi.',
            style: TextStyle(
              color: Color(0xFFE8F6FF),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final appointments = controller.myAppointments;
    final upcoming = appointments
        .where(
          (item) =>
              item.trangThai == 'pending' || item.trangThai == 'confirmed' || item.trangThai == 'examining',
        )
        .length;
    final completed = appointments
        .where((item) => item.trangThai == 'completed')
        .length;

    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              icon: Icons.event_available_rounded,
              label: 'Sắp tới',
              value: upcoming.toString(),
              color: _primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              icon: Icons.task_alt_rounded,
              label: 'Hoàn tất',
              value: completed.toString(),
              color: _secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              icon: Icons.receipt_long_rounded,
              label: 'Tổng lịch',
              value: appointments.length.toString(),
              color: _warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        'Lịch sử đặt khám',
        style: TextStyle(
          color: _text,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final appointment = controller.myAppointments[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 6, 16, 12),
          child: _AppointmentCard(
            appointment: appointment,
            dateText: _formatDate(appointment.ngay),
            timeText: _formatRange(
              appointment.gioBatDau,
              appointment.gioKetThuc,
            ),
            moneyText: _moneyFormat.format(appointment.tongTien ?? 0),
            statusColor: _getStatusColor(appointment.trangThai),
            statusLabel: _getStatusLabel(appointment.trangThai),
            paymentLabel: _getPaymentStatusLabel(
              appointment.trangThaiThanhToan,
            ),
            onCancel: appointment.trangThai == 'pending'
                ? () => _showCancelDialog(appointment.maLichKham)
                : null,
            onDetail: () => _showDetailSheet(appointment),
          ),
        );
      }, childCount: controller.myAppointments.length),
    );
  }

  Widget _buildLoadingList() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: LoadingView(
        message: 'Đang tải lịch khám của bạn...',
        isOverlay: false,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 42,
              color: _primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Chưa có lịch khám nào',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn dịch vụ cần khám để hệ thống gợi ý bác sĩ và suất khám phù hợp.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, height: 1.4),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () => Get.toNamed('/dat-lich-kham'),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Đặt lịch khám'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return value ?? 'Chưa có ngày';
    return _dateFormat.format(date);
  }

  String _formatRange(String? start, String? end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '--:--';
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return _warning;
      case 'confirmed':
        return _primary;
      case 'examining':
        return _primary;
      case 'completed':
        return _secondary;
      case 'cancelled':
        return _danger;
      case 'no-show':
        return _muted;
      default:
        return _muted;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'examining':
        return 'Đang khám';
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

  String _getPaymentStatusLabel(String? status) {
    switch (status) {
      case 'paid':
        return 'Đã thanh toán';
      case 'partial':
        return 'Thanh toán một phần';
      case 'unpaid':
        return 'Chưa thanh toán';
      default:
        return 'Không xác định';
    }
  }

  void _showCancelDialog(int? maLichKham) {
    if (maLichKham == null) return;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hủy lịch khám'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch khám này?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Không')),
          FilledButton(
            onPressed: () async {
              Get.back();
              await controller.cancelAppointment(maLichKham);
            },
            style: FilledButton.styleFrom(backgroundColor: _danger),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(Map<String, dynamic> appointment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailSheet(
        appointment: appointment,
        dateText: _formatDate(appointment.ngay),
        timeText: _formatRange(appointment.gioBatDau, appointment.gioKetThuc),
        moneyText: _moneyFormat.format(appointment.tongTien ?? 0),
        statusColor: _getStatusColor(appointment.trangThai),
        statusLabel: _getStatusLabel(appointment.trangThai),
        paymentLabel: _getPaymentStatusLabel(appointment.trangThaiThanhToan),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final String dateText;
  final String timeText;
  final String moneyText;
  final Color statusColor;
  final String statusLabel;
  final String paymentLabel;
  final VoidCallback? onCancel;
  final VoidCallback onDetail;

  const _AppointmentCard({
    required this.appointment,
    required this.dateText,
    required this.timeText,
    required this.moneyText,
    required this.statusColor,
    required this.statusLabel,
    required this.paymentLabel,
    required this.onDetail,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final services = appointment.dichVu;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _LichKhamCuaToiViewState._surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _LichKhamCuaToiViewState._line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.event_note_rounded, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch khám #${appointment.maLichKham ?? '--'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _LichKhamCuaToiViewState._text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.tenBacSi ?? 'Bác sĩ chưa cập nhật',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _LichKhamCuaToiViewState._muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.calendar_today_rounded,
                text: dateText,
                color: _LichKhamCuaToiViewState._primary,
              ),
              _InfoPill(
                icon: Icons.schedule_rounded,
                text: timeText,
                color: _LichKhamCuaToiViewState._secondary,
              ),
              _InfoPill(
                icon: Icons.meeting_room_rounded,
                text: appointment.tenPhong ?? 'Phòng khám',
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  label: 'Số thứ tự',
                  value: '#${appointment.soThuTu ?? '--'}',
                ),
              ),
              Expanded(
                child: _MiniInfo(label: 'Thanh toán', value: paymentLabel),
              ),
              Expanded(
                child: _MiniInfo(label: 'Tạm tính', value: moneyText),
              ),
            ],
          ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              services
                  .map((service) => service.tenDichVu ?? 'Dịch vụ')
                  .join(' • '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _LichKhamCuaToiViewState._text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (appointment.reason != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (appointment.trangThai == 'rejected'
                        ? _LichKhamCuaToiViewState._danger
                        : _LichKhamCuaToiViewState._primary)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (appointment.trangThai == 'rejected'
                          ? _LichKhamCuaToiViewState._danger
                          : _LichKhamCuaToiViewState._primary)
                      .withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: appointment.trangThai == 'rejected'
                        ? _LichKhamCuaToiViewState._danger
                        : _LichKhamCuaToiViewState._primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ghi chú: ${appointment.reason}',
                      style: TextStyle(
                        color: appointment.trangThai == 'rejected'
                            ? _LichKhamCuaToiViewState._danger
                            : _LichKhamCuaToiViewState._text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (onCancel != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _LichKhamCuaToiViewState._danger,
                      side: const BorderSide(
                        color: _LichKhamCuaToiViewState._danger,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDetail,
                  style: FilledButton.styleFrom(
                    backgroundColor: _LichKhamCuaToiViewState._primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('Chi tiết'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final String dateText;
  final String timeText;
  final String moneyText;
  final Color statusColor;
  final String statusLabel;
  final String paymentLabel;

  const _DetailSheet({
    required this.appointment,
    required this.dateText,
    required this.timeText,
    required this.moneyText,
    required this.statusColor,
    required this.statusLabel,
    required this.paymentLabel,
  });

  @override
  Widget build(BuildContext context) {
    final services = appointment.dichVu;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        math.max(MediaQuery.of(context).padding.bottom, 16),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STT: #${appointment.soThuTu ?? '--'}',
                        style: const TextStyle(
                          color: _LichKhamCuaToiViewState._muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateText,
                        style: const TextStyle(
                          color: _LichKhamCuaToiViewState._text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeText • ${appointment.tenPhong ?? 'Phòng'}',
                        style: const TextStyle(
                          color: _LichKhamCuaToiViewState._primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.person_rounded,
              label: 'Bác sĩ',
              value: appointment.tenBacSi ?? 'Chưa cập nhật',
            ),
            _DetailRow(
              icon: Icons.local_hospital_rounded,
              label: 'Chuyên khoa',
              value: appointment.chuyenKhoa ?? 'Chưa cập nhật',
            ),
            _DetailRow(
              icon: Icons.calendar_month_rounded,
              label: 'Ngày khám',
              value: dateText,
            ),
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: 'Giờ khám',
              value: timeText,
            ),
            _DetailRow(
              icon: Icons.meeting_room_rounded,
              label: 'Phòng khám',
              value: appointment.tenPhong ?? 'Chưa cập nhật',
            ),
            _DetailRow(
              icon: Icons.confirmation_number_rounded,
              label: 'Số thứ tự',
              value: '#${appointment.soThuTu ?? '--'}',
            ),
            _DetailRow(
              icon: Icons.payments_rounded,
              label: 'Thanh toán',
              value: paymentLabel,
            ),
            const Divider(height: 26),
            const Text(
              'Dịch vụ',
              style: TextStyle(
                color: _LichKhamCuaToiViewState._text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            if (services.isEmpty)
              const Text(
                'Chưa có dịch vụ trong lịch khám này.',
                style: TextStyle(color: _LichKhamCuaToiViewState._muted),
              )
            else
              ...services.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: _LichKhamCuaToiViewState._secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service.tenDichVu ?? 'Dịch vụ khám',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _LichKhamCuaToiViewState._text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if ((appointment['PhieuChiDinh'] as List? ?? []).isNotEmpty) ...[
              const Divider(height: 26),
              const Text(
                'Phiếu chỉ định xét nghiệm',
                style: TextStyle(
                  color: _LichKhamCuaToiViewState._text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...(appointment['PhieuChiDinh'] as List? ?? []).map((phieu) {
                final chiTiet = (phieu['ChiTiet'] as List? ?? []).cast<Map<String, dynamic>>();
                final tenBacSi = phieu['BacSiThucHien']?.toString() ?? 'Bác sĩ xét nghiệm';
                final chuyenKhoa = phieu['ChuyenKhoaBacSiThucHien']?.toString() ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _LichKhamCuaToiViewState._primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.science_rounded, size: 18, color: _LichKhamCuaToiViewState._primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phiếu #${phieu['MaPhieu']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  '$tenBacSi${chuyenKhoa.isNotEmpty ? " • $chuyenKhoa" : ""}',
                                  style: const TextStyle(fontSize: 11, color: _LichKhamCuaToiViewState._muted),
                                ),
                                if ((phieu['TenPhongXetNghiem']?.toString() ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.meeting_room_rounded, size: 11, color: _LichKhamCuaToiViewState._secondary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Phòng: ${phieu['TenPhongXetNghiem']}${(phieu['KhuPhongXetNghiem']?.toString() ?? '').isNotEmpty ? " (Khu ${phieu['KhuPhongXetNghiem']})" : ""}',
                                            style: const TextStyle(fontSize: 10, color: _LichKhamCuaToiViewState._secondary, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _LichKhamCuaToiViewState._primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              phieu['TrangThai'] == 'pending' ? 'Chờ xử lý' : phieu['TrangThai'] == 'processing' ? 'Đang xử lý' : 'Hoàn tất',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _LichKhamCuaToiViewState._primary),
                            ),
                          ),
                        ],
                      ),
                      if (chiTiet.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 8),
                        const SizedBox(height: 4),
                        ...chiTiet.take(3).map((ct) {
                          final tenDV = ct['TenDichVu']?.toString() ?? 'Dịch vụ';
                          final trangThai = ct['TrangThai']?.toString() ?? '';
                          final ketQua = ct['KetQua']?.toString() ?? '';
                          final chiSo = ct['ChiSo']?.toString() ?? '';
                          final hasResult = ketQua.isNotEmpty || chiSo.isNotEmpty;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      trangThai == 'completed' ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      size: 10,
                                      color: trangThai == 'completed' ? _LichKhamCuaToiViewState._secondary : _LichKhamCuaToiViewState._muted,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(tenDV, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                if (hasResult) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, top: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (chiSo.isNotEmpty)
                                          Text('Chỉ số: $chiSo', style: const TextStyle(fontSize: 10, color: _LichKhamCuaToiViewState._secondary, fontWeight: FontWeight.w600)),
                                        if (ketQua.isNotEmpty)
                                          Text('Kết quả: $ketQua', style: const TextStyle(fontSize: 10, color: _LichKhamCuaToiViewState._secondary, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        if (chiTiet.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+${chiTiet.length - 3} khác',
                              style: const TextStyle(fontSize: 11, color: _LichKhamCuaToiViewState._muted, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                   const Text(
                    'Tổng tiền',
                    style: TextStyle(
                      color: _LichKhamCuaToiViewState._muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    moneyText,
                    style: const TextStyle(
                      color: _LichKhamCuaToiViewState._primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (appointment['TrangThai'] == 'completed') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => _showConclusionModal(context, appointment),
                  style: FilledButton.styleFrom(
                    backgroundColor: _LichKhamCuaToiViewState._warning,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.assignment_rounded),
                  label: const Text(
                    'Xem kết luận khám',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showConclusionModal(BuildContext context, Map<String, dynamic> appointment) {
    final ketLuan = appointment['KetLuan'];
    if (ketLuan == null) {
      Get.snackbar('Thông báo', 'Hồ sơ kết luận đang được bác sĩ cập nhật.');
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kết luận của bác sĩ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow('Chẩn đoán:', ketLuan['ChanDoan'] ?? 'Chưa có'),
            const SizedBox(height: 16),
            _infoRow('Tình trạng:', ketLuan['TinhTrang'] ?? 'Chưa có'),
            const SizedBox(height: 16),
            _infoRow('Hướng điều trị:', ketLuan['HuongDieuTri'] ?? 'Chưa có'),
            const SizedBox(height: 24),
            if (ketLuan['HuongDieuTri'] == 'Kê đơn thuốc' && appointment['DonThuoc'] != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _showPrescriptionModal(context, appointment['DonThuoc']),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _LichKhamCuaToiViewState._primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.medication_liquid_rounded),
                  label: const Text('Xem toa thuốc', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPrescriptionModal(BuildContext buildCtx, Map<String, dynamic> donThuoc) {
    final chiTiet = donThuoc['ChiTiet'] as List? ?? [];

    const primary = Color(0xFF1565C0);
    const text = Color(0xFF172033);
    const muted = Color(0xFF667085);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.92),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primary.withValues(alpha: 0.2),
                              primary.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.medication_liquid_rounded,
                          color: primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Toa thuốc',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (chiTiet.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Không có thông tin thuốc.',
                        style: TextStyle(color: muted, fontSize: 14),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(maxHeight: MediaQuery.of(buildCtx).size.height * 0.5),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: chiTiet.length,
                        separatorBuilder: (_, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            color: primary.withValues(alpha: 0.1),
                            height: 1,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final item = chiTiet[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            primary.withValues(alpha: 0.3),
                                            primary.withValues(alpha: 0.15),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primary.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['TenThuoc'] ?? 'Thuốc',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              color: text,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item['HamLuong']} - ${item['DonViTinh']}',
                                            style: TextStyle(
                                              color: muted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            primary.withValues(alpha: 0.15),
                                            primary.withValues(alpha: 0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: primary.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        'x${item['SoLuong']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      'Hướng dẫn: ${item['LieuDung']}',
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Get.back(),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Đóng',
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
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _LichKhamCuaToiViewState._text)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _LichKhamCuaToiViewState._primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _LichKhamCuaToiViewState._muted),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _LichKhamCuaToiViewState._text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _LichKhamCuaToiViewState._text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _LichKhamCuaToiViewState._muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _LichKhamCuaToiViewState._muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _LichKhamCuaToiViewState._text,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;

  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
