import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final ApiClient _client;
  AppointmentService(this._client);

  // ─── Patient ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    required String date,
    required String time,
    required String patientName,
    required String patientPhone,
    required String checkupType,
    int? clinicId,
  }) async {
    return _client.post(Endpoints.publicBookAppointment, data: {
      'doctor_id': doctorId,
      if (clinicId != null && clinicId != 0) 'clinic_id': clinicId,
      'appointment_date': date,
      'start_time': time,
      'full_name': patientName,
      'phone': patientPhone,
      'notes': checkupType,
    });
  }

  // ─── Patient ─────────────────────────────────────────────────────────────────

  Future<List<AppointmentModel>> getMyAppointments() async {
    final res = await _client.get(Endpoints.clinicAppointments);

    List<dynamic> list = [];
    if (res['data'] is Map && res['data']['data'] != null) {
      list = res['data']['data'] as List<dynamic>;
    } else if (res['data'] is Map && res['data']['appointments'] != null) {
      list = res['data']['appointments'] as List<dynamic>;
    } else if (res['data'] is List) {
      list = res['data'] as List<dynamic>;
    }

    return list
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Doctor / Clinic ──────────────────────────────────────────────────────────

  Future<List<AppointmentModel>> getDoctorAppointments({
    String? date,
    String? status,
    int? patientId,
  }) async {
    final params = <String, dynamic>{};
    if (date != null) params['date'] = date;
    if (status != null) params['status'] = status;
    if (patientId != null) params['patient_id'] = patientId;

    final res = await _client.get(
      Endpoints.clinicAppointments,
      queryParameters: params,
    );

    List<dynamic> list = [];
    if (res['data'] is Map && res['data']['data'] != null) {
      list = res['data']['data'] as List<dynamic>;
    } else if (res['data'] is Map && res['data']['appointments'] != null) {
      list = res['data']['appointments'] as List<dynamic>;
    } else if (res['data'] is List) {
      list = res['data'] as List<dynamic>;
    }

    return list
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> getAppointment(int id) async {
    final res  = await _client.get('${Endpoints.clinicAppointments}/$id');
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return AppointmentModel.fromJson(data);
  }

  Future<void> confirmAppointment(int id) async {
    await _client.patch(Endpoints.appointmentConfirm(id));
  }

  Future<void> cancelAppointment(int id) async {
    await _client.patch(Endpoints.appointmentCancel(id));
  }

  Future<void> completeAppointment(int id) async {
    await _client.patch(Endpoints.appointmentComplete(id));
  }

  // Kept for backward compatibility with appointments_list_screen
  Future<void> updateAppointmentStatus(int id, String status) async {
    switch (status) {
      case 'confirmed': return confirmAppointment(id);
      case 'cancelled': return cancelAppointment(id);
      case 'completed': return completeAppointment(id);
    }
  }
}
