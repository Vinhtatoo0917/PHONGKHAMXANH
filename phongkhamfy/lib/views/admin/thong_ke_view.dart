import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/session_manager.dart';
import '../../theme/app_theme.dart';

class ThongKeView extends StatefulWidget {
  const ThongKeView({super.key});

  @override
  State<ThongKeView> createState() => _ThongKeViewState();
}

class _ThongKeViewState extends State<ThongKeView> {
  final _sessionManager = SessionManager();

  // Khoảng thời gian
  DateTime _from = DateTime.now().copyWith(day: 1);
  DateTime _to   = DateTime.now();

  // Data
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  // Selected preset
  int _selectedPreset = 1; // 0=7 ngày, 1=tháng này, 2=3 tháng

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final token = await _sessionManager.getToken();
      final from = DateFormat('yyyy-MM-dd').format(_from);
      final to   = DateFormat('yyyy-MM-dd').format(_to);
      final url  = '${ApiConfig.baseUrl}/admin/statistics?from=$from&to=$to';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          setState(() { _data = body['data']; _isLoading = false; });
          return;
        }
      }
      setState(() { _error = 'Không tải được dữ liệu'; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Lỗi kết nối: $e'; _isLoading = false; });
    }
  }

  void _setPreset(int index) {
    setState(() { _selectedPreset = index; });
    final now = DateTime.now();
    switch (index) {
      case 0: _from = now.subtract(const Duration(days: 6)); _to = now;
      case 1: _from = DateTime(now.year, now.month, 1);       _to = now;
      case 2: _from = DateTime(now.year, now.month - 2, 1);   _to = now;
    }
    _loadData();
  }

  String _formatCurrency(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}T';
    if (value >= 1000000)    return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000)       return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: iosAppBar(title: 'Thống Kê & Báo Cáo'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildBody(),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline_rounded, size: 56, color: AppColors.danger.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        Text(_error!, style: TextStyle(color: AppColors.subLabel)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Thử lại'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ],
    ),
  );

  Widget _buildBody() {
    final overview   = _data!['overview']   as Map<String, dynamic>;
    final byStatus   = _data!['appointmentsByStatus'] as Map<String, dynamic>;
    final revenueDay = (_data!['revenueByDay'] as List).cast<Map<String, dynamic>>();
    final topDoctors = (_data!['topDoctors']   as List).cast<Map<String, dynamic>>();
    final bySpecialty= (_data!['bySpecialty']  as List).cast<Map<String, dynamic>>();
    final gender     = _data!['genderStats']   as Map<String, dynamic>;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bộ lọc thời gian ─────────────────────────────────
            _buildPeriodFilter(),
            const SizedBox(height: 20),

            // ── Thẻ tổng quan ─────────────────────────────────────
            _buildSectionTitle('TỔNG QUAN', Icons.insights_rounded),
            const SizedBox(height: 10),
            _buildOverviewCards(overview),
            const SizedBox(height: 24),

            // ── Doanh thu 7 ngày ──────────────────────────────────
            _buildSectionTitle('DOANH THU 7 NGÀY GẦN NHẤT', Icons.bar_chart_rounded),
            const SizedBox(height: 10),
            _buildRevenueChart(revenueDay),
            const SizedBox(height: 24),

            // ── Trạng thái lịch khám ──────────────────────────────
            _buildSectionTitle('TRẠNG THÁI LỊCH KHÁM', Icons.donut_large_rounded),
            const SizedBox(height: 10),
            _buildStatusChart(byStatus),
            const SizedBox(height: 24),

            // ── Top bác sĩ ────────────────────────────────────────
            if (topDoctors.isNotEmpty) ...[
              _buildSectionTitle('TOP BÁC SĨ', Icons.medical_services_rounded),
              const SizedBox(height: 10),
              _buildTopDoctors(topDoctors),
              const SizedBox(height: 24),
            ],

            // ── Chuyên khoa ───────────────────────────────────────
            if (bySpecialty.isNotEmpty) ...[
              _buildSectionTitle('LỊCH KHÁM THEO CHUYÊN KHOA', Icons.science_rounded),
              const SizedBox(height: 10),
              _buildSpecialtyChart(bySpecialty),
              const SizedBox(height: 24),
            ],

            // ── Giới tính ─────────────────────────────────────────
            _buildSectionTitle('BỆNH NHÂN THEO GIỚI TÍNH', Icons.people_rounded),
            const SizedBox(height: 10),
            _buildGenderStats(gender),
          ],
        ),
      ),
    );
  }

  // ── Period filter ─────────────────────────────────────────────
  Widget _buildPeriodFilter() {
    final labels = ['7 ngày', 'Tháng này', '3 tháng'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecor.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormat('dd/MM/yyyy').format(_from)} – ${DateFormat('dd/MM/yyyy').format(_to)}',
            style: AppText.footnote.copyWith(color: AppColors.subLabel),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (i) => Expanded(
              child: GestureDetector(
                onTap: () => _setPreset(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedPreset == i ? AppColors.primary : AppColors.fill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedPreset == i ? Colors.white : AppColors.subLabel,
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 6),
      Text(title, style: AppText.caption.copyWith(
        color: AppColors.subLabel, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    ],
  );

  // ── Overview cards ────────────────────────────────────────────
  Widget _buildOverviewCards(Map<String, dynamic> ov) {
    final cards = [
      _StatCard(
        icon: Icons.event_note_rounded,
        label: 'Lịch khám',
        value: '${ov['totalAppointments']}',
        color: AppColors.primary,
        sub: 'trong kỳ',
      ),
      _StatCard(
        icon: Icons.attach_money_rounded,
        label: 'Doanh thu',
        value: _formatCurrency((ov['revenue'] as num).toDouble()),
        color: AppColors.success,
        sub: '${ov['paidCount']} hóa đơn',
      ),
      _StatCard(
        icon: Icons.hourglass_empty_rounded,
        label: 'Chờ thanh toán',
        value: _formatCurrency((ov['pendingRevenue'] as num).toDouble()),
        color: AppColors.warning,
        sub: '${ov['pendingCount']} hóa đơn',
      ),
      _StatCard(
        icon: Icons.person_add_rounded,
        label: 'Bệnh nhân mới',
        value: '${ov['newPatients']}',
        color: AppColors.info,
        sub: 'tổng: ${ov['totalPatients']}',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: cards.map((c) => _buildStatCard(c)).toList(),
    );
  }

  Widget _buildStatCard(_StatCard c) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border(left: BorderSide(color: c.color, width: 4)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(c.icon, size: 18, color: c.color),
            ),
            const Spacer(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.value, style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.label)),
            Text(c.label, style: AppText.footnote.copyWith(
              color: AppColors.subLabel, fontWeight: FontWeight.w600)),
            Text(c.sub, style: AppText.caption.copyWith(color: c.color)),
          ],
        ),
      ],
    ),
  );

  // ── Revenue bar chart ─────────────────────────────────────────
  Widget _buildRevenueChart(List<Map<String, dynamic>> days) {
    final maxVal = days.fold(0.0, (m, d) => (d['revenue'] as num).toDouble() > m
        ? (d['revenue'] as num).toDouble() : m);
    final interval = maxVal > 0 ? (maxVal / 4).ceilToDouble() : 1000000.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: AppDecor.card,
      child: BarChart(
        BarChartData(
          maxY: maxVal > 0 ? maxVal * 1.2 : interval * 5,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.separator, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: interval,
                getTitlesWidget: (v, _) => Text(
                  _formatCurrency(v),
                  style: TextStyle(fontSize: 10, color: AppColors.subLabel),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= days.length) return const SizedBox();
                  final date = DateTime.parse(days[idx]['date']);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(DateFormat('dd/MM').format(date),
                        style: TextStyle(fontSize: 10, color: AppColors.subLabel)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(days.length, (i) {
            final rev = (days[i]['revenue'] as num).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: rev,
                  color: rev > 0 ? AppColors.primary : AppColors.separator,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxVal > 0 ? maxVal * 1.2 : interval * 5,
                    color: AppColors.fill,
                  ),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.label,
              getTooltipItem: (group, _, rod, __) {
                final date = DateTime.parse(days[group.x]['date']);
                return BarTooltipItem(
                  '${DateFormat('dd/MM').format(date)}\n',
                  const TextStyle(color: Colors.white, fontSize: 11),
                  children: [TextSpan(
                    text: '${_formatCurrency(rod.toY)}đ',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  )],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Status donut chart ────────────────────────────────────────
  Widget _buildStatusChart(Map<String, dynamic> byStatus) {
    final completed = (byStatus['completed'] as int?) ?? 0;
    final confirmed = (byStatus['confirmed'] as int?) ?? 0;
    final pending   = (byStatus['pending']   as int?) ?? 0;
    final cancelled = (byStatus['cancelled'] as int?) ?? 0;
    final checkedIn = (byStatus['checked_in'] as int?) ?? 0;
    final total = completed + confirmed + pending + cancelled + checkedIn;

    final sections = [
      _PieSection('Hoàn thành', completed, AppColors.success),
      _PieSection('Đã xác nhận', confirmed, AppColors.info),
      _PieSection('Chờ xác nhận', pending, AppColors.warning),
      _PieSection('Đã hủy', cancelled, AppColors.danger),
      if (checkedIn > 0)
        _PieSection('Check-in', checkedIn, AppColors.accent),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card,
      child: total == 0
          ? _buildEmptyChart('Chưa có dữ liệu lịch khám')
          : Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: sections
                          .where((s) => s.value > 0)
                          .map((s) => PieChartSectionData(
                                value: s.value.toDouble(),
                                color: s.color,
                                radius: 40,
                                showTitle: false,
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: sections.map((s) => _buildLegendRow(
                      s.label,
                      s.value,
                      total,
                      s.color,
                    )).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendRow(String label, int value, int total, Color color) {
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(child: Text(label,
              style: AppText.caption.copyWith(color: AppColors.label2), overflow: TextOverflow.ellipsis)),
          Text('$value ($pct%)',
              style: AppText.caption.copyWith(color: AppColors.subLabel, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Top doctors ───────────────────────────────────────────────
  Widget _buildTopDoctors(List<Map<String, dynamic>> doctors) {
    final max = (doctors.first['soLichKham'] as int?) ?? 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card,
      child: Column(
        children: doctors.asMap().entries.map((e) {
          final i   = e.key;
          final doc = e.value;
          final count = (doc['soLichKham'] as int?) ?? 0;
          final double pct = max > 0 ? count / max : 0.0;
          final rankColors = [
            const Color(0xFFFFD700),
            const Color(0xFFC0C0C0),
            const Color(0xFFCD7F32),
          ];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: i < 3
                        ? rankColors[i].withValues(alpha: 0.15)
                        : AppColors.fill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: i < 3 ? rankColors[i] : AppColors.subLabel,
                    ),
                  )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(
                            'BS. ${doc['tenBacSi'] ?? ''}',
                            style: AppText.footnote.copyWith(
                              fontWeight: FontWeight.w700, color: AppColors.label),
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text('$count lịch',
                              style: AppText.footnote.copyWith(
                                color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: AppColors.fill,
                          valueColor: AlwaysStoppedAnimation(
                            i == 0 ? AppColors.primary
                                : i == 1 ? AppColors.accent
                                : AppColors.info,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(doc['ChuyenKhoa'] ?? '',
                          style: AppText.caption.copyWith(color: AppColors.subLabel)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Specialty horizontal bars ─────────────────────────────────
  Widget _buildSpecialtyChart(List<Map<String, dynamic>> specs) {
    final max = specs.fold(0, (m, s) {
      final v = (s['total'] as int?) ?? 0;
      return v > m ? v : m;
    });

    final colors = [
      AppColors.primary, AppColors.accent, AppColors.info,
      AppColors.success, AppColors.warning, const Color(0xFF9C27B0),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card,
      child: Column(
        children: specs.asMap().entries.map((e) {
          final spec  = e.value;
          final count = (spec['total'] as int?) ?? 0;
          final double pct = max > 0 ? count / max : 0.0;
          final color = colors[e.key % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    spec['ChuyenKhoa'] ?? 'N/A',
                    style: AppText.caption.copyWith(color: AppColors.label2),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.fill,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 28,
                  child: Text('$count',
                      style: AppText.caption.copyWith(
                        color: color, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gender stats ──────────────────────────────────────────────
  Widget _buildGenderStats(Map<String, dynamic> gender) {
    final nam   = (gender['nam']   as int?) ?? 0;
    final nu    = (gender['nu']    as int?) ?? 0;
    final other = (gender['other'] as int?) ?? 0;
    final total = nam + nu + other;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card,
      child: total == 0
          ? _buildEmptyChart('Chưa có dữ liệu')
          : Row(
              children: [
                _buildGenderItem(Icons.male_rounded, 'Nam', nam, total, const Color(0xFF1976D2)),
                const SizedBox(width: 12),
                _buildGenderItem(Icons.female_rounded, 'Nữ', nu, total, const Color(0xFFE91E63)),
                if (other > 0) ...[
                  const SizedBox(width: 12),
                  _buildGenderItem(Icons.person_rounded, 'Khác', other, total, AppColors.subLabel),
                ],
              ],
            ),
    );
  }

  Widget _buildGenderItem(IconData icon, String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text('$pct%', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: AppText.footnote.copyWith(color: AppColors.label2)),
            Text('$count người', style: AppText.caption.copyWith(color: AppColors.subLabel)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(msg, style: AppText.footnote.copyWith(color: AppColors.subLabel)),
    ),
  );
}

class _StatCard {
  final IconData icon;
  final String label, value, sub;
  final Color color;
  const _StatCard({required this.icon, required this.label,
      required this.value, required this.color, required this.sub});
}

class _PieSection {
  final String label;
  final int value;
  final Color color;
  const _PieSection(this.label, this.value, this.color);
}
