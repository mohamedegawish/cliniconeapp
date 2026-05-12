import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAuth = auth.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header & Profile Card Stack
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  children: [
                    // Gradient Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 60, bottom: 70),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'حسابي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الإعدادات والملف الشخصي',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Empty space for the card to overlap into, expanding the stack bounds
                    const SizedBox(height: 60),
                  ],
                ),
                
                // Profile Card
                Positioned(
                  bottom: 0,
                  left: 20,
                  right: 20,
                  child: isAuth 
                    ? _buildAuthenticatedCard(auth)
                    : _buildUnauthenticatedCard(context),
                ),
              ],
            ),
            
            const SizedBox(height: 20), // Space after the card
            
            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 12),
                    child: Text(
                      'الإعدادات العامة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Color(0xFF0A2952),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8EDF8)),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          icon: Icons.language,
                          title: 'اللغة (Language)',
                          trailingText: 'العربية',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('سيتم دعم تبديل اللغة قريباً', style: TextStyle(fontFamily: 'Tajawal'))),
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8EDF8)),
                        _buildSettingsItem(
                          icon: Icons.notifications_active_outlined,
                          title: 'الإشعارات',
                          trailingWidget: Switch(
                            value: true, 
                            onChanged: (v) {}, 
                            activeColor: const Color(0xFF00B4FF),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8EDF8)),
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          title: 'المساعدة والدعم',
                          trailingWidget: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('صفحة المساعدة والدعم قيد التطوير', style: TextStyle(fontFamily: 'Tajawal'))),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  if (isAuth) ...[
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFEE2E2)), // Light red border
                      ),
                      child: _buildSettingsItem(
                        icon: Icons.logout,
                        iconColor: const Color(0xFFDC2626), // Red
                        title: 'تسجيل الخروج',
                        titleColor: const Color(0xFFDC2626),
                        onTap: () {
                          auth.logout();
                          Navigator.pushReplacementNamed(context, '/main_container');
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedCard(AuthProvider auth) {
    final String role = auth.user?.role == 'doctor' ? 'طبيب' : (auth.user?.role == 'admin' ? 'مدير' : 'مريض');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4FF).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00B4FF).withValues(alpha: 0.3), width: 3),
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, size: 36, color: Color(0xFF00B4FF)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.user?.name ?? 'مستخدم',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Color(0xFF0A2952),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      color: Color(0xFF00B4FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EDF8)),
            ),
            child: const Icon(Icons.edit, color: Color(0xFF00B4FF), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4FF).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EDF8)),
            ),
            child: const Icon(Icons.account_circle, size: 40, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'أنت غير مسجل الدخول',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Color(0xFF0A2952),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4FF), Color(0xFF0077FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                'تسجيل الدخول',
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailingWidget,
    Color iconColor = const Color(0xFF00B4FF),
    Color titleColor = const Color(0xFF0A2952),
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: titleColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: trailingWidget ?? (trailingText != null 
        ? Text(
            trailingText, 
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )
          )
        : null),
    );
  }
}

