import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/appointment_model.dart';
import '../../models/consultation_model.dart';
import '../../services/appointment_service.dart';
import '../../services/consultation_service.dart';
import 'consultation_screen.dart';
import 'prescription_preview_screen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _service             = AppointmentService(ApiClient());
  final _consultationService = ConsultationService(ApiClient());
  AppointmentModel? _apt;
  ConsultationModel? _consultation;
  bool _isActing          = false;
  bool _loadingConsult    = false;
  bool _didInitConsult    = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AppointmentModel) {
      _apt = args;
      // Load linked consultation once for completed appointments
      if (!_didInitConsult && _apt!.status == 'completed') {
        _didInitConsult = true;
        _loadConsultation();
      }
    }
  }

  Future<void> _loadConsultation() async {
    setState(() => _loadingConsult = true);
    try {
      final c = await _consultationService.getConsultationByAppointment(_apt!.id);
      if (mounted) setState(() { _consultation = c; _loadingConsult = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingConsult = false);
    }
  }

  void _viewPrescription() {
    if (_consultation == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionPreviewScreen(consultationId: _consultation!.id),
      ),
    );
  }

  Future<void> _updateStatus(String action) async {
    if (_apt == null) return;
    setState(() => _isActing = true);
    try {
      switch (action) {
        case 'confirm':  await _service.confirmAppointment(_apt!.id); break;
        case 'cancel':   await _service.cancelAppointment(_apt!.id); break;
        case 'complete': await _service.completeAppointment(_apt!.id); break;
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isActing = false);
        _showSnack(e.toString(), isError: true);
      }
    }
  }

  void _startConsultation() {
    if (_apt == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationScreen(
          appointmentId: _apt!.id,
          patientName: _apt!.patientName ?? 'مريض',
          totalPrice: _apt!.totalPrice,
          isPaid: _apt!.isPaid,
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
    ));
  }

  void _confirmAction(String action) {
    final messages = {
      'confirm':  'هل تريد تأكيد هذا الموعد؟',
      'cancel':   'هل تريد إلغاء هذا الموعد؟',
      'complete': 'هل تريد إتمام هذا الموعد وإغلاقه؟',
    };
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأكيد', style: TextStyle(fontFamily: 'Cairo')),
        content: Text(messages[action] ?? '', style: const TextStyle(fontFamily: 'Tajawal')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رجوع', style: TextStyle(fontFamily: 'Tajawal')),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); _updateStatus(action); },
            child: Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: action == 'cancel' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_apt == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: Column(children: [
          _buildHeader(),
          const Expanded(child: Center(child: Text('لم يتم تمرير بيانات الموعد', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8))))),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPatientCard(),
                  const SizedBox(height: 16),
                  _buildDetailsCard(),
                  if (_apt!.notes != null && _apt!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                  ],
                  const SizedBox(height: 24),
                  _buildActions(),
                  const SizedBox(height: 20),
                ],
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
      gradient: LinearGradient(
        colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        const Text('تفاصيل الموعد', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildPatientCard() {
    final apt = _apt!;
    final initial = (apt.patientName?.isNotEmpty == true) ? apt.patientName![0] : 'م';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF8)),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initial, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt.patientName ?? 'مريض غير معروف',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2952)),
                ),
                if (apt.patientPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(apt.patientPhone!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF64748B))),
                  ]),
                ],
              ],
            ),
          ),
          _statusBadge(apt.status),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final apt = _apt!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF8)),
      ),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today_outlined, 'التاريخ', '${apt.dayStr} ${apt.monthStr}'),
          const Divider(height: 20, color: Color(0xFFF0F4FF)),
          _infoRow(Icons.access_time_outlined, 'الوقت', apt.startTime),
          const Divider(height: 20, color: Color(0xFFF0F4FF)),
          _infoRow(Icons.format_list_numbered, 'رقم الطابور', apt.queueNumber != null ? '#${apt.queueNumber}' : '--'),
          const Divider(height: 20, color: Color(0xFFF0F4FF)),
          _infoRow(Icons.medical_information_outlined, 'نوع الكشف', apt.checkupType ?? 'كشف عام'),
          if (apt.totalPrice > 0) ...[
            const Divider(height: 20, color: Color(0xFFF0F4FF)),
            _infoRow(
              apt.isPaid ? Icons.check_circle_outline : Icons.attach_money,
              'الرسوم',
              '${apt.totalPrice.toStringAsFixed(0)} ج${apt.isPaid ? ' (مدفوع)' : ''}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE8EDF8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Icon(Icons.notes_outlined, color: Color(0xFF00B4FF), size: 18),
          SizedBox(width: 8),
          Text('ملاحظات الحجز', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
        ]),
        const SizedBox(height: 10),
        Text(_apt!.notes!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF475569), height: 1.6)),
      ],
    ),
  );

  Widget _buildActions() {
    final apt = _apt!;

    if (_isActing) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)));
    }

    if (apt.status == 'completed' || apt.status == 'cancelled') {
      final isCompleted = apt.status == 'completed';
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isCompleted ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Text(
                  isCompleted ? 'تم اكتمال هذا الموعد' : 'تم إلغاء هذا الموعد',
                  style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold,
                      color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                ),
              ],
            ),
          ),
          // View Prescription button — only for completed appointments with a saved consultation
          if (isCompleted) ...[
            const SizedBox(height: 12),
            _loadingConsult
                ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: Color(0xFF2A7F62), strokeWidth: 2)))
                : _consultation != null
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _viewPrescription,
                          icon: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
                          label: const Text('عرض الوصفة الطبية', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A7F62),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
          ],
        ],
      );
    }

    final isConfirmed = apt.status == 'confirmed';
    final isPending   = apt.status == 'pending';

    return Column(
      children: [
        if (isConfirmed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startConsultation,
              icon: const Icon(Icons.medical_services, color: Colors.white, size: 20),
              label: const Text('بدء الكشف الطبي', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmAction('complete'),
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              label: const Text('إتمام الموعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
        if (isPending)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmAction('confirm'),
              icon: const Icon(Icons.check, color: Colors.white, size: 20),
              label: const Text('تأكيد الموعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmAction('cancel'),
            icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 20),
            label: const Text('إلغاء الموعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFFECACA)),
              backgroundColor: const Color(0xFFFEF2F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Row(
    children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF00B4FF), size: 18),
      ),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF94A3B8))),
      const Spacer(),
      Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
    ],
  );

  Widget _statusBadge(String status) {
    final (bgColor, textColor) = switch (status) {
      'confirmed' => (const Color(0xFFE0F2FE), const Color(0xFF00B4FF)),
      'pending'   => (const Color(0xFFFEF3C7), const Color(0xFFD97706)),
      'completed' => (const Color(0xFFD1FAE5), const Color(0xFF10B981)),
      'cancelled' => (const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
      _           => (const Color(0xFFF0F4FF), const Color(0xFF94A3B8)),
    };
    final apt = _apt!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(apt.statusAr, style: TextStyle(fontFamily: 'Tajawal', color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
