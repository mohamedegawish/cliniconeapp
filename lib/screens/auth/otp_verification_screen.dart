import 'package:flutter/material.dart';
import '../../components/primary_button.dart';
import '../../components/custom_text_field.dart';
import '../../constants/colors.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOTP(String email) {
    if (_otpController.text.length < 4) return;
    
    setState(() => _isLoading = true);
    // Simulate verification
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/reset_password', arguments: {
          'email': email,
          'otp': _otpController.text,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من الرمز'),
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
                'أدخل رمز التحقق',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'تم إرسال رمز تحقق إلى $email',
                style: const TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'رمز التحقق (OTP)',
                hint: 'أدخل الرمز هنا',
                controller: _otpController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.security),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'تحقق الآن',
                isLoading: _isLoading,
                onPressed: () => _verifyOTP(email),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
