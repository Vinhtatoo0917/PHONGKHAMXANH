import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';

class QuanLyLichKhamView extends StatefulWidget {
  const QuanLyLichKhamView({Key? key}) : super(key: key);

  @override
  State<QuanLyLichKhamView> createState() => _QuanLyLichKhamViewState();
}

class _QuanLyLichKhamViewState extends State<QuanLyLichKhamView> {
  final controller = Get.put(LichKhamController());
  String? selectedStatus;
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  @override
  void initState() {
    super.initState();
    selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
    selectedEndDate = DateTime.now().add(const Duration(days: 7));
    _loadAppointments();
  }

  void _loadAppointments() {
    final formatter = DateFormat('yyyy-MM-dd');
    controller.getAllAppointments(
      trangThai: selectedStatus,
      ngayBatDau: formatter.format(selectedStartDate),
      ngayKetThuc: formatter.format(selectedEndDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Lịch Khám'),
        elevation: 0,
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản Lý Lịch Khám',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Xem và quản lý tất cả lịch khám',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters
                  _buildFilters(),
                  const SizedBox(height: 24),

                  // Statistics
                  _buildStatistics(),
                  const SizedBox(height: 24),

                  // Appointments list
                  const Text(
                    'Danh Sách Lịch Khám',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAppointmentsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ Lọc',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 12),

          // Date range
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(true),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Từ ngày',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedStartDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(false),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đến ngày',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedEndDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status filter
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              labelText: 'Trạng Thái',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tất Cả')),
              const DropdownMenuItem(
                value: 'pending',
                child: Text('Chờ Xác Nhận'),
              ),
              const DropdownMenuItem(
                value: 'confirmed',
                child: Text('Đã Xác Nhận'),
              ),
              const DropdownMenuItem(
                value: 'completed',
                child: Text('Đã Hoàn Thành'),
              ),
              const DropdownMenuItem(value: 'cancelled', child: Text('Đã Hủy')),
              const DropdownMenuItem(
                value: 'no-show',
                child: Text('Không Đến'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tìm Kiếm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Tổng Lịch',
            value: '${controller.allAppointments.length}',
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Chờ Xác Nhận',
            value:
                '${controller.allAppointments.where((a) => a['TrangThai'] == 'pending').length}',
            icon: Icons.schedule,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Đã Xác Nhận',
            value:
                '${controller.allAppointments.where((a) => a['TrangThai'] == 'confirmed').length}',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Obx(() {
      if (controller.isLoadingAllAppointments.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
          ),
        );
      }

      if (controller.allAppointments.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'Không có lịch khám nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.allAppointments.length,
        itemBuilder: (context, index) {
          final appointment = controller.allAppointments[index];
          return _buildAppointmentCard(appointment);
        },
      );
    });
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final statusColor = _getStatusColor(appointment['TrangThai']);
    final statusLabel = _getStatusLabel(appointment['TrangThai']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getStatusIcon(appointment['TrangThai']),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch #${appointment['MaLichKham']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showActionMenu(appointment),
                  child: const Icon(Icons.more_vert, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.person_outline,
                    label: 'Bệnh nhân',
                    value: appointment['MaBenhNhan']?.toString() ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày',
                    value: 'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.attach_money_outlined,
                    label: 'Tổng tiền',
                    value:
                        '${NumberFormat('#,###').format(appointment['TongTien'] ?? 0)} đ',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.receipt_outlined,
                    label: 'Thanh toán',
                    value: _getPaymentStatusLabel(
                      appointment['TrangThaiThanhToan'],
                    ),
                  ),
                ),
              ],
            ),

            // Action buttons
            const SizedBox(height: 12),
            if (appointment['TrangThai'] == 'pending') ...[
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(appointment['MaLichKham'], 'confirmed'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xác Nhận',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(appointment['MaLichKham'], 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.red),
                      ),
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD32F2F)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'no-show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'no-show':
        return Icons.close;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
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

  void _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
      });
    }
  }

  void _updateStatus(int maLichKham, String trangThai) {
    controller.updateAppointmentStatus(
      maLichKham: maLichKham,
      trangThai: trangThai,
    );
  }

  void _showActionMenu(Map<String, dynamic> appointment) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Chi Tiết'),
              onTap: () {
                Get.back();
                _showDetailDialog(appointment);
              },
            ),
            if (appointment['TrangThai'] == 'pending')
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Xác Nhận'),
                onTap: () {
                  Get.back();
                  _updateStatus(appointment['MaLichKham'], 'confirmed');
                },
              ),
            if (appointment['TrangThai'] == 'confirmed')
              ListTile(
                leading: const Icon(Icons.done_all),
                title: const Text('Hoàn Thành'),
                onTap: () {
                  Get.back();
                  _updateStatus(appointment['MaLichKham'], 'completed');
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: const Text('Hủy', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _updateStatus(appointment['MaLichKham'], 'cancelled');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> appointment) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chi Tiết Lịch Khám',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailItem2(
                  'Mã lịch khám',
                  '#${appointment['MaLichKham']}',
                ),
                _buildDetailItem2(
                  'Bệnh nhân',
                  appointment['MaBenhNhan']?.toString() ?? 'N/A',
                ),
                _buildDetailItem2(
                  'Trạng thái',
                  _getStatusLabel(appointment['TrangThai']),
                ),
                _buildDetailItem2(
                  'Tổng tiền',
                  '${NumberFormat('#,###').format(appointment['TongTien'] ?? 0)} đ',
                ),
                _buildDetailItem2(
                  'Thanh toán',
                  _getPaymentStatusLabel(appointment['TrangThaiThanhToan']),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem2(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFB71C1C),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
