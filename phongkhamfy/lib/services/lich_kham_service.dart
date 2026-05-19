import 'package:dio/dio.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:phongkhamfy/models/lich_kham_model.dart';
import 'package:phongkhamfy/services/session_manager.dart';

class LichKhamService {
  final Dio _dio = Dio();
  final String _baseUrl = ApiConfig.baseUrl;

  Future<List<LichLamViecModel>> getAvailableSchedules({
    required String ngayBatDau,
    required String ngayKetThuc,
    String? maKhoa,
  }) async {
    try {
      final token = await SessionManager.getTokenStatic();
      final response = await _dio.get(
        '$_baseUrl/lich-kham/available',
        queryParameters: {
          'ngay_bat_dau': ngayBatDau,
          'ngay_ket_thuc': ngayKetThuc,
          if (maKhoa != null) 'ma_khoa': maKhoa,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => LichLamViecModel.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<LichKhamModel> bookAppointment({
    required int maBenhNhan,
    required int maLichLamViec,
    required List<int> dichVuIds,
  }) async {
    try {
      final token = await SessionManager.getTokenStatic();
      final response = await _dio.post(
        '$_baseUrl/lich-kham/book',
        data: {
          'ma_benh_nhan': maBenhNhan,
          'ma_lich_lam_viec': maLichLamViec,
          'dich_vu_ids': dichVuIds,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        return LichKhamModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi đặt lịch khám');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<List<LichKhamModel>> getMyAppointments() async {
    try {
      final token = await SessionManager.getTokenStatic();
      final response = await _dio.get(
        '$_baseUrl/lich-kham/my-appointments',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => LichKhamModel.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<void> cancelAppointment(int maLichKham) async {
    try {
      final token = await SessionManager.getTokenStatic();
      final response = await _dio.delete(
        '$_baseUrl/lich-kham/$maLichKham/cancel',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (!(response.statusCode == 200 && response.data['success'])) {
        throw Exception(response.data['message'] ?? 'Lỗi khi hủy lịch khám');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDoctorSchedule({
    String? ngayBatDau,
    String? ngayKetThuc,
  }) async {
    try {
      final token = await SessionManager.getTokenStatic();
      final response = await _dio.get(
        '$_baseUrl/lich-kham/doctor-schedule',
        queryParameters: {
          if (ngayBatDau != null) 'ngay_bat_dau': ngayBatDau,
          if (ngayKetThuc != null) 'ngay_ket_thuc': ngayKetThuc,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'];
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<Map<String, dynamic>> getAllAppointments({
    String? trangThai,
    String? ngayBatDau,
    String? ngayKetThuc,
    int? maBacSi,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final token = await SessionManager.getTokenStatic();
      final response = await _dio.get(
        '$_baseUrl/admin/lich-kham',
        queryParameters: {
          if (trangThai != null) 'trang_thai': trangThai,
          if (ngayBatDau != null) 'ngay_bat_dau': ngayBatDau,
          if (ngayKetThuc != null) 'ngay_ket_thuc': ngayKetThuc,
          if (maBacSi != null) 'ma_bac_si': maBacSi,
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        return {
          'data': response.data['data'],
          'pagination': response.data['pagination'],
        };
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<void> updateAppointmentStatus({
    required int maLichKham,
    required String trangThai,
    String? trangThaiThanhToan,
  }) async {
    try {
      final token = await SessionManager.getTokenStatic();
      final response = await _dio.patch(
        '$_baseUrl/admin/lich-kham/$maLichKham/status',
        data: {
          'trang_thai': trangThai,
          if (trangThaiThanhToan != null)
            'trang_thai_thanh_toan': trangThaiThanhToan,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (!(response.statusCode == 200 && response.data['success'])) {
        throw Exception(
          response.data['message'] ?? 'Lỗi khi cập nhật trạng thái',
        );
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}
