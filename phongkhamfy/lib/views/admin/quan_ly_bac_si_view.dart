// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/theme/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

class QuanLyBacSiView extends StatefulWidget {
  final bool isInTab;
  const QuanLyBacSiView({super.key, this.isInTab = false});

  @override
  State<QuanLyBacSiView> createState() => _QuanLyBacSiViewState();
}

class _QuanLyBacSiViewState extends State<QuanLyBacSiView> {
  final _adminController = AdminController();

  // State
  List<Map<String, dynamic>> _danhSachBacSi = [];
  List<Map<String, dynamic>> _danhSachBacSiFiltered = [];
  List<Map<String, dynamic>> _danhSachKhoa = [];
  String _searchQuery = '';
  String? _filterChuyenKhoa;
  bool _isLoading = true;

  // Form controllers
  final _hoController = TextEditingController();
  final _tenController = TextEditingController();
  final _emailController = TextEditingController();
  final _sdtController = TextEditingController();
  final _matKhauController = TextEditingController();

  // Form state
  String _gioiTinh = 'Nam';
  String? _chuyenKhoa;
  String? _bangCap;
  String? _kinhNghiem;
  DateTime? _ngaySinh;
  bool _isEditing = false;
  int? _editingBacSiId;

  List<String> get _danhSachChuyenKhoa => _danhSachKhoa
      .map((khoa) => khoa['TenKhoa']?.toString() ?? '')
      .where((tenKhoa) => tenKhoa.isNotEmpty)
      .toList();

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


  @override
  void initState() {
    super.initState();
    _taiDanhSachBacSi();
  }

