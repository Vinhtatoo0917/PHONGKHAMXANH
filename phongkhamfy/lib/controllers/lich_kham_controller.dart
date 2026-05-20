// ignore_for_file: use_null_aware_elements

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:phongkhamfy/services/session_manager.dart';

class LichKhamController extends GetxController {
  final Dio _dio = Dio();
  final String _baseUrl = ApiConfig.baseUrl;

  final availableSchedules = <Map<String, dynamic>>[].obs;
  final isLoadingSchedules = false.obs;

  final myAppointments = <Map<String, dynamic>>[].obs;
  final isLoadingMyAppointments = false.obs;

  final doctorSchedules = <Map<String, dynamic>>[].obs;
  final isLoadingDoctorSchedule = false.obs;

  final allAppointments = <Map<String, dynamic>>[].obs;
  final isLoadingAllAppointments = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;

  final isBooking = false.obs;
  final selectedSchedule = Rxn<Map<String, dynamic>>();
  final selectedServices = <int>[].obs;
  final availableServices = <Map<String, dynamic>>[].obs;
  final isLoadingServices = false.obs;
  
  final diseases = <Map<String, dynamic>>[].obs;
  final isLoadingDiseases = false.obs;
  final medicines = <Map<String, dynamic>>[].obs;
  final isLoadingMedicines = false.obs;
  final isSubmittingConclusion = false.obs;

  Future<Options> _jsonOptions() async {
    final token = await SessionManager.getTokenStatic();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Exception _friendlyError(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return Exception(data['message'].toString());
      }
      if (error.response?.statusCode == 401) {
        return Exception(
          'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.',
        );
      }
      if (error.response?.statusCode == 422) {
        return Exception(fallback);
      }
      return Exception(error.message ?? fallback);
    }

