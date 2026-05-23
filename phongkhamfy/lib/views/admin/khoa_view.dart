import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/constants.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

class KhoaView extends StatefulWidget {
  const KhoaView({super.key});

  @override
  State<KhoaView> createState() => _KhoaViewState();
}

class _KhoaViewState extends State<KhoaView> {
  final _adminController = AdminController();

  // State
  List<Map<String, dynamic>> _danhSachKhoa = [];
  List<Map<String, dynamic>> _danhSachKhoaFiltered = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Form controllers
  final _tenKhoaController = TextEditingController();
  final _maChuyenKhoaController = TextEditingController();

  // Form state
  bool _isEditing = false;
  int? _editingKhoaId;

  @override
  void initState() {
    super.initState();
    _taiDanhSachKhoa();
  }

  @override
  void dispose() {
    _tenKhoaController.dispose();
    _maChuyenKhoaController.dispose();
    super.dispose();
  }

  Future<void> _taiDanhSachKhoa() async {
    setState(() => _isLoading = true);
    try {
      final danhSach = await _adminController.layDanhSachKhoa();
      if (mounted) {
        setState(() {
          _danhSachKhoa = danhSach;
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
    _danhSachKhoaFiltered = _danhSachKhoa.where((khoa) {
      final tenKhoa = (khoa['TenKhoa'] ?? '').toLowerCase();
      final matchSearch = tenKhoa.contains(_searchQuery.toLowerCase());
      // Debug: In ra dữ liệu
      print('🔍 [KHOA] Dữ liệu khoa: $khoa');
      return matchSearch;
    }).toList();
  }

  Future<void> _themKhoa() async {
    if (!_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang thêm khoa...');
    final result = await _adminController.themKhoa(
      tenKhoa: _tenKhoaController.text.trim(),
      maChuyenKhoa: _maChuyenKhoaController.text.trim(),
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Thêm khoa thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachKhoa();
      } else {
        _showSnackBar(result['message'] ?? 'Thêm khoa thất bại', isError: true);
      }
    }
  }

  Future<void> _capNhatKhoa() async {
    if (!_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang cập nhật khoa...');
    final result = await _adminController.capNhatKhoa(
      maKhoa: _editingKhoaId.toString(),
      tenKhoa: _tenKhoaController.text.trim(),
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Cập nhật khoa thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachKhoa();
      } else {
        _showSnackBar(
          result['message'] ?? 'Cập nhật khoa thất bại',
          isError: true,
        );
      }
    }
  }

  Future<void> _xoaKhoa(int maKhoa) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa khoa này?'),
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

    LoadingUtils.showLoading(message: 'Đang xóa khoa...');
    final result = await _adminController.xoaKhoa(maKhoa.toString());
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Xóa khoa thành công');
        await _taiDanhSachKhoa();
      } else {
        _showSnackBar(result['message'] ?? 'Xóa khoa thất bại', isError: true);
      }
    }
  }

  bool _validateForm() {
    if (_tenKhoaController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập tên khoa', isError: true);
      return false;
    }
    if (_maChuyenKhoaController.text.trim().isEmpty && !_isEditing) {
      _showSnackBar('Vui lòng nhập mã chuyên khoa', isError: true);
      return false;
    }
    return true;
  }

  void _dienFormChinhSua(Map<String, dynamic> khoa) {
    _isEditing = true;
    _editingKhoaId = khoa['MaKhoa'];
    _tenKhoaController.text = khoa['TenKhoa'] ?? '';
    _maChuyenKhoaController.text = khoa['machuyenkhoa'] ?? '';
    _showFormDialog();
  }

  void _clearForm() {
    _tenKhoaController.clear();
    _maChuyenKhoaController.clear();
    _isEditing = false;
    _editingKhoaId = null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFormDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Chỉnh sửa khoa' : 'Thêm khoa mới',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
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
                const SizedBox(height: AppSizes.paddingLG),
                _buildFormField('Tên khoa *', _tenKhoaController, Icons.domain),
                const SizedBox(height: AppSizes.paddingMD),
                _buildFormField(
                  'Mã chuyên khoa *',
                  _maChuyenKhoaController,
                  Icons.code,
                  hintText: 'VD: CK001',
                ),
                const SizedBox(height: AppSizes.paddingLG),
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
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMD,
                            ),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMD),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isEditing ? _capNhatKhoa : _themKhoa),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMD,
                            ),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Cập nhật' : 'Thêm',
                          style: const TextStyle(
                            color: AppColors.textWhite,
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản Lý Khoa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading && _danhSachKhoa.isEmpty
          ? const LoadingView(
              message: 'Đang tải danh sách khoa...',
              isOverlay: false,
            )
          : Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm khoa...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // List
                Expanded(
                  child: _danhSachKhoaFiltered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.domain,
                                size: 64,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Không tìm thấy khoa',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _taiDanhSachKhoa,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMD,
                              vertical: 8,
                            ),
                            itemCount: _danhSachKhoaFiltered.length,
                            itemBuilder: (context, index) {
                              final khoa = _danhSachKhoaFiltered[index];
                              return _buildKhoaCard(khoa, index);
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
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Thêm khoa'),
      ),
    );
  }

  Widget _buildKhoaCard(Map<String, dynamic> khoa, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => _dienFormChinhSua(khoa),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.primary.withOpacity(0.02)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.domain,
                        color: AppColors.textWhite,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            khoa['TenKhoa'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  khoa.keys.contains('machuyenkhoa')
                                      ? khoa['machuyenkhoa']
                                      : (khoa.keys.contains('MaChuyenKhoa')
                                            ? khoa['MaChuyenKhoa']
                                            : 'N/A'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _dienFormChinhSua(khoa),
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Xóa',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _xoaKhoa(khoa['MaKhoa']),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hoạt động',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