  @override
  void dispose() {
    _hoController.dispose();
    _tenController.dispose();
    _emailController.dispose();
    _sdtController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  Future<void> _taiDanhSachBacSi() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _adminController.layDanhSachBacSi().catchError((e) {
          debugPrint('❌ [QUAN_LY_BAC_SI] Lỗi tải danh sách bác sĩ: $e');
          return <Map<String, dynamic>>[];
        }),
        _adminController.layDanhSachKhoa().catchError((e) {
          debugPrint('❌ [QUAN_LY_BAC_SI] Lỗi tải danh sách khoa: $e');
          return <Map<String, dynamic>>[];
        }),
      ]);

      if (!mounted) return;

      final danhSachBacSi = List<Map<String, dynamic>>.from(results[0] as List);
      final danhSachKhoa = List<Map<String, dynamic>>.from(results[1] as List);

      setState(() {
        _danhSachBacSi = danhSachBacSi;
        _danhSachKhoa = danhSachKhoa;
        _applyFilters();
      });

      if (_danhSachBacSi.isEmpty && _danhSachKhoa.isEmpty) {
        _showSnackBar(
          'Không tải được dữ liệu bác sĩ hoặc khoa',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Lỗi tải dữ liệu: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    _danhSachBacSiFiltered = _danhSachBacSi.where((bacsi) {
      final tenDayDu = '${bacsi['ho']} ${bacsi['ten']}'.toLowerCase();
      final matchSearch = tenDayDu.contains(_searchQuery.toLowerCase());
      final matchFilter =
          _filterChuyenKhoa == null || bacsi['ChuyenKhoa'] == _filterChuyenKhoa;
      return matchSearch && matchFilter;
    }).toList();
  }

  Future<void> _themBacSi() async {
    if (!_validateForm()) return;

    final ngaySinhStr =
        '${_ngaySinh!.year}-${_ngaySinh!.month.toString().padLeft(2, '0')}-${_ngaySinh!.day.toString().padLeft(2, '0')}';

    LoadingUtils.showLoading(message: 'Đang thêm bác sĩ...');
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
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Thêm bác sĩ thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachBacSi();
      } else {
        _showSnackBar(
          result['message'] ?? 'Thêm bác sĩ thất bại',
          isError: true,
        );
      }
    }
  }

  Future<void> _capNhatBacSi() async {
    if (_editingBacSiId == null || !_validateForm()) return;

    final ngaySinhStr =
        '${_ngaySinh!.year}-${_ngaySinh!.month.toString().padLeft(2, '0')}-${_ngaySinh!.day.toString().padLeft(2, '0')}';

    LoadingUtils.showLoading(message: 'Đang cập nhật bác sĩ...');
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
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Cập nhật bác sĩ thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachBacSi();
      } else {
        _showSnackBar(result['message'] ?? 'Cập nhật thất bại', isError: true);
      }
    }
  }

  Future<void> _xoaBacSi(int maBacSi) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc muốn xóa bác sĩ này?'),
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

    LoadingUtils.showLoading(message: 'Đang xóa bác sĩ...');
    final result = await _adminController.xoaBacSi(maBacSi);
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Xóa bác sĩ thành công');
        await _taiDanhSachBacSi();
      } else {
        _showSnackBar(result['message'] ?? 'Xóa thất bại', isError: true);
      }
    }
  }

  bool _validateForm() {
    if (_hoController.text.isEmpty ||
        _tenController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _sdtController.text.isEmpty ||
        (!_isEditing && _matKhauController.text.isEmpty) ||
        _ngaySinh == null ||
        _chuyenKhoa == null ||
        _bangCap == null) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin bắt buộc', isError: true);
      return false;
    }
    if (!_emailController.text.contains('@')) {
      _showSnackBar('Email không hợp lệ', isError: true);
      return false;
    }
    final sdtClean = _sdtController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (sdtClean.length < 9 || sdtClean.length > 11) {
      _showSnackBar('Số điện thoại phải có 9-11 chữ số', isError: true);
      return false;
    }
    if (_matKhauController.text.isNotEmpty &&
        _matKhauController.text.length < 6) {
      _showSnackBar('Mật khẩu phải có ít nhất 6 ký tự', isError: true);
      return false;
    }
    return true;
  }

  void _dienFormChinhSua(Map<String, dynamic> bacsi) {
    _isEditing = true;
    _editingBacSiId = bacsi['MaBacSi'];
    _hoController.text = bacsi['ho'] ?? '';
    _tenController.text = bacsi['ten'] ?? '';
    _emailController.text = bacsi['email'] ?? '';
    _sdtController.text = bacsi['sdt']?.toString() ?? '';
    _matKhauController.clear();
    _gioiTinh = bacsi['gioitinh'] ?? 'Nam';
    _chuyenKhoa =
        (bacsi['ChuyenKhoa'] != null &&
            _danhSachChuyenKhoa.contains(bacsi['ChuyenKhoa']))
        ? bacsi['ChuyenKhoa']
        : null;
    _bangCap =
        (bacsi['BangCap'] != null &&
            _danhSachBangCap.contains(bacsi['BangCap']))
        ? bacsi['BangCap']
        : null;
    _kinhNghiem =
        (bacsi['KinhNghiem'] != null &&
            _danhSachKinhNghiem.contains(bacsi['KinhNghiem']))
        ? bacsi['KinhNghiem']
        : null;
    if (bacsi['ngaysinh'] != null && bacsi['ngaysinh'].toString().isNotEmpty) {
      try {
        final parts = bacsi['ngaysinh'].toString().split('-');
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
    _showFormDialog();
  }

  void _clearForm() {
    _hoController.clear();
    _tenController.clear();
    _emailController.clear();
    _sdtController.clear();
    _matKhauController.clear();
    _isEditing = false;
    _editingBacSiId = null;
    _gioiTinh = 'Nam';
    _chuyenKhoa = null;
    _bangCap = null;
    _kinhNghiem = null;
    _ngaySinh = null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
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
                      _isEditing ? 'Chỉnh sửa bác sĩ' : 'Thêm bác sĩ mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.label,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFormField('Họ *', _hoController, Icons.person),
                const SizedBox(height: 12),
                _buildFormField('Tên *', _tenController, Icons.person),
                const SizedBox(height: 12),
                _buildFormField(
                  'Email *',
                  _emailController,
                  Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  'Số điện thoại *',
                  _sdtController,
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  _isEditing
                      ? 'Mật khẩu (để trống nếu không đổi)'
                      : 'Mật khẩu *',
                  _matKhauController,
                  Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Text(
                  'Giới tính *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'Nam',
                            groupValue: _gioiTinh,
                            onChanged: (v) => setState(() => _gioiTinh = v!),
                            activeColor: AppColors.primary,
                          ),
                          const Text('Nam'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'Nữ',
                            groupValue: _gioiTinh,
                            onChanged: (v) => setState(() => _gioiTinh = v!),
                            activeColor: AppColors.primary,
                          ),
                          const Text('Nữ'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDateField('Ngày sinh *', _ngaySinh),
                const SizedBox(height: 12),
                _buildDropdownField(
                  'Chuyên khoa *',
                  _chuyenKhoa,
                  _danhSachChuyenKhoa,
                  (v) => setState(() => _chuyenKhoa = v),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  'Bằng cấp *',
                  _bangCap,
                  _danhSachBangCap,
                  (v) => setState(() => _bangCap = v),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  'Kinh nghiệm',
                  _kinhNghiem,
                  _danhSachKinhNghiem,
                  (v) => setState(() => _kinhNghiem = v),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: (_isEditing ? _capNhatBacSi : _themBacSi),
                    icon: Icon(_isEditing ? Icons.save : Icons.add),
                    label: Text(
                      _isEditing ? 'Cập nhật' : 'Thêm bác sĩ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
    IconData icon, {
    bool obscureText = false,
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
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
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

  Widget _buildDateField(String label, DateTime? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _ngaySinh ?? DateTime(1990, 1, 1),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _ngaySinh = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  value != null
                      ? DateFormat('dd/MM/yyyy').format(value)
                      : 'Chọn ngày sinh',
                  style: TextStyle(
                    fontSize: 14,
                    color: value != null ? AppColors.label : Colors.grey[600],
                  ),
                ),
              ],
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
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          menuMaxHeight: 300,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fab = FloatingActionButton.extended(
      onPressed: () { _clearForm(); _showFormDialog(); },
      backgroundColor: AppColors.info,
      icon: const Icon(Icons.add),
      label: const Text('Thêm bác sĩ'),
    );

    final content = Column(
      children: [
        _buildSearchFilter(),
        Expanded(child: _buildList()),
      ],
    );

    if (widget.isInTab) {
      return Stack(
        children: [content, Positioned(bottom: 16, right: 16, child: fab)],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(title: 'Quản Lý Bác Sĩ'),
      body: content,
      floatingActionButton: fab,
    );
  }

  Widget _buildSearchFilter() {
    return Padding(
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
              hintText: 'Tìm kiếm bác sĩ...',
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tất cả'),
                  selected: _filterChuyenKhoa == null,
                  onSelected: (_) {
                    _filterChuyenKhoa = null;
                    _applyFilters();
                    setState(() {});
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _filterChuyenKhoa == null ? Colors.white : AppColors.label,
                  ),
                ),
                const SizedBox(width: 8),
                ..._danhSachChuyenKhoa.map(
                  (khoa) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(khoa),
                      selected: _filterChuyenKhoa == khoa,
                      onSelected: (_) {
                        _filterChuyenKhoa = khoa;
                        _applyFilters();
                        setState(() {});
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _filterChuyenKhoa == khoa ? Colors.white : AppColors.label,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const LoadingView(message: 'Đang tải danh sách bác sĩ...', isOverlay: false);
    }
    if (_danhSachBacSiFiltered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: AppColors.subLabel.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Không tìm thấy bác sĩ', style: TextStyle(fontSize: 16, color: AppColors.subLabel)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _taiDanhSachBacSi,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: _danhSachBacSiFiltered.length,
        itemBuilder: (context, index) => _buildBacSiCard(_danhSachBacSiFiltered[index]),
      ),
    );
  }

  Widget _buildBacSiCard(Map<String, dynamic> bacsi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      bacsi['gioitinh'] == 'Nam' ? Icons.male : Icons.female,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BS. ${bacsi['ho']} ${bacsi['ten']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.label,
                          ),
                        ),
                        Text(
                          bacsi['ChuyenKhoa'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.subLabel,
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
                        onTap: () => _dienFormChinhSua(bacsi),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () => _xoaBacSi(bacsi['MaBacSi']),
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
                    Icons.cake,
                    'Ngày sinh',
                    bacsi['ngaysinh'] ?? 'N/A',
                  ),
                  _buildInfoChip(
                    Icons.school,
                    'Bằng cấp',
                    bacsi['BangCap'] ?? 'N/A',
                  ),
                  _buildInfoChip(
                    Icons.work,
                    'Kinh nghiệm',
                    bacsi['KinhNghiem'] ?? 'N/A',
                  ),
                  _buildInfoChip(Icons.email, 'Email', bacsi['email'] ?? 'N/A'),
                  _buildInfoChip(
                    Icons.phone,
                    'SĐT',
                    bacsi['sdt']?.toString() ?? 'N/A',
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
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.label,
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