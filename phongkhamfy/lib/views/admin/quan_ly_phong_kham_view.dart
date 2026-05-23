import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

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

    LoadingUtils.showLoading(message: 'Đang thêm phòng khám...');
    final result = await _adminController.themPhongKham(
      tenPhong: _tenPhongController.text.trim(),
      khu: _khuChon!,
    );
    LoadingUtils.hideLoading();

    if (mounted) {
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

    LoadingUtils.showLoading(message: 'Đang cập nhật phòng khám...');
    final result = await _adminController.capNhatPhongKham(
      maPhong: _editingPhongId!,
      tenPhong: _tenPhongController.text.trim(),
      khu: _khuChon!,
    );
    LoadingUtils.hideLoading();

    if (mounted) {
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

  Future<void> _xoaPhongKham(int maPhong) async {
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

    LoadingUtils.showLoading(message: 'Đang xóa phòng khám...');
    final result = await _adminController.xoaPhongKham(maPhong);
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Xóa phòng khám thành công');
      } else {
        _showSnackBar(result['message'] ?? 'Xóa thất bại', isError: true);
      }
      await _loadData();
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

  void _showAddKhuDialog() {
    final tenKhuController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    'Thêm khu mới',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _mauChuDen,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: tenKhuController,
                style: TextStyle(fontSize: 15, color: _mauChuDen),
                decoration: InputDecoration(
                  labelText: 'Tên khu (VD: Tầng 1, Khu A...)',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.domain, color: _mauXanh),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _mauXanh.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _mauXanh, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: _mauChuDen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final tenKhu = tenKhuController.text.trim();
                        if (tenKhu.isEmpty) {
                          _showSnackBar('Vui lòng nhập tên khu', isError: true);
                          return;
                        }

                        LoadingUtils.showLoading(message: 'Đang thêm khu...');
                        final result =
                            await _adminController.themKhuMoi(tenKhu);
                        LoadingUtils.hideLoading();

                        if (mounted) {
                          if (result['success'] == true) {
                            _showSnackBar('Thêm khu thành công');
                            await _loadData();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            _showSnackBar(
                              result['message'] ?? 'Thêm khu thất bại',
                              isError: true,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mauXanh,
                        foregroundColor: _mauTrang,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Thêm khu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) => tenKhuController.dispose());
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 12,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_mauTrang, _mauNen],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _mauXanh.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isEditing ? '✏️ Chỉnh sửa' : '➕ Thêm mới',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _mauXanh,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isEditing
                                  ? 'Cập nhật thông tin phòng khám'
                                  : 'Tạo phòng khám mới',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _mauChuDen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: _mauChuXam,
                          size: 28,
                        ),
                        splashRadius: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _mauXanh.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _mauXanh.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildFormField(
                          'Tên phòng *',
                          _tenPhongController,
                          Icons.location_on,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          'Khu *',
                          _khuChon,
                          _danhSachKhu,
                          (v) => setState(() => _khuChon = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : (_isEditing ? _capNhatPhongKham : _themPhongKham),
                      icon: Icon(
                        _isEditing ? Icons.save_rounded : Icons.add_rounded,
                        size: 20,
                      ),
                      label: Text(
                        _isEditing ? 'Cập nhật phòng' : 'Thêm phòng khám',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mauXanh,
                        foregroundColor: _mauTrang,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
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
            fontWeight: FontWeight.w700,
            color: _mauChuDen,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 15,
            color: _mauChuDen,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, color: _mauXanh, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _mauXanh.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _mauXanh.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _mauXanh,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: _mauTrang,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintText: 'Nhập tên phòng...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w400,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _mauChuDen,
              ),
            ),
            GestureDetector(
              onTap: _showAddKhuDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _mauXanh.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: _mauXanh),
                    const SizedBox(width: 4),
                    Text(
                      'Thêm khu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _mauXanh,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: value != null
                  ? _mauXanh
                  : _mauXanh.withValues(alpha: 0.3),
              width: value != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _mauTrang,
            boxShadow: value != null
                ? [
                    BoxShadow(
                      color: _mauXanh.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                    )
                  ]
                : [],
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _mauXanh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            hint: Row(
              children: [
                Icon(Icons.domain_disabled, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text('Chọn khu', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
            menuMaxHeight: 300,
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
          ? const LoadingView(
              message: 'Đang tải danh sách phòng khám...',
              isOverlay: false,
            )
          : Column(
              children: [
                // Search & Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _mauXanh.withValues(alpha: 0.1),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            _searchQuery = value;
                            _applyFilters();
                            setState(() {});
                          },
                          style: TextStyle(
                            fontSize: 15,
                            color: _mauChuDen,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm phòng khám...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 14, right: 10),
                              child: Icon(
                                Icons.search_rounded,
                                color: _mauXanh,
                                size: 22,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minHeight: 24,
                              minWidth: 24,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        _searchQuery = '';
                                        _applyFilters();
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                    ),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: _mauXanh.withValues(alpha: 0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: _mauXanh.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: _mauXanh,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: _mauTrang,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text(
                                'Tất cả',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
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
                                    : Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide(
                                color: _filterKhu == null
                                    ? _mauXanh
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              avatar: _filterKhu == null
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: _mauTrang,
                                    )
                                  : null,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  selected: _filterKhu == khu,
                                  onSelected: (_) {
                                    _filterKhu = khu;
                                    _applyFilters();
                                    setState(() {});
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: _mauXanh.withValues(alpha: 0.85),
                                  labelStyle: TextStyle(
                                    color: _filterKhu == khu
                                        ? _mauTrang
                                        : Colors.grey[700],
                                  ),
                                  side: BorderSide(
                                    color: _filterKhu == khu
                                        ? _mauXanh
                                        : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                  avatar: _filterKhu == khu
                                      ? Icon(
                                          Icons.done_rounded,
                                          size: 16,
                                          color: _mauTrang,
                                        )
                                      : null,
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
    final khu = phong['Khu'] ?? 'N/A';
    final tenPhong = phong['TenPhong'] ?? 'N/A';
    final maPhong = phong['MaPhong'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_mauTrang, _mauNen],
          ),
          border: Border(
            left: BorderSide(
              color: _mauXanh,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _mauXanh.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: _mauXanh,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenPhong,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _mauChuDen,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _mauXanh.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.domain,
                                size: 12,
                                color: _mauXanh,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                khu,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _mauXanh,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: _mauChuXam,
                    ),
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
                        onTap: () => _xoaPhongKham(phong['MaPhong']),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _mauXanh.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _mauXanh.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tag,
                      size: 14,
                      color: _mauChuXam,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mã: $maPhong',
                      style: TextStyle(
                        fontSize: 12,
                        color: _mauChuXam,
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
