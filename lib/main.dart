import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api/api_client.dart';
import 'constants/colors.dart';
import 'services/doctor_service.dart';
import 'services/appointment_service.dart';
import 'store/auth_provider.dart';
import 'store/doctor_provider.dart';
import 'store/appointment_provider.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/reset_password_screen.dart';

import 'screens/public/home_screen.dart';
import 'screens/public/doctor_profile_screen.dart';
import 'screens/public/book_appointment_screen.dart';
import 'screens/public/booking_confirmation_screen.dart';
import 'screens/public/blood_bank_screen.dart';
import 'screens/public/blood_bank_registration_screen.dart';
import 'screens/public/main_container_screen.dart';
import 'screens/public/profile_screen.dart';

import 'screens/doctor/doctor_home_screen.dart';
import 'screens/doctor/queue_screen.dart';
import 'screens/doctor/appointments_list_screen.dart';
import 'screens/doctor/patients_list_screen.dart';
import 'screens/doctor/schedule_manager_screen.dart';
import 'screens/doctor/patient_detail_screen.dart';
import 'screens/doctor/appointment_detail_screen.dart';
import 'screens/doctor/reports_screen.dart';
import 'screens/doctor/expenses_screen.dart';
import 'screens/doctor/settings_screen.dart';
import 'screens/doctor/notifications_screen.dart';
import 'screens/doctor/doctor_profile_screen.dart' show DoctorSelfProfileScreen;
import 'screens/doctor/medications_screen.dart';
import 'screens/doctor/prescription_templates_screen.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/doctors_list_screen.dart';
import 'screens/admin/doctor_form_screen.dart';
import 'screens/admin/clinics_list_screen.dart';
import 'screens/admin/clinic_form_screen.dart';
import 'screens/admin/admin_patients_screen.dart';
import 'screens/admin/admin_blood_bank_screen.dart';
import 'screens/admin/admin_patient_form_screen.dart';
import 'screens/admin/admin_donors_db_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => DoctorProvider(DoctorService(ApiClient())),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentProvider(AppointmentService(ApiClient())),
        ),
      ],
      child: const ClinicOneApp(),
    ),
  );
}

class ClinicOneApp extends StatelessWidget {
  const ClinicOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicOne',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.cardWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        fontFamily: 'Cairo',
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      locale: const Locale('ar', ''),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/otp_verification': (context) => const OTPVerificationScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),

        // ── Public ──────────────────────────────────────────────────────────
        '/main_container':        (context) => const MainContainerScreen(),
        '/public_home':           (context) => const HomeScreen(),
        '/doctor_profile':        (context) => const DoctorProfileScreen(),
        '/book_appointment':      (context) => const BookAppointmentScreen(),
        '/booking_confirmation':  (context) => const BookingConfirmationScreen(),
        '/blood_bank':            (context) => const BloodBankScreen(),
        '/blood_bank_registration': (context) => const BloodBankRegistrationScreen(),
        '/profile':               (context) => const ProfileScreen(),

        // ── Doctor ──────────────────────────────────────────────────────────
        '/doctor_home':           (context) => const DoctorHomeScreen(),
        '/doctor_queue':          (context) => const QueueScreen(),
        '/doctor_appointments':   (context) => const AppointmentsListScreen(),
        '/doctor_patients':       (context) => const PatientsListScreen(),
        '/doctor_schedule':       (context) => const ScheduleManagerScreen(),
        '/patient_detail':        (context) => const PatientDetailScreen(),
        '/appointment_detail':    (context) => const AppointmentDetailScreen(),
        '/doctor_reports':        (context) => const ReportsScreen(),
        '/doctor_expenses':       (context) => const ExpensesScreen(),
        '/doctor_settings':       (context) => const SettingsScreen(),
        '/doctor_notifications':  (context) => const NotificationsScreen(),
        '/doctor_profile_edit':   (context) => const DoctorSelfProfileScreen(),
        '/doctor_medications':    (context) => const MedicationsScreen(),
        '/doctor_templates':      (context) => const PrescriptionTemplatesScreen(),

        // ── Admin ───────────────────────────────────────────────────────────
        '/admin_home':        (context) => const AdminDashboardScreen(),
        '/admin_doctors':     (context) => const DoctorsListScreen(),
        '/admin_doctor_form': (context) => const DoctorFormScreen(),
        '/admin_clinics':     (context) => const ClinicsListScreen(),
        '/admin_clinic_form': (context) => const ClinicFormScreen(),
        '/admin_patients':    (context) => const AdminPatientsScreen(),
        '/admin_patient_form': (context) => const AdminPatientFormScreen(),
        '/admin_blood_bank':  (context) => const AdminBloodBankScreen(),
        '/admin_donors_db':   (context) => const AdminDonorsDbScreen(),
      },
    );
  }
}
