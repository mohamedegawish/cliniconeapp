import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/clinic_model.dart';

class ClinicService {
  final ApiClient _client;
  ClinicService(this._client);

  Future<List<ClinicModel>> getClinics() async {
    final res  = await _client.get(Endpoints.adminClinics);
    final data = res['data'];
    // paginated: { data: [...], total: n, ... }  or plain list
    final list = (data is Map ? data['data'] : data) as List? ?? [];
    return list
        .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClinicModel> createClinic(Map<String, dynamic> data) async {
    final res = await _client.post(Endpoints.adminClinics, data: data);
    return ClinicModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<ClinicModel> updateClinic(int id, Map<String, dynamic> data) async {
    final res =
        await _client.put('${Endpoints.adminClinics}/$id', data: data);
    return ClinicModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> deleteClinic(int id) async {
    await _client.delete('${Endpoints.adminClinics}/$id');
  }
}
