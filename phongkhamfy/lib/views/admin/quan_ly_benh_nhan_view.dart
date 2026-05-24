import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/theme/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/loading_utils.dart';
import '../../widgets/loading_view.dart';

class QuanLyBenhNhanView extends StatefulWidget {
  const QuanLyBenhNhanView({super.key});

  @override
  State<QuanLyBenhNhanView> createState() => _QuanLyBenhNhanViewState();
}

class _QuanLyBenhNhanViewState extends State<QuanLyBenhNhanView> {
  final _adminController = AdminController();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _danhSach = [];
  List<Map<String, dynamic>> _danhSachFiltered = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _adminController.layDanhSachBenhNhan();
      if (mounted) {
        setState(() {
          _danhSach = data;
          _applyFilter();
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

  void _applyFilter() {
    _danhSachFiltered = _danhSach.where((bn) {
      final ho = (bn['ho'] ?? '').toLowerCase();
      final ten = (bn['ten'] ?? '').toLowerCase();
      final email = (bn['email'] ?? '').toLowerCase();
      final sdt = (bn['sdt'] ?? '').toString();
      final q = _searchQuery.toLowerCase();
      return '$ho $ten'.contains(q) || email.contains(q) || sdt.contains(q);
    }).toList();
  }

  Future<void> _toggleTrangThai(Map<String, dynamic> bn) async {
    final isActive = bn['trangthaihoatdong'] == 'active';
    final newStatus = isActive ? 'inactive' : 'active';
    final action = isActive ? 'khóa' : 'mở khóa';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xác nhận $action'),
        content: Text(
          'Bạn có chắc muốn $action tài khoản của\n${bn['ho']} ${bn['ten']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.danger : AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    LoadingUtils.showLoading(message: 'Đang cập nhật...');
    final result = await _adminController.capNhatTrangThaiBenhNhan(
      maBenhNhan: bn['MaBenhNhan'],
      trangThai: newStatus,
    );
    LoadingUtils.hideLoading();

    if (mounted) {
      _showSnackBar(
        result['message'] ?? (result['success'] ? 'Thành công' : 'Thất bại'),
        isError: result['success'] != true,
      );
      if (result['success'] == true) await _loadData();
    }
  }

  Future<void> _xoaBenhNhan(Map<String, dynamic> bn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa bệnh nhân ${bn['ho']} ${bn['ten']}?\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    LoadingUtils.showLoading(message: 'Đang xóa...');
    final result = await _adminController.xoaBenhNhan(bn['MaBenhNhan']);
    LoadingUtils.hideLoading();

    if (mounted) {
      _showSnackBar(
        result['message'] ?? (result['success'] ? 'Xóa thành công' : 'Xóa thất bại'),
        isError: result['success'] != true,
      );
      if (result['success'] == true) await _loadData();
    }
  }

  void _xemChiTiet(Map<String, dynamic> bn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChiTietBenhNhanSheet(
        benhNhan: bn,
        adminController: _adminController,
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(title: 'Quản Lý Bệnh Nhân'),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSummaryRow(),
          Expanded(
            child: _isLoading
                ? const LoadingView(message: 'Đang tải danh sách bệnh nhân...', isOverlay: false)
                : _danhSachFiltered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _danhSachFiltered.length,
                          itemBuilder: (_, i) => _buildCard(_danhSachFiltered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          _searchQuery = v;
          _applyFilter();
          setState(() {});
        },
        style: TextStyle(fontSize: 15, color: AppColors.label),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, email, số điện thoại...',
          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
          suffixIcon: _searchQuery.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _searchQuery = '';
                      _applyFilter();
                      setState(() {});
                    },
                    child: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final total = _danhSach.length;
    final active = _danhSach.where((b) => b['trangthaihoatdong'] == 'active').length;
    final inactive = total - active;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _buildStatChip(Icons.people_rounded, 'Tổng', total, AppColors.primary),
          const SizedBox(width: 8),
          _buildStatChip(Icons.check_circle_rounded, 'Hoạt động', active, AppColors.success),
          const SizedBox(width: 8),
          _buildStatChip(Icons.block_rounded, 'Bị khóa', inactive, AppColors.danger),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
                  Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 64,
              color: AppColors.subLabel.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Không tìm thấy bệnh nhân',
              style: TextStyle(fontSize: 16, color: AppColors.subLabel)),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> bn) {
    final isActive = bn['trangthaihoatdong'] == 'active';
    final hoTen = '${bn['ho'] ?? ''} ${bn['ten'] ?? ''}'.trim();
    final email = bn['email'] ?? 'N/A';
    final sdt = bn['sdt']?.toString() ?? 'N/A';
    final gioiTinh = bn['gioitinh'] ?? '';
    final isMale = gioiTinh.toLowerCase() == 'nam';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.success : AppColors.danger,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isMale ? const Color(0xFF1976D2) : const Color(0xFFE91E63))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isMale ? Icons.person_rounded : Icons.person_2_rounded,
                  color: isMale ? const Color(0xFF1976D2) : const Color(0xFFE91E63),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hoTen,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.label,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isActive ? 'Hoạt động' : 'Bị khóa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.success : AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 12, color: AppColors.subLabel),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            email,
                            style: TextStyle(fontSize: 12, color: AppColors.subLabel),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 12, color: AppColors.subLabel),
                        const SizedBox(width: 4),
                        Text(
                          sdt,
                          style: TextStyle(fontSize: 12, color: AppColors.subLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: AppColors.subLabel),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'detail') _xemChiTiet(bn);
                  if (value == 'toggle') _toggleTrangThai(bn);
                  if (value == 'delete') _xoaBenhNhan(bn);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(children: [
                      Icon(Icons.info_outline_rounded, size: 18),
                      SizedBox(width: 10),
                      Text('Xem chi tiết'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(children: [
                      Icon(
                        isActive ? Icons.lock_rounded : Icons.lock_open_rounded,
                        size: 18,
                        color: isActive ? AppColors.danger : AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isActive ? 'Khóa tài khoản' : 'Mở khóa',
                        style: TextStyle(
                          color: isActive ? AppColors.danger : AppColors.success,
                        ),
                      ),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded, size: 18, color: AppColors.danger),
                      SizedBox(width: 10),
                      Text('Xóa', style: TextStyle(color: AppColors.danger)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── BOTTOM SHEET CHI TIẾT ────────────────────────────────────────────────────

class _ChiTietBenhNhanSheet extends StatefulWidget {
  final Map<String, dynamic> benhNhan;
  final AdminController adminController;

  const _ChiTietBenhNhanSheet({
    required this.benhNhan,
    required this.adminController,
  });

  @override
  State<_ChiTietBenhNhanSheet> createState() => _ChiTietBenhNhanSheetState();
}

class _ChiTietBenhNhanSheetState extends State<_ChiTietBenhNhanSheet> {
  Map<String, dynamic>? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final maBenhNhan = widget.benhNhan['MaBenhNhan'];
    final detail = await widget.adminController.layChiTietBenhNhan(maBenhNhan);
    if (mounted) {
      setState(() {
        _detail = detail ?? widget.benhNhan;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController controller) {
    final bn = _detail!;
    final hoTen = '${bn['ho'] ?? ''} ${bn['ten'] ?? ''}'.trim();
    final isActive = bn['trangthaihoatdong'] == 'active';
    final gioiTinh = bn['gioitinh'] ?? '';
    final isMale = gioiTinh.toLowerCase() == 'nam';

    String? ngaySinhFormatted;
    if (bn['ngaysinh'] != null) {
      try {
        ngaySinhFormatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(bn['ngaysinh']));
      } catch (_) {
        ngaySinhFormatted = bn['ngaysinh'];
      }
    }

    String? ngayTaoFormatted;
    if (bn['ngaytao'] != null) {
      try {
        ngayTaoFormatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(bn['ngaytao']));
      } catch (_) {
        ngayTaoFormatted = bn['ngaytao'];
      }
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Avatar + tên
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: (isMale ? const Color(0xFF1976D2) : const Color(0xFFE91E63))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isMale ? Icons.person_rounded : Icons.person_2_rounded,
                  color: isMale ? const Color(0xFF1976D2) : const Color(0xFFE91E63),
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              Text(hoTen,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.label)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Đang hoạt động' : 'Bị khóa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        IosSection(
          title: 'THÔNG TIN CÁ NHÂN',
          children: [
            IosCell(
              leading: _iconBox(Icons.badge_rounded, AppColors.primary),
              title: 'Mã bệnh nhân',
              trailing: Text('#${bn['MaBenhNhan']}',
                  style: AppText.footnote.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              showSeparator: true,
            ),
            IosCell(
              leading: _iconBox(Icons.wc_rounded, AppColors.accent),
              title: 'Giới tính',
              trailing: Text(gioiTinh.isEmpty ? 'N/A' : gioiTinh,
                  style: AppText.footnote.copyWith(color: AppColors.label2)),
              showSeparator: true,
            ),
            IosCell(
              leading: _iconBox(Icons.cake_rounded, const Color(0xFFE91E63)),
              title: 'Ngày sinh',
              trailing: Text(ngaySinhFormatted ?? 'N/A',
                  style: AppText.footnote.copyWith(color: AppColors.label2)),
              showSeparator: true,
            ),
            IosCell(
              leading: _iconBox(Icons.credit_card_rounded, const Color(0xFF7B1FA2)),
              title: 'CCCD',
              trailing: Text(bn['cccd'] ?? 'N/A',
                  style: AppText.footnote.copyWith(color: AppColors.label2)),
              showSeparator: true,
            ),
            IosCell(
              leading: _iconBox(Icons.location_on_rounded, const Color(0xFF43A047)),
              title: 'Địa chỉ',
              trailing: Flexible(
                child: Text(bn['diachi'] ?? 'N/A',
                    style: AppText.footnote.copyWith(color: AppColors.label2),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              showSeparator: true,
            ),
            IosCell(
              leading: _iconBox(Icons.health_and_safety_rounded, const Color(0xFF00897B)),
              title: 'BHYT',
              trailing: Text(bn['BHYT'] ?? 'N/A',
                  style: AppText.footnote.copyWith(color: AppColors.label2)),
              showSeparator: false,
            ),
          ],
        ),

        const SizedBox(height: 16),

        IosSection(
          title: 'TÀI KHOẢN',
          children: [
            IosCell(
              leading: _iconBox(Icons.email_rounded, AppColors.primary),
              title: 'Email',
              trailing: Flexible(
                child: Text(bn['email'] ?? 'N/A',
                    style: AppText.footnote.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              showSeparator: true,
            ),
            IosCell(
              leading: _iconBox(Icons.phone_rounded, const Color(0xFF00897B)),
              title: 'Số điện thoại',
              trailing: Text(bn['sdt']?.toString() ?? 'N/A',
                  style: AppText.footnote.copyWith(color: AppColors.label2)),
              showSeparator: true,
            ),
            IosCell(
              leading: _iconBox(Icons.calendar_today_rounded, AppColors.accent),
              title: 'Ngày tạo',
              trailing: Text(ngayTaoFormatted ?? 'N/A',
                  style: AppText.footnote.copyWith(color: AppColors.label2)),
              showSeparator: false,
            ),
          ],
        ),

        if (bn['soLichKham'] != null) ...[
          const SizedBox(height: 16),
          IosSection(
            title: 'THỐNG KÊ',
            children: [
              IosCell(
                leading: _iconBox(Icons.event_note_rounded, AppColors.info),
                title: 'Lịch khám',
                trailing: Text('${bn['soLichKham']} lần',
                    style: AppText.footnote.copyWith(
                        color: AppColors.info, fontWeight: FontWeight.w600)),
                showSeparator: false,
              ),
            ],
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 17),
      );
}
