// ═══════════════════════════════════════════════════════════════
// FILE: quan_ly_khoa_view.dart
// MÔ TẢ: Giao diện quản lý khoa (Admin)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class QuanLyKhoaView extends StatefulWidget {
  const QuanLyKhoaView({super.key});

  @override
  State<QuanLyKhoaView> createState() => _QuanLyKhoaViewState();
}

class _QuanLyKhoaViewState extends State<QuanLyKhoaView> {
  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);

  // Danh sách khoa (tạm thời)
  List<Map<String, dynamic>> _danhSachKhoa = [];
  bool _dangTai = false;

  // Controllers
  final _tenKhoaController = TextEditingController();
  final _moTaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taiDanhSachKhoa();
  }

  @override
  void dispose() {
    _tenKhoaController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // TẢI DANH SÁCH KHOA
  // ─────────────────────────────────────────────────────────────
  Future<void> _taiDanhSachKhoa() async {
    setState(() => _dangTai = true);

    // TODO: Gọi API lấy danh sách khoa
    await Future.delayed(const Duration(seconds: 1));

    // Dữ liệu mẫu
    setState(() {
      _danhSachKhoa = [
        {
          'ma_khoa': 1,
          'ten_khoa': 'Khoa Nội',
          'mo_ta': 'Khám và điều trị các bệnh nội khoa',
        },
        {
          'ma_khoa': 2,
          'ten_khoa': 'Khoa Ngoại',
          'mo_ta': 'Phẫu thuật và điều trị ngoại khoa',
        },
        {
          'ma_khoa': 3,
          'ten_khoa': 'Khoa Nhi',
          'mo_ta': 'Chăm sóc sức khỏe trẻ em',
        },
        {
          'ma_khoa': 4,
          'ten_khoa': 'Khoa Sản',
          'mo_ta': 'Chăm sóc sức khỏe phụ nữ mang thai',
        },
        {
          'ma_khoa': 5,
          'ten_khoa': 'Khoa Mắt',
          'mo_ta': 'Khám và điều trị các bệnh về mắt',
        },
      ];
      _dangTai = false;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // HIỂN THỊ DIALOG THÊM/SỬA KHOA
  // ─────────────────────────────────────────────────────────────
  void _hienThiDialogKhoa({Map<String, dynamic>? khoa}) {
    final isEdit = khoa != null;

    if (isEdit) {
      _tenKhoaController.text = khoa['ten_khoa'] ?? '';
      _moTaController.text = khoa['mo_ta'] ?? '';
    } else {
      _tenKhoaController.clear();
      _moTaController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa khoa' : 'Thêm khoa mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tenKhoaController,
                decoration: const InputDecoration(
                  labelText: 'Tên khoa *',
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
                maxLines: 3,
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
              if (_tenKhoaController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên khoa')),
                );
                return;
              }

              // TODO: Gọi API thêm/sửa khoa
              Navigator.pop(context);
              _taiDanhSachKhoa();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEdit
                        ? 'Cập nhật khoa thành công'
                        : 'Thêm khoa thành công',
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
  // XÓA KHOA
  // ─────────────────────────────────────────────────────────────
  Future<void> _xoaKhoa(int maKhoa) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa khoa này?'),
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
      // TODO: Gọi API xóa khoa
      _taiDanhSachKhoa();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa khoa thành công'),
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
          'Quản lý Khoa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _hienThiDialogKhoa(),
        backgroundColor: _mauXanh,
        icon: const Icon(Icons.add),
        label: const Text('Thêm khoa'),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : _danhSachKhoa.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có khoa nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _danhSachKhoa.length,
              itemBuilder: (context, index) {
                final khoa = _danhSachKhoa[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _mauXanh.withValues(alpha: 0.1),
                      child: Icon(Icons.school, color: _mauXanh),
                    ),
                    title: Text(
                      khoa['ten_khoa'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _mauChuDen,
                        fontSize: 16,
                      ),
                    ),
                    subtitle:
                        khoa['mo_ta'] != null &&
                            khoa['mo_ta'].toString().isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              khoa['mo_ta'],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _hienThiDialogKhoa(khoa: khoa),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _xoaKhoa(khoa['ma_khoa']),
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
