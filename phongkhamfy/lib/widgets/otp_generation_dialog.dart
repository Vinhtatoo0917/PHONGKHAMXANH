import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OtpGenerationDialog extends StatefulWidget {
  final String otp;
  final String tenBenhNhan;
  final int maLichKham;
  final Future<String?> Function(int) onAutoRefresh;

  const OtpGenerationDialog({
    Key? key,
    required this.otp,
    required this.tenBenhNhan,
    required this.maLichKham,
    required this.onAutoRefresh,
  }) : super(key: key);

  @override
  State<OtpGenerationDialog> createState() => _OtpGenerationDialogState();
}

class _OtpGenerationDialogState extends State<OtpGenerationDialog> {
  late Timer _countdownTimer;
  int _remainingSeconds = 60;
  String _currentOtp = '';
  bool _isAutoRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otp;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _countdownTimer.cancel();
        _autoRefreshOtp();
      }
    });
  }

  Future<void> _autoRefreshOtp() async {
    setState(() {
      _isAutoRefreshing = true;
      _remainingSeconds = 0;
    });

    final newOtp = await widget.onAutoRefresh(widget.maLichKham);

    if (mounted && newOtp != null && newOtp.isNotEmpty) {
      setState(() {
        _currentOtp = newOtp;
        _remainingSeconds = 60;
        _isAutoRefreshing = false;
      });
      _startCountdown();

      // Show snackbar
      Get.snackbar(
        'Mã OTP mới',
        'Mã OTP đã được cập nhật',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentOtp));
    Get.snackbar(
      'Đã sao chép',
      'Mã OTP đã được copy vào clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Color _getCountdownColor() {
    if (_remainingSeconds > 30) return Colors.green;
    if (_remainingSeconds > 10) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF8C42).withValues(alpha: 0.1),
              const Color(0xFFFFB366).withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C42).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                size: 40,
                color: Color(0xFFFF8C42),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Mã OTP Check-in',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Patient Name
            Text(
              widget.tenBenhNhan,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // OTP Code Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF8C42).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8C42).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Mã OTP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentOtp,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: Color(0xFFFF8C42),
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Countdown Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _getCountdownColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCountdownColor().withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: _getCountdownColor(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isAutoRefreshing
                        ? 'Đang cập nhật mã mới...'
                        : 'Hết hạn trong $_remainingSeconds giây',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _getCountdownColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Cho bệnh nhân nhập mã này để check-in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Copy Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.content_copy_rounded, size: 18),
                label: const Text('Sao chép mã'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFFF8C42),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đóng',
                  style: TextStyle(
                    color: Color(0xFFFF8C42),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
