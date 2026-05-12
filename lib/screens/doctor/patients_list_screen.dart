import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final _patientService = PatientService(ApiClient());
  List<PatientModel> _patients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() => _isLoading = true);
    try {
      final data = await _patientService.getDoctorPatients();
      if (mounted) {
        setState(() {
          _patients = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPatientDialog({PatientModel? patient}) {
    final nameController = TextEditingController(text: patient?.name ?? '');
    final phoneController = TextEditingController(text: patient?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient == null ? 'إضافة مريض جديد' : 'تعديل بيانات المريض',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(0xFF0A2952),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ملاحظة: يمكنك فقط استعراض مرضى العيادة من لوحة الطبيب. الإضافة والتعديل تتم عبر موظف الاستقبال أو المسؤول.',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF00B4FF), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8EDF8), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00B4FF), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPatients = _patients.where((p) {
      final nameMatches = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final phoneMatches = (p.phone ?? '').contains(_searchQuery);
      return nameMatches || phoneMatches;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Header
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
                        GestureDetector(
                          onTap: () => _showPatientDialog(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: Color(0xFF0A2952), size: 16),
                                SizedBox(width: 4),
                                Text('إضافة مريض', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF0A2952), fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'إدارة المرضى',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سجل شامل بجميع مرضى العيادة',
                      style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha:0.8), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search Bar Overlapping
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFF0A2952).withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو رقم الهاتف...',
                    hintStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF00B4FF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
          
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
                : filteredPatients.isEmpty 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 80, color: const Color(0xFF94A3B8).withValues(alpha:0.5)),
                        const SizedBox(height: 16),
                        const Text('لا يوجد مرضى مطابقين للبحث', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPatients,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          final p = filteredPatients[index];
                          final isActve = true; // All fetched patients are active or handle based on status if you add it to the backend model
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE8EDF8)),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.02), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              children: [
                                Row(
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
                                          p.name.isNotEmpty ? p.name.substring(0, 1) : 'م',
                                          style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF00B4FF), fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(p.name, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 16, fontWeight: FontWeight.bold)),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isActve ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'نشط',
                                                  style: TextStyle(fontFamily: 'Tajawal', color: isActve ? const Color(0xFF10B981) : const Color(0xFFDC2626), fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 12, color: Color(0xFF64748B)),
                                              const SizedBox(width: 4),
                                              Text(p.phone ?? '-', style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.shield_outlined, size: 12, color: Color(0xFF64748B)),
                                              const SizedBox(width: 4),
                                              Text(p.email ?? 'لا يوجد تأمين', style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFE8EDF8)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildActionButton(Icons.remove_red_eye_outlined, 'عرض التفاصيل', const Color(0xFF00B4FF), () {
                                      Navigator.pushNamed(context, '/patient_detail', arguments: {'patient': p});
                                    }),
                                    _buildActionButton(Icons.edit_outlined, 'تعديل', const Color(0xFFF59E0B), () {
                                      _showPatientDialog(patient: p);
                                    }),
                                  ],
                                ),
                              ],
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

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
