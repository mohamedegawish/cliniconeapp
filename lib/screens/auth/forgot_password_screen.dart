import 'package:flutter/material.dart';
import '../../components/custom_text_field.dart';
import '../../components/primary_button.dart';
import '../../constants/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _sendOTP() {
    if (_emailController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to OTP screen passing email
        Navigator.pushNamed(context, '/otp_verification', arguments: _emailController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعادة كلمة المرور'),
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
                'هل نسيت كلمة المرور؟',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'أدخل بريدك الإلكتروني وسنقوم بإرسال رمز تحقق (OTP) لاستعادة الحساب.',
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'البريد الإلكتروني',
                hint: 'مثال: example@mail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'إرسال الرمز',
                isLoading: _isLoading,
                onPressed: _sendOTP,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
