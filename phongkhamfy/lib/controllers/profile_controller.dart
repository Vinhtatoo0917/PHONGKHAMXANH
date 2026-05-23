import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:phongkhamfy/utils/loading_utils.dart';

class ProfileController extends GetxController {
  final Dio _dio = Dio();
  final String _baseUrl = ApiConfig.baseUrl;

  final profile = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<Options> _jsonOptions() async {
    final token = await SessionManager.getTokenStatic();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(
        '$_baseUrl/profile',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        profile.value = Map<String, dynamic>.from(response.data['data']);
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy thông tin');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    LoadingUtils.showLoading(message: 'Đang lưu cập nhật...');
    try {
      isUpdating.value = true;
      final response = await _dio.post(
        '$_baseUrl/profile/update',
        data: data,
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        Get.snackbar(
          'Thành công',
          'Cập nhật thông tin thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
        await getProfile();
        return true;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi cập nhật');
    } catch (e) {
      String msg = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
      }
      Get.snackbar(
        'Lỗi',
        msg.replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUpdating.value = false;
      LoadingUtils.hideLoading();
    }
  }

  /// Lấy hoá đơn của bệnh nhân
  Future<Map<String, dynamic>?> getHoaDon(int maLichKham) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/lich-kham/$maLichKham/hoa-don',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Lỗi lấy hoá đơn: $e');
      return null;
    }
  }
}

