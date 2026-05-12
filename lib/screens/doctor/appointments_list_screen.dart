import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Today, 2: Pending

  final List<String> _filters = ['الكل', 'مواعيد اليوم', 'في الانتظار'];
  
  final _appointmentService = AppointmentService(ApiClient());
  bool _isLoading = true;
  List<AppointmentModel> _allAppointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _appointmentService.getDoctorAppointments();
      if (mounted) {
        setState(() {
          _allAppointments = appointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(AppointmentModel appointment, String newStatus) async {
    try {
      await _appointmentService.updateAppointmentStatus(appointment.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم التحديث بنجاح', style: TextStyle(fontFamily: 'Tajawal')),
            backgroundColor: newStatus == 'confirmed' ? const Color(0xFF10B981) : const Color(0xFFDC2626),
          ),
        );
        _fetchAppointments(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء التحديث'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AppointmentModel> filteredList = _allAppointments;
    if (_selectedFilterIndex == 1) {
      final todayStr = DateTime.now().toString().split(' ')[0];
      filteredList = _allAppointments.where((a) => a.appointmentDate == todayStr).toList();
    } else if (_selectedFilterIndex == 2) {
      filteredList = _allAppointments.where((a) => a.status == 'pending').toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
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
                        colors: [const Color(0xFF00B4FF).withValues(alpha:0.4), Colors.transparent],
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'إدارة المواعيد',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جدول الحجوزات القادمة والسابقة',
                      style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha:0.8), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters Overlapping Header
          Transform.translate(
            offset: const Offset(0, -20),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00B4FF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isSelected) BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          if (isSelected) BoxShadow(color: const Color(0xFF00B4FF).withValues(alpha:0.3), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // List of Appointments
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
                : filteredList.isEmpty
                    ? const Center(child: Text('لا توجد مواعيد مطابقة للفلتر المحدد', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8))))
                    : RefreshIndicator(
                        onRefresh: _fetchAppointments,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final apt = filteredList[index];
                            final isConfirmed = apt.status == 'confirmed';
                            final isCompleted = apt.status == 'completed';
                            final isPending = apt.status == 'pending';
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildAppointmentCard(
                                context,
                                appointment: apt,
                                isConfirmed: isConfirmed || isCompleted,
                                isCompleted: isCompleted,
                                isPending: isPending,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, {
    required AppointmentModel appointment,
    required bool isConfirmed,
    required bool isCompleted,
    required bool isPending,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EDF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section (Time & Status)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time_filled, color: Color(0xFF00B4FF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.startTime,
                          style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          appointment.appointmentDate,
                          style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConfirmed ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.statusAr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: isConfirmed ? const Color(0xFF00B4FF) : const Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE8EDF8)),
          
          // Patient info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00B4FF).withValues(alpha:0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      (appointment.patientName != null && appointment.patientName!.isNotEmpty) ? appointment.patientName!.substring(0, 1) : 'م',
                      style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF00B4FF), fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.patientName ?? 'مريض بدون اسم', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(appointment.patientPhone ?? '-', style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('رقم الطابور', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 11)),
                    Text(
                      appointment.queueNumber?.toString() ?? '--',
                      style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF00B4FF), fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Badges row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildBadge(Icons.medical_information, appointment.checkupType ?? 'كشف جديد', const Color(0xFF00B4FF), const Color(0xFFE0F2FE)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Actions
          if (!isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: isConfirmed 
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final refreshed = await Navigator.pushNamed(context, '/appointment_detail', arguments: appointment);
                      if (refreshed == true && mounted) _fetchAppointments();
                    },
                    icon: const Icon(Icons.medical_services, size: 18, color: Colors.white),
                    label: const Text('بدء الكشف / التفاصيل', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4FF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                )
              : Row(

                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus(appointment, 'confirmed'),
                        icon: const Icon(Icons.check, size: 18, color: Color(0xFF10B981)),
                        label: const Text('تأكيد الموعد', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus(appointment, 'cancelled'),
                        icon: const Icon(Icons.close, size: 18, color: Color(0xFFDC2626)),
                        label: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFFEE2E2)),
                          backgroundColor: const Color(0xFFFEF2F2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
