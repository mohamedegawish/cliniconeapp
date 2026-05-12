import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;
  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF194A6E)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('كلينيك وان', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('لوحة المدير العام', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: currentRoute == '/admin_home' ? AppColors.primary : Colors.grey),
            title: Text('لوحة التحكم', style: TextStyle(color: currentRoute == '/admin_home' ? AppColors.primary : Colors.black87, fontWeight: currentRoute == '/admin_home' ? FontWeight.bold : FontWeight.normal)),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_home'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text('الإدارة', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital, color: currentRoute == '/admin_clinics' ? AppColors.primary : Colors.grey),
            title: Text('العيادات', style: TextStyle(color: currentRoute == '/admin_clinics' ? AppColors.primary : Colors.black87, fontWeight: currentRoute == '/admin_clinics' ? FontWeight.bold : FontWeight.normal)),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_clinics'),
          ),
          ListTile(
            leading: Icon(Icons.medical_services, color: currentRoute == '/admin_doctors' ? AppColors.primary : Colors.grey),
            title: Text('الأطباء', style: TextStyle(color: currentRoute == '/admin_doctors' ? AppColors.primary : Colors.black87, fontWeight: currentRoute == '/admin_doctors' ? FontWeight.bold : FontWeight.normal)),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_doctors'),
          ),
          ListTile(
            leading: Icon(Icons.people, color: currentRoute == '/admin_patients' ? AppColors.primary : Colors.grey),
            title: Text('المرضى', style: TextStyle(color: currentRoute == '/admin_patients' ? AppColors.primary : Colors.black87, fontWeight: currentRoute == '/admin_patients' ? FontWeight.bold : FontWeight.normal)),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_patients'),
          ),
          ListTile(
            leading: Icon(Icons.bloodtype, color: currentRoute == '/admin_blood_bank' ? AppColors.primary : Colors.red.shade300),
            title: Text('بنك الدم', style: TextStyle(color: currentRoute == '/admin_blood_bank' ? AppColors.primary : Colors.black87, fontWeight: currentRoute == '/admin_blood_bank' ? FontWeight.bold : FontWeight.normal)),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_blood_bank'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
