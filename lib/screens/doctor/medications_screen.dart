import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/medication_model.dart';
import '../../services/medication_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final _service    = MedicationService(ApiClient());
  final _searchCtrl = TextEditingController();

  List<MedicationModel> _results     = [];
  bool _isSearching = false;
  bool _isAdding    = false;
  String _query     = '';

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    setState(() { _query = q; _isSearching = true; });
    try {
      final res = await _service.search(q);
      if (mounted) setState(() { _results = res; _isSearching = false; });
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _toggleFavorite(MedicationModel med) async {
    try {
      final isFav = await _service.toggleFavorite(med.id);
      setState(() {
        final idx = _results.indexWhere((m) => m.id == med.id);
        if (idx != -1) _results[idx].isFavorite = isFav;
      });
    } catch (_) {}
  }

  Future<void> _showAddForm() async {
    final nameCtrl         = TextEditingController();
    final genericCtrl      = TextEditingController();
    final dosageCtrl       = TextEditingController();
    final frequencyCtrl    = TextEditingController();
    final routeCtrl        = TextEditingController();
    final durationCtrl     = TextEditingController();
    final instructionsCtrl = TextEditingController();
    final formKey          = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MedicationFormSheet(
        formKey:          formKey,
        nameCtrl:         nameCtrl,
        genericCtrl:      genericCtrl,
        dosageCtrl:       dosageCtrl,
        frequencyCtrl:    frequencyCtrl,
        routeCtrl:        routeCtrl,
        durationCtrl:     durationCtrl,
        instructionsCtrl: instructionsCtrl,
      ),
    );

    if (confirmed != true || nameCtrl.text.trim().isEmpty) return;
    setState(() => _isAdding = true);
    try {
      final med = await _service.store(
        name:                nameCtrl.text.trim(),
        generic:             genericCtrl.text.trim().isEmpty     ? null : genericCtrl.text.trim(),
        defaultDosage:       dosageCtrl.text.trim().isEmpty      ? null : dosageCtrl.text.trim(),
        defaultFrequency:    frequencyCtrl.text.trim().isEmpty   ? null : frequencyCtrl.text.trim(),
        defaultRoute:        routeCtrl.text.trim().isEmpty       ? null : routeCtrl.text.trim(),
        defaultDuration:     durationCtrl.text.trim().isEmpty    ? null : durationCtrl.text.trim(),
        defaultInstructions: instructionsCtrl.text.trim().isEmpty ? null : instructionsCtrl.text.trim(),
      );
      setState(() { _results.insert(0, med); _isAdding = false; });
      if (mounted) _snack('تم إضافة ${med.name}');
    } catch (e) {
      if (mounted) { setState(() => _isAdding = false); _snack(e.toString(), error: true); }
    }
  }

  void _snack(String msg, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: error ? Colors.red : const Color(0xFF10B981),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2952),
        onPressed: _isAdding ? null : _showAddForm,
        child: _isAdding
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) { if (v != _query) _search(v); },
              style: const TextStyle(fontFamily: 'Tajawal'),
              decoration: InputDecoration(
                hintText: 'ابحث عن دواء...',
                hintStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                suffixIcon: _isSearching
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B4FF))))
                    : _searchCtrl.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); _search(''); })
                        : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF8))),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _results.isEmpty && !_isSearching
                ? const Center(child: Text('لا توجد نتائج', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8))))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _tile(_results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Container(
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('قاعدة الأدوية', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('بحث وإدارة المفضلة', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    ),
  );

  Widget _tile(MedicationModel med) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: med.isFavorite ? const Color(0xFFFEF3C7) : const Color(0xFFE8EDF8)),
    ),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: med.isMine ? const Color(0xFFEFF8FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.medication,
            color: med.isMine ? const Color(0xFF00B4FF) : const Color(0xFF94A3B8),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(med.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A2952))),
              if (med.generic != null && med.generic!.isNotEmpty)
                Text(med.generic!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF64748B))),
              if (med.defaultDosage != null || med.defaultFrequency != null)
                Text(
                  [med.defaultDosage, med.defaultFrequency].where((v) => v != null && v.isNotEmpty).join(' · '),
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              if (med.isMine)
                const Text('أضفته أنت', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF00B4FF))),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            med.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: med.isFavorite ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
            size: 26,
          ),
          onPressed: () => _toggleFavorite(med),
        ),
      ],
    ),
  );
}

class _MedicationFormSheet extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController genericCtrl;
  final TextEditingController dosageCtrl;
  final TextEditingController frequencyCtrl;
  final TextEditingController routeCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController instructionsCtrl;

  const _MedicationFormSheet({
    required this.formKey,
    required this.nameCtrl,
    required this.genericCtrl,
    required this.dosageCtrl,
    required this.frequencyCtrl,
    required this.routeCtrl,
    required this.durationCtrl,
    required this.instructionsCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFEFF8FF), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.medication, color: Color(0xFF00B4FF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إضافة دواء جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
                      Text('يمكن تعيين قيم افتراضية للروشتة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            // Form
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _sectionLabel('الاسم التجاري *'),
                    _field(nameCtrl, 'مثال: Amoxil 500mg', required: true),
                    const SizedBox(height: 14),

                    _sectionLabel('الاسم العلمي (الجنيريك)'),
                    _field(genericCtrl, 'مثال: Amoxicillin'),
                    const SizedBox(height: 20),

                    _sectionLabel('القيم الافتراضية في الروشتة'),
                    const Text(
                      'ستُملأ تلقائياً عند إضافة الدواء للكشف',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _sectionLabel('الجرعة'),
                        _field(dosageCtrl, 'مثال: 500mg'),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _sectionLabel('التكرار'),
                        _field(frequencyCtrl, 'مثال: 3 مرات يومياً'),
                      ])),
                    ]),
                    const SizedBox(height: 14),

                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _sectionLabel('طريقة الاستخدام'),
                        _field(routeCtrl, 'مثال: فم'),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _sectionLabel('المدة'),
                        _field(durationCtrl, 'مثال: 7 أيام'),
                      ])),
                    ]),
                    const SizedBox(height: 14),

                    _sectionLabel('تعليمات إضافية'),
                    _field(instructionsCtrl, 'مثال: يؤخذ بعد الأكل', maxLines: 2),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE8EDF8))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE8EDF8)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2952),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('حفظ الدواء', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
  );

  Widget _field(TextEditingController ctrl, String hint, {bool required = false, int maxLines = 1}) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8EDF8))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8EDF8))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00B4FF))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null : null,
  );
}
