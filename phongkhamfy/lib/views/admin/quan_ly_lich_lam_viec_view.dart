import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

class QuanLyLichLamViecView extends StatefulWidget {
  const QuanLyLichLamViecView({super.key});

  @override
  State<QuanLyLichLamViecView> createState() => _QuanLyLichLamViecViewState();
}

class _QuanLyLichLamViecViewState extends State<QuanLyLichLamViecView> {
  final _adminController = AdminController();

  // State
  List<Map<String, dynamic>> _danhSachLichLamViec = [];
  List<Map<String, dynamic>> _danhSachLichLamViecFiltered = [];
  List<Map<String, dynamic>> _danhSachBacSi = [];
  List<Map<String, dynamic>> _danhSachCaKham = [];
  List<Map<String, dynamic>> _danhSachPhongKham = [];

  String _searchQuery = '';
  DateTime _filterNgay = DateTime.now();

  // Loading state cho lần load đầu tiên (khi mở view)
  bool _isLoading = true;

  // Form state
  DateTime _ngayChon = DateTime.now();
  int? _bacSiDuocChon;
  int? _caDuocChon;
  int? _phongDuocChon;
  bool _isEditing = false;
  int? _editingLichId;

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

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait<dynamic>([
        _adminController.layDanhSachLichLamViec().catchError((e) {
          debugPrint('❌ [QL_LICH_LAM_VIEC] Lỗi tải lịch làm việc: $e');
          return <Map<String, dynamic>>[];
        }),
        _adminController.layDanhSachBacSi().catchError((e) {
          debugPrint('❌ [QL_LICH_LAM_VIEC] Lỗi tải bác sĩ: $e');
          return <Map<String, dynamic>>[];
        }),
        _adminController.layDanhSachCaKham().catchError((e) {
          debugPrint('❌ [QL_LICH_LAM_VIEC] Lỗi tải ca khám: $e');
          return <Map<String, dynamic>>[];
        }),
        _adminController.layDanhSachPhongKham().catchError((e) {
          debugPrint('❌ [QL_LICH_LAM_VIEC] Lỗi tải phòng khám: $e');
          return <Map<String, dynamic>>[];
        }),
      ]);

      if (!mounted) return;

      final danhSachLichLamViec = List<Map<String, dynamic>>.from(
        results[0] as List,
      );
      final danhSachBacSi = List<Map<String, dynamic>>.from(results[1] as List);
      final danhSachCaKham = List<Map<String, dynamic>>.from(results[2] as List);
      final danhSachPhongKham = List<Map<String, dynamic>>.from(
        results[3] as List,
      );

      setState(() {
        _danhSachLichLamViec = danhSachLichLamViec;
        _danhSachBacSi = danhSachBacSi;
        _danhSachCaKham = danhSachCaKham;
        _danhSachPhongKham = danhSachPhongKham;
        _applyFilters();
      });

