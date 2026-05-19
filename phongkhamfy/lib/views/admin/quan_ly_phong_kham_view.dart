import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';

class QuanLyPhongKhamView extends StatefulWidget {
  const QuanLyPhongKhamView({super.key});

  @override
  State<QuanLyPhongKhamView> createState() => _QuanLyPhongKhamViewState();
}

class _QuanLyPhongKhamViewState extends State<QuanLyPhongKhamView> {
  final _adminController = AdminController();

  // State
  List<Map<String, dynamic>> _danhSachPhongKham = [];
  List<Map<String, dynamic>> _danhSachPhongKhamFiltered = [];
  List<String> _danhSachKhu = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _filterKhu;

  // Form controllers
  final _tenPhongController = TextEditingController();

  // Form state
  String? _khuChon;
  bool _isEditing = false;
  int? _editingPhongId;

  // Colors
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);
  final _mauChuXam = const Color(0xFF5A8A70);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tenPhongController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _adminController.layDanhSachPhongKham(),
        _adminController.layDanhSachKhu(),
      ]);

      if (mounted) {
        setState(() {
          _danhSachPhongKham = (results[0] as List)
              .cast<Map<String, dynamic>>();
          _danhSachKhu = (results[1] as List).cast<String>();
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Lỗi tải dữ liệu', isError: true);
      }
    }
  }

  void _applyFilters() {
    _danhSachPhongKhamFiltered = _danhSachPhongKham.where((phong) {
      final matchSearch = (phong['TenPhong'] ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchFilter = _filterKhu == null || phong['Khu'] == _filterKhu;
      return matchSearch && matchFilter;
    }).toList();
  }

  Future<void> _themPhongKham() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    final result = await _adminController.themPhongKham(
      tenPhong: _tenPhongController.text.trim(),
      khu: _khuChon!,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        _showSnackBar('Thêm phòng khám thành công');
        Navigator.pop(context);
        _clearForm();
        await _loadData();
      } else {
        _showSnackBar(
          result['message'] ?? 'Thêm phòng khám thất bại',
          isError: true,
        );
      }
    }
  }

  Future<void> _capNhatPhongKham() async {
    if (_editingPhongId == null || !_validateForm()) return;

    setState(() => _isLoading = true);
    final result = await _adminController.capNhatPhongKham(
      maPhong: _editingPhongId!,
      tenPhong: _tenPhongController.text.trim(),
      khu: _khuChon!,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        _showSnackBar('Cập nhật phòng khám thành công');
        Navigator.pop(context);
        _clearForm();
        await _loadData();
      } else {
        _showSnackBar(result['message'] ?? 'Cập nhật thất bại', isError: true);
      }
    }
  }

  Future<void> _xoaPhongKham(int maPhong, int index) async {
    final confirmed =
        await showDialog<bool>(
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
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _danhSachPhongKham.removeAt(index));
    final result = await _adminController.xoaPhongKham(maPhong);

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Xóa phòng khám thành công');
        await _loadData();
      } else {
        _showSnackBar(result['message'] ?? 'Xóa thất bại', isError: true);
        await _loadData();
      }
    }
  }

  bool _validateForm() {
    if (_tenPhongController.text.isEmpty || _khuChon == null) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin', isError: true);
      return false;
    }
    return true;
  }

  void _dienFormChinhSua(Map<String, dynamic> phong) {
    _isEditing = true;
    _editingPhongId = phong['MaPhong'];
    _tenPhongController.text = phong['TenPhong'] ?? '';
    _khuChon = phong['Khu'];
    _showFormDialog();
  }

  void _clearForm() {
    _tenPhongController.clear();
    _isEditing = false;
    _editingPhongId = null;
    _khuChon = null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _mauXanh,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFormDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing
                          ? 'Chỉnh sửa phòng khám'
                          : 'Thêm phòng khám mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _mauChuDen,
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  'Tên phòng *',
                  _tenPhongController,
                  Icons.location_on,
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  'Khu *',
                  _khuChon,
                  _danhSachKhu,
                  (v) => setState(() => _khuChon = v),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : (_isEditing ? _capNhatPhongKham : _themPhongKham),
                    icon: Icon(_isEditing ? Icons.save : Icons.add),
                    label: Text(
                      _isEditing ? 'Cập nhật' : 'Thêm phòng khám',
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
      ),
    ).then((_) => _clearForm());
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _mauChuDen,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _mauXanh, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mauXanh.withValues(alpha: 0.3)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _mauChuDen,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _mauXanh.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            hint: Text('Chọn khu', style: TextStyle(color: Colors.grey[600])),
            menuMaxHeight: 300, // Cho phép dropdown scroll nếu có nhiều items
          ),
        ),
      ],
    );
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
        centerTitle: false,
      ),
      body: _isLoading && _danhSachPhongKham.isEmpty
          ? Center(child: CircularProgressIndicator(color: _mauXanh))
          : Column(
              children: [
                // Search & Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          _searchQuery = value;
                          _applyFilters();
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm phòng khám...',
                          prefixIcon: Icon(Icons.search, color: _mauXanh),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _mauXanh.withValues(alpha: 0.3),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Tất cả'),
                              selected: _filterKhu == null,
                              onSelected: (_) {
                                _filterKhu = null;
                                _applyFilters();
                                setState(() {});
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: _mauXanh,
                              labelStyle: TextStyle(
                                color: _filterKhu == null
                                    ? _mauTrang
                                    : _mauChuDen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ..._danhSachKhu.map(
                              (khu) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(
                                    khu,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  selected: _filterKhu == khu,
                                  onSelected: (_) {
                                    _filterKhu = khu;
                                    _applyFilters();
                                    setState(() {});
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: _mauXanh,
                                  labelStyle: TextStyle(
                                    color: _filterKhu == khu
                                        ? _mauTrang
                                        : _mauChuDen,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: _danhSachPhongKhamFiltered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: _mauChuXam.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy phòng khám',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _mauChuXam,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: _mauXanh,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _danhSachPhongKhamFiltered.length,
                            itemBuilder: (context, index) {
                              final phong = _danhSachPhongKhamFiltered[index];
                              final originalIndex = _danhSachPhongKham.indexOf(
                                phong,
                              );
                              return _buildPhongKhamCard(phong, originalIndex);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _clearForm();
          _showFormDialog();
        },
        backgroundColor: _mauXanh,
        icon: const Icon(Icons.add),
        label: const Text('Thêm phòng'),
      ),
    );
  }

  Widget _buildPhongKhamCard(Map<String, dynamic> phong, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_mauTrang, _mauNen],
          ),
        ),
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
                      color: _mauXanh.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on, color: _mauXanh, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phong['TenPhong'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _mauChuDen,
                          ),
                        ),
                        Text(
                          phong['Khu'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: _mauChuXam,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                        onTap: () => _dienFormChinhSua(phong),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () => _xoaPhongKham(phong['MaPhong'], index),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _mauXanh.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.domain, size: 14, color: _mauXanh),
                    const SizedBox(width: 6),
                    Text(
                      'Mã phòng: ${phong['MaPhong']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _mauChuDen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
