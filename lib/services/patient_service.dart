import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/patient_model.dart';

class PatientService {
  final ApiClient _client;
  PatientService(this._client);

  // ─── Doctor view ──────────────────────────────────────────────────────────────

  Future<List<PatientModel>> getDoctorPatients() async {
    final res = await _client.get(Endpoints.doctorPatients);
    List<dynamic> list = [];
    if (res['data'] is Map && res['data']['patients'] != null) {
      list = res['data']['patients'] as List<dynamic>;
    } else if (res['data'] is List) {
      list = res['data'] as List<dynamic>;
    }
    return list
        .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientModel> getPatientById(int id) async {
    final res = await _client.get('${Endpoints.doctorPatients}/$id');
    return PatientModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ─── Admin CRUD ───────────────────────────────────────────────────────────────

  Future<List<PatientModel>> adminGetPatients() async {
    final res = await _client.get(Endpoints.adminPatients);
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientModel> adminCreatePatient(Map<String, dynamic> data) async {
    final res = await _client.post(Endpoints.adminPatients, data: data);
    return PatientModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<PatientModel> adminUpdatePatient(
      int id, Map<String, dynamic> data) async {
    final res =
        await _client.put('${Endpoints.adminPatients}/$id', data: data);
    return PatientModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> adminDeletePatient(int id) async {
    await _client.delete('${Endpoints.adminPatients}/$id');
  }
}
