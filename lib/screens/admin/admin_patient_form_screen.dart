import 'package:flutter/material.dart';
import '../../components/custom_text_field.dart';
import '../../components/primary_button.dart';

class AdminPatientFormScreen extends StatefulWidget {
  const AdminPatientFormScreen({super.key});

  @override
  State<AdminPatientFormScreen> createState() => _AdminPatientFormScreenState();
}

class _AdminPatientFormScreenState extends State<AdminPatientFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة / تعديل مريض')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'اسم المريض',
              hint: 'أدخل الاسم الثلاثي',
              controller: _nameController,
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'رقم الهاتف',
              hint: '01xxxxxxxxx',
              controller: _phoneController,
              prefixIcon: const Icon(Icons.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'حفظ بيانات المريض',
              onPressed: () {
                if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إكمال جميع الحقول المطلوبة!'), backgroundColor: Colors.red));
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المريض بنجاح'), backgroundColor: Colors.green));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
