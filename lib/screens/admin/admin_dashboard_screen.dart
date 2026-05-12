import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../components/admin_drawer.dart';
import '../../services/dashboard_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = DashboardService(ApiClient());

  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final s = await _service.getAdminStats();
      if (mounted) setState(() { _stats = s; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apptToday = _stats['appointments_today'] as Map? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: const AdminDrawer(currentRoute: '/admin_home'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF0A2952),
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: -40,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [const Color(0xFF00B4FF).withValues(alpha: 0.4), Colors.transparent],
                              stops: const [0.0, 0.7],
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, left: 24, right: 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white24,
                                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('مرحباً بك', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white70, fontSize: 12)),
                                      Text('مدير النظام', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Text(
                                'لوحة التحكم الرئيسية',
                                style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'نظرة شاملة على أداء العيادات والنظام',
                                style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _buildStatCard('العيادات', '${_stats['total_clinics'] ?? 0}', Icons.local_hospital_rounded, const Color(0xFF00B4FF), const Color(0xFFE0F2FE)),
                            _buildStatCard('الأطباء', '${_stats['total_doctors'] ?? 0}', Icons.medical_services_rounded, const Color(0xFF8B5CF6), const Color(0xFFEDE9FE)),
                            _buildStatCard('المرضى', '${_stats['total_patients'] ?? 0}', Icons.people_alt_rounded, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                            _buildStatCard('حجوزات اليوم', '${apptToday['total'] ?? 0}', Icons.calendar_month_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Text('تفاصيل حجوزات اليوم', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE8EDF8)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildApptStat('قيد الانتظار', '${apptToday['pending'] ?? 0}', const Color(0xFFF59E0B)),
                              _buildApptStat('مؤكدة', '${apptToday['confirmed'] ?? 0}', const Color(0xFF00B4FF)),
                              _buildApptStat('مكتملة', '${apptToday['completed'] ?? 0}', const Color(0xFF10B981)),
                              _buildApptStat('ملغاة', '${apptToday['cancelled'] ?? 0}', const Color(0xFFEF4444)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF8)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
        ],
      ),
    );
  }

  Widget _buildApptStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }
}
