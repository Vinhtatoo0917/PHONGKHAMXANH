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

    // Dio mặc định sẽ throw exception khi statusCode không thuộc 2xx.
    // Với các màn quản trị, nếu token hết hạn/không đủ quyền sẽ trả 401/403,
    // nên mình cấu hình để luôn nhận response và tự xử lý theo message từ server.
    return Options(
      validateStatus: (_) => true,
      headers: {
        'Authorization': token == null ? null : 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  @override
  void onReady() {
    super.onReady();
    // Gọi sau khi màn hình đã build xong để tránh lỗi:
    // "visitChildElements() called during build" khi mở Get.dialog
    getMedicines();
  }

  Future<void> getMedicines() async {
    try {
      isLoading.value = true;

      final token = await SessionManager.getTokenStatic();
      if (token == null || token.isEmpty) {
        Get.snackbar('Hết phiên', 'Vui lòng đăng nhập lại');
        medicines.clear();
        return;
      }

      final response = await _dio.get(
        '$_baseUrl/admin/thuoc',
        options: await _jsonOptions(),
      );

      print('🔵 [THUOC] GET /admin/thuoc - Status: ${response.statusCode}');
      print('🔵 [THUOC] Response: ${response.data}');

      // Server đôi khi có thể trả về string/html khi lỗi cấu hình; handle an toàn
      final dynamic body = response.data;
      final Map<String, dynamic>? jsonBody =
          body is Map ? Map<String, dynamic>.from(body) : null;

      if (response.statusCode == 200 && (jsonBody?['success'] == true)) {
        final data = jsonBody?['data'];
        if (data is List) {
          medicines.value = data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          print('✅ [THUOC] Tải ${medicines.length} thuốc thành công');
        } else {
          print('❌ [THUOC] Dữ liệu không phải List: $data');
          Get.snackbar('Lỗi', 'Định dạng dữ liệu thuốc không hợp lệ');
        }
        return;
      }

      // Các case lỗi (401/403/500/...) hoặc success=false
      final message = (jsonBody?['message'] ??
              'Lấy danh sách thuốc thất bại (HTTP ${response.statusCode})')
          .toString();

      print('❌ [THUOC] Lỗi: $message');

      if (response.statusCode == 401 || response.statusCode == 403) {
        Get.snackbar('Không có quyền', message);
      } else {
        Get.snackbar('Lỗi', message);
      }
    } catch (e) {
      print('❌ [THUOC] Exception lấy danh sách thuốc: $e');
      Get.snackbar('Lỗi', 'Không thể lấy danh sách thuốc: $e');
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

      print('🔵 [THUOC] POST /admin/thuoc - Status: ${response.statusCode}');
      print('🔵 [THUOC] Response: ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success']) {
        await getMedicines();
        Get.snackbar('Thành công', 'Đã thêm thuốc mới');
        return true;
      } else {
        final message = response.data['message'] ?? 'Thêm thuốc thất bại';
        print('❌ [THUOC] Lỗi: $message');
        Get.snackbar('Lỗi', message);
      }
      return false;
    } catch (e) {
      print('❌ [THUOC] Exception thêm thuốc: $e');
      Get.snackbar('Lỗi', 'Không thể thêm thuốc: $e');
      return false;
    } finally {}
  }

  Future<bool> updateMedicine(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/admin/thuoc/$id',
        data: data,
        options: await _jsonOptions(),
      );

      print('🔵 [THUOC] PUT /admin/thuoc/$id - Status: ${response.statusCode}');
      print('🔵 [THUOC] Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success']) {
        await getMedicines();
        Get.snackbar('Thành công', 'Đã cập nhật thông tin thuốc');
        return true;
      } else {
        final message = response.data['message'] ?? 'Cập nhật thuốc thất bại';
        print('❌ [THUOC] Lỗi: $message');
        Get.snackbar('Lỗi', message);
      }
      return false;
    } catch (e) {
      print('❌ [THUOC] Exception cập nhật thuốc: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật thuốc: $e');
      return false;
    } finally {}
  }

  Future<bool> deleteMedicine(int id) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/admin/thuoc/$id',
        options: await _jsonOptions(),
      );

      print('🔵 [THUOC] DELETE /admin/thuoc/$id - Status: ${response.statusCode}');
      print('🔵 [THUOC] Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success']) {
        await getMedicines();
        Get.snackbar('Thành công', 'Đã xóa thuốc');
        return true;
      } else {
        final message = response.data['message'] ?? 'Xóa thuốc thất bại';
        print('❌ [THUOC] Lỗi: $message');
        Get.snackbar('Lỗi', message);
      }
      return false;
    } catch (e) {
      print('❌ [THUOC] Exception xóa thuốc: $e');
      Get.snackbar('Lỗi', 'Không thể xóa thuốc: $e');
      return false;
    } finally {}
  }
}
