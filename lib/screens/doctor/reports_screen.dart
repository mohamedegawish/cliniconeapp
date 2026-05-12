import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../constants/endpoints.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _client = ApiClient();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res  = await _client.get(Endpoints.clinicReports);
      if (mounted) setState(() { _data = res['data'] as Map<String, dynamic>?; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
                : _error != null
                    ? _errorView()
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        color: const Color(0xFF00B4FF),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: _buildContent(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF0A2952)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        const Text('التقارير والإحصائيات', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _errorView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, size: 56, color: Color(0xFFCBD5E1)),
      const SizedBox(height: 16),
      const Text('تعذّر تحميل البيانات', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF64748B))),
      const SizedBox(height: 12),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2952), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: _fetch,
        child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white)),
      ),
    ]),
  );

  Widget _buildContent() {
    final appts    = _data?['appointments']  as Map<String, dynamic>? ?? {};
    final patients = _data?['patients']      as Map<String, dynamic>? ?? {};
    final fin      = _data?['financials']    as Map<String, dynamic>? ?? {};
    final chart    = _data?['monthly_chart'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointments
        _sectionTitle('المواعيد'),
        Row(children: [
          Expanded(child: _statCard('الإجمالي',       '${appts['total'] ?? 0}',         Icons.calendar_month,          const Color(0xFF00B4FF))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('مكتملة',         '${appts['completed'] ?? 0}',      Icons.check_circle_outline,    const Color(0xFF10B981))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard('في الانتظار',    '${appts['pending'] ?? 0}',        Icons.hourglass_empty_rounded,  const Color(0xFFF59E0B))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('اليوم',          '${appts['today'] ?? 0}',          Icons.today_outlined,          const Color(0xFF8B5CF6))),
        ]),

        const SizedBox(height: 20),

        // Patients
        _sectionTitle('المرضى'),
        _wideCard('إجمالي المرضى', '${patients['total'] ?? 0}', Icons.people_alt_rounded, const Color(0xFF0A2952)),

        const SizedBox(height: 20),

        // Financials
        _sectionTitle('المالية'),
        Row(children: [
          Expanded(child: _statCard('إيرادات اليوم',  _fmt(fin['revenue_today']),  Icons.attach_money,            const Color(0xFF10B981))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('إيرادات الشهر',  _fmt(fin['revenue_month']),  Icons.bar_chart_rounded,       const Color(0xFF00B4FF))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard('الإجمالي',       _fmt(fin['revenue_total']),  Icons.account_balance_wallet,  const Color(0xFF8B5CF6))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('صافي الربح',     _fmt(fin['net_income']),     Icons.trending_up,             const Color(0xFFF59E0B))),
        ]),

        if (chart.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionTitle('المواعيد — آخر 6 أشهر'),
          _buildChart(chart),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  String _fmt(dynamic val) {
    final n = (val is num) ? val.toDouble() : double.tryParse(val?.toString() ?? '') ?? 0.0;
    return '${n.toStringAsFixed(0)} ج';
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
  );

  Widget _statCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EDF8))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
      Text(label,  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF64748B))),
    ]),
  );

  Widget _wideCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EDF8))),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
        Text(label,  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF64748B))),
      ]),
    ]),
  );

  Widget _buildChart(List chart) {
    final maxCount = chart.fold<int>(1, (m, p) => (p['count'] as int? ?? 0) > m ? (p['count'] as int) : m);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EDF8))),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: chart.map((p) {
                final count = p['count'] as int? ?? 0;
                final frac  = maxCount > 0 ? count / maxCount : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$count', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: (frac * 100).clamp(4.0, 100.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: chart.map((p) {
              final label = (p['label'] as String? ?? '').split(' ').first;
              return Expanded(
                child: Text(label, textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: Color(0xFF94A3B8))),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
