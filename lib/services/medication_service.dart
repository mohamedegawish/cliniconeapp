import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/medication_model.dart';

class MedicationService {
  final ApiClient _client;
  MedicationService(this._client);

  Future<List<MedicationModel>> search(String q) async {
    final res  = await _client.get(Endpoints.clinicMedicationSearch, queryParameters: {'q': q});
    final list = res['data'] as List? ?? [];
    return list.map((e) => MedicationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MedicationModel> store({
    required String name,
    String? generic,
    String? defaultDosage,
    String? defaultFrequency,
    String? defaultRoute,
    String? defaultDuration,
    String? defaultInstructions,
  }) async {
    final res = await _client.post(Endpoints.clinicMedications, data: {
      'name': name,
      if (generic             != null) 'generic':              generic,
      if (defaultDosage       != null) 'default_dosage':       defaultDosage,
      if (defaultFrequency    != null) 'default_frequency':    defaultFrequency,
      if (defaultRoute        != null) 'default_route':        defaultRoute,
      if (defaultDuration     != null) 'default_duration':     defaultDuration,
      if (defaultInstructions != null) 'default_instructions': defaultInstructions,
    });
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return MedicationModel.fromJson(data);
  }

  Future<bool> toggleFavorite(int medicationId) async {
    final res  = await _client.post(Endpoints.medicationFavorite(medicationId));
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return data['is_favorite'] as bool? ?? false;
  }
}
