import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HoaDonWidget extends StatelessWidget {
  final Map<String, dynamic> hoaDon;
  final List<dynamic> chiTiet;

  const HoaDonWidget({
    Key? key,
    required this.hoaDon,
    required this.chiTiet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3DAA70).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3DAA70)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hoá Đơn #${hoaDon['MaHoaDon']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3D2E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3DAA70),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hoaDon['TrangThai'] == 'pending' ? 'Chờ thanh toán' : 'Đã thanh toán',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ngày: ${dateFormat.format(DateTime.parse(hoaDon['NgayTao'] ?? DateTime.now().toString()))}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A8A70),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Patient Info
            _buildSectionTitle('Thông Tin Bệnh Nhân'),
            const SizedBox(height: 12),
            _buildInfoRow('Tên', hoaDon['TenBenhNhan'] ?? 'N/A'),
            _buildInfoRow('CCCD', hoaDon['cccd'] ?? 'N/A'),
            _buildInfoRow('Địa chỉ', hoaDon['diachi'] ?? 'N/A'),
            if (hoaDon['BHYT'] != null)
              _buildInfoRow('BHYT', hoaDon['BHYT']),

            const SizedBox(height: 20),

            // Doctor Info (if available)
            if (hoaDon['TenBacSi'] != null) ...[
              _buildSectionTitle('Thông Tin Bác Sĩ'),
              const SizedBox(height: 12),
              _buildInfoRow('Bác sĩ', hoaDon['TenBacSi'] ?? 'N/A'),
              _buildInfoRow('Chuyên khoa', hoaDon['ChuyenKhoa'] ?? 'N/A'),
              const SizedBox(height: 20),
            ],

            // Services
            _buildSectionTitle('Chi Tiết Dịch Vụ'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3DAA70).withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Dịch Vụ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'SL',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Giá',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Thành Tiền',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Items
                  ...chiTiet.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  item['TenHienThi'] ?? 'N/A',
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${item['SoLuong'] ?? 1}',
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  currencyFormat.format(item['DonGia'] ?? 0),
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  currencyFormat.format(item['ThanhTien'] ?? 0),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3DAA70),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < chiTiet.length - 1)
                          Divider(height: 1, color: Colors.grey[300]),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3DAA70).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        currencyFormat.format(hoaDon['TongTien'] ?? 0),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if ((hoaDon['GiamBHYT'] ?? 0) > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Giảm BHYT:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '- ${currencyFormat.format(hoaDon['GiamBHYT'] ?? 0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3D2E),
                        ),
                      ),
                      Text(
                        currencyFormat.format(hoaDon['SoTienPhaiTra'] ?? 0),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3DAA70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A3D2E),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5A8A70),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A3D2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
