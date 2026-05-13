// ═══════════════════════════════════════════════════════════════
// FILE: quan_ly_phong_kham_view.dart
// MÔ TẢ: Giao diện quản lý phòng khám (Admin) - Ultra Premium Design
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';

class QuanLyPhongKhamView extends StatefulWidget {
  const QuanLyPhongKhamView({super.key});

  @override
  State<QuanLyPhongKhamView> createState() => _QuanLyPhongKhamViewState();
}

class _QuanLyPhongKhamViewState extends State<QuanLyPhongKhamView>
    with SingleTickerProviderStateMixin {
  final _adminController = AdminController();
  late AnimationController _animationController;

  // Màu sắc - Premium Palette
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauXanhDam = const Color(0xFF2A8B5E);
  final _mauNen = const Color(0xFFF5F9F7);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF0F2818);
  final _mauChuXam = const Color(0xFF6B8B7E);

  // Controllers
  final _tenPhongController = TextEditingController();
  final _khuController = TextEditingController();
  final _timKiemController = TextEditingController();

  // State
  List<Map<String, dynamic>> _danhSachPhong = [];
  final List<String> _danhSachKhu = const [
    'Tầng 1 - Phòng Khám Ngoại Trú',
    'Tầng 2 - Phòng Khám Nội Trú',
    'Tầng 3 - Phòng Khám Tim Mạch',
    'Tầng 4 - Phòng Khám Nhi Khoa',
    'Tầng 5 - Phòng Khám Sản Phụ Khoa',
    'Tầng 6 - Phòng Khám Ngoại Khoa',
    'Tầng 7 - Phòng Khám Da Liễu',
    'Tầng 8 - Phòng Khám Mắt',
    'Tầng 9 - Phòng Khám Tai Mũi Họng',
    'Tầng 10 - Phòng Khám Thần Kinh',
    'Tầng 11 - Phòng Khám Hô Hấp',
    'Tầng 12 - Phòng Khám Tiêu Hóa',
    'Tầng 13 - Phòng Khám Cơ Xương Khớp',
    'Tầng 14 - Phòng Khám Tâm Thần',
    'Tầng 15 - Phòng Khám Nha Khoa',
    'Phòng Khám Cấp Cứu',
    'Phòng Khám Chuyên Sâu',
    'Phòng Khám Tư Vấn',
  ];
  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingPhongId;
  String? _selectedKhu;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _taiDanhSachPhong();
  }

  @override
  void dispose() {
    _tenPhongController.dispose();
    _khuController.dispose();
    _timKiemController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _taiDanhSachPhong({String? search, String? khu}) async {
    setState(() => _isLoading = true);
    try {
      final danhSach = await _adminController.layDanhSachPhongKham(
        search: search,
        khu: khu,
      );
      if (mounted) {
        setState(() {
          _danhSachPhong = danhSach;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _timKiemPhong() async {
    final keyword = _timKiemController.text.trim();
    await _taiDanhSachPhong(
      search: keyword.isEmpty ? null : keyword,
      khu: _selectedKhu,
    );
  }

  Future<void> _themPhong() async {
    if (_tenPhongController.text.trim().isEmpty ||
        _khuController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _adminController.themPhongKham(
      tenPhong: _tenPhongController.text.trim(),
      khu: _khuController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: _mauXanh),
        );
        _clearForm();
        await _taiDanhSachPhong();
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

  Future<void> _capNhatPhong() async {
    if (_editingPhongId == null) return;
    if (_tenPhongController.text.trim().isEmpty ||
        _khuController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _adminController.capNhatPhongKham(
      maPhong: _editingPhongId!,
      tenPhong: _tenPhongController.text.trim(),
      khu: _khuController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: _mauXanh),
        );
        _clearForm();
        await _taiDanhSachPhong();
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

  void _hienThiDialogChonKhu() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _mauTrang,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_mauXanh, _mauXanhDam],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: _mauTrang, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chọn Khu Phòng Khám',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _mauTrang,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _danhSachKhu.length,
                  itemBuilder: (context, index) {
                    final khu = _danhSachKhu[index];
                    final isSelected = _khuController.text == khu;
                    final isFloor = khu.startsWith('Tầng');

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isSelected
                            ? _mauXanh.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? _mauXanh : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _mauXanh.withValues(alpha: 0.2),
                                _mauXanh.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isFloor ? Icons.apartment : Icons.local_hospital,
                            color: _mauXanh,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          khu,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? _mauXanh : _mauChuDen,
                            letterSpacing: 0.2,
                          ),
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _mauXanh,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() => _khuController.text = khu);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: _mauChuDen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
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

  void _hienThiDialogLocKhu() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _mauTrang,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_mauXanh, _mauXanhDam],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: _mauTrang, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lọc Theo Khu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _mauTrang,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _danhSachKhu.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _selectedKhu == null;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isSelected
                              ? _mauXanh.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? _mauXanh : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _mauXanh.withValues(alpha: 0.2),
                                  _mauXanh.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.apps, color: _mauXanh, size: 22),
                          ),
                          title: Text(
                            'Tất cả khu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected ? _mauXanh : _mauChuDen,
                              letterSpacing: 0.2,
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _mauXanh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                )
                              : null,
                          onTap: () {
                            setState(() => _selectedKhu = null);
                            _taiDanhSachPhong(khu: null);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }

                    final khu = _danhSachKhu[index - 1];
                    final isSelected = _selectedKhu == khu;
                    final isFloor = khu.startsWith('Tầng');

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isSelected
                            ? _mauXanh.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? _mauXanh : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _mauXanh.withValues(alpha: 0.2),
                                _mauXanh.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isFloor ? Icons.apartment : Icons.local_hospital,
                            color: _mauXanh,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          khu,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? _mauXanh : _mauChuDen,
                            letterSpacing: 0.2,
                          ),
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _mauXanh,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedKhu = khu);
                          _taiDanhSachPhong(khu: khu);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: _mauChuDen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
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

  void _dienFormChinhSua(Map<String, dynamic> phong) {
    setState(() {
      _isEditing = true;
      _editingPhongId = phong['MaPhong'];
      _tenPhongController.text = phong['TenPhong'] ?? '';
      _khuController.text = phong['Khu'] ?? '';
    });
    _animationController.forward();
  }

  void _clearForm() {
    _tenPhongController.clear();
    _khuController.clear();
    setState(() {
      _isEditing = false;
      _editingPhongId = null;
    });
    _animationController.reverse();
  }

  Future<void> _xoaPhong(int maPhong, int index) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa phòng khám này?'),
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
      setState(() => _danhSachPhong.removeAt(index));
      final result = await _adminController.xoaPhongKham(maPhong);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: _mauXanh,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
          await _taiDanhSachPhong();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mauNen,
      appBar: AppBar(
        title: const Text(
          'Quản Lý Phòng Khám',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
      ),
      body: _isEditing ? _xayDungFormChinhSua() : _xayDungDanhSach(),
      floatingActionButton: !_isEditing
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _isEditing = true),
              backgroundColor: _mauXanh,
              elevation: 8,
              icon: const Icon(Icons.add, size: 28),
              label: const Text(
                'Thêm phòng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _xayDungDanhSach() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _mauXanh, strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(color: _mauChuXam, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header với gradient premium
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_mauXanh, _mauXanhDam],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _mauXanh.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // Tìm kiếm
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _timKiemController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm phòng khám...',
                    prefixIcon: Icon(Icons.search, size: 22, color: _mauXanh),
                    suffixIcon: _timKiemController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: _mauXanh),
                            onPressed: () {
                              _timKiemController.clear();
                              _timKiemPhong();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: _mauTrang,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _timKiemPhong(),
                ),
              ),
              const SizedBox(height: 12),
              // Lọc theo khu
              InkWell(
                onTap: () => _hienThiDialogLocKhu(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _mauTrang,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 22,
                        color: _mauXanh,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedKhu == null ? 'Lọc theo khu' : _selectedKhu!,
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedKhu == null
                                ? Colors.grey[500]
                                : _mauChuDen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: _mauXanh, size: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Danh sách
        Expanded(
          child: _danhSachPhong.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _mauXanh.withValues(alpha: 0.15),
                              _mauXanh.withValues(alpha: 0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.meeting_room_outlined,
                          size: 72,
                          color: _mauXanh,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Chưa có phòng khám nào',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _mauChuDen,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nhấn nút "Thêm phòng" để tạo mới',
                        style: TextStyle(
                          fontSize: 15,
                          color: _mauChuXam,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _taiDanhSachPhong,
                  color: _mauXanh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _danhSachPhong.length,
                    itemBuilder: (context, index) {
                      final phong = _danhSachPhong[index];
                      return _xayDungCardPhong(phong, index);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _xayDungCardPhong(Map<String, dynamic> phong, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _mauXanh.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: _mauTrang,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon với gradient
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _mauXanh.withValues(alpha: 0.25),
                        _mauXanh.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _mauXanh.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.meeting_room, color: _mauXanh, size: 32),
                ),
                const SizedBox(width: 16),
                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phong['TenPhong'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _mauChuDen,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _mauXanh.withValues(alpha: 0.15),
                              _mauXanh.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _mauXanh.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          phong['Khu'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _mauXanh,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Nút hành động
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: _mauXanh, size: 20),
                          const SizedBox(width: 10),
                          const Text(
                            'Chỉnh sửa',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      onTap: () => _dienFormChinhSua(phong),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Xóa',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _xoaPhong(phong['MaPhong'], index),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, color: _mauChuXam, size: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _xayDungFormChinhSua() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingPhongId != null ? 'CHỈNH SỬA' : 'THÊM MỚI',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _mauXanh,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _editingPhongId != null
                        ? 'Cập Nhật Phòng Khám'
                        : 'Tạo Phòng Khám Mới',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _mauChuDen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _clearForm,
                  icon: Icon(Icons.close, color: _mauChuXam, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Tên phòng
          Text(
            'Tên Phòng Khám',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _mauChuDen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: _mauXanh.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _tenPhongController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Phòng khám A1',
                prefixIcon: Icon(Icons.meeting_room, color: _mauXanh, size: 24),
                filled: true,
                fillColor: _mauTrang,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _mauXanh.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _mauXanh, width: 2.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _mauChuDen,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Khu
          Text(
            'Chọn Khu',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _mauChuDen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _hienThiDialogChonKhu(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: _mauTrang,
                border: Border.all(
                  color: _khuController.text.isEmpty
                      ? _mauXanh.withValues(alpha: 0.2)
                      : _mauXanh,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _mauXanh.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: _mauXanh, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _khuController.text.isEmpty
                          ? 'Chọn khu phòng khám'
                          : _khuController.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _khuController.text.isEmpty
                            ? Colors.grey[500]
                            : _mauChuDen,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: _mauXanh, size: 28),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Nút hành động
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _clearForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: _mauChuDen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[100],
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : (_editingPhongId != null ? _capNhatPhong : _themPhong),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          _editingPhongId != null ? Icons.save : Icons.add,
                          size: 24,
                        ),
                  label: Text(
                    _isLoading
                        ? 'Đang xử lý'
                        : (_editingPhongId != null ? 'Cập Nhật' : 'Thêm Mới'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mauXanh,
                    foregroundColor: _mauTrang,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    disabledBackgroundColor: _mauXanh.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
