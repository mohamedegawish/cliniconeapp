import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/medication_model.dart';
import '../../models/prescription_template_model.dart';
import '../../services/consultation_service.dart';
import '../../services/medication_service.dart';
import '../../services/template_service.dart';
import 'prescription_preview_screen.dart';

class ConsultationScreen extends StatefulWidget {
  final int appointmentId;
  final String patientName;
  final double totalPrice;
  final bool isPaid;

  const ConsultationScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
    this.totalPrice = 0,
    this.isPaid = false,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _consultationService = ConsultationService(ApiClient());
  final _medicationService   = MedicationService(ApiClient());
  final _templateService     = TemplateService(ApiClient());

  final _diagnosisCtrl  = TextEditingController();
  final _symptomsCtrl   = TextEditingController();
  final _treatmentCtrl  = TextEditingController();
  final _notesCtrl      = TextEditingController();
  final _bpCtrl         = TextEditingController();
  final _tempCtrl       = TextEditingController();
  final _pulseCtrl      = TextEditingController();
  final _weightCtrl     = TextEditingController();
  final _heightCtrl     = TextEditingController();
  final _medSearchCtrl  = TextEditingController();

  final List<Map<String, dynamic>> _medications = [];
  List<MedicationModel> _searchResults     = [];
  List<Map<String, dynamic>> _diagnosisSuggestions = [];
  bool _showDiagnosisSuggestions = false;

  bool _showVitals    = false;
  bool _isSaving      = false;
  bool _isSearching   = false;
  late bool _isPaid;

  @override
  void initState() {
    super.initState();
    _isPaid = widget.isPaid || widget.totalPrice == 0;
    _loadDiagnoses();
  }

