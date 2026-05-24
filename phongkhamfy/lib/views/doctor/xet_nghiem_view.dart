import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';
import 'package:phongkhamfy/widgets/loading_view.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/theme/app_theme.dart';

class XetNghiemView extends StatefulWidget {
  const XetNghiemView({super.key});

  @override
  State<XetNghiemView> createState() => _XetNghiemViewState();
}

class _XetNghiemViewState extends State<XetNghiemView> with SingleTickerProviderStateMixin {
  late TabController _sourceTabController;
  final controller = Get.find<LichKhamController>();

  final RxString _statusFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    _sourceTabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _sourceTabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controller.getDoctorSchedule(ngayBatDau: today, ngayKetThuc: today);
    controller.getMyTestOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(title: 'Xét nghiệm'),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _sourceTabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.subLabel,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.event_note_rounded, size: 20), text: 'Lịch xét nghiệm'),
                Tab(icon: Icon(Icons.assignment_rounded, size: 20), text: 'Phiếu chỉ định'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _sourceTabController,
              children: [
                _buildDirectAppointmentsTab(),
                _buildReferralOrdersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips({required List<String> values, required List<String> labels}) {
    return Obx(() {
      final current = _statusFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: List.generate(values.length, (i) {
            final isSelected = current == values[i];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labels[i]),
                selected: isSelected,
                onSelected: (_) => _statusFilter.value = values[i],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            );
          }),
        ),
      );
    });
  }

  // --------------- TAB 1: DIRECT APPOINTMENTS ---------------

  Widget _buildDirectAppointmentsTab() {
    return Column(
      children: [
        _buildStatusChips(
          values: const ['all', 'confirmed', 'completed', 'no-show'],
          labels: const ['Tất cả', 'Đang chờ', 'Hoàn thành', 'Vắng mặt'],
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingDoctorSchedule.value && controller.doctorSchedules.isEmpty) {
              return const LoadingView(message: 'Đang tải lịch xét nghiệm...', isOverlay: false);
            }

            final allAppointments = <Map<String, dynamic>>[];
            for (final schedule in controller.doctorSchedules) {
              final list = schedule['LichKham'] as List? ?? [];
              for (final item in list) {
                final appt = Map<String, dynamic>.from(item);
                appt['_NgayKham'] = schedule['Ngay'];
                appt['_TenCa'] = schedule['TenCa'];
                appt['_GioBatDau'] = schedule['GioBatDau'];
                appt['_TenPhong'] = schedule['TenPhong'];
                allAppointments.add(appt);
              }
            }

            final filter = _statusFilter.value;
            final filtered = filter == 'all'
                ? allAppointments
                : allAppointments.where((a) => a['TrangThai'] == filter).toList();

            if (filtered.isEmpty) {
              return _buildEmptyState(
                'Không có lịch xét nghiệm',
                'Hiện chưa có bệnh nhân đặt lịch xét nghiệm trong khoảng thời gian này.',
                Icons.event_note_rounded,
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildDirectCard(filtered[index]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDirectCard(Map<String, dynamic> appointment) {
    final patientName = appointment['TenBenhNhan']?.toString() ?? 'N/A';
    final status = appointment['TrangThai']?.toString() ?? 'confirmed';
    final soThuTu = appointment['SoThuTu']?.toString() ?? '-';
    final ngay = appointment['_NgayKham']?.toString() ?? '';
    final tenCa = appointment['_TenCa']?.toString() ?? '';
    final gioBatDau = appointment['_GioBatDau']?.toString() ?? '';
    final tenPhong = appointment['_TenPhong']?.toString() ?? '';
    final phieuChiDinh = appointment['PhieuChiDinh'] as List? ?? [];

    final (statusColor, statusIcon, statusText) = _mapDirectStatus(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAppointmentDetails(appointment),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_rounded, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.label,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'STT $soThuTu • ${[ngay, tenCa, gioBatDau].where((s) => s.isNotEmpty).join(' • ')}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (tenPhong.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.meeting_room_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        tenPhong,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                if (phieuChiDinh.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.science_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Có ${phieuChiDinh.length} phiếu xét nghiệm kèm theo',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, IconData, String) _mapDirectStatus(String status) {
    switch (status) {
      case 'confirmed':
        return (AppColors.warning, Icons.access_time_rounded, 'Đang chờ');
      case 'completed':
        return (AppColors.success, Icons.check_circle_rounded, 'Hoàn thành');
      case 'no-show':
        return (Colors.redAccent, Icons.cancel_rounded, 'Vắng mặt');
      default:
        return (Colors.grey, Icons.help_outline, status);
    }
  }

  // --------------- TAB 2: REFERRAL ORDERS ---------------

  Widget _buildReferralOrdersTab() {
    return Column(
      children: [
        _buildStatusChips(
          values: const ['all', 'pending', 'processing', 'completed'],
          labels: const ['Tất cả', 'Chờ xử lý', 'Đang xử lý', 'Hoàn thành'],
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingMyTestOrders.value && controller.myTestOrders.isEmpty) {
              return const LoadingView(message: 'Đang tải phiếu chỉ định...', isOverlay: false);
            }

            final filter = _statusFilter.value;
            final orders = filter == 'all'
                ? controller.myTestOrders
                : controller.myTestOrders.where((o) => o['TrangThai'] == filter).toList();

            if (orders.isEmpty) {
              return _buildEmptyState(
                'Không có phiếu chỉ định',
                'Hiện chưa có bác sĩ khác chỉ định xét nghiệm cho bạn.',
                Icons.assignment_rounded,
              );
            }

            return RefreshIndicator(
              onRefresh: () async => controller.getMyTestOrders(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: orders.length,
                itemBuilder: (context, index) => _buildReferralCard(orders[index]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReferralCard(Map<String, dynamic> order) {
    final patientName = order['TenBenhNhan']?.toString() ?? 'N/A';
    final bacSiYC = order['BacSiYeuCau']?.toString();
    final chuyenKhoaYC = order['ChuyenKhoaYeuCau']?.toString();
    final ngayChiDinh = order['NgayChiDinh']?.toString() ?? '';
    final status = order['TrangThai']?.toString() ?? 'pending';
    final ghiChu = order['GhiChu']?.toString();
    final chiTiet = order['ChiTiet'] as List? ?? [];

    final (statusColor, statusIcon, statusText) = _mapReferralStatus(status);
    final formattedDate = _formatDateTime(ngayChiDinh);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReferralDetails(order),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_rounded, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.label,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (formattedDate.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (bacSiYC != null && bacSiYC.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.medical_services_rounded, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BS yêu cầu: $bacSiYC',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.label,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (chuyenKhoaYC != null && chuyenKhoaYC.isNotEmpty)
                                Text(
                                  chuyenKhoaYC,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (chiTiet.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: chiTiet.take(3).map<Widget>((ct) {
                      final name = (ct as Map)['TenDichVu']?.toString() ?? 'Dịch vụ';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          name,
                          style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList()
                      ..addAll(chiTiet.length > 3
                          ? [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '+${chiTiet.length - 3}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            ]
                          : []),
                  ),
                ],
                if (ghiChu != null && ghiChu.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ghiChu,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
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
    );
  }

  (Color, IconData, String) _mapReferralStatus(String status) {
    switch (status) {
      case 'pending':
        return (AppColors.warning, Icons.pending_actions_rounded, 'Chờ xử lý');
      case 'processing':
        return (AppColors.info, Icons.science_rounded, 'Đang xử lý');
      case 'completed':
        return (AppColors.success, Icons.check_circle_rounded, 'Hoàn thành');
      default:
        return (Colors.grey, Icons.help_outline, status);
    }
  }

  String _formatDateTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  // --------------- DETAIL SHEETS ---------------

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildDirectDetailsSheet(appointment),
    );
  }

  Widget _buildDirectDetailsSheet(Map<String, dynamic> appointment) {
    final patientName = appointment['TenBenhNhan']?.toString() ?? 'N/A';
    final soThuTu = appointment['SoThuTu']?.toString() ?? '-';
    final ngay = appointment['_NgayKham']?.toString() ?? '';
    final tenCa = appointment['_TenCa']?.toString() ?? '';
    final tenPhong = appointment['_TenPhong']?.toString() ?? '';
    final phieuChiDinh = appointment['PhieuChiDinh'] as List? ?? [];
    final status = appointment['TrangThai']?.toString() ?? 'confirmed';
    final maLichKham = appointment['MaLichKham'] as int?;
    final (statusColor, _, statusText) = _mapDirectStatus(status);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailHeader('Chi tiết lịch xét nghiệm', statusText, statusColor, Icons.event_note_rounded),
                  const SizedBox(height: 20),
                  _buildDetailRow('Bệnh nhân', patientName, Icons.person_rounded),
                  _buildDetailRow('Số thứ tự', soThuTu, Icons.format_list_numbered_rounded),
                  if (ngay.isNotEmpty) _buildDetailRow('Ngày khám', ngay, Icons.calendar_today_rounded),
                  if (tenCa.isNotEmpty) _buildDetailRow('Ca khám', tenCa, Icons.access_time_rounded),
                  if (tenPhong.isNotEmpty) _buildDetailRow('Phòng', tenPhong, Icons.meeting_room_rounded),
                  if (phieuChiDinh.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Phiếu chỉ định đính kèm',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.label),
                    ),
                    const SizedBox(height: 8),
                    ...phieuChiDinh.map((p) => _buildPhieuChiDinhSummary(Map<String, dynamic>.from(p as Map))),
                  ],
                  if (status == 'confirmed' && maLichKham != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _hoanTatLichTrucTiep(maLichKham),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Hoàn tất khám'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _hoanTatLichTrucTiep(int maLichKham) async {
    Navigator.pop(context);
    await controller.updateAppointmentStatusByDoctor(maLichKham, 'completed');
    _loadData();
  }

  void _showReferralDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReferralWorkflowSheet(
        order: order,
        onChanged: _loadData,
      ),
    );
  }

  Widget _detailHeader(String title, String statusText, Color statusColor, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: statusColor, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.label),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey[600], fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhieuChiDinhSummary(Map<String, dynamic> phieu) {
    final chiTiet = phieu['ChiTiet'] as List? ?? [];
    final statusText = phieu['TrangThai']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Phiếu #${phieu['MaPhieu']}',
                style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (statusText.isNotEmpty)
                Text(
                  statusText,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w700),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ...chiTiet.map((ct) {
            final m = ct as Map;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      m['TenDichVu']?.toString() ?? '',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.label),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(icon, size: 56, color: Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w600, height: 1.4),
        ),
      ],
    );
  }
}


const _wfPrimary = AppColors.primary;
const _wfPending = AppColors.warning;
const _wfProcessing = AppColors.info;
const _wfCompleted = AppColors.success;

class _ReferralWorkflowSheet extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onChanged;

  const _ReferralWorkflowSheet({required this.order, required this.onChanged});

  @override
  State<_ReferralWorkflowSheet> createState() => _ReferralWorkflowSheetState();
}

class _ReferralWorkflowSheetState extends State<_ReferralWorkflowSheet> {
  late Map<String, dynamic> _order;
  final Map<int, TextEditingController> _ketQuaCtrls = {};
  final Map<int, TextEditingController> _chiSoCtrls = {};

  LichKhamController get _controller => Get.find<LichKhamController>();

  @override
  void initState() {
    super.initState();
    _order = Map<String, dynamic>.from(widget.order);
    _seedControllers();
  }

  void _seedControllers() {
    final chiTiet = _order['ChiTiet'] as List? ?? [];
    for (final ct in chiTiet) {
      final m = Map<String, dynamic>.from(ct as Map);
      final id = m['MaChiTietPhieu'] as int?;
      if (id == null) continue;
      _ketQuaCtrls[id] ??= TextEditingController(text: m['KetQua']?.toString() ?? '');
      _chiSoCtrls[id] ??= TextEditingController(text: m['ChiSo']?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _ketQuaCtrls.values) {
      c.dispose();
    }
    for (final c in _chiSoCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _refreshOrder() {
    final maPhieu = _order['MaPhieu'];
    final updated = _controller.myTestOrders.firstWhereOrNull(
      (o) => o['MaPhieu'] == maPhieu,
    );
    if (updated != null && mounted) {
      setState(() {
        _order = Map<String, dynamic>.from(updated);
        _seedControllers();
      });
    }
  }

  Future<void> _onTiepNhan() async {
    final maPhieu = _order['MaPhieu'] as int?;
    if (maPhieu == null) return;
    final ok = await _controller.tiepNhanPhieuChiDinh(maPhieu);
    if (ok) _refreshOrder();
  }

  Future<void> _onHoanTat() async {
    final maPhieu = _order['MaPhieu'] as int?;
    if (maPhieu == null) return;

    final chiTiet = _order['ChiTiet'] as List? ?? [];
    final payload = <Map<String, dynamic>>[];
    final missing = <String>[];

    for (final ct in chiTiet) {
      final m = Map<String, dynamic>.from(ct as Map);
      final id = m['MaChiTietPhieu'] as int?;
      if (id == null) continue;
      final ketQua = _ketQuaCtrls[id]?.text.trim() ?? '';
      final chiSo = _chiSoCtrls[id]?.text.trim() ?? '';
      if (ketQua.isEmpty && chiSo.isEmpty) {
        missing.add(m['TenDichVu']?.toString() ?? 'Dịch vụ #$id');
      }
      payload.add({
        'ma_chi_tiet_phieu': id,
        'ket_qua': ketQua.isEmpty ? null : ketQua,
        'chi_so': chiSo.isEmpty ? null : chiSo,
      });
    }

    if (missing.isNotEmpty) {
      Get.snackbar(
        'Thiếu kết quả',
        'Vui lòng nhập kết quả hoặc chỉ số cho: ${missing.join(", ")}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.15),
      );
      return;
    }

    final ok = await _controller.hoanTatPhieuChiDinh(maPhieu: maPhieu, ketQua: payload);
    if (ok && mounted) {
      Navigator.of(context).pop();
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _order['TrangThai']?.toString() ?? 'pending';
    final patientName = _order['TenBenhNhan']?.toString() ?? 'N/A';
    final ngaySinh = _order['NgaySinh']?.toString() ?? '';
    final tuoi = _order['Tuoi'];
    final gioiTinh = _order['GioiTinh']?.toString() ?? '';
    final cccd = _order['CCCD']?.toString() ?? '';
    final diaChi = _order['DiaChi']?.toString() ?? '';
    final bhyt = _order['BHYT']?.toString() ?? '';
    final sdt = _order['SoDienThoai']?.toString() ?? '';
    final soThuTu = _order['SoThuTu']?.toString() ?? '';
    final bacSiYC = _order['BacSiYeuCau']?.toString() ?? '';
    final chuyenKhoaYC = _order['ChuyenKhoaYeuCau']?.toString() ?? '';
    final ghiChu = _order['GhiChu']?.toString() ?? '';
    final ngayChiDinh = _formatDt(_order['NgayChiDinh']?.toString() ?? '');
    final ngayKham = _order['NgayKham']?.toString() ?? '';
    final tenCa = _order['TenCa']?.toString() ?? '';
    final gioBatDau = _order['GioBatDau']?.toString() ?? '';
    final gioKetThuc = _order['GioKetThuc']?.toString() ?? '';
    final tenPhong = _order['TenPhong']?.toString() ?? '';
    final chanDoan = _order['ChanDoan']?.toString() ?? '';
    final tinhTrang = _order['TinhTrang']?.toString() ?? '';
    final huongDieuTri = _order['HuongDieuTri']?.toString() ?? '';
    final tenBenh = _order['TenBenh']?.toString() ?? '';
    final chiTiet = _order['ChiTiet'] as List? ?? [];

    final (statusColor, statusText) = _mapStatus(status);

    final tongTien = chiTiet.fold<double>(0, (sum, ct) {
      final raw = (ct as Map)['Gia'];
      final gia = double.tryParse(raw?.toString() ?? '0') ?? 0;
      return sum + gia;
    });

    final ageGender = [
      if (tuoi != null) '$tuoi tuổi',
      if (gioiTinh.isNotEmpty) gioiTinh,
    ].join(' • ');

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _wfHeader('Chi tiết phiếu chỉ định', statusText, statusColor),
                  const SizedBox(height: 16),
                  _wfWorkflowStepper(status),
                  const SizedBox(height: 18),

                  // ============== SECTION 1: BỆNH NHÂN ==============
                  _sectionTitle('Thông tin bệnh nhân', Icons.person_rounded),
                  const SizedBox(height: 8),
                  _patientCard(
                    name: patientName,
                    ageGender: ageGender,
                    ngaySinh: ngaySinh,
                    sdt: sdt,
                    cccd: cccd,
                    diaChi: diaChi,
                    bhyt: bhyt,
                    soThuTu: soThuTu,
                  ),
                  const SizedBox(height: 16),

                  // ============== SECTION 2: BÁC SĨ YÊU CẦU & LÝ DO ==============
                  _sectionTitle('Yêu cầu xét nghiệm', Icons.medical_services_rounded),
                  const SizedBox(height: 8),
                  _referralContextCard(
                    bacSiYC: bacSiYC,
                    chuyenKhoaYC: chuyenKhoaYC,
                    ngayChiDinh: ngayChiDinh,
                    ngayKham: ngayKham,
                    tenCa: tenCa,
                    gioBatDau: gioBatDau,
                    gioKetThuc: gioKetThuc,
                    tenPhong: tenPhong,
                    tenBenh: tenBenh,
                    chanDoan: chanDoan,
                    tinhTrang: tinhTrang,
                    huongDieuTri: huongDieuTri,
                    ghiChu: ghiChu,
                  ),
                  const SizedBox(height: 16),

                  // ============== SECTION 3: DỊCH VỤ XÉT NGHIỆM ==============
                  Row(
                    children: [
                      Expanded(
                        child: _sectionTitle(
                          status == 'processing'
                              ? 'Nhập kết quả xét nghiệm'
                              : 'Danh sách dịch vụ xét nghiệm',
                          Icons.science_rounded,
                        ),
                      ),
                      if (tongTien > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _wfPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(tongTien)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: _wfPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...chiTiet.map((ct) {
                    final m = Map<String, dynamic>.from(ct as Map);
                    return _buildServiceItem(m, status);
                  }),
                  const SizedBox(height: 20),
                  _buildActionButton(status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _wfPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.label),
        ),
      ],
    );
  }

  Widget _patientCard({
    required String name,
    required String ageGender,
    required String ngaySinh,
    required String sdt,
    required String cccd,
    required String diaChi,
    required String bhyt,
    required String soThuTu,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _wfPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _wfPrimary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _wfPrimary.withValues(alpha: 0.12),
                child: const Icon(Icons.person_rounded, color: _wfPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.label),
                    ),
                    if (ageGender.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        ageGender,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey[700], fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
              if (soThuTu.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _wfPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'STT $soThuTu',
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          if (ngaySinh.isNotEmpty) _miniRow(Icons.cake_rounded, 'Ngày sinh', ngaySinh),
          if (sdt.isNotEmpty) _miniRow(Icons.phone_rounded, 'SĐT', sdt),
          if (cccd.isNotEmpty) _miniRow(Icons.badge_rounded, 'CCCD', cccd),
          if (bhyt.isNotEmpty) _miniRow(Icons.shield_rounded, 'BHYT', bhyt),
          if (diaChi.isNotEmpty) _miniRow(Icons.location_on_rounded, 'Địa chỉ', diaChi),
        ],
      ),
    );
  }

  Widget _miniRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, color: AppColors.label, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralContextCard({
    required String bacSiYC,
    required String chuyenKhoaYC,
    required String ngayChiDinh,
    required String ngayKham,
    required String tenCa,
    required String gioBatDau,
    required String gioKetThuc,
    required String tenPhong,
    required String tenBenh,
    required String chanDoan,
    required String tinhTrang,
    required String huongDieuTri,
    required String ghiChu,
  }) {
    final scheduleText = [
      if (ngayKham.isNotEmpty) ngayKham,
      if (tenCa.isNotEmpty) tenCa,
      if (gioBatDau.isNotEmpty && gioKetThuc.isNotEmpty) '$gioBatDau – $gioKetThuc',
    ].join(' • ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bacSiYC.isNotEmpty)
            _miniRow(Icons.medical_services_rounded, 'BS yêu cầu', 'BS. $bacSiYC${chuyenKhoaYC.isNotEmpty ? " ($chuyenKhoaYC)" : ""}'),
          if (ngayChiDinh.isNotEmpty) _miniRow(Icons.schedule_send_rounded, 'Ngày YC', ngayChiDinh),
          if (scheduleText.isNotEmpty) _miniRow(Icons.event_rounded, 'Lịch khám', scheduleText),
          if (tenPhong.isNotEmpty) _miniRow(Icons.meeting_room_rounded, 'Phòng', tenPhong),
          if (tenBenh.isNotEmpty || chanDoan.isNotEmpty || tinhTrang.isNotEmpty || huongDieuTri.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_ind_rounded, size: 14, color: Colors.orange[800]),
                      const SizedBox(width: 6),
                      Text(
                        'Lý do chỉ định / Chẩn đoán sơ bộ',
                        style: TextStyle(fontSize: 11.5, color: Colors.orange[900], fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (tenBenh.isNotEmpty) _clinicalLine('Bệnh nghi ngờ', tenBenh),
                  if (chanDoan.isNotEmpty) _clinicalLine('Chẩn đoán', chanDoan),
                  if (tinhTrang.isNotEmpty) _clinicalLine('Tình trạng', tinhTrang),
                  if (huongDieuTri.isNotEmpty) _clinicalLine('Hướng điều trị', huongDieuTri),
                  if (tenBenh.isEmpty && chanDoan.isEmpty && tinhTrang.isEmpty && huongDieuTri.isEmpty)
                    Text(
                      'BS yêu cầu chưa ghi nhận chẩn đoán sơ bộ.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800], fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          ],
          if (ghiChu.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _wfPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_rounded, size: 14, color: _wfPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12.5, color: AppColors.label),
                        children: [
                          const TextSpan(
                            text: 'Ghi chú từ BS yêu cầu: ',
                            style: TextStyle(fontWeight: FontWeight.w800, color: _wfPrimary),
                          ),
                          TextSpan(
                            text: ghiChu,
                            style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _clinicalLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12.5, color: AppColors.label, height: 1.4),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> ct, String orderStatus) {
    final id = ct['MaChiTietPhieu'] as int?;
    final name = ct['TenDichVu']?.toString() ?? 'Dịch vụ';
    final maDV = ct['MaDichVuYTe']?.toString() ?? '';
    final tenKhoa = ct['TenKhoa']?.toString() ?? '';
    final ctStatus = ct['TrangThai']?.toString() ?? '';
    final ketQua = ct['KetQua']?.toString() ?? '';
    final chiSo = ct['ChiSo']?.toString() ?? '';
    final giaRaw = ct['Gia'];
    final gia = double.tryParse(giaRaw?.toString() ?? '0') ?? 0;
    final ngayCoKetQua = ct['NgayCoKetQua']?.toString() ?? '';
    final (ctColor, ctText) = _mapStatus(ctStatus);

    final priceText = gia > 0
        ? NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(gia)
        : null;

    Widget serviceHeader({required bool showStatusBadge}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _wfPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.biotech_rounded, size: 18, color: _wfPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.label),
                    ),
                    if (tenKhoa.isNotEmpty || maDV.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (tenKhoa.isNotEmpty) tenKhoa,
                          if (maDV.isNotEmpty) 'Mã: $maDV',
                        ].join(' • '),
                        style: TextStyle(fontSize: 11.5, color: Colors.grey[600], fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              if (showStatusBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ctColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ctText,
                    style: TextStyle(fontSize: 10.5, color: ctColor, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          if (priceText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payments_rounded, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  priceText,
                  style: const TextStyle(fontSize: 13, color: _wfPrimary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ],
      );
    }

    if (orderStatus == 'processing' && id != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _wfPrimary.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            serviceHeader(showStatusBadge: false),
            const SizedBox(height: 12),
            TextField(
              controller: _chiSoCtrls[id],
              decoration: InputDecoration(
                labelText: 'Chỉ số đo',
                hintText: 'VD: 120 mg/dL',
                labelStyle: const TextStyle(fontSize: 13),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _wfPrimary, width: 1.5),
                ),
              ),
              maxLength: 100,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ketQuaCtrls[id],
              decoration: InputDecoration(
                labelText: 'Kết quả / nhận xét',
                hintText: 'VD: Bình thường, không phát hiện bất thường',
                labelStyle: const TextStyle(fontSize: 13),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _wfPrimary, width: 1.5),
                ),
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }

    final hasResult = chiSo.isNotEmpty || ketQua.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ctColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          serviceHeader(showStatusBadge: true),
          if (hasResult) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _wfCompleted.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _wfCompleted.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chiSo.isNotEmpty) _clinicalLine('Chỉ số', chiSo),
                  if (ketQua.isNotEmpty) _clinicalLine('Kết quả', ketQua),
                  if (ngayCoKetQua.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Thời điểm có kết quả: ${_formatDt(ngayCoKetQua)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(String status) {
    if (status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _onTiepNhan,
          icon: const Icon(Icons.handshake_rounded),
          label: const Text('Tiếp nhận phiếu chỉ định'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _wfProcessing,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
    if (status == 'processing') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _onHoanTat,
          icon: const Icon(Icons.task_alt_rounded),
          label: const Text('Hoàn tất xét nghiệm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _wfCompleted,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _wfCompleted.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _wfCompleted.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_rounded, color: _wfCompleted, size: 20),
          SizedBox(width: 8),
          Text(
            'Phiếu chỉ định đã hoàn tất',
            style: TextStyle(color: _wfCompleted, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _wfWorkflowStepper(String status) {
    final steps = [
      ('Chờ tiếp nhận', 'pending'),
      ('Đang xét nghiệm', 'processing'),
      ('Hoàn tất', 'completed'),
    ];
    final currentIndex = switch (status) {
      'pending' => 0,
      'processing' => 1,
      'completed' => 2,
      _ => 0,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= currentIndex;
          final isCurrent = i == currentIndex;
          final color = isActive ? _wfPrimary : Colors.grey;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? _wfPrimary : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(color: _wfPrimary, width: 3) : null,
                  ),
                  child: Center(
                    child: isActive
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    steps[i].$1,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 12,
                    height: 2,
                    color: i < currentIndex ? _wfPrimary : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _wfHeader(String title, String statusText, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.assignment_rounded, color: color, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.label),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (Color, String) _mapStatus(String status) {
    switch (status) {
      case 'pending':
        return (_wfPending, 'Chờ xử lý');
      case 'processing':
        return (_wfProcessing, 'Đang xử lý');
      case 'completed':
        return (_wfCompleted, 'Hoàn thành');
      default:
        return (Colors.grey, status.isEmpty ? '—' : status);
    }
  }

  String _formatDt(String raw) {
    if (raw.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}
