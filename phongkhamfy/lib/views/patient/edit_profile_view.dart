import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/profile_controller.dart';
import 'package:phongkhamfy/widgets/loading_view.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final controller = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _hoController;
  late TextEditingController _tenController;
  late TextEditingController _emailController;
  late TextEditingController _cccdController;
  late TextEditingController _diachiController;
  late TextEditingController _bhytController;
  
  String? _gioiTinh;
  DateTime? _ngaySinh;

  final _primary = const Color(0xFF0F9F7A);
  final _ink = const Color(0xFF12312A);
  final _muted = const Color(0xFF64748B);
  final _surface = Colors.white;

  @override
  void initState() {
    super.initState();
    _initControllers();
    
    // Fix bug: Lang nghe su thay doi cua profile de cap nhat controller
    controller.profile.listen((p) {
      if (mounted) {
        setState(() {
          _updateControllerValues();
        });
      }
    });
  }

  void _initControllers() {
    _hoController = TextEditingController();
    _tenController = TextEditingController();
    _emailController = TextEditingController();
    _cccdController = TextEditingController();
    _diachiController = TextEditingController();
    _bhytController = TextEditingController();
    _updateControllerValues();
  }

  void _updateControllerValues() {
    final p = controller.profile.value?['BenhNhan'] ?? {};
    final account = controller.profile.value ?? {};
    
    _hoController.text = p['ho']?.toString() ?? '';
    _tenController.text = p['ten']?.toString() ?? '';
    _emailController.text = account['email']?.toString() ?? '';
    _cccdController.text = p['cccd']?.toString() ?? '';
    _diachiController.text = p['diachi']?.toString() ?? '';
    _bhytController.text = p['BHYT']?.toString() ?? '';
    
    _gioiTinh = p['gioitinh']?.toString();
    if (p['ngaysinh'] != null) {
      _ngaySinh = DateTime.tryParse(p['ngaysinh'].toString());
    }
  }

  @override
  void dispose() {
    _hoController.dispose();
    _tenController.dispose();
    _emailController.dispose();
    _cccdController.dispose();
    _diachiController.dispose();
    _bhytController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ngaySinh ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _ngaySinh = picked);
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'ho': _hoController.text.trim(),
      'ten': _tenController.text.trim(),
      'email': _emailController.text.trim(),
      'ngaysinh': _ngaySinh != null ? DateFormat('yyyy-MM-dd').format(_ngaySinh!) : null,
      'gioitinh': _gioiTinh,
      'cccd': _cccdController.text.trim(),
      'diachi': _diachiController.text.trim(),
      'BHYT': _bhytController.text.trim(),
    };

    final success = await controller.updateProfile(data);
    if (success) {
      if (!mounted) return;
      
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: _primary, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thành công!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thông tin cá nhân của bạn đã được cập nhật thành công.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      );
      
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView(
            message: 'Đang tải hồ sơ...',
            isOverlay: false,
          );
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: _primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Thông tin cá nhân',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primary, _primary.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: _primary.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Color(0xFFF1F5F9),
                                    child: Icon(Icons.person_rounded, size: 50, color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: _primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Thông tin cơ bản'),
                          const SizedBox(height: 16),
                          _panel(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _textField(_hoController, 'Họ', Icons.person_outline)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _textField(_tenController, 'Tên', Icons.person_outline)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _textField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: _datePickerField('Ngày sinh', _ngaySinh, _selectDate)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _dropdownField('Giới tính', Icons.wc_outlined, ['Nam', 'Nữ', 'Khác'])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Thông tin định danh'),
                          const SizedBox(height: 16),
                          _panel(
                            child: Column(
                              children: [
                                _textField(_cccdController, 'Số CCCD/Passport', Icons.badge_outlined),
                                const SizedBox(height: 16),
                                _textField(_bhytController, 'Số thẻ BHYT', Icons.health_and_safety_outlined),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Địa chỉ liên lạc'),
                          const SizedBox(height: 16),
                          _panel(
                            child: _textField(_diachiController, 'Địa chỉ hiện tại', Icons.location_on_outlined, maxLines: 2),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: FilledButton(
                              onPressed: controller.isUpdating.value ? null : _onSave,
                              style: FilledButton.styleFrom(
                                backgroundColor: _primary,
                                elevation: 8,
                                shadowColor: _primary.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (controller.isUpdating.value) const LoadingView(message: 'Đang lưu thông tin...'),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  Widget _textField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int? maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
      decoration: _inputDecoration(label, icon),
      validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }

  Widget _datePickerField(String label, DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.calendar_today_outlined),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Chọn ngày',
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, IconData icon, List<String> options) {
    return DropdownButtonFormField<String>(
      initialValue: _gioiTinh,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      decoration: _inputDecoration(label, icon),
      style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
      onChanged: (v) => setState(() => _gioiTinh = v),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500, fontSize: 14),
      prefixIcon: Icon(icon, color: _primary, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
