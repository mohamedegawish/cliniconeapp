import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/prescription_template_model.dart';

class TemplateService {
  final ApiClient _client;
  TemplateService(this._client);

  Future<List<PrescriptionTemplateModel>> getTemplates() async {
    final res  = await _client.get(Endpoints.clinicTemplates);
    final list = res['data'] as List? ?? [];
    return list.map((e) => PrescriptionTemplateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PrescriptionTemplateModel> getTemplate(int id) async {
    final res  = await _client.get(Endpoints.templateShow(id));
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return PrescriptionTemplateModel.fromJson(data);
  }

  Future<PrescriptionTemplateModel> createTemplate({
    required String name,
    required List<Map<String, dynamic>> items,
  }) async {
    final res  = await _client.post(Endpoints.clinicTemplates, data: {'name': name, 'items': items});
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return PrescriptionTemplateModel.fromJson(data);
  }

  Future<void> deleteTemplate(int id) async {
    await _client.delete(Endpoints.templateDelete(id));
  }
}
