import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';

class DoctorSelfProfileScreen extends StatefulWidget {
  const DoctorSelfProfileScreen({super.key});

  @override
  State<DoctorSelfProfileScreen> createState() => _DoctorSelfProfileScreenState();
}

class _DoctorSelfProfileScreenState extends State<DoctorSelfProfileScreen> {
  final _service = ProfileService(ApiClient());
  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isSaving  = false;
  bool _editMode  = false;

  final _nameCtrl         = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _specialtyCtrl    = TextEditingController();
  final _bioCtrl          = TextEditingController();
  final _qualCtrl         = TextEditingController();
  final _govCtrl          = TextEditingController();
  final _cityCtrl         = TextEditingController();
  final _expCtrl          = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _specialtyCtrl, _bioCtrl, _qualCtrl, _govCtrl, _cityCtrl, _expCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final p = await _service.getProfile();
      if (mounted) {
        _fillControllers(p);
        setState(() { _profile = p; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _fillControllers(ProfileModel p) {
    _nameCtrl.text      = p.name;
    _phoneCtrl.text     = p.doctor?.phone ?? '';
    _specialtyCtrl.text = p.doctor?.specialty ?? '';
    _bioCtrl.text       = p.doctor?.bio ?? '';
    _qualCtrl.text      = p.doctor?.qualification ?? '';
    _govCtrl.text       = p.doctor?.governorate ?? '';
    _cityCtrl.text      = p.doctor?.city ?? '';
    _expCtrl.text       = p.doctor?.experienceYears?.toString() ?? '';
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _service.updateProfile(
        name:            _nameCtrl.text.trim(),
        phone:           _phoneCtrl.text.trim(),
        specialty:       _specialtyCtrl.text.trim(),
        bio:             _bioCtrl.text.trim(),
        qualification:   _qualCtrl.text.trim(),
        governorate:     _govCtrl.text.trim(),
        city:            _cityCtrl.text.trim(),
        experienceYears: int.tryParse(_expCtrl.text.trim()),
      );
      if (mounted) {
        setState(() { _editMode = false; _isSaving = false; });
        _showSuccess('تم حفظ البيانات بنجاح');
        await _load();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError(e.toString());
      }
    }
  }

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
            const SizedBox(height: 20),
            _passField(currCtrl, 'كلمة المرور الحالية'),
            const SizedBox(height: 12),
            _passField(newCtrl,  'كلمة المرور الجديدة'),
            const SizedBox(height: 12),
            _passField(confCtrl, 'تأكيد كلمة المرور الجديدة'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2952),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await _service.changePassword(
                      currentPassword:          currCtrl.text,
                      newPassword:              newCtrl.text,
                      newPasswordConfirmation:  confCtrl.text,
                    );
                    if (mounted) _showSuccess('تم تغيير كلمة المرور بنجاح');
                  } catch (e) {
                    if (mounted) _showError(e.toString());
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

  void _showError(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: Colors.red));

  void _showSuccess(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: const Color(0xFF10B981)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildBody()),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF0A2952),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: _editMode ? _save : () => setState(() => _editMode = true),
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(_editMode ? 'حفظ' : 'تعديل',
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: _profile?.doctor?.photo != null
                        ? NetworkImage(_profile!.doctor!.photo!) : null,
                    child: _profile?.doctor?.photo == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_profile?.name ?? '', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (_profile?.doctor?.specialty != null)
                Text(_profile!.doctor!.specialty!, style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _section('البيانات الأساسية', [
            _field('الاسم', _nameCtrl, Icons.person_outline),
            _field('التخصص', _specialtyCtrl, Icons.medical_services_outlined),
            _field('رقم الهاتف', _phoneCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone),
            _field('سنوات الخبرة', _expCtrl, Icons.work_outline, keyboardType: TextInputType.number),
          ]),
          const SizedBox(height: 16),
          _section('المعلومات المهنية', [
            _field('المؤهل العلمي', _qualCtrl, Icons.school_outlined),
            _field('نبذة تعريفية', _bioCtrl, Icons.info_outline, maxLines: 3),
          ]),
          const SizedBox(height: 16),
          _section('الموقع الجغرافي', [
            _field('المحافظة', _govCtrl, Icons.location_on_outlined),
            _field('المدينة', _cityCtrl, Icons.location_city_outlined),
          ]),
          const SizedBox(height: 16),
          _section('الأمان', [
            _actionTile(Icons.lock_outline, 'تغيير كلمة المرور', _showChangePassword),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
      ),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EDF8))),
        child: Column(children: children),
      ),
    ],
  );

  Widget _field(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: ctrl,
        enabled: _editMode,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF0A2952)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF00B4FF), size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFF00B4FF).withValues(alpha: 0.4))),
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) => ListTile(
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
