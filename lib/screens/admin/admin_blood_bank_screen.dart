import 'package:flutter/material.dart';
import '../../components/admin_drawer.dart';

class AdminBloodBankScreen extends StatelessWidget {
  const AdminBloodBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: const AdminDrawer(currentRoute: '/admin_blood_bank'),
      body: CustomScrollView(
        slivers: [
          // Premium Header (Red Theme for Blood Bank)
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF991B1B),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/admin_donors_db'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.folder_shared_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('قاعدة المتبرعين', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                    colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
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
                            colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
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
                            const Row(
                              children: [
                                Icon(Icons.water_drop_rounded, color: Colors.white, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'إدارة بنك الدم',
                                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'نظام المتابعة والتنسيق المتكامل لعمليات التبرع',
                              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
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
                    // Stats Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0A2952).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.water_drop_rounded, color: Color(0xFFEF4444), size: 28),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إجمالي المتبرعين', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 2),
                              const Text(
                                '47',
                                style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFEF4444), fontSize: 28, fontWeight: FontWeight.bold, height: 1),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                            child: const Text('متبرع متاح', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildStatCard('طلبات معلقة', '1', Icons.bloodtype_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
                        _buildStatCard('تمت بنجاح', '0', Icons.handshake_rounded, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                        _buildStatCard('جاري التواصل', '0', Icons.support_agent_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                        _buildStatCard('إلغاء الطلب', '0', Icons.cancel_rounded, const Color(0xFF64748B), const Color(0xFFF1F5F9)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('طلبات الدم الأخيرة', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8EDF8)),
                          ),
                          child: const Icon(Icons.filter_list_rounded, color: Color(0xFF0A2952), size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Requests List
                    _buildRequestCard(context, 'محمد أحمد', '01001234567', 'A+', 'منذ 2 ساعة'),
                    const SizedBox(height: 12),
                    _buildRequestCard(context, 'سارة خالد', '01112345678', 'O-', 'منذ 4 ساعات'),
                    const SizedBox(height: 12),
                    _buildRequestCard(context, 'عمر حسن', '01223456789', 'B+', 'منذ 1 يوم'),
                    
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold, color: color, height: 1)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String name, String phone, String bloodType, String time) {
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
                gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFF991B1B)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Text(
                  bloodType,
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(phone, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جارٍ مراجعة طلب التبرع...', style: TextStyle(fontFamily: 'Tajawal')),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
              label: const Text('مراجعة', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF0A2952), fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                side: const BorderSide(color: Color(0xFFE8EDF8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