  @override
  void dispose() {
    for (final c in [_diagnosisCtrl, _symptomsCtrl, _treatmentCtrl, _notesCtrl,
                     _bpCtrl, _tempCtrl, _pulseCtrl, _weightCtrl, _heightCtrl, _medSearchCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDiagnoses({String? q}) async {
    try {
      final list = await _consultationService.getDiagnoses(q: q);
      if (mounted) setState(() => _diagnosisSuggestions = list);
    } catch (_) {}
  }

  Future<void> _searchMedications(String q) async {
    if (q.length < 2) { setState(() => _searchResults = []); return; }
    setState(() => _isSearching = true);
    try {
      final results = await _medicationService.search(q);
      if (mounted) setState(() { _searchResults = results; _isSearching = false; });
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _addMedication(MedicationModel med) {
    setState(() {
      _medications.add({
        'medication_id': med.id,
        'name':          med.name,
        'generic':       med.generic ?? '',
        'dosage':        med.defaultDosage ?? '',
        'frequency':     med.defaultFrequency ?? '',
        'route':         med.defaultRoute ?? '',
        'duration':      med.defaultDuration ?? '',
        'instructions':  med.defaultInstructions ?? '',
      });
      _searchResults  = [];
      _medSearchCtrl.clear();
    });
  }

  void _removeMedication(int idx) => setState(() => _medications.removeAt(idx));

  Future<void> _loadTemplate() async {
    try {
      final templates = await _templateService.getTemplates();
      if (!mounted || templates.isEmpty) {
        if (mounted) _showSnack('لا توجد قوالب محفوظة');
        return;
      }
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('اختر قالب', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ...templates.map((t) => ListTile(
              title: Text(t.name, style: const TextStyle(fontFamily: 'Tajawal')),
              subtitle: Text('${t.items.length} دواء', style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8))),
              onTap: () {
                Navigator.pop(context);
                _applyTemplate(t);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      );
    } catch (_) {}
  }

  void _applyTemplate(PrescriptionTemplateModel t) {
    setState(() {
      for (final item in t.items) {
        _medications.add(item.toMedEntry());
      }
    });
    _showSnack('تم تطبيق القالب: ${t.name}');
  }

  Future<void> _save() async {
    if (_diagnosisCtrl.text.trim().isEmpty) {
      _showSnack('يرجى إدخال التشخيص');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final consultation = await _consultationService.createConsultation(
        appointmentId: widget.appointmentId,
        diagnosis:     _diagnosisCtrl.text.trim(),
        symptoms:      _symptomsCtrl.text.trim().isEmpty  ? null : _symptomsCtrl.text.trim(),
        treatment:     _treatmentCtrl.text.trim().isEmpty ? null : _treatmentCtrl.text.trim(),
        notes:         _notesCtrl.text.trim().isEmpty     ? null : _notesCtrl.text.trim(),
        bp:            _bpCtrl.text.trim().isEmpty        ? null : _bpCtrl.text.trim(),
        temp:          _tempCtrl.text.trim().isEmpty      ? null : _tempCtrl.text.trim(),
        pulse:         _pulseCtrl.text.trim().isEmpty     ? null : _pulseCtrl.text.trim(),
        weight:        _weightCtrl.text.trim().isEmpty    ? null : _weightCtrl.text.trim(),
        height:        _heightCtrl.text.trim().isEmpty    ? null : _heightCtrl.text.trim(),
        medications:   _medications,
        isPaid:        _isPaid,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PrescriptionPreviewScreen(consultationId: consultation.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnack(e.toString(), isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Banner
                  if (widget.totalPrice > 0) _buildPaymentBanner(),
                  if (widget.totalPrice > 0) const SizedBox(height: 16),

                  // Diagnosis
                  _card('التشخيص والأعراض', [
                    _diagnosisField(),
                    const SizedBox(height: 12),
                    _textArea(_symptomsCtrl,   'الأعراض'),
                    const SizedBox(height: 12),
                    _textArea(_treatmentCtrl,  'خطة العلاج'),
                    const SizedBox(height: 12),
                    _textArea(_notesCtrl,      'ملاحظات إضافية'),
                  ]),
                  const SizedBox(height: 16),

                  // Vitals toggle
                  GestureDetector(
                    onTap: () => setState(() => _showVitals = !_showVitals),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8EDF8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [
                            Icon(Icons.monitor_heart_outlined, color: Color(0xFF00B4FF)),
                            SizedBox(width: 8),
                            Text('العلامات الحيوية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
                          ]),
                          Icon(_showVitals ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                  if (_showVitals) ...[
                    const SizedBox(height: 8),
                    _card(null, [
                      Row(children: [
                        Expanded(child: _vitalField(_bpCtrl,    'ضغط الدم', 'mmHg')),
                        const SizedBox(width: 12),
                        Expanded(child: _vitalField(_tempCtrl,  'الحرارة',  '°C')),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _vitalField(_pulseCtrl,  'النبض',  'bpm')),
                        const SizedBox(width: 12),
                        Expanded(child: _vitalField(_weightCtrl, 'الوزن',  'kg')),
                      ]),
                      const SizedBox(height: 12),
                      _vitalField(_heightCtrl, 'الطول', 'cm'),
                    ]),
                  ],

                  const SizedBox(height: 16),

                  // Medications
                  _card('الأدوية', [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _medSearchCtrl,
                            onChanged: _searchMedications,
                            style: const TextStyle(fontFamily: 'Tajawal'),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن دواء...',
                              hintStyle: const TextStyle(fontFamily: 'Tajawal'),
                              prefixIcon: _isSearching
                                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                                  : const Icon(Icons.search, color: Color(0xFF94A3B8)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.library_books_outlined, color: Color(0xFF00B4FF)),
                          tooltip: 'قالب',
                          onPressed: _loadTemplate,
                        ),
                      ],
                    ),
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8EDF8)),
                        ),
                        child: Column(
                          children: _searchResults.take(5).map((med) => ListTile(
                            dense: true,
                            title: Text(med.name, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14)),
                            leading: Icon(med.isFavorite ? Icons.star : Icons.medication_outlined,
                              color: med.isFavorite ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8), size: 20),
                            onTap: () => _addMedication(med),
                          )).toList(),
                        ),
                      ),
                    if (_medications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: Text('لم يتم إضافة أدوية بعد', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8)))),
                      )
                    else
                      ...List.generate(_medications.length, (i) => _medTile(i)),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildPaymentBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isPaid ? Icons.check_circle_rounded : Icons.payments_outlined,
              color: _isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPaid ? 'تم استلام الدفع' : 'بانتظار الدفع',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
                Text(
                  'سعر الكشف: ${widget.totalPrice.toInt()} ج.م',
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPaid,
            onChanged: (v) => setState(() => _isPaid = v),
            activeThumbColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFFD1FAE5),
          ),
        ],
      ),
    );
  }

  Widget _diagnosisField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _diagnosisCtrl,
          maxLines: 2,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
          onChanged: (v) {
            if (v.length >= 2) {
              _loadDiagnoses(q: v);
              setState(() => _showDiagnosisSuggestions = true);
            } else {
              setState(() => _showDiagnosisSuggestions = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'التشخيص *',
            hintStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        if (_showDiagnosisSuggestions && _diagnosisSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EDF8)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(
              children: _diagnosisSuggestions.take(4).map((d) => ListTile(
                dense: true,
                leading: const Icon(Icons.history_rounded, size: 16, color: Color(0xFF00B4FF)),
                title: Text(d['name'] as String, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
                onTap: () {
                  _diagnosisCtrl.text = d['name'] as String;
                  setState(() => _showDiagnosisSuggestions = false);
                },
              )).toList(),
            ),
          ),
      ],
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
        bottomLeft:  Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('كشف طبي جديد', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('المريض: ${widget.patientName}', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSaveBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    color: Colors.white,
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A2952),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isSaving ? null : _save,
        child: _isSaving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('حفظ الكشف', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    ),
  );

  Widget _card(String? title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8EDF8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
          const SizedBox(height: 12),
        ],
        ...children,
      ],
    ),
  );

  Widget _textArea(TextEditingController ctrl, String hint, {int maxLines = 1}) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );

  Widget _vitalField(TextEditingController ctrl, String label, String unit) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.text,
    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      suffixText: unit,
      suffixStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
  );

  Widget _medTile(int idx) {
    final med = _medications[idx];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.medication, color: Color(0xFF00B4FF), size: 18),
                const SizedBox(width: 6),
                Text(med['name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2952))),
              ]),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => _removeMedication(idx),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _medSubField(idx, 'dosage',    'الجرعة')),
            const SizedBox(width: 8),
            Expanded(child: _medSubField(idx, 'frequency', 'التكرار')),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _medSubField(idx, 'route',    'طريقة الاستخدام')),
            const SizedBox(width: 8),
            Expanded(child: _medSubField(idx, 'duration', 'المدة')),
          ]),
          const SizedBox(height: 6),
          _medSubField(idx, 'instructions', 'تعليمات إضافية'),
        ],
      ),
    );
  }

  Widget _medSubField(int idx, String key, String label) => TextFormField(
    initialValue: _medications[idx][key] as String? ?? '',
    onChanged: (v) => _medications[idx][key] = v,
    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12),
    decoration: InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF94A3B8)),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE8EDF8))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
  );
}
