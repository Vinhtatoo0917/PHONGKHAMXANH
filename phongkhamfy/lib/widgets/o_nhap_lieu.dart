import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ONhapLieu extends StatelessWidget {
  final TextEditingController boQuanLy;
  final String goiY;
  final IconData iconTrai;
  final bool laMatKhau;
  final bool hienThiMatKhau;
  final VoidCallback? khiBatTatHienThiMatKhau;
  final TextInputType? loaiBanPhim;
  final bool kichHoat;

  const ONhapLieu({
    super.key,
    required this.boQuanLy,
    required this.goiY,
    required this.iconTrai,
    this.laMatKhau = false,
    this.hienThiMatKhau = false,
    this.khiBatTatHienThiMatKhau,
    this.loaiBanPhim,
    this.kichHoat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecor.input,
      child: TextFormField(
        controller: boQuanLy,
        enabled: kichHoat,
        obscureText: laMatKhau && !hienThiMatKhau,
        keyboardType: loaiBanPhim,
        style: AppText.body.copyWith(color: AppColors.label),
        decoration: InputDecoration(
          hintText: goiY,
          hintStyle: AppText.body.copyWith(color: AppColors.placeholder),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(iconTrai, color: AppColors.primary, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: laMatKhau
              ? IconButton(
                  icon: Icon(
                    hienThiMatKhau
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.subLabel,
                    size: 20,
                  ),
                  onPressed: khiBatTatHienThiMatKhau,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
