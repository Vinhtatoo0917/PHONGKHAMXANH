// ignore_for_file: use_null_aware_elements

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/config/api_config.dart';
import 'package:phongkhamfy/services/session_manager.dart';
import 'package:phongkhamfy/utils/loading_utils.dart';

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

  void _patchPhieuLocally(
    int maPhieu, {
    required String newStatus,
    List<Map<String, dynamic>>? ketQuaItems,
  }) {
    final idx = myTestOrders.indexWhere((o) => o['MaPhieu'] == maPhieu);
    if (idx < 0) return;
    final updated = Map<String, dynamic>.from(myTestOrders[idx]);
    updated['TrangThai'] = newStatus;

    final original = updated['ChiTiet'];
    if (original is List) {
      final chiTietList = original.map((ct) {
        final m = Map<String, dynamic>.from(ct as Map);
        if (ketQuaItems != null) {
          final match = ketQuaItems.firstWhere(
            (kq) => kq['ma_chi_tiet_phieu'] == m['MaChiTietPhieu'],
            orElse: () => const <String, dynamic>{},
          );
          if (match.isNotEmpty) {
            m['TrangThai'] = 'completed';
            if (match['ket_qua'] != null) m['KetQua'] = match['ket_qua'];
            if (match['chi_so'] != null) m['ChiSo'] = match['chi_so'];
          }
        } else if (m['TrangThai'] == 'pending') {
          m['TrangThai'] = newStatus;
        }
        return m;
      }).toList();
      updated['ChiTiet'] = chiTietList;
    }
    myTestOrders[idx] = updated;
    myTestOrders.refresh();
  }

  void _patchLichKhamStatusLocally(int maLichKham, String newStatus) {
    bool changed = false;
    for (var i = 0; i < doctorSchedules.length; i++) {
      final schedule = Map<String, dynamic>.from(doctorSchedules[i]);
      final list = schedule['LichKham'] as List? ?? [];
      bool localChanged = false;
      final newList = list.map((lk) {
        final m = Map<String, dynamic>.from(lk as Map);
        if (m['MaLichKham'] == maLichKham) {
          m['TrangThai'] = newStatus;
          localChanged = true;
        }
        return m;
      }).toList();
      if (localChanged) {
        schedule['LichKham'] = newList;
        doctorSchedules[i] = schedule;
        changed = true;
      }
    }
    if (changed) doctorSchedules.refresh();
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
    LoadingUtils.showLoading(message: 'Đang đặt lịch khám...');
    bool success = false;
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
      selectedSchedule.value = null;
      selectedServices.clear();
      success = true;
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
      LoadingUtils.hideLoading();
    }
    if (success) {
      unawaited(getMyAppointments());
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
    LoadingUtils.showLoading(message: 'Đang hủy lịch khám...');
    bool success = false;
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
      success = true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi hủy lịch khám')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      LoadingUtils.hideLoading();
    }
    if (success) {
      unawaited(getMyAppointments());
    }
  }

  Future<void> getDoctorSchedule({
    String? ngayBatDau,
    String? ngayKetThuc,
  }) async {
    // Không dùng LoadingUtils (Get.dialog) ở đây vì:
    // 1) Màn hình đã có Obx + LoadingView để hiển thị loading.
    // 2) Get.dialog có thể gây lỗi "visitChildElements() called during build"
    //    nếu được gọi quá sớm (ví dụ trong initState).
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
    LoadingUtils.showLoading(message: 'Đang cập nhật trạng thái...');
    bool success = false;
    try {
      final response = await _dio.patch(
        '$_baseUrl/bacsi/lich-kham/$maLichKham/status',
        data: {'trang_thai': trangThai},
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        _patchLichKhamStatusLocally(maLichKham, trangThai);
        Get.snackbar(
          'Thành công',
          'Cập nhật trạng thái thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF43A047).withValues(alpha: 0.1),
        );
        success = true;
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi khi cập nhật trạng thái');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi cập nhật trạng thái')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      LoadingUtils.hideLoading();
    }
    if (success) {
      unawaited(getMyTestOrders());
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
    LoadingUtils.showLoading(message: 'Đang cập nhật trạng thái...');
    bool success = false;
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
      success = true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi cập nhật trạng thái')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      LoadingUtils.hideLoading();
    }
    if (success && refresh) {
      unawaited(getAllAppointments());
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
    LoadingUtils.showLoading(message: 'Đang lưu kết luận...');
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
      LoadingUtils.hideLoading();
    }
  }

  final testingDoctors = <Map<String, dynamic>>[].obs;
  final isLoadingTestingDoctors = false.obs;
  final isCreatingReferral = false.obs;

  final myTestOrders = <Map<String, dynamic>>[].obs;
  final isLoadingMyTestOrders = false.obs;

  Future<void> getTestingDoctors(int maLichKham) async {
    try {
      isLoadingTestingDoctors.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/testing-doctors/$maLichKham',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        testingDoctors.value = _mapList(response.data['data']);
        return;
      }
      testingDoctors.clear();
    } catch (e) {
      print('Error fetching testing doctors: $e');
      testingDoctors.clear();
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
    LoadingUtils.showLoading(message: 'Đang tạo phiếu chỉ định...');
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
      LoadingUtils.hideLoading();
    }
  }

  Future<void> getMyTestOrders({
    String? ngayBatDau,
    String? ngayKetThuc,
    String? trangThai,
  }) async {
    try {
      isLoadingMyTestOrders.value = true;
      final response = await _dio.get(
        '$_baseUrl/bacsi/phieu-chi-dinh-cua-toi',
        queryParameters: {
          if (ngayBatDau != null) 'ngay_bat_dau': ngayBatDau,
          if (ngayKetThuc != null) 'ngay_ket_thuc': ngayKetThuc,
          if (trangThai != null) 'trang_thai': trangThai,
        },
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        myTestOrders.value = _mapList(response.data['data']);
        return;
      }
      throw Exception(response.data['message'] ?? 'Lỗi khi lấy phiếu chỉ định');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lấy phiếu chỉ định')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMyTestOrders.value = false;
    }
  }

  Future<bool> tiepNhanPhieuChiDinh(int maPhieu) async {
    LoadingUtils.showLoading(message: 'Đang tiếp nhận phiếu...');
    bool success = false;
    try {
      final response = await _dio.patch(
        '$_baseUrl/bacsi/phieu-chi-dinh/$maPhieu/tiep-nhan',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        _patchPhieuLocally(maPhieu, newStatus: 'processing');
        Get.snackbar(
          'Thành công',
          'Đã tiếp nhận phiếu chỉ định',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF43A047).withValues(alpha: 0.1),
        );
        success = true;
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi khi tiếp nhận phiếu');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi tiếp nhận phiếu')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      LoadingUtils.hideLoading();
    }
    if (success) {
      unawaited(getMyTestOrders());
    }
    return success;
  }

  Future<bool> hoanTatPhieuChiDinh({
    required int maPhieu,
    required List<Map<String, dynamic>> ketQua,
  }) async {
    LoadingUtils.showLoading(message: 'Đang lưu kết quả xét nghiệm...');
    bool success = false;
    try {
      final response = await _dio.post(
        '$_baseUrl/bacsi/phieu-chi-dinh/$maPhieu/hoan-tat',
        data: {'ket_qua': ketQua},
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        _patchPhieuLocally(maPhieu, newStatus: 'completed', ketQuaItems: ketQua);
        Get.snackbar(
          'Thành công',
          'Đã hoàn tất xét nghiệm và lưu kết quả',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF43A047).withValues(alpha: 0.1),
        );
        success = true;
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi khi lưu kết quả');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi khi lưu kết quả')),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      LoadingUtils.hideLoading();
    }
    if (success) {
      unawaited(getMyTestOrders());
    }
    return success;
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ CHECK-IN (NHÂN VIÊN TIẾP ĐÓN)
  // ═══════════════════════════════════════════════════════════════

  final todayAppointments = <Map<String, dynamic>>[].obs;
  final isLoadingTodayAppointments = false.obs;

  /// Lấy danh sách lịch khám hôm nay
  /// GET /admin/lich-kham-hom-nay
  Future<void> getTodayAppointments({String search = '', String filter = 'all'}) async {
    isLoadingTodayAppointments.value = true;
    try {
      var url = '$_baseUrl/admin/lich-kham-hom-nay';
      final params = <String>[];

      if (search.isNotEmpty) {
        params.add('search=$search');
      }
      if (filter.isNotEmpty && filter != 'all') {
        params.add('filter=$filter');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await _dio.get(
        url,
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        todayAppointments.value = _mapList(response.data['data']);
      }
    } catch (e) {
      print('❌ Lỗi lấy lịch khám hôm nay: $e');
    } finally {
      isLoadingTodayAppointments.value = false;
    }
  }

  /// Check-in bệnh nhân
  /// POST /admin/lich-kham/{maLichKham}/check-in
  Future<bool> checkInAppointment(int maLichKham) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/admin/lich-kham/$maLichKham/check-in',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        Get.snackbar(
          'Thành công',
          'Check-in bệnh nhân thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF6BA583).withValues(alpha: 0.1),
        );
        await getTodayAppointments();
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi check-in');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi check-in bệnh nhân')),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Check-out bệnh nhân
  /// PATCH /admin/lich-kham/{maLichKham}/check-out
  Future<bool> checkOutAppointment(int maLichKham) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/admin/lich-kham/$maLichKham/check-out',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        Get.snackbar(
          'Thành công',
          'Check-out bệnh nhân thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF6BA583).withValues(alpha: 0.1),
        );
        await getTodayAppointments();
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi check-out');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi check-out bệnh nhân')),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> acceptPatient(int maLichKham) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/bacsi/lich-kham/$maLichKham/tiep-nhan',
        data: {'accept': true},
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        Get.snackbar(
          'Thành công',
          'Tiếp nhận bệnh nhân thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF6BA583).withValues(alpha: 0.1),
        );
        // Refresh doctor schedule to get updated ThoiDiemCheckIn
        await getDoctorSchedule(
          ngayBatDau: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ngayKetThuc: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi tiếp nhận');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Lỗi tiếp nhận bệnh nhân')),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<String?> getTiepNhanStatus(int maLichKham) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/bacsi/lich-kham/$maLichKham/tiep-nhan-status',
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data']['TrangThaiTiepNhan'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> createVNPayPayment(String maHoaDon, double soTien) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/vnpay/create-payment',
        data: {
          'maHoaDon': maHoaDon,
          'soTien': soTien,
        },
        options: await _jsonOptions(),
      );

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data']['payment_url'] as String?;
      }
      throw Exception(response.data['message'] ?? 'Lỗi tạo link thanh toán');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        _message(_friendlyError(e, 'Không thể tạo link thanh toán')),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
