// Test responsive design trên các kích thước khác nhau
import 'package:flutter/material.dart';
import 'lib/views/auth/login_view.dart';

void main() {
  runApp(const ResponsiveTestApp());
}

class ResponsiveTestApp extends StatelessWidget {
  const ResponsiveTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Responsive Design',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF82),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ResponsiveTestScreen(),
    );
  }
}

class ResponsiveTestScreen extends StatefulWidget {
  const ResponsiveTestScreen({super.key});

  @override
  State<ResponsiveTestScreen> createState() => _ResponsiveTestScreenState();
}

class _ResponsiveTestScreenState extends State<ResponsiveTestScreen> {
  double _screenWidth = 1200; // Mặc định desktop

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Responsive Design'),
        backgroundColor: const Color(0xFF3DAA70),
        foregroundColor: Colors.white,
        actions: [
          // Nút test các kích thước
          PopupMenuButton<double>(
            icon: const Icon(Icons.phone_android),
            onSelected: (width) {
              setState(() {
                _screenWidth = width;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 375, child: Text('📱 iPhone (375px)')),
              const PopupMenuItem(value: 768, child: Text('📟 iPad (768px)')),
              const PopupMenuItem(
                value: 1024,
                child: Text('💻 Desktop (1024px)'),
              ),
              const PopupMenuItem(
                value: 1440,
                child: Text('🖥️ Large Desktop (1440px)'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: _screenWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: const ManHinhDangNhap(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Text(
          'Kích thước hiện tại: ${_screenWidth.toInt()}px\n'
          'Loại thiết bị: ${_getDeviceType(_screenWidth)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getDeviceType(double width) {
    if (width < 600) return '📱 Điện thoại';
    if (width < 1024) return '📟 Tablet';
    return '💻 Desktop';
  }
}
