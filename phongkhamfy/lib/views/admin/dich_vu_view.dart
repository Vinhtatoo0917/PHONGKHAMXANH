import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

class DichVuView extends StatefulWidget {
  const DichVuView({super.key});

  @override
  State<DichVuView> createState() => _DichVuViewState();
}

class _DichVuViewState extends State<DichVuView> {
  final _adminController = AdminController();

  // State
  List<Map<String, dynamic>> _danhSachDichVu = [];
  List<Map<String, dynamic>> _danhSachDichVuFiltered = [];
  List<Map<String, dynamic>> _danhSachKhoa = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _filterKhoa;

  // Form controllers
  final _tenDichVuController = TextEditingController();
  final _maDichVuYteController = TextEditingController();
  final _giaController = TextEditingController();

  // Form state
  String? _selectedKhoa;
  bool _isEditing = false;
  int? _editingDichVuId;

  // Colors
  final _mauXanh = const Color(0xFF4CAF50);
  final _mauNen = const Color(0xFFF1F8F5);
  final _mauTrang = Colors.white;
  final _mauChuDen = const Color(0xFF1B5E20);
  final _mauChuXam = const Color(0xFF5A8A70);

  @override
  void initState() {
    super.initState();
    _taiDanhSachKhoa();
    _taiDanhSachDichVu();
  }

  @override
  void dispose() {
    _tenDichVuController.dispose();
    _maDichVuYteController.dispose();
    _giaController.dispose();
    super.dispose();
  }

  Future<void> _taiDanhSachKhoa() async {
    try {
      final danhSach = await _adminController.layDanhSachKhoa();
      if (mounted) {
        setState(() => _danhSachKhoa = danhSach);
      }
    } catch (e) {
      _showSnackBar('Lỗi tải danh sách khoa', isError: true);
    }
  }

