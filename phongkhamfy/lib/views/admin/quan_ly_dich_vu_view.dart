// ═══════════════════════════════════════════════════════════════
// FILE: quan_ly_dich_vu_view.dart
// MÔ TẢ: Giao diện quản lý dịch vụ (Admin)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuanLyDichVuView extends StatefulWidget {
  const QuanLyDichVuView({super.key});

  @override
  State<QuanLyDichVuView> createState() => _QuanLyDichVuViewState();
}

class _QuanLyDichVuViewState extends State<QuanLyDichVuView> {
  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);

  // Danh sách dịch vụ (tạm thời)
  List<Map<String, dynamic>> _danhSachDichVu = [];
  bool _dangTai = false;

  // Controllers
  final _tenDichVuController = TextEditingController();
  final _maDichVuController = TextEditingController();
  final _moTaController = TextEditingController();
  final _donGiaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taiDanhSachDichVu();
  }

  @override
  void dispose() {
    _tenDichVuController.dispose();
    _maDichVuController.dispose();
    _moTaController.dispose();
    _donGiaController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // TẢI DANH SÁCH DỊCH VỤ
  // ─────────────────────────────────────────────────────────────
  Future<void> _taiDanhSachDichVu() async {
    setState(() => _dangTai = true);

    // TODO: Gọi API lấy danh sách dịch vụ
    await Future.delayed(const Duration(seconds: 1));

    // Dữ liệu mẫu
    setState(() {
      _danhSachDichVu = [
        {
          'id': 1,
          'ma_dich_vu': 'DV001',
          'ten_dich_vu': 'Khám tổng quát',
          'mo_ta': 'Khám sức khỏe tổng quát',
          'don_gia': 200000,
        },
        {
          'id': 2,
          'ma_dich_vu': 'DV002',
          'ten_dich_vu': 'Xét nghiệm máu',
          'mo_ta': 'Xét nghiệm công thức máu',
          'don_gia': 150000,
        },
        {
          'id': 3,
          'ma_dich_vu': 'DV003',
          'ten_dich_vu': 'Chụp X-quang',
          'mo_ta': 'Chụp X-quang phổi',
          'don_gia': 300000,
        },
        {
          'id': 4,
          'ma_dich_vu': 'DV004',
          'ten_dich_vu': 'Siêu âm',
          'mo_ta': 'Siêu âm bụng tổng quát',
          'don_gia': 250000,
        },
        {
          'id': 5,
          'ma_dich_vu': 'DV005',
          'ten_dich_vu': 'Điện tâm đồ',
          'mo_ta': 'Đo điện tâm đồ',
          'don_gia': 180000,
        },
      ];
      _dangTai = false;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // ĐỊNH DẠNG TIỀN TỆ
  // ─────────────────────────────────────────────────────────────
  String _dinhDangTien(int? gia) {
    if (gia == null) return '0 đ';
    return '${gia.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ';
  }

  // ─────────────────────────────────────────────────────────────
  // HIỂN THỊ DIALOG THÊM/SỬA DỊCH VỤ
  // ─────────────────────────────────────────────────────────────
  void _hienThiDialogDichVu({Map<String, dynamic>? dichVu}) {
    final isEdit = dichVu != null;

    if (isEdit) {
      _maDichVuController.text = dichVu['ma_dich_vu'] ?? '';
      _tenDichVuController.text = dichVu['ten_dich_vu'] ?? '';
      _moTaController.text = dichVu['mo_ta'] ?? '';
      _donGiaController.text = dichVu['don_gia']?.toString() ?? '';
    } else {
      _maDichVuController.clear();
      _tenDichVuController.clear();
      _moTaController.clear();
      _donGiaController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa dịch vụ' : 'Thêm dịch vụ mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _maDichVuController,
                decoration: const InputDecoration(
                  labelText: 'Mã dịch vụ *',
                  border: OutlineInputBorder(),
                ),
                enabled: !isEdit,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tenDichVuController,
                decoration: const InputDecoration(
                  labelText: 'Tên dịch vụ *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _moTaController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _donGiaController,
                decoration: const InputDecoration(
                  labelText: 'Đơn giá (VNĐ) *',
                  border: OutlineInputBorder(),
                  prefixText: '₫ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_maDichVuController.text.trim().isEmpty ||
                  _tenDichVuController.text.trim().isEmpty ||
                  _donGiaController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập đầy đủ thông tin bắt buộc'),
                  ),
                );
                return;
              }

              // TODO: Gọi API thêm/sửa dịch vụ
              Navigator.pop(context);
              _taiDanhSachDichVu();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEdit
                        ? 'Cập nhật dịch vụ thành công'
                        : 'Thêm dịch vụ thành công',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _mauXanh),
            child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // XÓA DỊCH VỤ
  // ─────────────────────────────────────────────────────────────
  Future<void> _xoaDichVu(int id) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa dịch vụ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (xacNhan == true) {
      // TODO: Gọi API xóa dịch vụ
      _taiDanhSachDichVu();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa dịch vụ thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // GIAO DIỆN
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mauNen,
      appBar: AppBar(
        title: const Text(
          'Quản lý Dịch vụ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _hienThiDialogDichVu(),
        backgroundColor: _mauXanh,
        icon: const Icon(Icons.add),
        label: const Text('Thêm dịch vụ'),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : _danhSachDichVu.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có dịch vụ nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _danhSachDichVu.length,
              itemBuilder: (context, index) {
                final dichVu = _danhSachDichVu[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.cyan.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.cyan,
                      ),
                    ),
                    title: Text(
                      dichVu['ten_dich_vu'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _mauChuDen,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Mã: ${dichVu['ma_dich_vu']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        if (dichVu['mo_ta'] != null &&
                            dichVu['mo_ta'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            dichVu['mo_ta'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _mauXanh.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _dinhDangTien(dichVu['don_gia']),
                            style: TextStyle(
                              color: _mauXanh,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _hienThiDialogDichVu(dichVu: dichVu),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _xoaDichVu(dichVu['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
