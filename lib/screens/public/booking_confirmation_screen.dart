import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../components/primary_button.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (booking == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'تم تأكيد الحجز بنجاح!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى التواجد في العيادة قبل الموعد بـ 15 دقيقة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              
              const SizedBox(height: 40),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('رقم الطابور الخاص بك', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                      Text(
                        booking['queue_number'],
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Divider(height: 32),
                      _buildRow('الطبيب:', booking['doctor_name']),
                      const SizedBox(height: 12),
                      _buildRow('التاريخ:', booking['date']),
                      const SizedBox(height: 12),
                      _buildRow('الوقت:', booking['time']),
                      const SizedBox(height: 12),
                      _buildRow('اسم المريض:', booking['patient_name']),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'العودة للرئيسية',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/public_home', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textLight)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ],
    );
  }
}
