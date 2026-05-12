import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_client.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../services/notification_service.dart';
import '../../store/auth_provider.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final _appointmentService  = AppointmentService(ApiClient());
  final _notificationService = NotificationService(ApiClient());

  bool _isLoading = true;
  List<AppointmentModel> _todayAppointments = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchAppointments(), _fetchUnread()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchAppointments() async {
    try {
      final today = DateTime.now().toString().split(' ')[0];
      final list  = await _appointmentService.getDoctorAppointments(date: today);
      if (mounted) setState(() => _todayAppointments = list);
    } catch (_) {}
  }

  Future<void> _fetchUnread() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authProvider    = Provider.of<AuthProvider>(context);
    final doctorName      = authProvider.user?.name ?? 'طبيب';
    final totalAppts      = _todayAppointments.length;
    final pendingCount    = _todayAppointments.where((a) => a.status == 'pending' || a.status == 'confirmed').length;
    final completedCount  = _todayAppointments.where((a) => a.status == 'completed').length;
    final revenue         = _todayAppointments
        .where((a) => a.isPaid)
        .fold<double>(0, (sum, a) => sum + a.totalPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
          : RefreshIndicator(
              onRefresh: _fetchAll,
              color: const Color(0xFF00B4FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(doctorName),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(children: [
                              Expanded(child: _statCard('مواعيد اليوم', '$totalAppts',     Icons.calendar_month,         const Color(0xFF00B4FF))),
                              const SizedBox(width: 16),
                              Expanded(child: _statCard('في الانتظار',  '$pendingCount',   Icons.people_outline,         const Color(0xFFF59E0B))),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: _statCard('تم الكشف',    '$completedCount', Icons.check_circle_outline,   const Color(0xFF10B981))),
                              const SizedBox(width: 16),
                              Expanded(child: _statCard('الإيرادات',   '${revenue.toStringAsFixed(0)} ج', Icons.monetization_on_outlined, const Color(0xFF8B5CF6))),
                            ]),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('المواعيد القادمة',
                                  style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 18, fontWeight: FontWeight.bold)),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/doctor_appointments'),
                                  child: const Text('عرض الكل',
                                    style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF00B4FF), fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_todayAppointments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('لا توجد مواعيد متبقية اليوم',
                                  style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8))),
                              )
                            else
                              ..._todayAppointments.map((apt) {
                                final (statusColor, statusBg) = _statusColors(apt.status);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _appointmentCard(
                                    name:        apt.patientName ?? 'مريض',
                                    time:        apt.startTime,
                                    type:        apt.checkupType ?? 'كشف جديد',
                                    status:      apt.statusAr,
                                    statusColor: statusColor,
                                    statusBg:    statusBg,
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  (Color, Color) _statusColors(String status) => switch (status) {
    'completed' => (const Color(0xFF10B981), const Color(0xFFD1FAE5)),
    'confirmed' => (const Color(0xFF00B4FF), const Color(0xFFE0F2FE)),
    'cancelled' => (const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
    _           => (const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
  };

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(String doctorName) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20, right: -40,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF00B4FF).withValues(alpha: 0.4), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu, color: Colors.white),
                      ),
                    ),
                  ),
                  // Notification bell with unread badge
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(context, '/doctor_notifications');
                      _fetchUnread();
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_none, color: Colors.white),
                        ),
                        if (_unreadCount > 0)
                          Positioned(
                            top: 4, right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                _unreadCount > 9 ? '9+' : '$_unreadCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مرحباً، د. ${doctorName.split(' ').first}',
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('لوحة التحكم - اليوم',
                        style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('ClinicOne', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('لوحة تحكم الطبيب', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(context, Icons.dashboard_rounded,          'لوحة التحكم',            '/doctor_home',          isActive: true),
                _drawerItem(context, Icons.people_alt_rounded,         'إدارة المرضى',           '/doctor_patients'),
                _drawerItem(context, Icons.calendar_month_rounded,     'جدول المواعيد',          '/doctor_appointments'),
                _drawerItem(context, Icons.queue_rounded,              'طابور الانتظار',          '/doctor_queue'),
                _sectionLabel('الطب والكشف'),
                _drawerItem(context, Icons.medication_rounded,         'قاعدة الأدوية',          '/doctor_medications'),
                _drawerItem(context, Icons.library_books_rounded,      'قوالب الوصفات',          '/doctor_templates'),
                _sectionLabel('المالية والتقارير'),
                _drawerItem(context, Icons.account_balance_wallet_rounded, 'المصروفات',          '/doctor_expenses'),
                _drawerItem(context, Icons.bar_chart_rounded,          'التقارير والإحصائيات',   '/doctor_reports'),
                _sectionLabel('النظام'),
                _drawerItemWithBadge(context, Icons.notifications_rounded, 'الإشعارات', '/doctor_notifications', _unreadCount),
                _drawerItem(context, Icons.person_outline_rounded,     'ملفي الشخصي',            '/doctor_profile_edit'),
                _drawerItem(context, Icons.settings_rounded,           'الإعدادات',              '/doctor_settings'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Color(0xFFDC2626), size: 20),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(right: 24, top: 16, bottom: 8),
    child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
  );

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00B4FF).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? const Color(0xFF00B4FF) : const Color(0xFF64748B)),
        title: Text(title,
          style: TextStyle(fontFamily: 'Cairo', color: isActive ? const Color(0xFF00B4FF) : const Color(0xFF0A2952),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          if (!isActive) Navigator.pushNamed(context, route);
        },
      ),
    );
  }

  Widget _drawerItemWithBadge(BuildContext context, IconData icon, String title, String route, int badge) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(icon, color: const Color(0xFF64748B)),
            if (badge > 0)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: badge > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(10)),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () async {
          Navigator.pop(context);
          await Navigator.pushNamed(context, route);
          _fetchUnread();
        },
      ),
    );
  }

  // ── Cards ───────────────────────────────────────────────────────────────────

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _appointmentCard({
    required String name, required String time,
    required String type, required String status,
    required Color statusColor, required Color statusBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF8)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(time,  style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, size: 4, color: Color(0xFFCBD5E1)),
                    const SizedBox(width: 8),
                    Text(type,  style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(fontFamily: 'Tajawal', color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
