// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phongkhamfy/controllers/lich_kham_controller.dart';
import 'package:phongkhamfy/widgets/loading_view.dart';
import 'package:phongkhamfy/theme/app_theme.dart';

extension _LichKhamMap on Map<String, dynamic> {
  int? get maLichLamViec => _toInt(this['MaLichLamViec']);
  int? get maDichVu => _toInt(this['MaDichVu']);
  int? get maKhoa => _toInt(this['MaKhoa']);
  int? get soChoTrong => _toInt(this['SoChoTrong']);
  int? get soLuongToiDa => _toInt(this['SoLuongToiDa']);
  double? get gia => _toDouble(this['Gia']);
  String? get ngay => this['Ngay']?.toString();
  String? get tenCa => this['TenCa']?.toString();
  String? get gioBatDau => this['GioBatDau']?.toString();
  String? get gioKetThuc => this['GioKetThuc']?.toString();
  String? get tenBacSi => this['TenBacSi']?.toString();
  String? get tenKhoa => this['TenKhoa']?.toString();
  String? get chuyenKhoa => this['ChuyenKhoa']?.toString();
  String? get tenPhong => this['TenPhong']?.toString();
  String? get tenDichVu => this['TenDichVu']?.toString();

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class DatLichKhamView extends StatefulWidget {
  const DatLichKhamView({super.key});

  @override
  State<DatLichKhamView> createState() => _DatLichKhamViewState();
}

class _DatLichKhamViewState extends State<DatLichKhamView> {
final LichKhamController _controller = Get.put(LichKhamController());
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _dayFormat = DateFormat('dd/MM');
  late final List<DateTime> _days;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDay = DateTime(today.year, today.month, today.day);
    _days = List.generate(
      14,
      (index) => _selectedDay.add(Duration(days: index)),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.getServices();

    final maKhoa = _selectedMaKhoa;
    if (maKhoa != null) {
      await _loadSchedulesForService(maKhoa);
    } else {
      _controller.availableSchedules.clear();
    }
  }

  List<Map<String, dynamic>> _schedulesForSelectedDay() {
    final selected = _apiDateFormat.format(_selectedDay);
    return _controller.availableSchedules
        .where((schedule) => schedule.ngay == selected)
        .toList();
  }

  List<Map<String, dynamic>> get _selectedServiceModels {
    return _controller.availableServices
        .where(
          (service) =>
              service.maDichVu != null &&
              _controller.selectedServices.contains(service.maDichVu),
        )
        .toList();
  }

  Map<String, dynamic>? get _selectedPrimaryService {
    final selectedServices = _selectedServiceModels;
    return selectedServices.isEmpty ? null : selectedServices.first;
  }

  int? get _selectedMaKhoa => _selectedPrimaryService?.maKhoa;

  double get _totalPrice {
    return _selectedServiceModels.fold(
      0,
      (sum, service) => sum + (service.gia ?? 0),
    );
  }

  Future<void> _loadSchedulesForService(int maKhoa) {
    return _controller.getAvailableSchedules(
      ngayBatDau: _apiDateFormat.format(_days.first),
      ngayKetThuc: _apiDateFormat.format(_days.last),
      maKhoa: maKhoa.toString(),
    );
  }

  Future<void> _confirmBooking() async {
    final schedule = _controller.selectedSchedule.value;
    final maLichLamViec = schedule?.maLichLamViec;
    if (schedule == null || maLichLamViec == null) return;

    final accepted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        schedule: schedule,
        services: _selectedServiceModels,
        totalPrice: _totalPrice,
        displayDate: _formatFullDate(schedule.ngay),
      ),
    );

    if (accepted != true) return;

    await _controller.bookAppointment(
      maLichLamViec: maLichLamViec,
      dichVuIds: _controller.selectedServices.toList(),
    );

