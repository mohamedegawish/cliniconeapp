import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';
import 'doctor_profile_screen.dart';
import 'notifications_screen.dart';
import 'medications_screen.dart';
import 'prescription_templates_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileService = ProfileService(ApiClient());
  ProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _profileService.getProfile();
      if (mounted) setState(() { _profile = p; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟', style: TextStyle(fontFamily: 'Tajawal')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal'))),
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, '/login'); },
            child: const Text('خروج', style: TextStyle(fontFamily: 'Tajawal', color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc   = _profile?.doctor;
    final name  = _profile?.name  ?? '';
    final email = _profile?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Profile summary card
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorSelfProfileScreen()));
                              _load();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8EDF8)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFF00B4FF),
                                    backgroundImage: doc?.photo != null ? NetworkImage(doc!.photo!) : null,
                                    child: doc?.photo == null
                                        ? Text(initial, style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
                                        Text(email, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF94A3B8))),
                                        if (doc?.specialty != null)
                                          Text(doc!.specialty!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF00B4FF))),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.edit_outlined, color: Color(0xFF00B4FF), size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _group('الطب والكشف', [
                            _item(Icons.medication_outlined,       'قاعدة الأدوية',     () => _push(const MedicationsScreen())),
                            _item(Icons.library_books_outlined,    'قوالب الوصفات',     () => _push(const PrescriptionTemplatesScreen())),
                          ]),

                          const SizedBox(height: 16),

                          _group('الإشعارات والتواصل', [
                            _item(Icons.notifications_none_outlined, 'الإشعارات', () => _push(const NotificationsScreen())),
                          ]),

                          const SizedBox(height: 16),

                          _group('الأمان والحساب', [
                            _item(Icons.person_outline,  'البيانات الشخصية',     () => _push(const DoctorSelfProfileScreen())),
                            _item(Icons.lock_outline,    'تغيير كلمة المرور',    _showChangePassword),
                          ]),

                          const SizedBox(height: 30),

                          // Logout
                          GestureDetector(
                            onTap: _logout,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5F5),
                                border: Border.all(color: const Color(0xFFFFE0E0)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE53E3E))),
                                  SizedBox(width: 8),
                                  Icon(Icons.logout, color: Color(0xFFE53E3E), size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _showChangePassword() {
    final currCtrl = TextEditingController();
    final newCtrl  = TextEditingController();
    final confCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تغيير كلمة المرور', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
            const SizedBox(height: 16),
            _passField(currCtrl, 'كلمة المرور الحالية'),
            const SizedBox(height: 10),
            _passField(newCtrl,  'كلمة المرور الجديدة'),
            const SizedBox(height: 10),
            _passField(confCtrl, 'تأكيد كلمة المرور'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2952), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await _profileService.changePassword(
                      currentPassword: currCtrl.text,
                      newPassword: newCtrl.text,
                      newPasswordConfirmation: confCtrl.text,
                    );
                    if (mounted) _snack('تم تغيير كلمة المرور بنجاح');
                  } catch (e) {
                    if (mounted) _snack(e.toString(), error: true);
                  }
                },
                child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passField(TextEditingController ctrl, String label) => TextField(
    controller: ctrl,
    obscureText: true,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Tajawal'),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  void _snack(String msg, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: error ? Colors.red : const Color(0xFF10B981)),
  );

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF0C1A3A), Color(0xFF0A2952)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
          ),
        ),
        const Text('الإعدادات', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(width: 36),
      ],
    ),
  );

  Widget _group(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
      ),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EDF8))),
        child: Column(
          children: items.asMap().entries.map((e) => Column(children: [
            e.value,
            if (e.key < items.length - 1) const Divider(height: 1, thickness: 1, color: Color(0xFFF0F4FF), indent: 56),
          ])).toList(),
        ),
      ),
    ],
  );

  Widget _item(IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: const Color(0xFF0A2952), size: 20),
    ),
    title: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A2952))),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCBD5E1)),
    onTap: onTap,
  );
}
