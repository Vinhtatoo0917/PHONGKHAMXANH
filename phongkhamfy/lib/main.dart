// ═══════════════════════════════════════════════════════════════
// FILE: main.dart
// MÔ TẢ: Check token khi khởi động app
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'views/admin/admin_home_view.dart';
import 'controllers/auth_controller.dart';

void main() {
  runApp(const UngDungPhongKham());
}

class UngDungPhongKham extends StatelessWidget {
  const UngDungPhongKham({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phòng Khám Xanh',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF82),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ManHinhKhoiDong(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MÀN HÌNH KHỞI ĐỘNG - CHECK TOKEN
// ═══════════════════════════════════════════════════════════════
class ManHinhKhoiDong extends StatefulWidget {
  const ManHinhKhoiDong({super.key});

  @override
  State<ManHinhKhoiDong> createState() => _TrangThaiManHinhKhoiDong();
}

class _TrangThaiManHinhKhoiDong extends State<ManHinhKhoiDong> {
  final _dichVuXacThuc = DichVuXacThuc();

  @override
  void initState() {
    super.initState();
    _kiemTraToken();
  }

  Future<void> _kiemTraToken() async {
    // Đợi 1 giây (splash screen)
    await Future.delayed(const Duration(seconds: 1));

    // Check token với database
    final userData = await _dichVuXacThuc.kiemTraToken();

    if (!mounted) return;

    if (userData != null) {
      // Token hợp lệ - kiểm tra vai trò
      final vaiTro = userData['VaiTro'] ?? 'BenhNhan';

      // DEBUG: In ra vai trò để kiểm tra
      print('🔍 [DEBUG MAIN] VaiTro từ API: "$vaiTro"');
      print('🔍 [DEBUG MAIN] Toàn bộ userData: $userData');

      if (!mounted) return;

      // So sánh không phân biệt hoa thường
      if (vaiTro.toString().toLowerCase() == 'admin') {
        print('✅ [DEBUG MAIN] Đang chuyển đến màn hình Admin');
        // Vào màn hình Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHomeView(
              tenNguoiDung: userData['email'] ?? userData['sdt'] ?? 'Admin',
              email: userData['email'] ?? userData['sdt'] ?? '',
            ),
          ),
        );
      } else {
        print(
          '❌ [DEBUG MAIN] Vai trò không phải admin, chuyển đến màn hình bệnh nhân',
        );
        // Vào màn hình Home bệnh nhân
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ManHinhTrangChu(
              tenNguoiDung:
                  userData['email'] ?? userData['sdt'] ?? 'Người dùng',
              email: userData['email'] ?? userData['sdt'] ?? '',
              vaiTro: vaiTro,
            ),
          ),
        );
      }
    } else {
      // Không có token hoặc token không hợp lệ - về Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ManHinhDangNhap()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital,
              size: 80,
              color: const Color(0xFF3DAA70),
            ),
            const SizedBox(height: 24),
            const Text(
              'Phòng Khám FY',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3D2E),
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3DAA70)),
            ),
          ],
        ),
      ),
    );
  }
}
