import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../components/custom_text_field.dart';
import '../../components/primary_button.dart';

class DoctorFormScreen extends StatefulWidget {
  const DoctorFormScreen({super.key});

  @override
  State<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends State<DoctorFormScreen> {
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة / تعديل طبيب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'اسم الطبيب',
              hint: 'أدخل الاسم كاملاً',
              controller: _nameController,
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'التخصص',
              hint: 'أدخل التخصص (مثال: أطفال، أسنان)',
              controller: _specialtyController,
              prefixIcon: const Icon(Icons.medical_services),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'البريد الإلكتروني',
              hint: 'البريد المستخدم لتسجيل الدخول',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'كلمة المرور',
              hint: 'كلمة مرور حساب الطبيب',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'حفظ البيانات',
              onPressed: () {
                if (_nameController.text.isEmpty || _specialtyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إكمال جميع الحقول المطلوبة!'), backgroundColor: Colors.red));
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الطبيب بنجاح'), backgroundColor: AppColors.statusCompleted),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
