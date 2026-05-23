import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';
import 'package:phongkhamfy/utils/loading_utils.dart';
import 'package:phongkhamfy/widgets/loading_view.dart';

class LichKhamBacSiView extends StatefulWidget {
  const LichKhamBacSiView({super.key});

  @override
  State<LichKhamBacSiView> createState() => _LichKhamBacSiViewState();
}

class _LichKhamBacSiViewState extends State<LichKhamBacSiView> {
  final controller = Get.put(LichKhamController());
  late DateTime selectedDate;

  final _primary = const Color(0xFF0D47A1);
  final _accent = const Color(0xFF1976D2);
  final _bg = const Color(0xFFF0F4F8);
  final _success = const Color(0xFF43A047);
  final _warning = const Color(0xFFFFA000);

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

    // Đợi build xong frame đầu tiên rồi mới gọi API để:
    // - tránh các issue kiểu gọi dialog/overlay trong lúc build
    // - đảm bảo Obx đã được mount để nhận update và render dữ liệu ngay lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });
  }

  void _loadSchedule() {
    final formatter = DateFormat('yyyy-MM-dd');
    controller.getDoctorSchedule(
      ngayBatDau: formatter.format(selectedDate),
      ngayKetThuc: formatter.format(selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Công việc khám của tôi', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadSchedule,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHorizontalCalendar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingDoctorSchedule.value &&
                  controller.doctorSchedules.isEmpty) {
                return const LoadingView(message: 'Đang tải lịch khám...');
              }

              if (controller.doctorSchedules.isEmpty) {
                return _buildEmptyState();
              }

              return _buildScheduleContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 2));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final dayName = DateFormat('E', 'vi_VN').format(date);
          final dayNum = date.day.toString();

          return GestureDetector(
            onTap: () {
              setState(() => selectedDate = date);
              _loadSchedule();
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? _primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? _primary : Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Hôm nay bác sĩ không có ca khám nào',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent() {
    final schedule = controller.doctorSchedules[0]; // Assuming focus on selected date
    final patients = schedule['LichKham'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(schedule),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Danh sách bệnh nhân',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${patients.length} người',
                  style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_sortPatientsBySTT(patients.cast<Map<String, dynamic>>())).map((p) => _buildPatientCard(p)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> schedule) {
    final patients = schedule['LichKham'] as List? ?? [];
    final total = patients.length;
    final completed = patients.where((p) => p['TrangThai'] == 'completed').length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _accent],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _infoItem(Icons.meeting_room_rounded, 'Phòng', schedule['TenPhong'] ?? 'N/A'),
              Container(width: 1, height: 30, color: Colors.white24),
              const SizedBox(width: 20),
              _infoItem(Icons.access_time_filled_rounded, 'Ca khám', schedule['TenCa'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statMini('Tổng cộng', total.toString()),
              _statMini('Hoàn tất', completed.toString()),
              _statMini('Còn lại', (total - completed).toString()),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tiến độ công việc', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMini(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final status = patient['TrangThai'];
    final statusLabel = _getStatusLabel(status);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPatientDetails(patient),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    '${patient['SoThuTu'] ?? '0'}',
                    style: TextStyle(color: _primary, fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['TenBenhNhan'] ?? 'Chưa rõ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (status == 'confirmed')
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: _success.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.play_arrow_rounded, color: _success),
                  )
                else
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person_rounded, color: _primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['TenBenhNhan'] ?? 'Chưa rõ',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Số thứ tự: ${patient['SoThuTu']}',
                                style: TextStyle(color: _primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Hành động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _buildAcceptanceButton(patient),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: patient['TrangThai'] == 'completed'
                            ? _buildCompletedStatus()
                            : _buildActionButtonWithLock(
                              Icons.assignment_turned_in_rounded,
                              'Kết luận khám',
                              _success,
                              () => _showConclusionForm(patient),
                              patient,
                            ),
                        ),
                        const SizedBox(width: 12),
                        // Nút Tạo phiếu chỉ định mới (chỉ hiển thị khi chưa hoàn tất)
                        if (patient['TrangThai'] != 'completed')
                          Expanded(
                            child: _buildActionButtonWithLock(
                              Icons.note_add_rounded,
                              'Tạo phiếu chỉ định',
                              _accent,
                              () => _showIndicationForm(patient),
                              patient,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Nút Xem lịch sử phiếu chỉ định nếu có
                    if ((patient['PhieuChiDinh'] as List? ?? []).isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: _actionButton(
                          Icons.description_rounded,
                          'Xem lịch sử phiếu chỉ định (${(patient['PhieuChiDinh'] as List).length})',
                          const Color(0xFF34495E),
                          () => _showIndicationsDialog(patient),
                        ),
                      ),
                    const SizedBox(height: 32),
                    const Text('Chi tiết cuộc hẹn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    _detailItem('Trạng thái', _getStatusLabel(patient['TrangThai'])),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptanceButton(Map<String, dynamic> patient) {
    final maLichKham = patient['MaLichKham'] as int;
    final thoiDiemCheckIn = patient['ThoiDiemCheckIn'];

    if (thoiDiemCheckIn != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: _success, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đã tiếp nhận bệnh nhân',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Tiếp nhận bệnh nhân'),
            content: Text('Bạn có chắc chắn muốn tiếp nhận ${patient['TenBenhNhan']}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // Close dialog
                  final result = await controller.acceptPatient(maLichKham);
                  if (result && mounted) {
                    Navigator.pop(context); // Close sheet
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _success,
                ),
                child: const Text(
                  'Tiếp nhận',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.person_add_rounded),
      label: const Text('Tiếp nhận bệnh nhân'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _success,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCompletedStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.done_all_rounded, color: _success, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Đã hoàn thành khám',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonWithLock(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
    Map<String, dynamic> patient,
  ) {
    final isEnabled = patient['ThoiDiemCheckIn'] != null;

    return Tooltip(
      message: isEnabled
          ? ''
          : 'Cần tiếp nhận bệnh nhân trước',
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: isEnabled ? 0.3 : 0.15),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Icon(icon, color: color, size: 32),
                      if (!isEnabled)
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIndicationsDialog(Map<String, dynamic> patient) {
    final listPhieu = patient['PhieuChiDinh'] as List? ?? [];
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lịch sử chỉ định', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded))
                ],
              ),
              const SizedBox(height: 20),
              if (listPhieu.isEmpty)
                const Expanded(child: Center(child: Text('Chưa có phiếu chỉ định nào.')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: listPhieu.length,
                    itemBuilder: (context, index) {
                      final phieu = listPhieu[index];
                      final chiTiet = phieu['ChiTiet'] as List? ?? [];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Mã phiếu: #${phieu['MaPhieu']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                  Text(
                                    DateFormat('dd/MM HH:mm').format(DateTime.parse(phieu['NgayChiDinh'])),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              if (phieu['GhiChu'] != null && phieu['GhiChu'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('Ghi chú: ${phieu['GhiChu']}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                                ),
                              const Divider(height: 24),
                              ...chiTiet.map((ct) {
                                final isCompleted = ct['TrangThai'] == 'completed';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isCompleted ? Colors.green[100]! : Colors.blue[100]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                               color: isCompleted ? Colors.green : Colors.blue, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(ct['TenDichVu'] ?? 'Dịch vụ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                if ((ct['TenKhoa']?.toString() ?? '').isNotEmpty || (ct['Gia'] != null))
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2),
                                                    child: Text(
                                                      [
                                                        if ((ct['TenKhoa']?.toString() ?? '').isNotEmpty) ct['TenKhoa'],
                                                        if (ct['Gia'] != null) NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(double.tryParse(ct['Gia']?.toString() ?? '0') ?? 0)
                                                      ].join(' • '),
                                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            isCompleted ? 'Đã có kết quả' : 'Đang chờ',
                                            style: TextStyle(fontSize: 11, color: isCompleted ? Colors.green : Colors.blue, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      if (isCompleted) ...[
                                        const Divider(height: 16),
                                        if (ct['ChiSo'] != null && ct['ChiSo'].toString().isNotEmpty)
                                          _resultDetail('Chỉ số:', ct['ChiSo'].toString()),
                                        if (ct['KetQua'] != null && ct['KetQua'].toString().isNotEmpty)
                                          _resultDetail('Kết quả:', ct['KetQua'].toString()),
                                        if (ct['NgayCoKetQua'] != null && ct['NgayCoKetQua'].toString().isNotEmpty)
                                          _resultDetail('Ngày có kết quả:', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(ct['NgayCoKetQua'].toString()))),
                                        if (ct['FileKetQua'] != null && ct['FileKetQua'].toString().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: TextButton.icon(
                                              onPressed: () {
                                                Get.snackbar('Thông báo', 'Đang mở tệp đính kèm...');
                                              },
                                              icon: const Icon(Icons.file_present_rounded, size: 18),
                                              label: const Text('Xem tệp kết quả', style: TextStyle(fontSize: 13)),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.orange[800],
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _showIndicationForm(Map<String, dynamic> patient) async {
    final selectedServiceId = Rxn<int>();
    final noteController = TextEditingController();
    int? selectedDoctorId;

    LoadingUtils.showLoading(message: 'Đang tải dữ liệu chỉ định...');
    try {
      await controller.getTestingDoctors(patient['MaLichKham']);
      await controller.getAllServicesForDoctor();
    } finally {
      LoadingUtils.hideLoading();
    }

    if (!mounted) return;

    Get.bottomSheet(
      isScrollControlled: true,
      Builder(builder: (sheetCtx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tạo phiếu chỉ định', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                IconButton(onPressed: () => Navigator.of(sheetCtx).pop(), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chọn bác sĩ thực hiện (Khoa Xét nghiệm)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.isLoadingTestingDoctors.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.testingDoctors.isEmpty) {
                        return const Text('Không tìm thấy bác sĩ xét nghiệm nào.', style: TextStyle(color: Colors.red));
                      }
                      return DropdownButtonFormField<int>(
                        initialValue: selectedDoctorId,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: controller.testingDoctors.map((doc) {
                          return DropdownMenuItem<int>(
                            value: doc['MaBacSi'],
                            child: Text('BS. ${doc['ten']} - ${doc['ChuyenKhoa']}'),
                          );
                        }).toList(),
                        onChanged: (val) => selectedDoctorId = val,
                        hint: const Text('Chọn bác sĩ'),
                      );
                    }),
                    const SizedBox(height: 24),
                    const Text('Ghi chú chỉ định', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú cho bác sĩ xét nghiệm...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Chọn dịch vụ chỉ định (Chọn 1)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.isLoadingServices.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        children: controller.availableServices.map((service) {
                          final id = service['MaDichVu'];
                          return Obx(() => RadioListTile<int>(
                            value: id,
                            groupValue: selectedServiceId.value,
                            title: Text(service['TenDichVu'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(double.tryParse(service['Gia']?.toString() ?? '0') ?? 0)}'),
                            onChanged: (val) => selectedServiceId.value = val,
                            contentPadding: EdgeInsets.zero,
                            activeColor: _accent,
                          ));
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: controller.isCreatingReferral.value 
                  ? null 
                  : () async {
                    if (selectedDoctorId == null) {
                      Get.snackbar('Thông báo', 'Vui lòng chọn bác sĩ thực hiện');
                      return;
                    }
                    if (selectedServiceId.value == null) {
                      Get.snackbar('Thông báo', 'Vui lòng chọn một dịch vụ');
                      return;
                    }

                    final success = await controller.createReferral(
                      maLichKham: patient['MaLichKham'],
                      maBacSiThucHien: selectedDoctorId!,
                      ghiChu: noteController.text,
                      maDichVuIds: [selectedServiceId.value!],
                    );

                    if (!sheetCtx.mounted) return;
                    if (success) {
                      Navigator.of(sheetCtx).pop(); // close sheet
                      _loadSchedule();
                    }
                  },
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: controller.isCreatingReferral.value 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Xác nhận tạo phiếu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        ),
      )),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  void _showConclusionForm(Map<String, dynamic> patient) async {
    final existingKetLuan = patient['KetLuan'];
    final existingDonThuoc = patient['DonThuoc'];

    final selectedMedicines = <Map<String, dynamic>>[].obs;
    if (existingDonThuoc != null) {
      final chiTiet = existingDonThuoc['ChiTiet'] as List? ?? [];
      selectedMedicines.value = chiTiet.map((ct) => {
        'MaThuoc': ct['MaThuoc'],
        'TenThuoc': ct['TenThuoc'],
        'HamLuong': ct['HamLuong'],
        'DonViTinh': ct['DonViTinh'],
        'so_luong': ct['SoLuong']?.toString() ?? '1',
        'lieu_dung': ct['LieuDung'] ?? '',
      }).toList();
    }

    final chanDoanController = TextEditingController(text: existingKetLuan?['ChanDoan']);
    final tinhTrangController = TextEditingController(text: existingKetLuan?['TinhTrang']);
    String? selectedBenh = existingKetLuan?['MaBenh']?.toString();
    String huongDieuTri = existingKetLuan?['HuongDieuTri'] ?? 'Kê đơn thuốc';

    await controller.getDiseases();
    await controller.getMedicinesForDoctor();

    if (selectedBenh != null) {
      await controller.getServicesByBenh(selectedBenh);
    }

    if (!mounted) return;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kết luận khám', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Loại bệnh', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                initialValue: selectedBenh,
                decoration: _inputDecoration('Chọn loại bệnh', Icons.coronavirus_rounded),
                items: controller.diseases.map((b) => DropdownMenuItem(
                  value: b['MaBenh'].toString(),
                  child: Text(b['TenBenh']),
                )).toList(),
                onChanged: (v) {
                  selectedBenh = v;
                  if (v != null) controller.getServicesByBenh(v);
                },
              )),
              const SizedBox(height: 16),
              const Text('Chẩn đoán', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextField(
                controller: chanDoanController,
                decoration: _inputDecoration('Nhập chẩn đoán', Icons.description_rounded),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Tình trạng', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextField(
                controller: tinhTrangController,
                decoration: _inputDecoration('Nhập tình trạng hiện tại', Icons.monitor_heart_rounded),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setInternalState) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hướng điều trị', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['Kê đơn thuốc', 'Phẫu thuật', 'Nhập viện'].map((type) => ChoiceChip(
                        label: Text(type),
                        selected: huongDieuTri == type,
                        onSelected: (val) {
                          setInternalState(() => huongDieuTri = type);
                          setState(() => {}); // Sync with parent if needed
                        },
                        selectedColor: _primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(color: huongDieuTri == type ? _primary : Colors.grey, fontWeight: FontWeight.w700),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                    _buildPrescriptionSection(huongDieuTri, selectedMedicines),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: Obx(() => FilledButton(
                  onPressed: controller.isSubmittingConclusion.value ? null : () async {
                    if (selectedBenh == null) {
                      Get.snackbar('Lỗi', 'Vui lòng chọn loại bệnh');
                      return;
                    }
                    final success = await controller.submitConclusion(
                      maLichKham: patient['MaLichKham'],
                      maBenh: selectedBenh!,
                      chanDoan: chanDoanController.text,
                      tinhTrang: tinhTrangController.text,
                      huongDieuTri: huongDieuTri,
                      donThuoc: huongDieuTri == 'Kê đơn thuốc' 
                        ? selectedMedicines.map((m) => {
                            'ma_thuoc': m['MaThuoc'],
                            'so_luong': int.tryParse(m['so_luong']?.toString() ?? '1') ?? 1,
                            'lieu_dung': m['lieu_dung'] ?? '',
                          }).toList() 
                        : null,
                    );
                    if (success && mounted) {
                      Navigator.pop(context); // close form
                      Navigator.pop(context); // close details
                      _loadSchedule();
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: controller.isSubmittingConclusion.value 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Hoàn tất & Lưu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionSection(String type, RxList<Map<String, dynamic>> selectedMedicines) {
    if (type != 'Kê đơn thuốc') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Danh sách thuốc kê đơn', style: TextStyle(fontWeight: FontWeight.w800)),
            TextButton.icon(
              onPressed: () => _showMedicinePicker(selectedMedicines),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('Thêm thuốc'),
            ),
          ],
        ),
        Obx(() => selectedMedicines.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.medication_rounded, color: Colors.grey[300], size: 40),
                    const SizedBox(height: 12),
                    Text('Chưa có thuốc nào được chọn', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedMedicines.length,
                itemBuilder: (context, index) {
                  final med = selectedMedicines[index];
                  return _buildPrescribedMedItem(med, selectedMedicines);
                },
              )),
        
        const SizedBox(height: 24),
        Obx(() {
          if (controller.isLoadingServices.value) {
            return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
          }
          if (controller.availableServices.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dịch vụ gợi ý cho bệnh này', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableServices.map((svc) => Chip(
                  label: Text(svc['TenDichVu'], style: const TextStyle(fontSize: 12)),
                  backgroundColor: _accent.withValues(alpha: 0.1),
                  side: BorderSide(color: _accent.withValues(alpha: 0.2)),
                )).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPrescribedMedItem(Map<String, dynamic> med, RxList<Map<String, dynamic>> list) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['TenThuoc'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('${med['HamLuong']} - ${med['DonViTinh']}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => list.remove(med),
                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: TextEditingController(text: med['so_luong']?.toString() ?? '')..selection = TextSelection.collapsed(offset: (med['so_luong']?.toString() ?? '').length),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => med['so_luong'] = v,
                  decoration: _miniInput('SL', null),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: med['lieu_dung'] ?? '')..selection = TextSelection.collapsed(offset: (med['lieu_dung'] ?? '').length),
                  onChanged: (v) => med['lieu_dung'] = v,
                  decoration: _miniInput('Liều dùng', 'Ngày uống 2 lần, mỗi lần 1 viên...'),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _miniInput(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11),
      labelStyle: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.bold),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primary)),
    );
  }

  void _showMedicinePicker(RxList<Map<String, dynamic>> selectedList) {
    final searchCtrl = TextEditingController();
    final searchResults = <Map<String, dynamic>>[].obs;
    searchResults.value = controller.medicines;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: double.infinity,
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Chọn thuốc', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(
                controller: searchCtrl,
                onChanged: (v) {
                  searchResults.value = controller.medicines.where((m) => 
                    m['TenThuoc'].toString().toLowerCase().contains(v.toLowerCase())).toList();
                },
                decoration: _inputDecoration('Tìm tên thuốc...', Icons.search_rounded),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final med = searchResults[index];
                    final isPicked = selectedList.any((m) => m['MaThuoc'] == med['MaThuoc']);

                    return ListTile(
                      title: Text(med['TenThuoc'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${med['HamLuong']} - ${med['DonViTinh']}'),
                      trailing: Icon(
                        isPicked ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                        color: isPicked ? _success : _primary,
                      ),
                      onTap: isPicked ? null : () {
                        selectedList.add({...med, 'so_luong': '1', 'lieu_dung': ''});
                        Get.back();
                      },
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: _primary),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed': return _success;
      case 'examining': return _accent;
      case 'confirmed': return _accent;
      case 'pending': return _warning;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'completed': return 'Đã khám xong';
      case 'examining': return 'Đang khám';
      case 'confirmed': return 'Đang chờ khám';
      case 'pending': return 'Chưa đến';
      case 'cancelled': return 'Đã hủy';
      default: return 'Không xác định';
    }
  }

  List<Map<String, dynamic>> _sortPatientsBySTT(List<Map<String, dynamic>> patients) {
    final sorted = List<Map<String, dynamic>>.from(patients);
    sorted.sort((a, b) {
      final soThuTuA = int.tryParse(a['SoThuTu']?.toString() ?? '0') ?? 0;
      final soThuTuB = int.tryParse(b['SoThuTu']?.toString() ?? '0') ?? 0;
      return soThuTuA.compareTo(soThuTuB);
    });
    return sorted;
  }

  void _handleStatusUpdate(int maLichKham, String status) async {
    await controller.updateAppointmentStatusByDoctor(maLichKham, status);
    _loadSchedule();
  }
}
