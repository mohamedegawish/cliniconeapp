import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/prescription_template_model.dart';
import '../../services/template_service.dart';

class PrescriptionTemplatesScreen extends StatefulWidget {
  const PrescriptionTemplatesScreen({super.key});

  @override
  State<PrescriptionTemplatesScreen> createState() => _PrescriptionTemplatesScreenState();
}

class _PrescriptionTemplatesScreenState extends State<PrescriptionTemplatesScreen> {
  final _service = TemplateService(ApiClient());
  List<PrescriptionTemplateModel> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.getTemplates();
      if (mounted) setState(() { _templates = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف القالب', style: TextStyle(fontFamily: 'Cairo')),
        content: Text('هل تريد حذف قالب "$name"؟', style: const TextStyle(fontFamily: 'Tajawal')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Tajawal', color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteTemplate(id);
      setState(() => _templates.removeWhere((t) => t.id == id));
      if (mounted) _snack('تم حذف القالب');
    } catch (e) {
      if (mounted) _snack(e.toString(), error: true);
    }
  }

  void _showCreate() {
    final nameCtrl = TextEditingController();
    final items    = <Map<String, dynamic>>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          void addItem() => setSheetState(() => items.add({'name': '', 'dosage': '', 'frequency': '', 'duration': ''}));
          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('قالب جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'اسم القالب',
                      labelStyle: const TextStyle(fontFamily: 'Tajawal'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontFamily: 'Tajawal'),
                  ),
                  const SizedBox(height: 16),
                  const Text('الأدوية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ...List.generate(items.length, (i) => Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: items[i]['name'] as String,
                            onChanged: (v) => items[i]['name'] = v,
                            decoration: InputDecoration(
                              hintText: 'اسم الدواء *',
                              hintStyle: const TextStyle(fontFamily: 'Tajawal'),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                            ),
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                          onPressed: () => setSheetState(() => items.removeAt(i)),
                        ),
                      ],
                    ),
                  )),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة دواء', style: TextStyle(fontFamily: 'Tajawal')),
                    onPressed: addItem,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2952),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty || items.isEmpty) return;
                        Navigator.pop(ctx);
                        try {
                          await _service.createTemplate(name: nameCtrl.text.trim(), items: items);
                          _load();
                          if (mounted) _snack('تم إنشاء القالب');
                        } catch (e) {
                          if (mounted) _snack(e.toString(), error: true);
                        }
                      },
                      child: const Text('حفظ القالب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _snack(String msg, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: error ? Colors.red : const Color(0xFF10B981)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0A2952),
        onPressed: _showCreate,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('قالب جديد', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
      ),
      body: Column(
        children: [
          _header(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF))))
          else if (_templates.isEmpty)
            Expanded(child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.library_books_outlined, size: 64, color: Color(0xFFCBD5E1)),
                const SizedBox(height: 16),
                const Text('لا توجد قوالب بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Color(0xFF94A3B8))),
                const SizedBox(height: 8),
                const Text('أنشئ قالباً لتسريع وصف الأدوية', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8))),
              ]),
            ))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                color: const Color(0xFF00B4FF),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _templates.length,
                  itemBuilder: (_, i) => _templateCard(_templates[i]),
                ),
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
        const Text('قوالب الوصفات', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _templateCard(PrescriptionTemplateModel t) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8EDF8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.library_books, color: Color(0xFF00B4FF), size: 22),
              const SizedBox(width: 10),
              Text(t.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
            ]),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
              onPressed: () => _delete(t.id, t.name),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...t.items.take(3).map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            const Icon(Icons.medication_outlined, size: 14, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(item.name, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF64748B))),
            if (item.dosage != null) Text(' — ${item.dosage}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF94A3B8))),
          ]),
        )),
        if (t.items.length > 3)
          Text('+${t.items.length - 3} أدوية أخرى', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF94A3B8))),
      ],
    ),
  );
}
