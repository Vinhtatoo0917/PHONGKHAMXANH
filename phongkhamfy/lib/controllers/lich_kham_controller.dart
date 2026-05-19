import 'package:get/get.dart';
import 'package:phongkhamfy/models/lich_kham_model.dart';
import 'package:phongkhamfy/services/lich_kham_service.dart';

class LichKhamController extends GetxController {
  final LichKhamService _service = LichKhamService();

  // Available schedules
  final availableSchedules = <LichLamViecModel>[].obs;
  final isLoadingSchedules = false.obs;

  // My appointments
  final myAppointments = <LichKhamModel>[].obs;
  final isLoadingMyAppointments = false.obs;

  // Doctor schedule
  final doctorSchedules = <Map<String, dynamic>>[].obs;
  final isLoadingDoctorSchedule = false.obs;

  // All appointments (admin)
  final allAppointments = <dynamic>[].obs;
  final isLoadingAllAppointments = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;

  // Booking
  final isBooking = false.obs;
  final selectedSchedule = Rxn<LichLamViecModel>();
  final selectedServices = <int>[].obs;

  Future<void> getAvailableSchedules({
    required String ngayBatDau,
    required String ngayKetThuc,
    String? maKhoa,
  }) async {
    try {
      isLoadingSchedules.value = true;
      final schedules = await _service.getAvailableSchedules(
        ngayBatDau: ngayBatDau,
        ngayKetThuc: ngayKetThuc,
        maKhoa: maKhoa,
      );
      availableSchedules.value = schedules;
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  Future<void> bookAppointment({
    required int maBenhNhan,
    required int maLichLamViec,
    required List<int> dichVuIds,
  }) async {
    try {
      isBooking.value = true;
      await _service.bookAppointment(
        maBenhNhan: maBenhNhan,
        maLichLamViec: maLichLamViec,
        dichVuIds: dichVuIds,
      );
      Get.snackbar(
        'Thành công',
        'Đặt lịch khám thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      await getMyAppointments();
      selectedSchedule.value = null;
      selectedServices.clear();
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> getMyAppointments() async {
    try {
      isLoadingMyAppointments.value = true;
      final appointments = await _service.getMyAppointments();
      myAppointments.value = appointments;
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingMyAppointments.value = false;
    }
  }

  Future<void> cancelAppointment(int maLichKham) async {
    try {
      await _service.cancelAppointment(maLichKham);
      Get.snackbar(
        'Thành công',
        'Hủy lịch khám thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      await getMyAppointments();
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> getDoctorSchedule({
    String? ngayBatDau,
    String? ngayKetThuc,
  }) async {
    try {
      isLoadingDoctorSchedule.value = true;
      final schedules = await _service.getDoctorSchedule(
        ngayBatDau: ngayBatDau,
        ngayKetThuc: ngayKetThuc,
      );
      doctorSchedules.value = schedules;
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingDoctorSchedule.value = false;
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
      final result = await _service.getAllAppointments(
        trangThai: trangThai,
        ngayBatDau: ngayBatDau,
        ngayKetThuc: ngayKetThuc,
        maBacSi: maBacSi,
        page: page,
      );
      allAppointments.value = result['data'];
      currentPage.value = result['pagination']['current_page'];
      totalPages.value = result['pagination']['last_page'];
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingAllAppointments.value = false;
    }
  }

  Future<void> updateAppointmentStatus({
    required int maLichKham,
    required String trangThai,
    String? trangThaiThanhToan,
  }) async {
    try {
      await _service.updateAppointmentStatus(
        maLichKham: maLichKham,
        trangThai: trangThai,
        trangThaiThanhToan: trangThaiThanhToan,
      );
      Get.snackbar(
        'Thành công',
        'Cập nhật trạng thái thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      await getAllAppointments();
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void selectSchedule(LichLamViecModel schedule) {
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
}
