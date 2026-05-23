import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

class QuanLyCaKhamView extends StatefulWidget {
  const QuanLyCaKhamView({super.key});

  @override
  State<QuanLyCaKhamView> createState() => _QuanLyCaKhamViewState();
}

class _QuanLyCaKhamViewState extends State<QuanLyCaKhamView> {
  final _adminController = AdminController();

  // State
  List<Map<String, dynamic>> _danhSachCaKham = [];
  List<Map<String, dynamic>> _danhSachCaKhamFiltered = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _filterTrangThai;

  // Form controllers
  final _tenCaController = TextEditingController();
  final _soLuongController = TextEditingController();
  final _thoiLuongController = TextEditingController();

  // Form state
  TimeOfDay? _gioBatDau;
  TimeOfDay? _gioKetThuc;
  String _trangThai = 'active';
  bool _isEditing = false;
  int? _editingCaId;

  // Colors
  final _mauXanh = const Color(0xFF3DAA70);
  final _mauNen = const Color(0xFFF0FAF5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1A3D2E);
  final _mauChuXam = const Color(0xFF5A8A70);

  @override
  void initState() {
    super.initState();
    _taiDanhSachCaKham();
  }

  @override
  void dispose() {
    _tenCaController.dispose();
    _soLuongController.dispose();
    _thoiLuongController.dispose();
    super.dispose();
  }

