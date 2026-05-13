// ═══════════════════════════════════════════════════════════════
// FILE: quan_ly_ca_kham_view.dart
// MÔ TẢ: Giao diện quản lý ca khám (Admin)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class QuanLyCaKhamView extends StatefulWidget {
  const QuanLyCaKhamView({super.key});

  @override
  State<QuanLyCaKhamView> createState() => _QuanLyCaKhamViewState();
}

class _QuanLyCaKhamViewState extends State<QuanLyCaKhamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);
  final _mauChuXam = const Color(0xFF5A8A70);

  // Controllers
  final _tenCaController = TextEditingController();
  final _gioBatDauController = TextEditingController();
  final _gioKetThucController = TextEditingController();
  final _soLuongToiDaController = TextEditingController();
  final _thoiLuongKhamController = TextEditingController();

  // Dữ liệu mẫu
  final List<Map<String, dynamic>> _danhSachCa = [
    {
      'MaCa': 1,
      'TenCa': 'Ca sáng',
      'GioBatDau': '07:00',
      'GioKetThuc': '11:00',
      'SoLuongToiDa': 20,
      'ThoiLuongKham': 15,
      'TrangThai': 'active',
    },
    {
      'MaCa': 2,
      'TenCa': 'Ca chiều',
      'GioBatDau': '13:00',
      'GioKetThuc': '17:00',
      'SoLuongToiDa': 20,
      'ThoiLuongKham': 15,
      'TrangThai': 'active',
    },
    {
      'MaCa': 3,
      'TenCa': 'Ca tối',
      'GioBatDau': '18:00',
      'GioKetThuc': '21:00',
      'SoLuongToiDa': 15,
      'ThoiLuongKham': 15,
      'TrangThai': 'active',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tenCaController.dispose();
    _gioBatDauController.dispose();
    _gioKetThucController.dispose();
    _soLuongToiDaController.dispose();
    _thoiLuongKhamController.dispose();
    super.dispose();
  }

  void _themCa() {
    // TODO: Gọi API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thêm ca khám thành công'),
        backgroundColor: _mauXanh,
      ),
    );
    _tabController.animateTo(0);
  }

  void _xoaCa(int maCa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa ca khám này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa ca khám'),
                  backgroundColor: _mauXanh,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mauNen,
      appBar: AppBar(
        title: const Text(
          'Quản Lý Ca Khám',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _mauTrang,
          labelColor: _mauTrang,
          unselectedLabelColor: _mauTrang.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.list, size: 20), text: 'Danh sách'),
            Tab(
              icon: Icon(Icons.add_circle_outline, size: 20),
              text: 'Thêm mới',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_xayDungDanhSach(), _xayDungFormThem()],
      ),
    );
  }

  Widget _xayDungDanhSach() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _danhSachCa.length,
      itemBuilder: (context, index) {
        final ca = _danhSachCa[index];
        return _xayDungCardCa(ca);
      },
    );
  }

  Widget _xayDungCardCa(Map<String, dynamic> ca) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.teal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ca['TenCa'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _mauChuDen,
                        ),
                      ),
                      Text(
                        '${ca['GioBatDau']} - ${ca['GioKetThuc']}',
                        style: TextStyle(fontSize: 13, color: _mauChuXam),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _xoaCa(ca['MaCa']),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _xayDungThongTin(
                    Icons.people_outline,
                    'Số lượng tối đa',
                    '${ca['SoLuongToiDa']} bệnh nhân',
                  ),
                ),
                Expanded(
                  child: _xayDungThongTin(
                    Icons.timer_outlined,
                    'Thời lượng khám',
                    '${ca['ThoiLuongKham']} phút',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Đang hoạt động',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Sửa
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mauXanh,
                    foregroundColor: _mauTrang,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungThongTin(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _mauChuXam),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: _mauChuXam)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: _mauChuDen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _xayDungFormThem() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin ca khám',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _mauChuDen,
                ),
              ),
              const SizedBox(height: 20),

              // Tên ca
              _xayDungNhan('Tên ca'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _tenCaController,
                'Ca sáng',
                Icons.label_outline,
              ),
              const SizedBox(height: 16),

              // Giờ bắt đầu
              _xayDungNhan('Giờ bắt đầu'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _gioBatDauController,
                '07:00',
                Icons.access_time,
              ),
              const SizedBox(height: 16),

              // Giờ kết thúc
              _xayDungNhan('Giờ kết thúc'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _gioKetThucController,
                '11:00',
                Icons.access_time_filled,
              ),
              const SizedBox(height: 16),

              // Số lượng tối đa
              _xayDungNhan('Số lượng bệnh nhân tối đa'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _soLuongToiDaController,
                '20',
                Icons.people_outline,
              ),
              const SizedBox(height: 16),

              // Thời lượng khám
              _xayDungNhan('Thời lượng khám (phút)'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _thoiLuongKhamController,
                '15',
                Icons.timer_outlined,
              ),
              const SizedBox(height: 24),

              // Nút thêm
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _themCa,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Thêm ca khám',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mauXanh,
                    foregroundColor: _mauTrang,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _xayDungNhan(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _mauChuDen,
      ),
    );
  }

  Widget _xayDungTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
