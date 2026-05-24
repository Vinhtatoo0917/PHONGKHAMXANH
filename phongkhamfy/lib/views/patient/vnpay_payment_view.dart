import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayPaymentView extends StatefulWidget {
  final String paymentUrl;
  final String maHoaDon;

  const VNPayPaymentView({
    super.key,
    required this.paymentUrl,
    required this.maHoaDon,
  });

  @override
  State<VNPayPaymentView> createState() => _VNPayPaymentViewState();
}

class _VNPayPaymentViewState extends State<VNPayPaymentView> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  Timer? _checkPaymentTimer;
  final _sessionManager = SessionManager();
  final _dio = Dio();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _launchWebPayment();
    } else {
      _initializeWebView();
    }
    _startPaymentCheck();
  }

  Future<void> _launchWebPayment() async {
    try {
      await launchUrl(Uri.parse(widget.paymentUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể mở link thanh toán');
    }
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _handleReturnUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            // Bỏ qua lỗi redirect
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleReturnUrl(String url) {
    if (!url.contains('/vnpay/return')) return;

    _checkPaymentTimer?.cancel();
    final uri = Uri.tryParse(url);
    final responseCode = uri?.queryParameters['vnp_ResponseCode'];

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (responseCode == '00') {
        Get.snackbar(
          'Thành công',
          'Thanh toán hóa đơn ${widget.maHoaDon} thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF43A047).withValues(alpha: 0.1),
        );
        Navigator.pop(context, true);
      } else {
        Get.snackbar(
          'Thất bại',
          'Thanh toán không thành công, vui lòng thử lại',
          snackPosition: SnackPosition.BOTTOM,
        );
        Navigator.pop(context, false);
      }
    });
  }

  void _startPaymentCheck() {
    _checkPaymentTimer = Timer.periodic(Duration(seconds: 3), (_) async {
      await _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final token = await _sessionManager.getToken();
      if (token == null) return;

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/benhnhan/my-invoices',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final invoices = (response.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        Map<String, dynamic>? invoice;
        for (var inv in invoices) {
          if (inv['MaHoaDon'].toString() == widget.maHoaDon) {
            invoice = inv;
            break;
          }
        }

        if (invoice != null && invoice['TrangThai'] == 'paid') {
          _checkPaymentTimer?.cancel();

          if (!mounted) return;

          // Nhỏ delay để đảm bảo database update hoàn toàn
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          Get.snackbar(
            'Thành công',
            'Thanh toán hóa đơn ${widget.maHoaDon} thành công',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF43A047).withValues(alpha: 0.1),
          );

          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      // Silent fail, continue checking
    }
  }

  @override
  void dispose() {
    _checkPaymentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebVersion();
    } else {
      return _buildMobileVersion();
    }
  }

  Widget _buildWebVersion() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang kiểm tra...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hóa đơn: ${widget.maHoaDon}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileVersion() {
    if (_webViewController == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Thanh toán hóa đơn ${widget.maHoaDon}'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán hóa đơn ${widget.maHoaDon}'),
        elevation: 0,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isLoading)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Kiểm tra thanh toán...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}




