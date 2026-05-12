import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/doctor_model.dart';

class DoctorService {
  final ApiClient _client;
  DoctorService(this._client);

  // ─── Public ──────────────────────────────────────────────────────────────────

  Future<List<DoctorModel>> getDoctors({
    String? specialty,
    String? governorate,
    String? city,
    String? search,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (specialty != null && specialty.isNotEmpty) params['specialty'] = specialty;
    if (governorate != null) params['governorate'] = governorate;
    if (city != null) params['city'] = city;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res = await _client.get(Endpoints.publicDoctors, queryParameters: params);
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DoctorModel> getDoctorById(int id) async {
    final res = await _client.get('${Endpoints.publicDoctors}/$id');
    return DoctorModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<List<String>> getSpecialties() async {
    final res = await _client.get(Endpoints.publicSpecialties);
    final list = res['data'] as List? ?? [];
    return list.map((e) => e.toString()).toList();
  }

  Future<Map<String, List<String>>> getLocations() async {
    final res = await _client.get(Endpoints.publicLocations);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final map  = data['map'] as Map<String, dynamic>? ?? {};
    return map.map((gov, areas) => MapEntry(gov, List<String>.from(areas as List)));
  }

  Future<List<String>> getAvailableSlots(int doctorId, String date) async {
    final res = await _client.get(
      Endpoints.publicAvailableSlots,
      queryParameters: {'doctor_id': doctorId, 'date': date},
    );
    
    final data = res['data'];
    List list = [];
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic> && data.containsKey('available_slots')) {
      list = data['available_slots'] as List? ?? [];
    }

    return list.map((e) {
      if (e is Map<String, dynamic>) {
        return e['start_time']?.toString() ?? '';
      }
      return e.toString();
    }).where((s) => s.isNotEmpty).toList();
  }

  // ─── Admin CRUD ───────────────────────────────────────────────────────────────

  Future<List<DoctorModel>> adminGetDoctors() async {
    final res = await _client.get(Endpoints.adminDoctors);
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DoctorModel> adminCreateDoctor(Map<String, dynamic> data) async {
    final res = await _client.post(Endpoints.adminDoctors, data: data);
    return DoctorModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<DoctorModel> adminUpdateDoctor(int id, Map<String, dynamic> data) async {
    final res = await _client.put('${Endpoints.adminDoctors}/$id', data: data);
    return DoctorModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> adminDeleteDoctor(int id) async {
    await _client.delete('${Endpoints.adminDoctors}/$id');
  }
}