    if (!mounted) return;
    await _loadData();
  }

  String _formatFullDate(String? rawDate) {
    final date = DateTime.tryParse(rawDate ?? '');
    if (date == null) return rawDate ?? 'Chưa có ngày';
    return '${_weekdayName(date)}, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  String _weekdayName(DateTime date) {
    const weekdays = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật',
    ];
    return weekdays[date.weekday - 1];
  }

  String _shortWeekdayName(DateTime date) {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return weekdays[date.weekday - 1];
  }

  String _formatMoney(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '--:--';
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  Future<void> _selectSchedule(Map<String, dynamic> schedule) async {
    _controller.selectSchedule(schedule);
  }

  Future<void> _selectService(Map<String, dynamic> service) async {
    final serviceId = service.maDichVu;
    final maKhoa = service.maKhoa;
    if (serviceId == null) return;

    final isSelected = _controller.selectedServices.contains(serviceId);
    if (isSelected) {
      _controller.selectedServices.remove(serviceId);
    } else {
      _controller.selectedServices.clear();
      _controller.selectedServices.add(serviceId);
    }

    _controller.selectedSchedule.value = null;
    _controller.availableSchedules.clear();

    if (!isSelected && maKhoa != null) {
      await _loadSchedulesForService(maKhoa);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(
        title: 'Đặt lịch khám',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildSectionTitle('Dịch vụ cần khám')),
              Obx(() => _buildServiceList()),
              SliverToBoxAdapter(child: _buildDateStrip()),
              SliverToBoxAdapter(
                child: _buildSectionTitle('Suất khám phù hợp'),
              ),
              Obx(() => _buildScheduleList()),
              const SliverToBoxAdapter(child: SizedBox(height: 112)),
            ],
          ),
        ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDateStrip() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
      child: SizedBox(
        height: 74,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final day = _days[index];
            final selected = DateUtils.isSameDay(day, _selectedDay);
            final isToday = index == 0;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDay = day);
                _controller.selectedSchedule.value = null;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 68,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.separator),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isToday ? 'Hôm nay' : _shortWeekdayName(day),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.subLabel,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dayFormat.format(day),
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.label,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.label,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _separatedSliver({
    required int itemCount,
    required double gap,
    required Widget Function(BuildContext context, int index) itemBuilder,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index.isOdd) return SizedBox(height: gap);
        return itemBuilder(context, index ~/ 2);
      }, childCount: math.max(0, itemCount * 2 - 1)),
    );
  }

  Widget _buildScheduleList() {
    if (_controller.selectedServices.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyState(
          icon: Icons.medical_services_outlined,
          title: 'Chọn dịch vụ trước',
          message:
              'Sau khi chọn dịch vụ, hệ thống sẽ hiển thị bác sĩ và suất khám đúng chuyên khoa.',
        ),
      );
    }

    if (_controller.isLoadingSchedules.value) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: LoadingView(
            message: 'Đang tìm suất khám...',
            isOverlay: false,
          ),
        ),
      );
    }

    final schedules = _schedulesForSelectedDay();
    if (schedules.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'Chưa có suất khám trống',
          message:
              'Bạn thử chọn ngày khác hoặc kéo xuống để tải lại lịch cho dịch vụ đã chọn.',
        ),
      );
    }

    return _separatedSliver(
      itemCount: schedules.length,
      gap: 12,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final selected =
            _controller.selectedSchedule.value?.maLichLamViec ==
            schedule.maLichLamViec;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ScheduleCard(
            schedule: schedule,
            selected: selected,
            dateText: _formatFullDate(schedule.ngay),
            formatTime: _formatTime,
            onTap: () => _selectSchedule(schedule),
          ),
        );
      },
    );
  }

  Widget _buildServiceList() {
    if (_controller.isLoadingServices.value) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 240,
          child: LoadingView(
            message: 'Đang tải danh sách dịch vụ...',
            isOverlay: false,
          ),
        ),
      );
    }

    final services = _controller.availableServices;

    if (services.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyState(
          icon: Icons.medical_services_outlined,
          title: 'Chưa có dịch vụ',
          message:
              'Kéo xuống để tải lại hoặc quay lại sau khi phòng khám cập nhật dịch vụ.',
        ),
      );
    }

    return _separatedSliver(
      itemCount: services.length,
      gap: 10,
      itemBuilder: (context, index) {
        final service = services[index];
        final serviceId = service.maDichVu;
        final selected =
            serviceId != null &&
            _controller.selectedServices.contains(serviceId);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ServiceTile(
            service: service,
            selected: selected,
            priceText: _formatMoney(service.gia ?? 0),
            onTap: serviceId == null ? null : () => _selectService(service),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final selectedSchedule = _controller.selectedSchedule.value;
      final canBook =
          _controller.selectedServices.isNotEmpty &&
          selectedSchedule?.maLichLamViec != null &&
          !_controller.isBooking.value;
      final selectedService = _selectedPrimaryService;

      return Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          math.max(MediaQuery.of(context).padding.bottom, 12),
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.separator)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedService == null
                        ? 'Chưa chọn dịch vụ'
                        : selectedSchedule == null
                        ? selectedService.tenDichVu ?? 'Dịch vụ đã chọn'
                        : '${_formatTime(selectedSchedule.gioBatDau)} • ${selectedSchedule.tenCa ?? 'Ca khám'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.label,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selectedService == null
                        ? 'Chọn dịch vụ để xem bác sĩ phù hợp'
                        : selectedSchedule == null
                        ? 'Tiếp theo chọn ngày và bác sĩ'
                        : '${_controller.selectedServices.length} dịch vụ • ${_formatMoney(_totalPrice)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.subLabel, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: canBook ? _confirmBooking : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.separator,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                icon: _controller.isBooking.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  _controller.isBooking.value ? 'Đang đặt' : 'Đặt lịch',
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final bool selected;
  final String dateText;
  final String Function(String?) formatTime;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.schedule,
    required this.selected,
    required this.dateText,
    required this.formatTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.separator,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_search_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.tenBacSi ?? 'Bác sĩ chưa cập nhật',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.label,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.tenKhoa ??
                            schedule.chuyenKhoa ??
                            'Chuyên khoa chưa cập nhật',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.subLabel,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? AppColors.primary
                      : AppColors.subLabel,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.calendar_today_rounded,
                  text: dateText,
                  color: AppColors.primary,
                ),
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  text:
                      '${formatTime(schedule.gioBatDau)} - ${formatTime(schedule.gioKetThuc)}',
                  color: AppColors.accent,
                ),
                _InfoPill(
                  icon: Icons.meeting_room_rounded,
                  text: schedule.tenPhong ?? 'Phòng khám',
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.group_rounded,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  'Còn ${schedule.soChoTrong ?? 0}/${schedule.soLuongToiDa ?? 0} chỗ',
                  style: const TextStyle(
                    color: AppColors.label,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool selected;
  final String priceText;
  final VoidCallback? onTap;

  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.separator,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryBg
                    : AppColors.fill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.medical_services_rounded,
                color: selected
                    ? AppColors.accent
                    : AppColors.subLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.tenDichVu ?? 'Dịch vụ khám',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.label,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceText,
                    style: const TextStyle(
                      color: AppColors.subLabel,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              color: selected
                  ? AppColors.accent
                  : AppColors.subLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final List<Map<String, dynamic>> services;
  final double totalPrice;
  final String displayDate;

  const _ConfirmSheet({
    required this.schedule,
    required this.services,
    required this.totalPrice,
    required this.displayDate,
  });

  String _formatMoney(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);
  }

  String _time(String? value) {
    if (value == null || value.isEmpty) return '--:--';
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        math.max(MediaQuery.of(context).padding.bottom, 16),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.separator,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Xác nhận lịch khám',
            style: TextStyle(
              color: AppColors.label,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.person_rounded,
            text: schedule.tenBacSi ?? 'Bác sĩ',
          ),
          _SummaryRow(icon: Icons.calendar_month_rounded, text: displayDate),
          _SummaryRow(
            icon: Icons.schedule_rounded,
            text:
                '${schedule.tenCa ?? 'Ca khám'} • ${_time(schedule.gioBatDau)} - ${_time(schedule.gioKetThuc)}',
          ),
          _SummaryRow(
            icon: Icons.meeting_room_rounded,
            text: schedule.tenPhong ?? 'Phòng khám',
          ),
          const Divider(height: 26),
          Text(
            services.isEmpty ? 'Chưa chọn dịch vụ' : 'Dịch vụ đã chọn',
            style: const TextStyle(
              color: AppColors.label,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (services.isEmpty)
            const Text(
              'Bạn có thể bổ sung dịch vụ tại quầy tiếp nhận.',
              style: TextStyle(color: AppColors.subLabel),
            )
          else
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service.tenDichVu ?? 'Dịch vụ khám',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.label,
                        ),
                      ),
                    ),
                    Text(
                      _formatMoney(service.gia ?? 0),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text(
                  'Tạm tính',
                  style: TextStyle(
                    color: AppColors.subLabel,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatMoney(totalPrice),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Xác nhận đặt lịch'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.separator),
      ),
      child: Column(
        children: [
          Icon(icon, size: 46, color: AppColors.subLabel),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.subLabel,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;

  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