  Future<void> _taiDanhSachDichVu() async {
    setState(() => _isLoading = true);
    try {
      final danhSach = await _adminController.layDanhSachDichVu();
      if (mounted) {
        setState(() {
          _danhSachDichVu = danhSach;
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
    _danhSachDichVuFiltered = _danhSachDichVu.where((dv) {
      final tenDichVu = (dv['TenDichVu'] ?? '').toLowerCase();
      final matchSearch = tenDichVu.contains(_searchQuery.toLowerCase());
      final matchFilter =
          _filterKhoa == null || dv['MaKhoa'].toString() == _filterKhoa;
      return matchSearch && matchFilter;
    }).toList();
  }

  Future<void> _themDichVu() async {
    if (!_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang thêm dịch vụ...');
    try {
      final gia = double.parse(_giaController.text.trim());

      final result = await _adminController.themDichVu(
        tenDichVu: _tenDichVuController.text.trim(),
        gia: gia,
        maDichVuYte: _maDichVuYteController.text.trim(),
        maKhoa: _selectedKhoa != null ? int.tryParse(_selectedKhoa!) : null,
      );
      LoadingUtils.hideLoading();

      if (mounted) {
        if (result['success'] == true) {
          _showSnackBar('Thêm dịch vụ thành công');
          Navigator.pop(context);
          _clearForm();
          await _taiDanhSachDichVu();
        } else {
          _showSnackBar(
            result['message'] ?? 'Thêm dịch vụ thất bại',
            isError: true,
          );
        }
      }
    } catch (e) {
      LoadingUtils.hideLoading();
      if (mounted) {
        _showSnackBar('Giá không hợp lệ', isError: true);
      }
    }
  }

  Future<void> _capNhatDichVu() async {
    if (!_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang cập nhật dịch vụ...');
    try {
      final gia = double.parse(_giaController.text.trim());

      final result = await _adminController.capNhatDichVu(
        maDichVu: _editingDichVuId.toString(),
        tenDichVu: _tenDichVuController.text.trim(),
        gia: gia,
        maKhoa: _selectedKhoa,
      );
      LoadingUtils.hideLoading();

      if (mounted) {
        if (result['success'] == true) {
          _showSnackBar('Cập nhật dịch vụ thành công');
          Navigator.pop(context);
          _clearForm();
          await _taiDanhSachDichVu();
        } else {
          _showSnackBar(
            result['message'] ?? 'Cập nhật dịch vụ thất bại',
            isError: true,
          );
        }
      }
    } catch (e) {
      LoadingUtils.hideLoading();
      if (mounted) {
        _showSnackBar('Giá không hợp lệ', isError: true);
      }
    }
  }

  Future<void> _xoaDichVu(int maDichVu) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa dịch vụ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    LoadingUtils.showLoading(message: 'Đang xóa dịch vụ...');
    final result = await _adminController.xoaDichVu(maDichVu.toString());
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Xóa dịch vụ thành công');
        await _taiDanhSachDichVu();
      } else {
        _showSnackBar(
          result['message'] ?? 'Xóa dịch vụ thất bại',
          isError: true,
        );
      }
    }
  }

  bool _validateForm() {
    if (_tenDichVuController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập tên dịch vụ', isError: true);
      return false;
    }
    if (_maDichVuYteController.text.trim().isEmpty && !_isEditing) {
      _showSnackBar('Vui lòng nhập mã dịch vụ Y tế', isError: true);
      return false;
    }
    if (_giaController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập giá', isError: true);
      return false;
    }
    return true;
  }

  void _dienFormChinhSua(Map<String, dynamic> dichVu) {
    _isEditing = true;
    _editingDichVuId = dichVu['MaDichVu'];
    _tenDichVuController.text = dichVu['TenDichVu'] ?? '';
    _maDichVuYteController.text = dichVu['madichvuyte'] ?? '';
    // Xóa .00 nếu giá là số nguyên
    final gia = dichVu['Gia'];
    if (gia is num) {
      _giaController.text = gia.toInt() == gia
          ? gia.toInt().toString()
          : gia.toString();
    } else {
      _giaController.text = gia.toString();
    }
    _selectedKhoa = dichVu['MaKhoa']?.toString();
    _showFormDialog();
  }

  void _clearForm() {
    _tenDichVuController.clear();
    _maDichVuYteController.clear();
    _giaController.clear();
    _selectedKhoa = null;
    _isEditing = false;
    _editingDichVuId = null;
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
                      _isEditing ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ mới',
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
                  'Tên dịch vụ *',
                  _tenDichVuController,
                  Icons.medical_services,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  'Mã dịch vụ Y tế *',
                  _maDichVuYteController,
                  Icons.code,
                  hintText: 'VD: DV-XN-001',
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  'Giá (VNĐ) *',
                  _giaController,
                  Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  'Khoa (Tùy chọn)',
                  _selectedKhoa,
                  _danhSachKhoa,
                  (value) {
                    setState(() => _selectedKhoa = value);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isEditing ? _capNhatDichVu : _themDichVu),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mauXanh,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Cập nhật' : 'Thêm',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      if (!_isEditing) _clearForm();
    });
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: _mauXanh),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mauXanh.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mauXanh.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mauXanh, width: 2),
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
    List<Map<String, dynamic>> items,
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
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mauXanh.withValues(alpha: 0.3)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: [
            DropdownMenuItem(value: null, child: const Text('Không chọn')),
            ...items.map(
              (khoa) => DropdownMenuItem(
                value: khoa['MaKhoa'].toString(),
                child: Text(khoa['TenKhoa'] ?? ''),
              ),
            ),
          ],
          onChanged: onChanged,
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
          'Quản Lý Dịch Vụ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading && _danhSachDichVu.isEmpty
          ? const LoadingView(
              message: 'Đang tải danh sách dịch vụ...',
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
                          hintText: 'Tìm kiếm dịch vụ...',
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
                              selected: _filterKhoa == null,
                              onSelected: (_) {
                                _filterKhoa = null;
                                _applyFilters();
                                setState(() {});
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: _mauXanh,
                              labelStyle: TextStyle(
                                color: _filterKhoa == null
                                    ? _mauTrang
                                    : _mauChuDen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ..._danhSachKhoa.map(
                              (khoa) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(khoa['TenKhoa'] ?? ''),
                                  selected:
                                      _filterKhoa == khoa['MaKhoa'].toString(),
                                  onSelected: (_) {
                                    _filterKhoa = khoa['MaKhoa'].toString();
                                    _applyFilters();
                                    setState(() {});
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: _mauXanh,
                                  labelStyle: TextStyle(
                                    color:
                                        _filterKhoa == khoa['MaKhoa'].toString()
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
                  child: _danhSachDichVuFiltered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medical_services,
                                size: 64,
                                color: _mauChuXam.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy dịch vụ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _mauChuXam,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _taiDanhSachDichVu,
                          color: _mauXanh,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _danhSachDichVuFiltered.length,
                            itemBuilder: (context, index) {
                              final dichVu = _danhSachDichVuFiltered[index];
                              return _buildDichVuCard(dichVu, index);
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
        label: const Text('Thêm dịch vụ'),
      ),
    );
  }

  Widget _buildDichVuCard(Map<String, dynamic> dichVu, int index) {
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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _mauXanh.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.medical_services,
                      color: _mauXanh,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dichVu['TenDichVu'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _mauChuDen,
                          ),
                        ),
                        Text(
                          'Mã: ${dichVu['madichvuyte'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
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
                        onTap: () => _dienFormChinhSua(dichVu),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () => _xoaDichVu(dichVu['MaDichVu']),
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
                    Icons.attach_money,
                    'Giá',
                    _formatPrice(dichVu['Gia'] ?? 0),
                  ),
                  if (dichVu['TenKhoa'] != null)
                    _buildInfoChip(
                      Icons.domain,
                      'Khoa',
                      dichVu['TenKhoa'] ?? 'N/A',
                    ),
                  _buildInfoChip(
                    Icons.code,
                    'Mã Y tế',
                    dichVu['madichvuyte'] ?? 'N/A',
                  ),
                  _buildInfoChip(Icons.info, 'Trạng thái', 'Hoạt động'),
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

  String _formatPrice(dynamic price) {
    try {
      final priceNum = price is String ? double.parse(price) : price.toDouble();
      if (priceNum >= 1000000) {
        return '${(priceNum / 1000000).toStringAsFixed(1)}M VNĐ';
      } else if (priceNum >= 1000) {
        return '${(priceNum / 1000).toStringAsFixed(0)}K VNĐ';
      }
      // Xóa .00 nếu là số nguyên
      if (priceNum.toInt() == priceNum) {
        return '${priceNum.toInt()} VNĐ';
      }
      return '${priceNum.toStringAsFixed(0)} VNĐ';
    } catch (e) {
      return 'N/A';
    }
  }
}
