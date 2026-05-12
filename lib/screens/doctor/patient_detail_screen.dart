import 'package:flutter/material.dart';
import '../../models/patient_model.dart';
import '../../models/appointment_model.dart';
import '../../models/consultation_model.dart';
import '../../services/appointment_service.dart';
import '../../services/consultation_service.dart';
import '../../api/api_client.dart';
import 'consultation_screen.dart';
import 'prescription_preview_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _appointmentService  = AppointmentService(ApiClient());
  final _consultationService = ConsultationService(ApiClient());

  List<AppointmentModel>   _visits       = [];
  List<ConsultationModel>  _consultations = [];
  bool _isLoading = true;
  PatientModel? _patient;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('patient')) {
      _patient = args['patient'] as PatientModel;
      _didInit = true;
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    if (_patient == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _appointmentService.getDoctorAppointments(patientId: _patient!.id),
        _consultationService.getConsultations(patientId: _patient!.id),
      ]);
      if (mounted) {
        setState(() {
          _visits        = results[0] as List<AppointmentModel>;
          _consultations = results[1] as List<ConsultationModel>;
          _isLoading     = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openConsultation(int appointmentId, String patientName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationScreen(
          appointmentId: appointmentId,
          patientName: patientName,
        ),
      ),
    ).then((_) => _loadAll());
  }

  void _viewPrescription(int consultationId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrescriptionPreviewScreen(consultationId: consultationId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ملف المريض')),
        body: const Center(child: Text('خطأ في تحميل بيانات المريض')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ملف المريض'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white.withValues(alpha:0.2),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Color(0xFF00B4FF)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _patient!.name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _patient!.phone ?? 'بدون رقم هاتف',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Basic Info Card
                    _buildSectionCard(
                      title: 'البيانات الأساسية',
                      icon: Icons.info_outline,
                      child: Column(
                        children: [
                          _buildDetailRow('العمر:', '${_patient!.age ?? '--'} سنة'),
                          const Divider(height: 24, color: Color(0xFFE8EDF8)),
                          _buildDetailRow('الجنس:', _patient!.gender == 'male' ? 'ذكر' : 'أنثى'),
                          const Divider(height: 24, color: Color(0xFFE8EDF8)),
                          _buildDetailRow('تاريخ الميلاد:', _patient!.dateOfBirth ?? '--'),
                          const Divider(height: 24, color: Color(0xFFE8EDF8)),
                          _buildDetailRow('العنوان:', _patient!.address ?? 'غير مسجل'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Consultations History
                    _buildSectionCard(
                      title: 'سجل الاستشارات',
                      icon: Icons.medical_services_outlined,
                      child: _isLoading
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ))
                        : _consultations.isEmpty
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('لا يوجد استشارات سابقة', style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey)),
                            ))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _consultations.length,
                              itemBuilder: (context, index) {
                                final consult = _consultations[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE8EDF8)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF7F2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.description_outlined, color: Color(0xFF2A7F62), size: 22),
                                    ),
                                    title: Text(
                                      consult.diagnosis,
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2952)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      consult.createdAt ?? '--',
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                    trailing: TextButton.icon(
                                      onPressed: () => _viewPrescription(consult.id),
                                      icon: const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF00B4FF)),
                                      label: const Text('الوصفة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF00B4FF))),
                                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Pending / Confirmed Appointments
                    _buildSectionCard(
                      title: 'المواعيد القادمة',
                      icon: Icons.calendar_today_outlined,
                      child: _isLoading
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ))
                        : _visits.where((v) => v.status == 'pending' || v.status == 'confirmed').isEmpty
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('لا يوجد مواعيد قادمة', style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey)),
                            ))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _visits.where((v) => v.status == 'pending' || v.status == 'confirmed').length,
                              itemBuilder: (context, index) {
                                final visit = _visits.where((v) => v.status == 'pending' || v.status == 'confirmed').elementAt(index);
                                final isConfirmed = visit.status == 'confirmed';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE8EDF8)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isConfirmed ? const Color(0xFFE0F2FE) : const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isConfirmed ? Icons.event_available_outlined : Icons.schedule_outlined,
                                        color: isConfirmed ? const Color(0xFF0369A1) : const Color(0xFFD97706),
                                        size: 22,
                                      ),
                                    ),
                                    title: Text(
                                      'زيارة يوم ${visit.appointmentDate}',
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2952)),
                                    ),
                                    subtitle: Text(
                                      visit.startTime,
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                    trailing: isConfirmed
                                      ? TextButton.icon(
                                          onPressed: () => _openConsultation(visit.id, _patient!.name),
                                          icon: const Icon(Icons.edit_note_outlined, size: 16, color: Color(0xFF2A7F62)),
                                          label: const Text('استشارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF2A7F62))),
                                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                        )
                                      : null,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00B4FF), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2952),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2952),
          ),
        ),
      ],
    );
  }

}
