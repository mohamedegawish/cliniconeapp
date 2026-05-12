import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../components/custom_text_field.dart';
import '../../components/primary_button.dart';

class ClinicFormScreen extends StatefulWidget {
  const ClinicFormScreen({super.key});

  @override
  State<ClinicFormScreen> createState() => _ClinicFormScreenState();
}

class _ClinicFormScreenState extends State<ClinicFormScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة / تعديل عيادة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'اسم العيادة',
              hint: 'أدخل اسم أو فرع العيادة',
              controller: _nameController,
              prefixIcon: const Icon(Icons.local_hospital),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'عنوان العيادة',
              hint: 'المحافظة، المنطقة، الشارع',
              controller: _addressController,
              prefixIcon: const Icon(Icons.location_on),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'حفظ العيادة',
              onPressed: () {
                if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إكمال جميع الحقول المطلوبة!'), backgroundColor: Colors.red));
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ العيادة بنجاح'), backgroundColor: AppColors.statusCompleted),
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