      if (_danhSachLichLamViec.isEmpty &&
          _danhSachBacSi.isEmpty &&
          _danhSachCaKham.isEmpty &&
          _danhSachPhongKham.isEmpty) {
        _showSnackBar(
          'Không tải được dữ liệu lịch làm việc',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Lỗi tải dữ liệu: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    _danhSachLichLamViecFiltered = _danhSachLichLamViec.where((lich) {
      final matchSearch = (lich['TenBacSi'] ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchDate =
          lich['Ngay'] == DateFormat('yyyy-MM-dd').format(_filterNgay);
      return matchSearch && matchDate;
    }).toList();
  }

  Future<void> _themLichLamViec() async {
    if (_bacSiDuocChon == null ||
        _caDuocChon == null ||
        _phongDuocChon == null) {
      _showSnackBar('Vui lòng chọn đầy đủ thông tin', isError: true);
      return;
    }

    LoadingUtils.showLoading(message: 'Đang tạo lịch làm việc...');
    final result = await _adminController.themLichLamViec(
      maBacSi: _bacSiDuocChon!,
      ngay: DateFormat('yyyy-MM-dd').format(_ngayChon),
      maCa: _caDuocChon!,
      maPhong: _phongDuocChon!,
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success']) {
        _showSnackBar('Thêm lịch làm việc thành công');
        Navigator.pop(context);
        _clearForm();
        await _loadData();
      } else {
        _showSnackBar(
          result['message'] ?? 'Thêm lịch làm việc thất bại',
          isError: true,
        );
      }
    }
  }

  Future<void> _xoaLichLamViec(int maLich) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc muốn xóa lịch làm việc này?'),
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

    LoadingUtils.showLoading(message: 'Đang xóa lịch làm việc...');
    final result = await _adminController.xoaLichLamViec(maLich);
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success']) {
        _showSnackBar('Xóa lịch làm việc thành công');
        await _loadData();
      } else {
        _showSnackBar(result['message'] ?? 'Xóa thất bại', isError: true);
      }
    }
  }

  Future<void> _capNhatLichLamViec() async {
    if (_editingLichId == null ||
        _bacSiDuocChon == null ||
        _caDuocChon == null ||
        _phongDuocChon == null) {
      _showSnackBar('Vui lòng chọn đầy đủ thông tin', isError: true);
      return;
    }

    LoadingUtils.showLoading(message: 'Đang cập nhật lịch làm việc...');
    final result = await _adminController.capNhatLichLamViec(
      maLichLamViec: _editingLichId!,
      maBacSi: _bacSiDuocChon,
      ngay: DateFormat('yyyy-MM-dd').format(_ngayChon),
      maCa: _caDuocChon,
      maPhong: _phongDuocChon,
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      if (result['success']) {
        _showSnackBar('Cập nhật lịch làm việc thành công');
        Navigator.pop(context);
        _clearForm();
        await _loadData();
      } else {
        _showSnackBar(
          result['message'] ?? 'Cập nhật lịch làm việc thất bại',
          isError: true,
        );
      }
    }
  }

  void _dienFormChinhSua(Map<String, dynamic> lich) {
    _isEditing = true;
    _editingLichId = lich['MaLichLamViec'];
    _ngayChon = DateTime.parse(lich['Ngay']);
    _bacSiDuocChon = lich['MaBacSi'];
    _caDuocChon = lich['MaCa'];
    _phongDuocChon = lich['MaPhong'];
    _showFormDialog();
  }

  void _clearForm() {
    _bacSiDuocChon = null;
    _caDuocChon = null;
    _phongDuocChon = null;
    _ngayChon = DateTime.now();
    _isEditing = false;
    _editingLichId = null;
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
                        _isEditing
                            ? 'Chỉnh sửa lịch làm việc'
                            : 'Tạo lịch làm việc mới',
                        style: TextStyle(
                          fontSize: 20,
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
                  _buildDateField(
                    'Chọn ngày *',
                    _ngayChon,
                    (date) => setState(() => _ngayChon = date),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    'Chọn bác sĩ *',
                    _bacSiDuocChon,
                    _danhSachBacSi,
                    'MaBacSi',
                    (bacsi) =>
                        '${bacsi['ho']} ${bacsi['ten']} - ${bacsi['ChuyenKhoa']}',
                    (v) => setState(() => _bacSiDuocChon = v),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    'Chọn ca khám *',
                    _caDuocChon,
                    _danhSachCaKham,
                    'MaCa',
                    (ca) =>
                        '${ca['TenCa']} (${ca['GioBatDau']} - ${ca['GioKetThuc']})',
                    (v) => setState(() => _caDuocChon = v),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    'Chọn phòng khám *',
                    _phongDuocChon,
                    _danhSachPhongKham,
                    'MaPhong',
                    (phong) => '${phong['TenPhong']} - ${phong['Khu']}',
                    (v) => setState(() => _phongDuocChon = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: (_isEditing
                                ? _capNhatLichLamViec
                                : _themLichLamViec),
                      icon: Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(
                        _isEditing
                            ? 'Cập nhật lịch làm việc'
                            : 'Tạo lịch làm việc',
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

  Widget _buildDateField(
    String label,
    DateTime value,
    Function(DateTime) onChanged,
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
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
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
                Icon(Icons.calendar_today, color: _mauXanh, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(value),
                  style: TextStyle(
                    fontSize: 14,
                    color: _mauChuDen,
                    fontWeight: FontWeight.w500,
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
    int? value,
    List<Map<String, dynamic>> items,
    String idKey,
    Function(Map<String, dynamic>) displayText,
    Function(int?) onChanged,
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
        DropdownButtonFormField<int>(
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
          items: items
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item[idKey] as int,
                  child: Text(
                    displayText(item).toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          menuMaxHeight: 300,
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
          'Quản Lý Lịch Làm Việc',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: _mauXanh,
        foregroundColor: _mauTrang,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
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
                    hintText: 'Tìm kiếm bác sĩ...',
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
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _filterNgay,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                    );
                    if (picked != null) {
                      _filterNgay = picked;
                      _applyFilters();
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _mauXanh.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _mauXanh.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: _mauXanh,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Lọc theo ngày: ${DateFormat('dd/MM/yyyy').format(_filterNgay)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _mauChuDen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _isLoading
                ? const LoadingView(
                    message: 'Đang tải lịch làm việc...',
                    isOverlay: false,
                  )
                : _danhSachLichLamViecFiltered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: _mauChuXam.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy lịch làm việc',
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
                      itemCount: _danhSachLichLamViecFiltered.length,
                      itemBuilder: (context, index) {
                        final lich = _danhSachLichLamViecFiltered[index];
                        return _buildLichLamViecCard(lich);
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
        label: const Text('Thêm lịch'),
      ),
    );
  }

  Widget _buildLichLamViecCard(Map<String, dynamic> lich) {
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
                    child: Icon(
                      Icons.calendar_today,
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
                          'BS. ${lich['TenBacSi'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _mauChuDen,
                          ),
                        ),
                        Text(
                          lich['ChuyenKhoa'] ?? '',
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
                        onTap: () => _dienFormChinhSua(lich),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () =>
                            _xoaLichLamViec(lich['MaLichLamViec']),
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
                    Icons.calendar_month,
                    'Ngày',
                    lich['Ngay'] ?? 'N/A',
                  ),
                  _buildInfoChip(
                    Icons.access_time,
                    'Ca',
                    lich['TenCa'] ?? 'N/A',
                  ),
                  _buildInfoChip(
                    Icons.location_on,
                    'Phòng',
                    lich['TenPhong'] ?? 'N/A',
                  ),
                  _buildInfoChip(Icons.domain, 'Khu', lich['Khu'] ?? 'N/A'),
                  _buildInfoChip(
                    Icons.schedule,
                    'Giờ',
                    '${lich['GioBatDau']} - ${lich['GioKetThuc']}',
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