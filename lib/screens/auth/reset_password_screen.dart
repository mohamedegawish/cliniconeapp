import 'package:flutter/material.dart';
import '../../components/primary_button.dart';
import '../../components/custom_text_field.dart';
import '../../constants/colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() {
    if (_passwordController.text.isEmpty || _passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور غير متطابقة')),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Simulate API Call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح!', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.statusCompleted),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كلمة مرور جديدة'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إنشاء كلمة مرور جديدة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'كلمة المرور الجديدة',
                hint: 'أدخل كلمة المرور',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'تأكيد كلمة المرور',
                hint: 'أعد إدخال كلمة المرور',
                controller: _confirmController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'تأكيد وحفظ',
                isLoading: _isLoading,
                onPressed: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