    return Exception(error.toString().replaceFirst('Exception: ', ''));
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  Future<void> getAvailableSchedules({
    required String ngayBatDau,
    required String ngayKetThuc,
    String? maKhoa,
  }) async {
    try {
      isLoadingSchedules.value = true;
      final response = await _dio.get(
        '$_baseUrl/lich-kham/available',
        queryParameters: {
          'ngay_bat_dau': ngayBatDau,
          'ngay_ket_thuc': ngayKetThuc,
          if (maKhoa != null) 'ma_khoa': maKhoa,
        },
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        availableSchedules.value = _mapList(response.data['data']);
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lấy lịch khám')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  Future<void> bookAppointment({
    int? maBenhNhan,
    required int maLichLamViec,
    required List<int> dichVuIds,
  }) async {
    try {
      isBooking.value = true;
      final response = await _dio.post(
        '$_baseUrl/lich-kham/book',
        data: {
          if (maBenhNhan != null) 'ma_benh_nhan': maBenhNhan,
          'ma_lich_lam_viec': maLichLamViec,
          'dich_vu_ids': dichVuIds,
        },
        options: await _jsonOptions(),
      );

      if (!(response.statusCode == 200 && response.data['success'])) {
        throw Exception(response.data['message'] ?? 'Lỗi khi đặt lịch khám');
      }

      Get.snackbar(
        'Thành công',
        'Đặt lịch khám thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      await getMyAppointments();
      selectedSchedule.value = null;
      selectedServices.clear();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(
          _friendlyError(
            e,
            'Không thể đặt lịch khám. Vui lòng kiểm tra lại thông tin.',
          ),
        ),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> getServices({int? maKhoa}) async {
    try {
      isLoadingServices.value = true;
      final response = await _dio.get(
        '$_baseUrl/admin/dich-vu',
        queryParameters: {if (maKhoa != null) 'MaKhoa': maKhoa},
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        availableServices.value = _mapList(response.data['data']);
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy dịch vụ');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lấy dịch vụ')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> getMyAppointments() async {
    try {
      isLoadingMyAppointments.value = true;
      final response = await _dio.get(
        '$_baseUrl/lich-kham/my-appointments',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        myAppointments.value = _mapList(response.data['data']);
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lấy lịch khám')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMyAppointments.value = false;
    }
  }

  Future<void> cancelAppointment(int maLichKham) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/lich-kham/$maLichKham/cancel',
        options: await _jsonOptions(),
      );

      if (!(response.statusCode == 200 && response.data['success'])) {
        throw Exception(response.data['message'] ?? 'Lỗi khi hủy lịch khám');
      }

      Get.snackbar(
        'Thành công',
        'Hủy lịch khám thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      await getMyAppointments();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi hủy lịch khám')),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getDoctorSchedule({
    String? ngayBatDau,
    String? ngayKetThuc,
  }) async {
    try {
      isLoadingDoctorSchedule.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/lich-kham',
        queryParameters: {
          if (ngayBatDau != null) 'ngay_bat_dau': ngayBatDau,
          if (ngayKetThuc != null) 'ngay_ket_thuc': ngayKetThuc,
        },
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        doctorSchedules.value = _mapList(response.data['data']);
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lấy lịch khám')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDoctorSchedule.value = false;
    }
  }

  Future<void> updateAppointmentStatusByDoctor(int maLichKham, String trangThai) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/bacsi/lich-kham/$maLichKham/status',
        data: {'trang_thai': trangThai},
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        Get.snackbar(
          'Thành công',
          'Cập nhật trạng thái thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF43A047).withValues(alpha: 0.1),
        );
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi cập nhật trạng thái');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi cập nhật trạng thái')),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getAllAppointments({
    String? trangThai,
    String? ngayBatDau,
    String? ngayKetThuc,
    int? maBacSi,
    int page = 1,
  }) async {
    try {
      isLoadingAllAppointments.value = true;
      final response = await _dio.get(
        '$_baseUrl/admin/lich-kham',
        queryParameters: {
          if (trangThai != null) 'trang_thai': trangThai,
          if (ngayBatDau != null) 'ngay_bat_dau': ngayBatDau,
          if (ngayKetThuc != null) 'ngay_ket_thuc': ngayKetThuc,
          if (maBacSi != null) 'ma_bac_si': maBacSi,
          'page': page,
          'per_page': 15,
        },
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        allAppointments.value = _mapList(response.data['data']);
        final pagination = response.data['pagination'];
        currentPage.value = pagination['current_page'] ?? 1;
        totalPages.value = pagination['last_page'] ?? 1;
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy lịch khám');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lấy lịch khám')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingAllAppointments.value = false;
    }
  }

  Future<void> updateAppointmentStatus({
    required int maLichKham,
    required String trangThai,
    String? trangThaiThanhToan,
    String? lyDoTuChoi,
    bool refresh = true,
  }) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/admin/lich-kham/$maLichKham/status',
        data: {
          'trang_thai': trangThai,
          if (trangThaiThanhToan != null)
            'trang_thai_thanh_toan': trangThaiThanhToan,
          if (lyDoTuChoi != null) 'ly_do_tu_choi': lyDoTuChoi,
        },
        options: await _jsonOptions(),
      );

      if (!(response.statusCode == 200 && response.data['success'])) {
        throw Exception(
          response.data['message'] ?? 'Lỗi khi cập nhật trạng thái',
        );
      }

      Get.snackbar(
        'Thành công',
        'Cập nhật trạng thái thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (refresh) {
        await getAllAppointments();
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi cập nhật trạng thái')),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void selectSchedule(Map<String, dynamic> schedule) {
    selectedSchedule.value = schedule;
  }

  void toggleService(int serviceId) {
    if (selectedServices.contains(serviceId)) {
      selectedServices.remove(serviceId);
    } else {
      selectedServices.add(serviceId);
    }
  }

  void clearSelection() {
    selectedSchedule.value = null;
    selectedServices.clear();
  }

  Future<void> getDiseases() async {
    try {
      isLoadingDiseases.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/benh',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        diseases.value = _mapList(response.data['data']);
        return;
      }
    } catch (e) {
      print('Error fetching diseases: $e');
    } finally {
      isLoadingDiseases.value = false;
    }
  }
  Future<void> getServicesByBenh(String maBenh) async {
    try {
      isLoadingServices.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/benh/$maBenh/dich-vu',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        availableServices.value = _mapList(response.data['data']);
        return;
      }
    } catch (e) {
      print('Error fetching services by benh: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> getMedicinesForDoctor() async {
    try {
      isLoadingMedicines.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/thuoc',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        medicines.value = _mapList(response.data['data']);
        return;
      }
    } catch (e) {
      print('Error fetching medicines: $e');
    } finally {
      isLoadingMedicines.value = false;
    }
  }

  Future<bool> submitConclusion({
    required int maLichKham,
    required String maBenh,
    required String chanDoan,
    required String tinhTrang,
    required String huongDieuTri,
    List<Map<String, dynamic>>? donThuoc,
  }) async {
    try {
      isSubmittingConclusion.value = true;
      final response = await _dio.post(
        '$_baseUrl/bacsi/ket-luan',
        data: {
          'ma_lich_kham': maLichKham,
          'ma_benh': maBenh,
          'chan_doan': chanDoan,
          'tinh_trang': tinhTrang,
          'huong_dieu_tri': huongDieuTri,
          if (donThuoc != null) 'don_thuoc': donThuoc,
        },
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        Get.snackbar(
          'Thành công',
          'Đã hoàn tất kết luận khám và kê đơn',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF43A047).withValues(alpha: 0.1),
        );
        return true;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lưu kết luận');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lưu kết luận')),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingConclusion.value = false;
    }
  }

  final testingDoctors = <Map<String, dynamic>>[].obs;
  final isLoadingTestingDoctors = false.obs;
  final isCreatingReferral = false.obs;

  Future<void> getTestingDoctors() async {
    try {
      isLoadingTestingDoctors.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/testing-doctors',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        testingDoctors.value = _mapList(response.data['data']);
        return;
      }
    } catch (e) {
      print('Error fetching testing doctors: $e');
    } finally {
      isLoadingTestingDoctors.value = false;
    }
  }

  Future<void> getAllServicesForDoctor() async {
    try {
      isLoadingServices.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/all-services',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        availableServices.value = _mapList(response.data['data']);
        return;
      }
    } catch (e) {
      print('Error fetching all services: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<bool> createReferral({
    required int maLichKham,
    required int maBacSiThucHien,
    String? ghiChu,
    required List<int> maDichVuIds,
  }) async {
    try {
      isCreatingReferral.value = true;
      final response = await _dio.post(
        '$_baseUrl/bacsi/tao-phieu-chi-dinh',
        data: {
          'ma_lich_kham': maLichKham,
          'ma_bac_si_thuc_hien': maBacSiThucHien,
          'ghi_chu': ghiChu,
          'dich_vu': maDichVuIds.map((id) => {'ma_dich_vu': id}).toList(),
        },
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        Get.snackbar(
          'Thành công',
          'Đã tạo phiếu chỉ định dịch vụ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF43A047).withValues(alpha: 0.1),
        );
        return true;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi tạo phiếu chỉ định');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi tạo phiếu chỉ định')),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCreatingReferral.value = false;
    }
  }
}
