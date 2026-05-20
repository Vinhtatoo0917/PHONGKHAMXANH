import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:phongkhamfy/services/session_manager.dart';

class ThuocController extends GetxController {
  final Dio _dio = Dio();
  final String _baseUrl = ApiConfig.baseUrl;

  final medicines = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  Future<Options> _jsonOptions() async {
    final token = await SessionManager.getTokenStatic();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    getMedicines();
  }

  Future<void> getMedicines() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(
        '$_baseUrl/admin/thuoc',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        medicines.value = (response.data['data'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lấy danh sách thuốc');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addMedicine(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/admin/thuoc',
        data: data,
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        await getMedicines();
        Get.snackbar('Thành công', 'Đã thêm thuốc mới');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm thuốc');
      return false;
    }
  }

  Future<bool> updateMedicine(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/admin/thuoc/$id',
        data: data,
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        await getMedicines();
        Get.snackbar('Thành công', 'Đã cập nhật thông tin thuốc');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật thuốc');
      return false;
    }
  }

  Future<bool> deleteMedicine(int id) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/admin/thuoc/$id',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        await getMedicines();
        Get.snackbar('Thành công', 'Đã xóa thuốc');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa thuốc');
      return false;
    }
  }
}
