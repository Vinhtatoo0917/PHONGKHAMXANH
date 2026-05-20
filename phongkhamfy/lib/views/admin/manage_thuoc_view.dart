import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/controllers/thuoc_controller.dart';
import 'dart:ui';

class ManageThuocView extends StatefulWidget {
  const ManageThuocView({super.key});

  @override
  State<ManageThuocView> createState() => _ManageThuocViewState();
}

class _ManageThuocViewState extends State<ManageThuocView> {
  final controller = Get.put(ThuocController());
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  final _primary = const Color(0xFF6366F1); // Modern Indigo
  final _accent = const Color(0xFF10B981); // Emerald Green
  final _bg = const Color(0xFFF8FAFC);
  final _slate = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildSearchSection(),
              _buildMedicineList(),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        centerTitle: false,
        title: Text(
          'Danh mục thuốc',
          style: TextStyle(
            color: _slate,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        background: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 1,
              color: Colors.grey[100],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => _searchQuery.value = v,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tên thuốc, mã...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: _primary),
              suffixIcon: Obx(() => _searchQuery.isEmpty 
                ? const SizedBox.shrink() 
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _searchQuery.value = '';
                    },
                  )),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
      }

      final items = controller.medicines.where((m) {
        final query = _searchQuery.value.toLowerCase();
        return m['TenThuoc'].toString().toLowerCase().contains(query) ||
               (m['MoTa'] ?? '').toString().toLowerCase().contains(query);
      }).toList();

      if (items.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_liquid_rounded, size: 80, color: Colors.grey[200]),
                const SizedBox(height: 16),
                Text('Không tìm thấy thuốc nào', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildThuocCard(items[index]),
            childCount: items.length,
          ),
        ),
      );
    });
  }

  Widget _buildThuocCard(Map<String, dynamic> thuoc) {
    Color statusColor;
    switch (thuoc['TrangThai']) {
      case 'Kinh doanh': statusColor = _accent; break;
      case 'Hết hàng': statusColor = Colors.orange; break;
      case 'Ngừng kinh doanh': statusColor = Colors.redAccent; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showThuocForm(thuoc: thuoc),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.medication_rounded, color: _primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              thuoc['TenThuoc'],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: _slate,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              thuoc['HamLuong'] ?? 'Không rõ hàm lượng',
                              style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(thuoc['TrangThai'] ?? 'Unknown', statusColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.grey[50]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đơn giá', style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(
                            '${thuoc['Gia']}đ / ${thuoc['DonViTinh']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _primary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildActionBtn(Icons.edit_note_rounded, Colors.grey[400]!, () => _showThuocForm(thuoc: thuoc)),
                          const SizedBox(width: 8),
                          _buildActionBtn(Icons.delete_outline_rounded, Colors.red[300]!, () => _confirmDelete(thuoc)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.2),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[100]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildAddButton() {
    return Positioned(
      bottom: 30,
      right: 24,
      left: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: InkWell(
            onTap: () => _showThuocForm(),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Thêm thuốc mới',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showThuocForm({Map<String, dynamic>? thuoc}) {
    final tenController = TextEditingController(text: thuoc?['TenThuoc']);
    final dvtController = TextEditingController(text: thuoc?['DonViTinh']);
    final giaController = TextEditingController(text: thuoc?['Gia']?.toString());
    final hamLuongController = TextEditingController(text: thuoc?['HamLuong']);
    final motaController = TextEditingController(text: thuoc?['MoTa']);
    String trangThai = thuoc?['TrangThai'] ?? 'Kinh doanh';

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Text(thuoc == null ? 'Thêm thuốc mới' : 'Cập nhật thuốc', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _slate)),
              const SizedBox(height: 8),
              Text('Điền đầy đủ thông tin vào các trường bên dưới', 
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 32),
              _buildField('Tên thuốc', tenController, Icons.title_rounded, hint: 'E.g. Paracetamol'),
              Row(
                children: [
                  Expanded(child: _buildField('Đơn vị tính', dvtController, Icons.straighten_rounded, hint: 'Viên, Chai...')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Hàm lượng', hamLuongController, Icons.science_rounded, hint: '500mg...')),
                ],
              ),
              _buildField('Giá bán (đ)', giaController, Icons.payments_rounded, isNum: true, hint: '0.00'),
              _buildField('Mô tả / Ghi chú', motaController, Icons.description_rounded, maxLines: 3, hint: 'Hướng dẫn sử dụng...'),
              
              Text('Trạng thái kinh doanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: trangThai,
                items: ['Kinh doanh', 'Ngừng kinh doanh', 'Hết hàng']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (v) => trangThai = v ?? 'Kinh doanh',
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.info_outline_rounded, size: 20, color: _primary),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: () async {
                    if (tenController.text.isEmpty) {
                      Get.snackbar('Cảnh báo', 'Vui lòng nhập tên thuốc');
                      return;
                    }
                    final data = {
                      'TenThuoc': tenController.text,
                      'DonViTinh': dvtController.text,
                      'HamLuong': hamLuongController.text,
                      'Gia': double.tryParse(giaController.text) ?? 0,
                      'MoTa': motaController.text,
                      'TrangThai': trangThai,
                    };

                    _showLoadingDialog('Đang xử lý...');
                    
                    bool success;
                    final startTime = DateTime.now();
                    
                    if (thuoc == null) {
                      success = await controller.addMedicine(data);
                    } else {
                      success = await controller.updateMedicine(thuoc['MaThuoc'], data);
                    }

                    // Đảm bảo load ít nhất 2s
                    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
                    if (elapsed < 2000) {
                      await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                    }

                    if (mounted) {
                      Navigator.pop(context); // Đóng loading dialog
                      if (success) {
                        Navigator.pop(context); // Đóng form
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Lưu thông tin danh mục', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool isNum = false, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
              prefixIcon: Icon(icon, size: 20, color: _primary),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> thuoc) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              ),
              const SizedBox(width: 12),
              const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: Text('Bạn có chắc muốn gỡ bỏ thuốc "${thuoc['TenThuoc']}" khỏi hệ thống?', 
            style: const TextStyle(color: Colors.grey, fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Quay lại', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold))
            ),
            Container(
              margin: const EdgeInsets.only(left: 12),
              child: FilledButton(
                onPressed: () async {
                  _showLoadingDialog('Đang xóa thuốc...');
                  final startTime = DateTime.now();
                  
                  final success = await controller.deleteMedicine(thuoc['MaThuoc']);
                  
                  final elapsed = DateTime.now().difference(startTime).inMilliseconds;
                  if (elapsed < 2000) {
                    await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                  }

                  if (mounted) {
                    Navigator.pop(context); // Đóng loading dialog
                    if (success) {
                      Navigator.pop(context); // Đóng confirm dialog
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Đồng ý xóa', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
        ),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    Get.dialog(
      barrierDismissible: false,
      Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _primary),
              const SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(
                  color: _slate,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
