import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';

class LichKhamCuaToiView extends StatefulWidget {
  const LichKhamCuaToiView({Key? key}) : super(key: key);

  @override
  State<LichKhamCuaToiView> createState() => _LichKhamCuaToiViewState();
}

class _LichKhamCuaToiViewState extends State<LichKhamCuaToiView> {
  final controller = Get.put(LichKhamController());

  @override
  void initState() {
    super.initState();
    controller.getMyAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Khám Của Tôi'),
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Obx(() {
        if (controller.isLoadingMyAppointments.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          );
        }

        if (controller.myAppointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có lịch khám nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hãy đặt lịch khám ngay',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/dat-lich-kham'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đặt Lịch Khám',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myAppointments.length,
          itemBuilder: (context, index) {
            final appointment = controller.myAppointments[index];
            return _buildAppointmentCard(appointment);
          },
        );
      }),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    final statusColor = _getStatusColor(appointment.trangThai);
    final statusLabel = _getStatusLabel(appointment.trangThai);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withValues(alpha: 0.8), statusColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch khám #${appointment.maLichKham}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    'STT: ${appointment.soThuTu}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_outline,
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
                            appointment.tenBacSi ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bác sĩ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Appointment details
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Ngày khám',
                  value: DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(appointment.ngay ?? '')),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.access_time_outlined,
                  label: 'Giờ khám',
                  value:
                      '${appointment.gioBatDau?.substring(0, 5)} - ${appointment.gioKetThuc?.substring(0, 5)}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Phòng khám',
                  value: appointment.tenPhong ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.attach_money_outlined,
                  label: 'Tổng tiền',
                  value:
                      '${NumberFormat('#,###').format(appointment.tongTien ?? 0)} đ',
                  valueColor: const Color(0xFF2E7D32),
                ),

                // Services
                if (appointment.dichVu != null &&
                    (appointment.dichVu as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Dịch vụ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(appointment.dichVu as List).map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service.tenDichVu ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(service.gia ?? 0)} đ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Payment status
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(
                      appointment.trangThaiThanhToan,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 18,
                        color: _getPaymentStatusColor(
                          appointment.trangThaiThanhToan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thanh toán: ${_getPaymentStatusLabel(appointment.trangThaiThanhToan)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _getPaymentStatusColor(
                              appointment.trangThaiThanhToan,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (appointment.trangThai == 'pending') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showCancelDialog(appointment.maLichKham),
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
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showDetailDialog(appointment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Chi Tiết',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black,
                ),
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

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
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
    Get.dialog(
      AlertDialog(
        title: const Text('Hủy Lịch Khám'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch khám này?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Không')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelAppointment(maLichKham!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(dynamic appointment) {
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
                _buildDetailItem('Mã lịch khám', '#${appointment.maLichKham}'),
                _buildDetailItem('Bác sĩ', appointment.tenBacSi ?? 'N/A'),
                _buildDetailItem(
                  'Ngày khám',
                  DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(appointment.ngay ?? '')),
                ),
                _buildDetailItem(
                  'Giờ khám',
                  '${appointment.gioBatDau?.substring(0, 5)} - ${appointment.gioKetThuc?.substring(0, 5)}',
                ),
                _buildDetailItem('Phòng khám', appointment.tenPhong ?? 'N/A'),
                _buildDetailItem(
                  'Tổng tiền',
                  '${NumberFormat('#,###').format(appointment.tongTien ?? 0)} đ',
                ),
                _buildDetailItem(
                  'Trạng thái',
                  _getStatusLabel(appointment.trangThai),
                ),
                _buildDetailItem(
                  'Thanh toán',
                  _getPaymentStatusLabel(appointment.trangThaiThanhToan),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
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
                color: Color(0xFF1B5E20),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
