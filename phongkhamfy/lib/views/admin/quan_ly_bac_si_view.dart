// ═══════════════════════════════════════════════════════════════
// FILE: quan_ly_bac_si_view.dart
// MÔ TẢ: Giao diện quản lý bác sĩ (Admin)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';

class QuanLyBacSiView extends StatefulWidget {
  const QuanLyBacSiView({super.key});

  @override
  State<QuanLyBacSiView> createState() => _QuanLyBacSiViewState();
}

class _QuanLyBacSiViewState extends State<QuanLyBacSiView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adminController = AdminController();

  // Màu sắc
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);
  final _mauChuXam = const Color(0xFF5A8A70);

  // Controllers cho form - CHỈ CÁC TRƯỜNG NHẬP TAY
  final _hoController = TextEditingController();
  final _tenController = TextEditingController();
  final _emailController = TextEditingController();
  final _sdtController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _timKiemController = TextEditingController();

  // Dropdown values
  String _gioiTinh = 'Nam';
  String? _chuyenKhoa;
  String? _bangCap;
  String? _kinhNghiem;
  DateTime? _ngaySinh;

  // State cho chỉnh sửa
  bool _isEditing = false;
  int? _editingBacSiId;

  // Danh sách cho dropdown
  final List<String> _danhSachChuyenKhoa = [
    'Tim mạch',
    'Nội khoa',
    'Nhi khoa',
    'Sản phụ khoa',
    'Ngoại khoa',
    'Da liễu',
    'Mắt',
    'Tai mũi họng',
    'Răng hàm mặt',
    'Thần kinh',
  ];

  final List<String> _danhSachBangCap = [
    'Bác sĩ',
    'Thạc sĩ',
    'Tiến sĩ',
    'Giáo sư',
  ];

  final List<String> _danhSachKinhNghiem = [
    '0 năm',
    '1 năm',
    '2 năm',
    '3 năm',
    '4 năm',
    '5 năm',
    '6-10 năm',
    '11-15 năm',
    '16-20 năm',
    'Trên 20 năm',
  ];

  // State
  List<BacSi> _danhSachBacSi = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _taiDanhSachBacSi();
  }

  void _onTabChanged() {
    // Khi chuyển về tab Danh sách (index 0), reload danh sách
    if (_tabController.index == 0) {
      _timKiemController.clear();
      _taiDanhSachBacSi();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hoController.dispose();
    _tenController.dispose();
    _emailController.dispose();
    _sdtController.dispose();
    _matKhauController.dispose();
    _timKiemController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // TẢI DANH SÁCH BÁC SĨ TỪ API
  // ═══════════════════════════════════════════════════════════════
  Future<void> _taiDanhSachBacSi({String? search}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final danhSach = await _adminController.layDanhSachBacSi(search: search);
      if (mounted) {
        setState(() {
          _danhSachBacSi = danhSach;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải danh sách bác sĩ';
          _isLoading = false;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TÌM KIẾM BÁC SĨ
  // ═══════════════════════════════════════════════════════════════
  Future<void> _timKiemBacSi() async {
    final keyword = _timKiemController.text.trim();
    await _taiDanhSachBacSi(search: keyword.isEmpty ? null : keyword);
  }

  // ═══════════════════════════════════════════════════════════════
  // THÊM BÁC SĨ MỚI
  // ═══════════════════════════════════════════════════════════════
  Future<void> _themBacSi() async {
    // Validation các trường bắt buộc theo API Laravel
    if (_hoController.text.trim().isEmpty ||
        _tenController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _sdtController.text.trim().isEmpty ||
        _matKhauController.text.trim().isEmpty ||
        _ngaySinh == null ||
        _chuyenKhoa == null ||
        _bangCap == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin bắt buộc (*)'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validation email
    if (!_emailController.text.contains('@')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email không hợp lệ'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validation SĐT
    final sdtClean = _sdtController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (sdtClean.length < 9 || sdtClean.length > 11) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Số điện thoại phải có 9-11 chữ số'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validation mật khẩu
    if (_matKhauController.text.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    // Format ngày sinh: YYYY-MM-DD
    final ngaySinhStr =
        '${_ngaySinh!.year}-${_ngaySinh!.month.toString().padLeft(2, '0')}-${_ngaySinh!.day.toString().padLeft(2, '0')}';

    final result = await _adminController.themBacSi(
      ho: _hoController.text.trim(),
      ten: _tenController.text.trim(),
      ngaySinh: ngaySinhStr,
      gioiTinh: _gioiTinh,
      chuyenKhoa: _chuyenKhoa!,
      bangCap: _bangCap!,
      kinhNghiem: _kinhNghiem ?? '0 năm',
      email: _emailController.text.trim(),
      sdt: _sdtController.text.trim(),
      matKhau: _matKhauController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: _mauXanh),
        );

        // Clear form
        _hoController.clear();
        _tenController.clear();
        _emailController.clear();
        _sdtController.clear();
        _matKhauController.clear();
        setState(() {
          _gioiTinh = 'Nam';
          _chuyenKhoa = null;
          _bangCap = null;
          _ngaySinh = null;
        });

        // Reload danh sách và chuyển về tab danh sách
        await _taiDanhSachBacSi();
        _tabController.animateTo(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CẬP NHẬT BÁC SĨ
  // ═══════════════════════════════════════════════════════════════
  Future<void> _capNhatBacSi() async {
    if (_editingBacSiId == null) return;

    // Validation các trường bắt buộc (trừ mật khẩu khi cập nhật)
    if (_hoController.text.trim().isEmpty ||
        _tenController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _sdtController.text.trim().isEmpty ||
        _ngaySinh == null ||
        _chuyenKhoa == null ||
        _bangCap == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin bắt buộc (*)'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validation email
    if (!_emailController.text.contains('@')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email không hợp lệ'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validation SĐT
    final sdtClean = _sdtController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (sdtClean.length < 9 || sdtClean.length > 11) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Số điện thoại phải có 9-11 chữ số'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validation mật khẩu (nếu có nhập)
    if (_matKhauController.text.isNotEmpty &&
        _matKhauController.text.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    // Format ngày sinh: YYYY-MM-DD
    final ngaySinhStr =
        '${_ngaySinh!.year}-${_ngaySinh!.month.toString().padLeft(2, '0')}-${_ngaySinh!.day.toString().padLeft(2, '0')}';

    final result = await _adminController.capNhatBacSi(
      maBacSi: _editingBacSiId!,
      ho: _hoController.text.trim(),
      ten: _tenController.text.trim(),
      ngaySinh: ngaySinhStr,
      gioiTinh: _gioiTinh,
      chuyenKhoa: _chuyenKhoa!,
      bangCap: _bangCap!,
      kinhNghiem: _kinhNghiem ?? '0 năm',
      email: _emailController.text.trim(),
      sdt: _sdtController.text.trim(),
      matKhau: _matKhauController.text.trim().isEmpty
          ? null
          : _matKhauController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: _mauXanh),
        );

        _clearForm();
        await _taiDanhSachBacSi();
        _tabController.animateTo(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ĐIỀN FORM ĐỂ CHỈNH SỬA
  // ═══════════════════════════════════════════════════════════════
  void _dienFormChinhSua(BacSi bacsi) {
    setState(() {
      _isEditing = true;
      _editingBacSiId = bacsi.maBacSi;

      _hoController.text = bacsi.ho;
      _tenController.text = bacsi.ten;
      _emailController.text = bacsi.email ?? '';
      _sdtController.text = bacsi.sdt ?? '';
      _matKhauController.clear(); // Không hiển thị mật khẩu cũ

      _gioiTinh = bacsi.gioiTinh ?? 'Nam';

      // Kiểm tra xem giá trị có trong danh sách không trước khi set
      _chuyenKhoa =
          (bacsi.chuyenKhoa != null &&
              _danhSachChuyenKhoa.contains(bacsi.chuyenKhoa))
          ? bacsi.chuyenKhoa
          : null;

      _bangCap =
          (bacsi.bangCap != null && _danhSachBangCap.contains(bacsi.bangCap))
          ? bacsi.bangCap
          : null;

      _kinhNghiem =
          (bacsi.kinhNghiem != null &&
              _danhSachKinhNghiem.contains(bacsi.kinhNghiem))
          ? bacsi.kinhNghiem
          : null;

      // Parse ngày sinh
      if (bacsi.ngaySinh != null && bacsi.ngaySinh!.isNotEmpty) {
        try {
          final parts = bacsi.ngaySinh!.split('-');
          if (parts.length == 3) {
            _ngaySinh = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        } catch (e) {
          _ngaySinh = null;
        }
      }
    });

    _tabController.animateTo(1);
  }

  // ═══════════════════════════════════════════════════════════════
  // XÓA FORM
  // ═══════════════════════════════════════════════════════════════
  void _clearForm() {
    _hoController.clear();
    _tenController.clear();
    _emailController.clear();
    _sdtController.clear();
    _matKhauController.clear();
    setState(() {
      _isEditing = false;
      _editingBacSiId = null;
      _gioiTinh = 'Nam';
      _chuyenKhoa = null;
      _bangCap = null;
      _kinhNghiem = null;
      _ngaySinh = null;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // XÓA BÁC SĨ - XÓA NGAY KHỎI DANH SÁCH
  // ═══════════════════════════════════════════════════════════════
  Future<void> _xoaBacSi(int maBacSi, int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa bác sĩ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Xóa ngay khỏi danh sách (optimistic update)
              setState(() {
                _danhSachBacSi.removeAt(index);
              });

              // Gọi API xóa
              final result = await _adminController.xoaBacSi(maBacSi);

              if (mounted) {
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: _mauXanh,
                    ),
                  );
                } else {
                  // Nếu xóa thất bại, reload lại danh sách
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                  await _taiDanhSachBacSi();
                }
              }
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
          'Quản Lý Bác Sĩ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _mauTrang,
          labelColor: _mauTrang,
          unselectedLabelColor: _mauTrang.withValues(alpha: 0.7),
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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: _mauXanh));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _taiDanhSachBacSi,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mauXanh,
                foregroundColor: _mauTrang,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Thanh tìm kiếm
        Container(
          padding: const EdgeInsets.all(16),
          color: _mauTrang,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _timKiemController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên bác sĩ...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _timKiemBacSi(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _timKiemBacSi,
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Tìm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mauXanh,
                  foregroundColor: _mauTrang,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Danh sách hoặc thông báo không tìm thấy
        Expanded(
          child: _danhSachBacSi.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: _mauChuXam.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _timKiemController.text.trim().isEmpty
                            ? 'Chưa có bác sĩ nào'
                            : 'Không tìm thấy bác sĩ',
                        style: TextStyle(
                          fontSize: 16,
                          color: _mauChuXam,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_timKiemController.text.trim().isNotEmpty)
                        Text(
                          'Từ khóa: "${_timKiemController.text.trim()}"',
                          style: TextStyle(
                            fontSize: 14,
                            color: _mauChuXam.withValues(alpha: 0.7),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(1),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Thêm bác sĩ mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mauXanh,
                          foregroundColor: _mauTrang,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _taiDanhSachBacSi,
                  color: _mauXanh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _danhSachBacSi.length,
                    itemBuilder: (context, index) {
                      final bacsi = _danhSachBacSi[index];
                      return _xayDungCardBacSi(bacsi, index);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _xayDungCardBacSi(BacSi bacsi, int index) {
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
                CircleAvatar(
                  backgroundColor: _mauXanh.withValues(alpha: 0.1),
                  radius: 24,
                  child: Icon(
                    bacsi.gioiTinh == 'Nam' ? Icons.male : Icons.female,
                    color: _mauXanh,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BS. ${bacsi.hoTen}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _mauChuDen,
                        ),
                      ),
                      Text(
                        '${bacsi.chuyenKhoa ?? 'N/A'} • ${bacsi.bangCap ?? 'N/A'}',
                        style: TextStyle(fontSize: 13, color: _mauChuXam),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _dienFormChinhSua(bacsi),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _xoaBacSi(bacsi.maBacSi, index),
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
                    Icons.cake,
                    'Ngày sinh',
                    bacsi.ngaySinh ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: _xayDungThongTin(
                    Icons.work_outline,
                    'Kinh nghiệm',
                    bacsi.kinhNghiem ?? 'N/A',
                  ),
                ),
              ],
            ),
            if (bacsi.email != null || bacsi.sdt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (bacsi.email != null)
                    Expanded(
                      child: _xayDungThongTin(
                        Icons.email_outlined,
                        'Email',
                        bacsi.email!,
                      ),
                    ),
                  if (bacsi.sdt != null)
                    Expanded(
                      child: _xayDungThongTin(
                        Icons.phone_outlined,
                        'SĐT',
                        bacsi.sdt!,
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
                overflow: TextOverflow.ellipsis,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Chỉnh sửa bác sĩ' : 'Thêm bác sĩ mới',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _mauChuDen,
                    ),
                  ),
                  if (_isEditing)
                    TextButton.icon(
                      onPressed: _clearForm,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Hủy'),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Họ
              _xayDungNhan('Họ *'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _hoController,
                'Nguyễn Văn',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Tên
              _xayDungNhan('Tên *'),
              const SizedBox(height: 8),
              _xayDungTextField(_tenController, 'An', Icons.person),
              const SizedBox(height: 16),

              // Email
              _xayDungNhan('Email *'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _emailController,
                'bacsi@example.com',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // SĐT
              _xayDungNhan('Số điện thoại *'),
              const SizedBox(height: 8),
              _xayDungTextField(
                _sdtController,
                '0901234567',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Mật khẩu
              _xayDungNhan(
                _isEditing ? 'Mật khẩu (để trống nếu không đổi)' : 'Mật khẩu *',
              ),
              const SizedBox(height: 8),
              _xayDungTextField(
                _matKhauController,
                'Mật khẩu tài khoản',
                Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Divider
              Divider(color: _mauChuXam.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'Thông tin cơ bản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _mauChuDen,
                ),
              ),
              const SizedBox(height: 16),

              // Giới tính
              _xayDungNhan('Giới tính *'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Nam', style: TextStyle(fontSize: 14)),
                      value: 'Nam',
                      groupValue: _gioiTinh,
                      onChanged: (value) {
                        setState(() => _gioiTinh = value!);
                      },
                      activeColor: _mauXanh,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Nữ', style: TextStyle(fontSize: 14)),
                      value: 'Nữ',
                      groupValue: _gioiTinh,
                      onChanged: (value) {
                        setState(() => _gioiTinh = value!);
                      },
                      activeColor: _mauXanh,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ngày sinh - Date Picker
              _xayDungNhan('Ngày sinh *'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _ngaySinh ?? DateTime(1990, 1, 1),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _ngaySinh = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: _mauChuXam),
                      const SizedBox(width: 12),
                      Text(
                        _ngaySinh != null
                            ? DateFormat('dd/MM/yyyy').format(_ngaySinh!)
                            : 'Chọn ngày sinh',
                        style: TextStyle(
                          fontSize: 16,
                          color: _ngaySinh != null
                              ? _mauChuDen
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Chuyên khoa - Dropdown
              _xayDungNhan('Chuyên khoa *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _chuyenKhoa,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.medical_services_outlined,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                hint: const Text('Chọn chuyên khoa'),
                isExpanded: true,
                items: _danhSachChuyenKhoa.map((khoa) {
                  return DropdownMenuItem(
                    value: khoa,
                    child: Text(khoa, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _chuyenKhoa = value);
                },
              ),
              const SizedBox(height: 16),

              // Bằng cấp - Dropdown
              _xayDungNhan('Bằng cấp *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _bangCap,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                hint: const Text('Chọn bằng cấp'),
                isExpanded: true,
                items: _danhSachBangCap.map((cap) {
                  return DropdownMenuItem(
                    value: cap,
                    child: Text(cap, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _bangCap = value);
                },
              ),
              const SizedBox(height: 16),

              // Kinh nghiệm - Dropdown
              _xayDungNhan('Kinh nghiệm'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _kinhNghiem,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.work_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                hint: const Text('Chọn kinh nghiệm'),
                isExpanded: true,
                items: _danhSachKinhNghiem.map((kn) {
                  return DropdownMenuItem(
                    value: kn,
                    child: Text(kn, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _kinhNghiem = value);
                },
              ),
              const SizedBox(height: 8),
              Text(
                '* Trường bắt buộc',
                style: TextStyle(fontSize: 12, color: _mauChuXam),
              ),
              const SizedBox(height: 24),

              // Nút thêm/cập nhật
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : (_isEditing ? _capNhatBacSi : _themBacSi),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.add, size: 20),
                  label: Text(
                    _isLoading
                        ? (_isEditing ? 'Đang cập nhật...' : 'Đang thêm...')
                        : (_isEditing ? 'Cập nhật' : 'Thêm bác sĩ'),
                    style: const TextStyle(
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
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
