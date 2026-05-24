import 'package:flutter/material.dart';
import 'package:phongkhamfy/theme/app_theme.dart' show iosAppBar;
import '../../controllers/admin_controller.dart';
import '../../utils/constants.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

class BenhView extends StatefulWidget {
  const BenhView({super.key});

  @override
  State<BenhView> createState() => _BenhViewState();
}

class _BenhViewState extends State<BenhView> {
  final _adminController = AdminController();

  // State
  List<Map<String, dynamic>> _danhSachBenh = [];
  List<Map<String, dynamic>> _danhSachBenhFiltered = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Form controllers
  final _tenBenhController = TextEditingController();
  final _maBenhLyController = TextEditingController();
  final _moTaController = TextEditingController();

  // Form state
  bool _isEditing = false;
  int? _editingBenhId;

  @override
  void initState() {
    super.initState();
    _taiDanhSachBenh();
  }

  @override
  void dispose() {
    _tenBenhController.dispose();
    _maBenhLyController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _taiDanhSachBenh() async {
    setState(() => _isLoading = true);
    try {
      final danhSach = await _adminController.layDanhSachBenh();
      if (mounted) {
        setState(() {
          _danhSachBenh = danhSach;
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
    _danhSachBenhFiltered = _danhSachBenh.where((benh) {
      final tenBenh = (benh['TenBenh'] ?? '').toLowerCase();
      final matchSearch = tenBenh.contains(_searchQuery.toLowerCase());
      // Debug: In ra tất cả keys
      if (_danhSachBenhFiltered.isEmpty) {
        print('🔍 [BENH] Keys trong dữ liệu: ${benh.keys.toList()}');
        print('🔍 [BENH] Dữ liệu bệnh: $benh');
      }
      return matchSearch;
    }).toList();
  }

  Future<void> _themBenh() async {
    if (!_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang thêm bệnh...');
    final result = await _adminController.themBenh(
      tenBenh: _tenBenhController.text.trim(),
      maBenhLy: _maBenhLyController.text.trim(),
      moTa: _moTaController.text.trim(),
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Thêm bệnh thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachBenh();
      } else {
        _showSnackBar(result['message'] ?? 'Thêm bệnh thất bại', isError: true);
      }
    }
  }

  Future<void> _capNhatBenh() async {
    if (!_validateForm()) return;

    LoadingUtils.showLoading(message: 'Đang cập nhật bệnh...');
    final result = await _adminController.capNhatBenh(
      maBenh: _editingBenhId.toString(),
      tenBenh: _tenBenhController.text.trim(),
      moTa: _moTaController.text.trim(),
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Cập nhật bệnh thành công');
        Navigator.pop(context);
        _clearForm();
        await _taiDanhSachBenh();
      } else {
        _showSnackBar(
          result['message'] ?? 'Cập nhật bệnh thất bại',
          isError: true,
        );
      }
    }
  }

  Future<void> _xoaBenh(int maBenh) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa bệnh này?'),
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

    LoadingUtils.showLoading(message: 'Đang xóa bệnh...');
    final result = await _adminController.xoaBenh(maBenh.toString());
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar('Xóa bệnh thành công');
        await _taiDanhSachBenh();
      } else {
        _showSnackBar(result['message'] ?? 'Xóa bệnh thất bại', isError: true);
      }
    }
  }

  bool _validateForm() {
    if (_tenBenhController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập tên bệnh', isError: true);
      return false;
    }
    if (_maBenhLyController.text.trim().isEmpty && !_isEditing) {
      _showSnackBar('Vui lòng nhập mã bệnh Y tế', isError: true);
      return false;
    }
    return true;
  }

  void _dienFormChinhSua(Map<String, dynamic> benh) {
    _isEditing = true;
    _editingBenhId = benh['MaBenh'];
    _tenBenhController.text = benh['TenBenh'] ?? '';
    _maBenhLyController.text = benh['mabenhly'] ?? '';
    _moTaController.text = benh['MoTa'] ?? '';
    _showFormDialog();
  }

  void _clearForm() {
    _tenBenhController.clear();
    _maBenhLyController.clear();
    _moTaController.clear();
    _isEditing = false;
    _editingBenhId = null;
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
                      _isEditing ? 'Chỉnh sửa bệnh' : 'Thêm bệnh mới',
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
                _buildFormField(
                  'Tên bệnh *',
                  _tenBenhController,
                  Icons.health_and_safety,
                ),
                const SizedBox(height: AppSizes.paddingMD),
                _buildFormField(
                  'Mã bệnh Y tế *',
                  _maBenhLyController,
                  Icons.code,
                  hintText: 'VD: ICD-10 A00',
                ),
                const SizedBox(height: AppSizes.paddingMD),
                _buildFormField(
                  'Mô tả',
                  _moTaController,
                  Icons.description,
                  maxLines: 3,
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
                            : (_isEditing ? _capNhatBenh : _themBenh),
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
      appBar: iosAppBar(title: 'Quản Lý Bệnh'),
      body: _isLoading && _danhSachBenh.isEmpty
          ? const LoadingView(
              message: 'Đang tải danh sách bệnh...',
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
                      hintText: 'Tìm kiếm bệnh...',
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
                  child: _danhSachBenhFiltered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.health_and_safety,
                                size: 64,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Không tìm thấy bệnh',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _taiDanhSachBenh,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMD,
                              vertical: 8,
                            ),
                            itemCount: _danhSachBenhFiltered.length,
                            itemBuilder: (context, index) {
                              final benh = _danhSachBenhFiltered[index];
                              return _buildBenhCard(benh, index);
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
        backgroundColor: AppColors.info,
        icon: const Icon(Icons.add),
        label: const Text('Thêm bệnh'),
      ),
    );
  }

  Widget _buildBenhCard(Map<String, dynamic> benh, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          color: AppColors.surface,
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Icon(
                      Icons.health_and_safety,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          benh['TenBenh'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã: ${benh.keys.contains('mabenhly') ? benh['mabenhly'] : (benh.keys.contains('MaBenhLy') ? benh['MaBenhLy'] : 'Không tìm thấy field')}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
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
                            Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                        onTap: () => _dienFormChinhSua(benh),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Xóa',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                        onTap: () => _xoaBenh(benh['MaBenh']),
                      ),
                    ],
                  ),
                ],
              ),
              if (benh['MoTa'] != null && benh['MoTa'].toString().isNotEmpty)
                Column(
                  children: [
                    const Divider(height: 16),
                    Text(
                      benh['MoTa'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              const Divider(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.code,
                    'Mã Y tế',
                    benh['mabenhly'] ?? 'N/A',
                  ),
                  _buildInfoChip(Icons.check_circle, 'Trạng thái', 'Hoạt động'),
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
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
