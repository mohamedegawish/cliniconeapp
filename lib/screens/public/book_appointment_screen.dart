import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../services/appointment_service.dart';
import '../../services/doctor_service.dart';
import '../../utils/api_exception.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _checkupType = 'كشف جديد';
  bool _isBooking = false;
  bool _isSlotsLoading = false;
  List<String> _slots = [];

  final _doctorService = DoctorService(ApiClient());
  final _appointmentService = AppointmentService(ApiClient());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSlots());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _doctor =>
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _fetchSlots() async {
    final doctorId = _doctor?['id'] as int?;
    if (doctorId == null) return;

    setState(() {
      _isSlotsLoading = true;
      _selectedSlot = null;
    });

    try {
      final slots = await _doctorService.getAvailableSlots(doctorId, _dateStr);
      if (mounted) setState(() => _slots = slots);
    } on ApiException {
      if (mounted) setState(() => _slots = []);
    } finally {
      if (mounted) setState(() => _isSlotsLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00B4FF),
            onPrimary: Colors.white,
            onSurface: Color(0xFF0A2952),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() => _selectedDate = picked);
      _fetchSlots();
    }
  }

  Future<void> _confirmBooking() async {
    final doctor = _doctor ?? {};
    final doctorId = doctor['id'] as int?;

    if (_selectedSlot == null) {
      _showSnack('الرجاء اختيار وقت الموعد', isError: true);
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showSnack('الرجاء إدخال اسم المريض', isError: true);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnack('الرجاء إدخال رقم الهاتف', isError: true);
      return;
    }
    if (doctorId == null) {
      _showSnack('بيانات الطبيب غير مكتملة', isError: true);
      return;
    }

    setState(() => _isBooking = true);

    try {
      final result = await _appointmentService.bookAppointment(
        doctorId: doctorId,
        date: _dateStr,
        time: _selectedSlot!,
        patientName: _nameController.text.trim(),
        patientPhone: _phoneController.text.trim(),
        checkupType: _checkupType,
      );

      if (!mounted) return;

      final payload = result['data'] as Map<String, dynamic>? ?? {};
      Navigator.pushReplacementNamed(
        context,
        '/booking_confirmation',
        arguments: {
          'doctor_name': doctor['name'] ?? '',
          'date': _dateStr,
          'time': _selectedSlot,
          'queue_number': payload['queue_number']?.toString() ?? '—',
          'patient_name': _nameController.text.trim(),
        },
      );
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.displayMessage, isError: true);
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor:
            isError ? const Color(0xFFE53E3E) : const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = _doctor ?? {
      'name': 'د. أحمد محمود',
      'specialty': 'استشاري أمراض القلب'
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Transform.translate(
                offset: const Offset(0, -50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDoctorCard(doctor),
                    const SizedBox(height: 24),
                    _buildFormCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(
          top: 52, left: 20, right: 20, bottom: 80),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'حجز موعد',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'أكمل بيانات الحجز لتأكيد موعدك',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4FF).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: const Color(0xFF00B4FF).withValues(alpha: 0.3),
                  width: 2),
            ),
            child: const Center(
                child: Text('👨‍⚕️', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'] as String? ?? '',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Color(0xFF0A2952),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor['specialty'] as String? ?? '',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2952).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('اختر التاريخ'),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE8EDF8)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateStr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFF0A2952),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.calendar_month,
                      color: Color(0xFF00B4FF)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('المواعيد المتاحة'),
          const SizedBox(height: 12),
          _buildSlotsGrid(),
          const SizedBox(height: 24),
          _sectionTitle('نوع الحجز'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE8EDF8)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _radioOption('كشف جديد', 'سعر الكشف: 250 ج.م'),
                const Divider(height: 1, color: Color(0xFFE8EDF8)),
                _radioOption('إعادة (استشارة)', 'سعر الإعادة: 50 ج.م'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('بيانات المريض'),
          const SizedBox(height: 12),
          _inputLabel('الاسم الكامل'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration:
                _inputDecoration('أدخل اسمك الثلاثي', Icons.person_outline),
          ),
          const SizedBox(height: 16),
          _inputLabel('رقم الهاتف'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
                'أدخل رقم هاتفك للتواصل', Icons.phone_outlined),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _isBooking ? null : _confirmBooking,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4FF), Color(0xFF0077FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _isBooking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'تأكيد الحجز',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsGrid() {
    if (_isSlotsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
              color: Color(0xFF00B4FF), strokeWidth: 2),
        ),
      );
    }

    if (_slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'لا تتوفر مواعيد متاحة في هذا اليوم',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: _slots.length,
      itemBuilder: (_, i) {
        final slot = _slots[i];
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00B4FF)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00B4FF)
                    : const Color(0xFFE8EDF8),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00B4FF).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                slot,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF0A2952),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: Color(0xFF0A2952),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _inputLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A2952),
        ),
      );

  Widget _radioOption(String title, String subtitle) => RadioListTile<String>(
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2952),
                fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontFamily: 'Tajawal',
                color: Color(0xFF00B4FF),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        value: title,
        groupValue: _checkupType,
        activeColor: const Color(0xFF00B4FF),
        onChanged: (val) => setState(() => _checkupType = val!),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Color(0xFF94A3B8),
            fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00B4FF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE8EDF8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF00B4FF), width: 1.5),
        ),
      );
}

