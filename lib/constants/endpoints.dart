class Endpoints {
  static const String baseUrl = 'https://clinicone1.com/api';

  // ─── Auth ────────────────────────────────────────────────────────────────────
  static const String login          = '/login';
  static const String logout         = '/logout';
  static const String register       = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword  = '/reset-password';
  static const String verifyOtp      = '/verify-otp';
  static const String user           = '/user';
  static const String refreshToken   = '/refresh-token';

  // ─── Profile (authenticated user) ────────────────────────────────────────────
  static const String profile         = '/profile';
  static const String profileUpdate   = '/profile';
  static const String profilePhoto    = '/profile/photo';
  static const String profilePassword = '/profile/password';

  // ─── Public (no auth required) ───────────────────────────────────────────────
  static const String publicDoctors        = '/public/doctors';
  static const String publicSpecialties    = '/public/specialties';
  static const String publicLocations      = '/public/locations';
  static const String publicAvailableSlots = '/public/appointments/available-slots';
  static const String publicBookAppointment = '/public/appointments/book';
  static const String publicBloodBank      = '/public/blood-bank/donors';
  static const String bloodBankRegister    = '/public/blood-bank/donors';
  static const String publicReviews        = '/public/reviews';

  // ─── Clinic — Dashboard ───────────────────────────────────────────────────────
  static const String clinicDashboard = '/clinic/dashboard';

  // ─── Clinic — Patients ────────────────────────────────────────────────────────
  static const String clinicPatients = '/clinic/patients';

  // ─── Clinic — Appointments ────────────────────────────────────────────────────
  static const String clinicAppointments      = '/clinic/appointments';
  static const String clinicAvailableSlots    = '/clinic/appointments/available-slots';

  // ─── Clinic — Queue ──────────────────────────────────────────────────────────
  static const String clinicQueue = '/clinic/queue';

  // ─── Clinic — Schedules ──────────────────────────────────────────────────────
  static const String clinicSchedules = '/clinic/schedules';

  // ─── Clinic — Consultations & Diagnoses ──────────────────────────────────────
  static const String clinicConsultations = '/clinic/consultations';
  static const String clinicDiagnoses     = '/clinic/diagnoses';

  // ─── Clinic — Medications ─────────────────────────────────────────────────────
  static const String clinicMedications       = '/clinic/medications';
  static const String clinicMedicationSearch  = '/clinic/medications/search';

  // ─── Clinic — Prescription Templates ─────────────────────────────────────────
  static const String clinicTemplates = '/clinic/prescription-templates';

  // ─── Clinic — Expenses & Reports ─────────────────────────────────────────────
  static const String clinicExpenses = '/clinic/expenses';
  static const String clinicReports  = '/clinic/reports';

  // ─── Clinic — Settings ────────────────────────────────────────────────────────
  static const String clinicSettings           = '/clinic/settings';
  static const String clinicSettingsPrices     = '/clinic/settings/prices';
  static const String clinicSettingsServices   = '/clinic/settings/services';
  static const String clinicSettingsBranding   = '/clinic/settings/branding';
  static const String clinicSettingsOtpRequest = '/clinic/settings/otp/request';
  static const String clinicSettingsOtpVerify  = '/clinic/settings/otp/verify';

  // ─── Clinic — Notifications ───────────────────────────────────────────────────
  static const String clinicNotifications      = '/clinic/notifications';
  static const String clinicNotifUnreadCount   = '/clinic/notifications/unread-count';
  static const String clinicNotifReadAll       = '/clinic/notifications/read-all';

  // ─── Doctor (aliases to clinic-prefix routes) ─────────────────────────────────
  static const String doctorExpenses = clinicExpenses;
  static const String doctorReports  = clinicReports;
  static const String doctorPatients = clinicPatients;
  static const String doctorQueue    = clinicQueue;

  // ─── Admin ────────────────────────────────────────────────────────────────────
  static const String adminStats     = '/admin/stats';
  static const String adminDoctors   = '/admin/doctors';
  static const String adminClinics   = '/admin/clinics';
  static const String adminPatients  = '/admin/patients';
  static const String adminBloodBank = '/admin/blood-bank/donors';

  // ─── Helpers ──────────────────────────────────────────────────────────────────
  static String notifMarkRead(int id)        => '/clinic/notifications/$id/read';
  static String appointmentCancel(int id)    => '/clinic/appointments/$id/cancel';
  static String appointmentConfirm(int id)   => '/clinic/appointments/$id/confirm';
  static String appointmentComplete(int id)  => '/clinic/appointments/$id/complete';
  static String consultationStore(int apptId)    => '/clinic/consultations/$apptId';
  static String consultationShow(int id)         => '/clinic/consultations/$id';
  static String consultationPrint(int id)        => '/clinic/consultations/$id/print';
  static String consultationPrescription(int id) => '/clinic/consultations/$id/prescription';
  static String medicationFavorite(int id)    => '/clinic/medications/$id/favorite';
  static String templateShow(int id)          => '/clinic/prescription-templates/$id';
  static String templateDelete(int id)        => '/clinic/prescription-templates/$id';
  static String settingsServiceDelete(int id) => '/clinic/settings/services/$id';
  static String queueShow(int doctorId)       => '/clinic/queue/$doctorId';
  static String queueAdvance(int doctorId)    => '/clinic/queue/$doctorId/advance';
  static String patientShow(int id)           => '/clinic/patients/$id';
}