  Future<void> _taiDanhSachCaKham() async {
    setState(() => _isLoading = true);
    try {
      final danhSach = await _adminController.layDanhSachCaKham();
      if (mounted) {
        setState(() {
          _danhSachCaKham = danhSach;
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
    _danhSachCaKhamFiltered = _danhSachCaKham.where((ca) {
      final matchSearch = (ca['TenCa'] ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchFilter =
          _filterTrangThai == null || ca['TrangThai'] == _filterTrangThai;
      return matchSearch && matchFilter;
    }).toList();
  }

  Future<void> _themCaKham() async {
    if (!_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang thêm ca khám...');
    final result = await _adminController.themCaKham(
      tenCa: _tenCaController.text.trim(),
      gioBatDau:
          '${_gioBatDau!.hour.toString().padLeft(2, '0')}:${_gioBatDau!.minute.toString().padLeft(2, '0')}',
      gioKetThuc:
          '${_gioKetThuc!.hour.toString().padLeft(2, '0')}:${_gioKetThuc!.minute.toString().padLeft(2, '0')}',
      soLuongToiDa: int.parse(_soLuongController.text),
      thoiLuongKham: int.parse(_thoiLuongController.text),
      trangThai: _trangThai,
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Thêm ca khám thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachCaKham();
      } else {
        _showSnackBar(
          result['message'] ?? 'Thêm ca khám thất bại',
          isError: true,
        );
      }
    }
  }

  Future<void> _capNhatCaKham() async {
    if (_editingCaId == null || !_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang cập nhật ca khám...');
    final result = await _adminController.capNhatCaKham(
      maCa: _editingCaId!,
      tenCa: _tenCaController.text.trim(),
      gioBatDau:
          '${_gioBatDau!.hour.toString().padLeft(2, '0')}:${_gioBatDau!.minute.toString().padLeft(2, '0')}',
      gioKetThuc:
          '${_gioKetThuc!.hour.toString().padLeft(2, '0')}:${_gioKetThuc!.minute.toString().padLeft(2, '0')}',
      soLuongToiDa: int.parse(_soLuongController.text),
      thoiLuongKham: int.parse(_thoiLuongController.text),
      trangThai: _trangThai,
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Cập nhật ca khám thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachCaKham();
      } else {
        _showSnackBar(result['message'] ?? 'Cập nhật thất bại', isError: true);
      }
    }
  }

  Future<void> _xoaCaKham(int maCa) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc muốn xóa ca khám này?'),
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

    LoadingUtils.showLoading(message: 'Đang xóa ca khám...');
    final result = await _adminController.xoaCaKham(maCa);
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Xóa ca khám thành công');
      } else {
        _showSnackBar(result['message'] ?? 'Xóa thất bại', isError: true);
      }
      await _taiDanhSachCaKham();
    }
  }

  bool _validateForm() {
    if (_tenCaController.text.isEmpty ||
        _soLuongController.text.isEmpty ||
        _thoiLuongController.text.isEmpty ||
        _gioBatDau == null ||
        _gioKetThuc == null) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin', isError: true);
      return false;
    }
    if (_gioBatDau!.hour * 60 + _gioBatDau!.minute >=
        _gioKetThuc!.hour * 60 + _gioKetThuc!.minute) {
      _showSnackBar('Giờ bắt đầu phải nhỏ hơn giờ kết thúc', isError: true);
      return false;
    }
    return true;
  }

  void _dienFormChinhSua(Map<String, dynamic> ca) {
    setState(() {
      _isEditing = true;
      _editingCaId = ca['MaCa'];
      _tenCaController.text = ca['TenCa'] ?? '';
      _soLuongController.text = ca['SoLuongToiDa']?.toString() ?? '';
      _thoiLuongController.text = ca['ThoiLuongKham']?.toString() ?? '';
      _trangThai = ca['TrangThai'] ?? 'active';

      if (ca['GioBatDau'] != null) {
        final parts = ca['GioBatDau'].toString().split(':');
        if (parts.length >= 2) {
          _gioBatDau = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
      if (ca['GioKetThuc'] != null) {
        final parts = ca['GioKetThuc'].toString().split(':');
        if (parts.length >= 2) {
          _gioKetThuc = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    });
    _showFormDialog();
  }

  void _clearForm() {
    _tenCaController.clear();
    _soLuongController.clear();
    _thoiLuongController.clear();
    _isEditing = false;
    _editingCaId = null;
    _gioBatDau = null;
    _gioKetThuc = null;
    _trangThai = 'active';
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
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
                        _isEditing ? 'Chỉnh sửa ca khám' : 'Thêm ca khám mới',
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
                  _buildFormField('Tên ca *', _tenCaController, Icons.label),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeField(
                          'Giờ bắt đầu *',
                          _gioBatDau,
                          (time) => setState(() => _gioBatDau = time),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeField(
                          'Giờ kết thúc *',
                          _gioKetThuc,
                          (time) => setState(() => _gioKetThuc = time),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          'Số lượng tối đa *',
                          _soLuongController,
                          Icons.people,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          'Thời lượng (phút) *',
                          _thoiLuongController,
                          Icons.schedule,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Trạng thái',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _mauChuDen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'active',
                              groupValue: _trangThai,
                              onChanged: (v) => setState(() => _trangThai = v!),
                              activeColor: _mauXanh,
                            ),
                            const Text('Hoạt động'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'inactive',
                              groupValue: _trangThai,
                              onChanged: (v) => setState(() => _trangThai = v!),
                              activeColor: _mauXanh,
                            ),
                            const Text('Không hoạt động'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : (_isEditing ? _capNhatCaKham : _themCaKham),
                      icon: Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(
                        _isEditing ? 'Cập nhật' : 'Thêm ca khám',
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
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
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
          keyboardType: keyboardType,
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

  Widget _buildTimeField(
    String label,
    TimeOfDay? value,
    Function(TimeOfDay) onChanged,
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
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: _mauXanh.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: _mauXanh, size: 20),
                const SizedBox(width: 12),
                Text(
                  value != null ? value.format(context) : 'Chọn giờ',
                  style: TextStyle(
                    fontSize: 14,
                    color: value != null ? _mauChuDen : Colors.grey[600],
                  ),
                ),
              ],
            ),
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
          'Quản Lý Ca Khám',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading && _danhSachCaKham.isEmpty
          ? const LoadingView(
              message: 'Đang tải danh sách ca khám...',
              isOverlay: false,
            )
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
                          hintText: 'Tìm kiếm ca khám...',
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
                              selected: _filterTrangThai == null,
                              onSelected: (_) {
                                _filterTrangThai = null;
                                _applyFilters();
                                setState(() {});
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: _mauXanh,
                              labelStyle: TextStyle(
                                color: _filterTrangThai == null
                                    ? _mauTrang
                                    : _mauChuDen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Hoạt động'),
                              selected: _filterTrangThai == 'active',
                              onSelected: (_) {
                                _filterTrangThai = 'active';
                                _applyFilters();
                                setState(() {});
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: Colors.green,
                              labelStyle: TextStyle(
                                color: _filterTrangThai == 'active'
                                    ? _mauTrang
                                    : _mauChuDen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Không hoạt động'),
                              selected: _filterTrangThai == 'inactive',
                              onSelected: (_) {
                                _filterTrangThai = 'inactive';
                                _applyFilters();
                                setState(() {});
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: Colors.red,
                              labelStyle: TextStyle(
                                color: _filterTrangThai == 'inactive'
                                    ? _mauTrang
                                    : _mauChuDen,
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
                  child: _danhSachCaKhamFiltered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 64,
                                color: _mauChuXam.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy ca khám',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _mauChuXam,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _taiDanhSachCaKham,
                          color: _mauXanh,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _danhSachCaKhamFiltered.length,
                            itemBuilder: (context, index) {
                              final ca = _danhSachCaKhamFiltered[index];
                              final originalIndex = _danhSachCaKham.indexOf(ca);
                              return _buildCaKhamCard(ca, originalIndex);
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
        label: const Text('Thêm ca khám'),
      ),
    );
  }

  Widget _buildCaKhamCard(Map<String, dynamic> ca, int index) {
    final isActive = ca['TrangThai'] == 'active';
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
                      color: isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: isActive ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ca['TenCa'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _mauChuDen,
                          ),
                        ),
                        Text(
                          isActive ? 'Hoạt động' : 'Không hoạt động',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
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
                        onTap: () => _dienFormChinhSua(ca),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () => _xoaCaKham(ca['MaCa']),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.access_time,
                    'Giờ',
                    '${ca['GioBatDau']} - ${ca['GioKetThuc']}',
                  ),
                  _buildInfoChip(
                    Icons.people,
                    'Số lượng',
                    '${ca['SoLuongToiDa']} người',
                  ),
                  _buildInfoChip(
                    Icons.timer,
                    'Thời lượng',
                    '${ca['ThoiLuongKham']} phút',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _mauXanh.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _mauXanh),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: _mauChuDen,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
