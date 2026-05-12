import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../components/admin_drawer.dart';
import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final _service = DoctorService(ApiClient());

  List<DoctorModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.adminGetDoctors();
      if (mounted) setState(() { _doctors = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDoctor(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذا الطبيب؟', style: TextStyle(fontFamily: 'Tajawal')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.adminDeleteDoctor(id);
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الحذف', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: Color(0xFFEF4444)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: const AdminDrawer(currentRoute: '/admin_doctors'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF0A2952),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin_doctor_form').then((_) => _load()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('إضافة طبيب', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
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
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 36, left: 24, right: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إدارة الأطباء',
                            style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoading ? 'جارٍ التحميل...' : 'إجمالي الأطباء المسجلين: ${_doctors.length}',
                            style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Total count card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: const Color(0xFF0A2952).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.medical_services_rounded, color: Color(0xFF00B4FF), size: 28),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إجمالي الأطباء', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                              Text(
                                _isLoading ? '--' : '${_doctors.length}',
                                style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 28, fontWeight: FontWeight.bold, height: 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text('الأطباء المسجلين', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                    else if (_doctors.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('لا يوجد أطباء مسجلين', style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey)),
                        ),
                      )
                    else
                      ...List.generate(_doctors.length, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDoctorCard(_doctors[i]),
                      )),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doc) {
    final initial = doc.name.isNotEmpty ? doc.name[0] : '؟';
    final isActive = doc.status == 'active' || doc.status == null;
    final clinicName = doc.clinics?.isNotEmpty == true ? doc.clinics!.first['name'] as String? ?? '' : (doc.location ?? '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EDF8)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF0A2952)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(initial, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.name, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (doc.specialty.isNotEmpty)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.medical_services_rounded, size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(doc.specialty, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                            ]),
                          if (clinicName.isNotEmpty)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.local_hospital_rounded, size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(clinicName, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                            ]),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Text(isActive ? 'نشط' : 'موقوف', style: TextStyle(fontFamily: 'Tajawal', color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (doc.experienceYears != null || doc.consultationFee != null) ...[
            const Divider(height: 1, color: Color(0xFFE8EDF8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  if (doc.experienceYears != null)
                    Expanded(child: _buildStat('الخبرة', '${doc.experienceYears} سنة', Icons.workspace_premium_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7))),
                  if (doc.consultationFee != null)
                    Expanded(child: _buildStat('الكشف', '${doc.consultationFee!.toInt()} ج', Icons.payments_rounded, const Color(0xFF10B981), const Color(0xFFD1FAE5))),
                  if (doc.clinicsCount != null)
                    Expanded(child: _buildStat('العيادات', '${doc.clinicsCount}', Icons.business_rounded, const Color(0xFF8B5CF6), const Color(0xFFEDE9FE))),
                ],
              ),
            ),
          ],

          const Divider(height: 1, color: Color(0xFFE8EDF8)),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doc.email != null)
                      Row(children: [
                        const Icon(Icons.email_rounded, color: Color(0xFF94A3B8), size: 14),
                        const SizedBox(width: 6),
                        Text(doc.email!, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 12)),
                      ]),
                    if (doc.phone != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.phone_rounded, color: Color(0xFF94A3B8), size: 14),
                        const SizedBox(width: 6),
                        Text(doc.phone!, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/admin_doctor_form', arguments: doc).then((_) => _load()),
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF00B4FF), size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE0F2FE),
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteDoctor(doc.id),
                      icon: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color, Color bgColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2952), height: 1), overflow: TextOverflow.ellipsis),
              Text(label, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 10), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
