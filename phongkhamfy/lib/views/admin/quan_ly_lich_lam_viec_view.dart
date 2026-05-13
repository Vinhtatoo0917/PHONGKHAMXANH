// ═══════════════════════════════════════════════════════════════
// FILE: quan_ly_lich_lam_viec_view.dart
// MÔ TẢ: Giao diện quản lý lịch làm việc cho bác sĩ (Admin)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuanLyLichLamViecView extends StatefulWidget {
  const QuanLyLichLamViecView({super.key});

  @override
  State<QuanLyLichLamViecView> createState() => _QuanLyLichLamViecViewState();
}

class _QuanLyLichLamViecViewState extends State<QuanLyLichLamViecView>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────
  // BIẾN TRẠNG THÁI
  // ─────────────────────────────────────────────────────────────
  late TabController _tabController;
  DateTime _ngayDuocChon = DateTime.now();
  int? _bacSiDuocChon;
  int? _caDuocChon;
  int? _phongDuocChon;

  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);
  final _mauChuXam = const Color(0xFF5A8A70);

  // ─────────────────────────────────────────────────────────────
  // DỮ LIỆU MẪU (sẽ thay bằng API sau)
  // ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _danhSachBacSi = [
    {
      'MaBacSi': 1,
      'ho': 'Nguyễn Văn',
      'ten': 'An',
      'ChuyenKhoa': 'Tim mạch',
      'BangCap': 'Thạc sĩ',
    },
    {
      'MaBacSi': 2,
      'ho': 'Trần Thị',
      'ten': 'Bình',
      'ChuyenKhoa': 'Nội khoa',
      'BangCap': 'Tiến sĩ',
    },
    {
      'MaBacSi': 3,
      'ho': 'Lê Minh',
      'ten': 'Châu',
      'ChuyenKhoa': 'Nhi khoa',
      'BangCap': 'Bác sĩ',
    },
  ];

  final List<Map<String, dynamic>> _danhSachCaKham = [
    {
      'MaCa': 1,
      'TenCa': 'Ca sáng',
      'GioBatDau': '07:00',
      'GioKetThuc': '11:00',
      'SoLuongToiDa': 20,
    },
    {
      'MaCa': 2,
      'TenCa': 'Ca chiều',
      'GioBatDau': '13:00',
      'GioKetThuc': '17:00',
      'SoLuongToiDa': 20,
    },
    {
      'MaCa': 3,
      'TenCa': 'Ca tối',
      'GioBatDau': '18:00',
      'GioKetThuc': '21:00',
      'SoLuongToiDa': 15,
    },
  ];

  final List<Map<String, dynamic>> _danhSachPhongKham = [
    {'MaPhong': 1, 'TenPhong': 'Phòng khám 101', 'Khu': 'Khu A'},
    {'MaPhong': 2, 'TenPhong': 'Phòng khám 102', 'Khu': 'Khu A'},
    {'MaPhong': 3, 'TenPhong': 'Phòng khám 201', 'Khu': 'Khu B'},
    {'MaPhong': 4, 'TenPhong': 'Phòng khám 202', 'Khu': 'Khu B'},
  ];

  final List<Map<String, dynamic>> _danhSachLichLamViec = [
    {
      'MaLichLamViec': 1,
      'MaBacSi': 1,
      'tenBacSi': 'BS. Nguyễn Văn An',
      'ChuyenKhoa': 'Tim mạch',
      'Ngay': '2025-05-10',
      'MaCa': 1,
      'TenCa': 'Ca sáng',
      'GioBatDau': '07:00',
      'GioKetThuc': '11:00',
      'MaPhong': 1,
      'TenPhong': 'Phòng khám 101',
      'Khu': 'Khu A',
    },
    {
      'MaLichLamViec': 2,
      'MaBacSi': 2,
      'tenBacSi': 'BS. Trần Thị Bình',
      'ChuyenKhoa': 'Nội khoa',
      'Ngay': '2025-05-10',
      'MaCa': 2,
      'TenCa': 'Ca chiều',
      'GioBatDau': '13:00',
      'GioKetThuc': '17:00',
      'MaPhong': 2,
      'TenPhong': 'Phòng khám 102',
      'Khu': 'Khu A',
    },
  ];

  // ─────────────────────────────────────────────────────────────
  // KHỞI TẠO VÀ HỦY
  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // HÀM XỬ LÝ
  // ─────────────────────────────────────────────────────────────
  void _chonNgay() async {
    final ngayChon = await showDatePicker(
      context: context,
      initialDate: _ngayDuocChon,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _mauXanh,
              onPrimary: _mauTrang,
            ),
          ),
          child: child!,
        );
      },
    );

    if (ngayChon != null) {
      setState(() => _ngayDuocChon = ngayChon);
    }
  }

  void _themLichLamViec() {
    if (_bacSiDuocChon == null ||
        _caDuocChon == null ||
        _phongDuocChon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ thông tin'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // TODO: Gọi API thêm lịch làm việc
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thêm lịch làm việc thành công'),
        backgroundColor: _mauXanh,
      ),
    );

    // Reset form
    setState(() {
      _bacSiDuocChon = null;
      _caDuocChon = null;
      _phongDuocChon = null;
      _ngayDuocChon = DateTime.now();
      _tabController.animateTo(0);
    });
  }

  void _xoaLichLamViec(int maLich) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa lịch làm việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Gọi API xóa lịch
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa lịch làm việc'),
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

  // ─────────────────────────────────────────────────────────────
  // GIAO DIỆN
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mauNen,
      appBar: AppBar(
        title: const Text(
          'Quản Lý Lịch Làm Việc',
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
            Tab(icon: Icon(Icons.list), text: 'Danh sách'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Thêm mới'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_xayDungDanhSachLich(), _xayDungFormThemLich()],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: DANH SÁCH LỊCH LÀM VIỆC
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungDanhSachLich() {
    return Column(
      children: [
        // Bộ lọc
        Container(
          padding: const EdgeInsets.all(16),
          color: _mauTrang,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bác sĩ...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  // TODO: Mở bộ lọc nâng cao
                },
                icon: Icon(Icons.filter_list, color: _mauXanh),
                style: IconButton.styleFrom(
                  backgroundColor: _mauXanh.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),

        // Danh sách
        Expanded(
          child: _danhSachLichLamViec.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: _mauChuXam.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có lịch làm việc nào',
                        style: TextStyle(fontSize: 16, color: _mauChuXam),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _danhSachLichLamViec.length,
                  itemBuilder: (context, index) {
                    final lich = _danhSachLichLamViec[index];
                    return _xayDungCardLichLamViec(lich);
                  },
                ),
        ),
      ],
    );
  }

  Widget _xayDungCardLichLamViec(Map<String, dynamic> lich) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tên bác sĩ + Chuyên khoa
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _mauXanh.withOpacity(0.1),
                  radius: 20,
                  child: Icon(Icons.person, color: _mauXanh, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lich['tenBacSi'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _mauChuDen,
                        ),
                      ),
                      Text(
                        lich['ChuyenKhoa'],
                        style: TextStyle(fontSize: 13, color: _mauChuXam),
                      ),
                    ],
                  ),
                ),
                // Nút xóa
                IconButton(
                  onPressed: () => _xoaLichLamViec(lich['MaLichLamViec']),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),

            const Divider(height: 24),

            // Thông tin lịch
            Row(
              children: [
                Expanded(
                  child: _xayDungThongTinNho(
                    Icons.calendar_today,
                    'Ngày',
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.parse(lich['Ngay'])),
                  ),
                ),
                Expanded(
                  child: _xayDungThongTinNho(
                    Icons.access_time,
                    lich['TenCa'],
                    '${lich['GioBatDau']} - ${lich['GioKetThuc']}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _xayDungThongTinNho(
                    Icons.meeting_room,
                    lich['TenPhong'],
                    lich['Khu'],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Sửa lịch
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

  Widget _xayDungThongTinNho(IconData icon, String tieude, String noidung) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _mauChuXam),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tieude,
                style: TextStyle(
                  fontSize: 11,
                  color: _mauChuXam,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                noidung,
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

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: THÊM LỊCH MỚI
  // ═══════════════════════════════════════════════════════════════
  Widget _xayDungFormThemLich() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card form
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin lịch làm việc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _mauChuDen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chọn bác sĩ
                  _xayDungNhan('Chọn bác sĩ'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      hintText: 'Chọn bác sĩ',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    isExpanded:
                        true, // ✅ Thêm dòng này để text không bị overflow
                    items: _danhSachBacSi.map((bacsi) {
                      return DropdownMenuItem<int>(
                        value: bacsi['MaBacSi'],
                        child: Text(
                          'BS. ${bacsi['ho']} ${bacsi['ten']} - ${bacsi['ChuyenKhoa']}',
                          overflow:
                              TextOverflow.ellipsis, // ✅ Cắt text nếu quá dài
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _bacSiDuocChon = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Chọn ngày
                  _xayDungNhan('Chọn ngày làm việc'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _chonNgay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: _mauChuXam),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_ngayDuocChon),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn ca khám
                  _xayDungNhan('Chọn ca khám'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      hintText: 'Chọn ca khám',
                      prefixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    isExpanded: true, // ✅ Thêm dòng này
                    items: _danhSachCaKham.map((ca) {
                      return DropdownMenuItem<int>(
                        value: ca['MaCa'],
                        child: Text(
                          '${ca['TenCa']} (${ca['GioBatDau']} - ${ca['GioKetThuc']})',
                          overflow:
                              TextOverflow.ellipsis, // ✅ Cắt text nếu quá dài
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _caDuocChon = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Chọn phòng khám
                  _xayDungNhan('Chọn phòng khám'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      hintText: 'Chọn phòng khám',
                      prefixIcon: const Icon(Icons.meeting_room),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    isExpanded: true, // ✅ Thêm dòng này
                    items: _danhSachPhongKham.map((phong) {
                      return DropdownMenuItem<int>(
                        value: phong['MaPhong'],
                        child: Text(
                          '${phong['TenPhong']} - ${phong['Khu']}',
                          overflow:
                              TextOverflow.ellipsis, // ✅ Cắt text nếu quá dài
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _phongDuocChon = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút thêm
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _themLichLamViec,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Thêm lịch làm việc',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

          const SizedBox(height: 16),

          // Hướng dẫn
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _mauXanh),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lưu ý: Kiểm tra kỹ thông tin trước khi thêm lịch làm việc',
                      style: TextStyle(fontSize: 13, color: _mauChuXam),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
}
