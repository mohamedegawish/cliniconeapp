import 'package:flutter/material.dart';
import '../../components/admin_drawer.dart';

class AdminPatientsScreen extends StatelessWidget {
  const AdminPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: const AdminDrawer(currentRoute: '/admin_patients'),
      body: CustomScrollView(
        slivers: [
          // Premium Header
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
                  onTap: () => Navigator.pushNamed(context, '/admin_patient_form'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('إضافة مريض', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                child: Stack(
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
                            colors: [const Color(0xFF00B4FF).withValues(alpha: 0.4), Colors.transparent],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'إدارة المرضى',
                              style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إجمالي المرضى المسجلين في النظام: 6',
                              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                    // Filter & Stats Box (without add button since it moved to AppBar)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0A2952).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('فلترة ومتابعة', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                  value: 'الكل',
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                                  items: const [
                                    DropdownMenuItem(value: 'الكل', child: Text('جميع العيادات', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF0A2952)))),
                                  ],
                                  onChanged: (val) {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF00B4FF)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('سجل المرضى', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // Patients List
                    _buildPatientCard(context, 'Hhgfhjgg', '01508825550', 'عيادة كلينك ون', '2026-05-02'),
                    const SizedBox(height: 12),
                    _buildPatientCard(context, 'محمد خالد', '01121202332', 'عيادة كلينك ون', '2026-04-29'),
                    const SizedBox(height: 12),
                    _buildPatientCard(context, 'Mohamed Elsheikh', '01004947096', 'عيادة كلينك ون', '2026-04-27'),
                    const SizedBox(height: 12),
                    _buildPatientCard(context, 'Esraa Mohamed', '01004555555', 'Test Clinic', '2026-04-27'),
                    
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, String name, String phone, String clinic, String lastVisit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00B4FF).withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'M',
                  style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF00B4FF), fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(phone, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.local_hospital_rounded, size: 12, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(clinic, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text('آخر زيارة: $lastVisit', style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('جارٍ فتح ملف المريض...', style: TextStyle(fontFamily: 'Tajawal')),
                        backgroundColor: Color(0xFF0A2952),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF00B4FF), size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE0F2FE),
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

