// ═══════════════════════════════════════════════════════════════
// FILE: quan_ly_benh_view.dart
// MÔ TẢ: Giao diện quản lý bệnh (Admin)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class QuanLyBenhView extends StatefulWidget {
  const QuanLyBenhView({super.key});

  @override
  State<QuanLyBenhView> createState() => _QuanLyBenhViewState();
}

class _QuanLyBenhViewState extends State<QuanLyBenhView> {
  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);

  // Danh sách bệnh (tạm thời)
  List<Map<String, dynamic>> _danhSachBenh = [];
  bool _dangTai = false;

  // Controllers
  final _tenBenhController = TextEditingController();
  final _maBenhController = TextEditingController();
  final _moTaController = TextEditingController();
  final _trieuChungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taiDanhSachBenh();
  }

  @override
  void dispose() {
    _tenBenhController.dispose();
    _maBenhController.dispose();
    _moTaController.dispose();
    _trieuChungController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // TẢI DANH SÁCH BỆNH
  // ─────────────────────────────────────────────────────────────
  Future<void> _taiDanhSachBenh() async {
    setState(() => _dangTai = true);

    // TODO: Gọi API lấy danh sách bệnh
    await Future.delayed(const Duration(seconds: 1));

    // Dữ liệu mẫu
    setState(() {
      _danhSachBenh = [
        {
          'id': 1,
          'ma_benh': 'B001',
          'ten_benh': 'Cảm cúm',
          'mo_ta': 'Bệnh nhiễm trùng đường hô hấp',
          'trieu_chung': 'Sốt, ho, đau họng',
        },
        {
          'id': 2,
          'ma_benh': 'B002',
          'ten_benh': 'Viêm họng',
          'mo_ta': 'Viêm nhiễm vùng họng',
          'trieu_chung': 'Đau họng, khó nuốt',
        },
        {
          'id': 3,
          'ma_benh': 'B003',
          'ten_benh': 'Đau dạ dày',
          'mo_ta': 'Viêm loét dạ dày',
          'trieu_chung': 'Đau bụng, buồn nôn',
        },
        {
          'id': 4,
          'ma_benh': 'B004',
          'ten_benh': 'Cao huyết áp',
          'mo_ta': 'Huyết áp cao bất thường',
          'trieu_chung': 'Đau đầu, chóng mặt',
        },
        {
          'id': 5,
          'ma_benh': 'B005',
          'ten_benh': 'Tiểu đường',
          'mo_ta': 'Rối loạn chuyển hóa đường',
          'trieu_chung': 'Khát nước, tiểu nhiều',
        },
      ];
      _dangTai = false;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // HIỂN THỊ DIALOG THÊM/SỬA BỆNH
  // ─────────────────────────────────────────────────────────────
  void _hienThiDialogBenh({Map<String, dynamic>? benh}) {
    final isEdit = benh != null;

    if (isEdit) {
      _maBenhController.text = benh['ma_benh'] ?? '';
      _tenBenhController.text = benh['ten_benh'] ?? '';
      _moTaController.text = benh['mo_ta'] ?? '';
      _trieuChungController.text = benh['trieu_chung'] ?? '';
    } else {
      _maBenhController.clear();
      _tenBenhController.clear();
      _moTaController.clear();
      _trieuChungController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa bệnh' : 'Thêm bệnh mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _maBenhController,
                decoration: const InputDecoration(
                  labelText: 'Mã bệnh *',
                  border: OutlineInputBorder(),
                ),
                enabled: !isEdit,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tenBenhController,
                decoration: const InputDecoration(
                  labelText: 'Tên bệnh *',
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
                controller: _trieuChungController,
                decoration: const InputDecoration(
                  labelText: 'Triệu chứng',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
              if (_maBenhController.text.trim().isEmpty ||
                  _tenBenhController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập đầy đủ thông tin bắt buộc'),
                  ),
                );
                return;
              }

              // TODO: Gọi API thêm/sửa bệnh
              Navigator.pop(context);
              _taiDanhSachBenh();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEdit
                        ? 'Cập nhật bệnh thành công'
                        : 'Thêm bệnh thành công',
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
  // XÓA BỆNH
  // ─────────────────────────────────────────────────────────────
  Future<void> _xoaBenh(int id) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa bệnh này?'),
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
      // TODO: Gọi API xóa bệnh
      _taiDanhSachBenh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa bệnh thành công'),
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
          'Quản lý Bệnh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _hienThiDialogBenh(),
        backgroundColor: _mauXanh,
        icon: const Icon(Icons.add),
        label: const Text('Thêm bệnh'),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : _danhSachBenh.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bệnh nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _danhSachBenh.length,
              itemBuilder: (context, index) {
                final benh = _danhSachBenh[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.pink,
                      ),
                    ),
                    title: Text(
                      benh['ten_benh'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _mauChuDen,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Mã: ${benh['ma_benh']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (benh['mo_ta'] != null &&
                                benh['mo_ta'].toString().isNotEmpty) ...[
                              const Text(
                                'Mô tả:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(benh['mo_ta']),
                              const SizedBox(height: 12),
                            ],
                            if (benh['trieu_chung'] != null &&
                                benh['trieu_chung'].toString().isNotEmpty) ...[
                              const Text(
                                'Triệu chứng:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(benh['trieu_chung']),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _hienThiDialogBenh(benh: benh),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Sửa'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _xoaBenh(benh['id']),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Xóa'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
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
              },
            ),
    );
  }
}
