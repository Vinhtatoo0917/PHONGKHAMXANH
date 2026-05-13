// ═══════════════════════════════════════════════════════════════
// FILE: hieu_ung_nen.dart
// MÔ TẢ: Widget tạo các vòng tròn trang trí ở background
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// CLASS: HieuUngNen
// MÔ TẢ: Tạo các vòng tròn mờ làm background trang trí
// LOẠI: StatelessWidget
// ═══════════════════════════════════════════════════════════════
class HieuUngNen extends StatelessWidget {
  const HieuUngNen({super.key});

  // ─────────────────────────────────────────────────────────────
  // MÀU SẮC
  // ─────────────────────────────────────────────────────────────
  static const Color _mauChinh = Color(0xFF3DAA70);
  static const Color _mauChinhNhat = Color(0xFF6DC896);

  // ═══════════════════════════════════════════════════════════════
  // HÀM BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;

    // Stack - Xếp các widget chồng lên nhau
    return Stack(
      children: [
        // ─────────────────────────────────────────────────────────
        // VÒNG TRÒN 1 - Góc trên bên phải
        // ─────────────────────────────────────────────────────────
        Positioned(
          top: -60,      // Dịch lên trên 60px (ra ngoài màn hình)
          right: -60,    // Dịch sang phải 60px (ra ngoài màn hình)
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,                           // Hình tròn
              color: _mauChinhNhat.withValues(alpha: 0.18),     // Màu xanh nhạt, trong suốt 18%
            ),
          ),
        ),

        // ─────────────────────────────────────────────────────────
        // VÒNG TRÒN 2 - Góc dưới bên trái
        // ─────────────────────────────────────────────────────────
        Positioned(
          bottom: -80,   // Dịch xuống dưới 80px (ra ngoài màn hình)
          left: -50,     // Dịch sang trái 50px (ra ngoài màn hình)
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _mauChinh.withValues(alpha: 0.10),         // Màu xanh, trong suốt 10%
            ),
          ),
        ),

        // ─────────────────────────────────────────────────────────
        // VÒNG TRÒN 3 - Giữa bên trái
        // ─────────────────────────────────────────────────────────
        Positioned(
          top: size.height * 0.35,  // Vị trí 35% chiều cao màn hình
          left: -30,                // Dịch sang trái 30px
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _mauChinhNhat.withValues(alpha: 0.12),     // Màu xanh nhạt, trong suốt 12%
            ),
          ),
        ),
      ],
    );
  }
}
