// ═══════════════════════════════════════════════════════════════
// FILE: logo_phong_kham.dart
// MÔ TẢ: Widget hiển thị logo và tên phòng khám
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// CLASS: LogoPhongKham
// MÔ TẢ: Widget hiển thị logo dấu thập y tế và tên phòng khám
// LOẠI: StatelessWidget (không thay đổi trạng thái)
// ═══════════════════════════════════════════════════════════════
class LogoPhongKham extends StatelessWidget {
  const LogoPhongKham({super.key});

  // ─────────────────────────────────────────────────────────────
  // MÀU SẮC
  // ─────────────────────────────────────────────────────────────
  static const Color mauChinh = Color(0xFF3DAA70); // Màu xanh lá chính
  static const Color mauChinhDam = Color(0xFF1F7A4C); // Màu xanh lá đậm
  static const Color mauChuChinh = Color(0xFF1A3D2E); // Màu chữ đậm
  static const Color mauChuPhu = Color(0xFF5A8A70); // Màu chữ nhạt

  // ═══════════════════════════════════════════════════════════════
  // HÀM BUILD - Xây dựng giao diện
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Column - Sắp xếp các widget theo chiều dọc (từ trên xuống dưới)
    return Column(
      children: [
        // ─────────────────────────────────────────────────────────
        // CONTAINER LOGO (Hình vuông chứa dấu thập y tế)
        // ─────────────────────────────────────────────────────────
        Container(
          width: 96, // Chiều rộng 96px
          height: 96, // Chiều cao 96px
          // BoxDecoration - Trang trí cho Container
          decoration: BoxDecoration(
            // LinearGradient - Hiệu ứng chuyển màu tuyến tính
            gradient: const LinearGradient(
              colors: [mauChinh, mauChinhDam], // Từ xanh nhạt → xanh đậm
              begin: Alignment.topLeft, // Bắt đầu từ góc trên trái
              end: Alignment.bottomRight, // Kết thúc ở góc dưới phải
            ),

            // Bo tròn 4 góc với bán kính 28px
            borderRadius: BorderRadius.circular(28),

            // boxShadow - Bóng đổ (có thể có nhiều bóng)
            boxShadow: [
              BoxShadow(
                // Màu bóng với độ trong suốt 40%
                color: mauChinh.withValues(alpha: 0.40),
                blurRadius: 24, // Độ mờ của bóng (càng lớn càng mờ)
                offset: const Offset(
                  0,
                  10,
                ), // Dịch bóng: (x: 0, y: 10) - xuống dưới 10px
              ),
            ],
          ),

          // ─────────────────────────────────────────────────────────
          // STACK - Xếp các widget chồng lên nhau
          // ─────────────────────────────────────────────────────────
          child: Stack(
            alignment: Alignment.center, // Căn giữa tất cả các widget con
            children: [
              // ───────────────────────────────────────────────────
              // THANH DỌC của dấu thập (+)
              // ───────────────────────────────────────────────────
              Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Căn giữa theo chiều dọc
                children: [
                  Container(
                    width: 10, // Rộng 10px
                    height: 36, // Cao 36px
                    decoration: BoxDecoration(
                      color: Colors.white, // Màu trắng
                      borderRadius: BorderRadius.circular(5), // Bo góc 5px
                    ),
                  ),
                ],
              ),

              // ───────────────────────────────────────────────────
              // THANH NGANG của dấu thập (+)
              // ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Căn giữa theo chiều ngang
                children: [
                  Container(
                    width: 36, // Rộng 36px
                    height: 10, // Cao 10px
                    decoration: BoxDecoration(
                      color: Colors.white, // Màu trắng
                      borderRadius: BorderRadius.circular(5), // Bo góc 5px
                    ),
                  ),
                ],
              ),

              // ───────────────────────────────────────────────────
              // CHẤM TRÒN NHỎ ở góc dưới phải (điểm nhấn)
              // ───────────────────────────────────────────────────
              // Positioned - Đặt widget ở vị trí cụ thể trong Stack
              Positioned(
                bottom: 14, // Cách đáy 14px
                right: 14, // Cách phải 14px
                child: Container(
                  width: 14, // Rộng 14px
                  height: 14, // Cao 14px
                  decoration: BoxDecoration(
                    // Màu trắng với độ trong suốt 85%
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle, // Hình tròn
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─────────────────────────────────────────────────────────
        // KHOẢNG CÁCH giữa logo và text
        // ─────────────────────────────────────────────────────────
        const SizedBox(height: 16), // Khoảng cách 16px
        // ─────────────────────────────────────────────────────────
        // TÊN PHÒNG KHÁM (chữ in hoa)
        // ─────────────────────────────────────────────────────────
        const Text(
          'PHÒNG KHÁM XANH',
          style: TextStyle(
            fontSize: 22, // Kích thước chữ 22px
            fontWeight: FontWeight.w800, // Độ đậm (w800 = extra bold)
            color: mauChuChinh, // Màu chữ đậm
            letterSpacing: 2.5, // Khoảng cách giữa các chữ cái
          ),
        ),

        // Khoảng cách nhỏ
        const SizedBox(height: 4),

        // ─────────────────────────────────────────────────────────
        // SLOGAN (chữ nhỏ bên dưới)
        // ─────────────────────────────────────────────────────────
        const Text(
          'Chăm sóc sức khỏe toàn diện',
          style: TextStyle(
            fontSize: 13, // Kích thước chữ 13px
            color: mauChuPhu, // Màu chữ nhạt hơn
            letterSpacing: 0.5, // Khoảng cách giữa các chữ cái
          ),
        ),
      ],
    );
  }
}
