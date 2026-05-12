import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/consultation_model.dart';

class ConsultationService {
  final ApiClient _client;
  ConsultationService(this._client);

  Future<List<ConsultationModel>> getConsultations({int? patientId, int? appointmentId, int page = 1}) async {
    final params = <String, dynamic>{'page': page};
    if (patientId != null)    params['patient_id']    = patientId;
    if (appointmentId != null) params['appointment_id'] = appointmentId;
    final res  = await _client.get(Endpoints.clinicConsultations, queryParameters: params);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = data['data'] as List? ?? [];
    return list.map((e) => ConsultationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConsultationModel?> getConsultationByAppointment(int appointmentId) async {
    final list = await getConsultations(appointmentId: appointmentId, page: 1);
    return list.isNotEmpty ? list.first : null;
  }

  Future<ConsultationModel> getConsultation(int id) async {
    final res  = await _client.get(Endpoints.consultationShow(id));
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return ConsultationModel.fromJson(data);
  }

  Future<ConsultationModel> createConsultation({
    required int appointmentId,
    required String diagnosis,
    String? symptoms,
    String? treatment,
    String? notes,
    String? bp, String? temp, String? pulse, String? hr,
    String? rr, String? spo2, String? weight, String? height,
    List<Map<String, dynamic>> medications = const [],
    bool isPaid = false,
  }) async {
    final res = await _client.post(
      Endpoints.consultationStore(appointmentId),
      data: {
        'diagnosis':   diagnosis,
        'is_paid':     isPaid,
        if (symptoms  != null) 'symptoms':  symptoms,
        if (treatment != null) 'treatment': treatment,
        if (notes     != null) 'notes':     notes,
        if (bp        != null) 'bp':        bp,
        if (temp      != null) 'temp':      temp,
        if (pulse     != null) 'pulse':     pulse,
        if (hr        != null) 'hr':        hr,
        if (rr        != null) 'rr':        rr,
        if (spo2      != null) 'spo2':      spo2,
        if (weight    != null) 'weight':    weight,
        if (height    != null) 'height':    height,
        if (medications.isNotEmpty) 'medications': medications,
      },
    );
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return ConsultationModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getPrintData(int id) async {
    final res = await _client.get(Endpoints.consultationPrint(id));
    return res['data'] as Map<String, dynamic>? ?? {};
  }

  Future<List<Map<String, dynamic>>> getDiagnoses({String? q}) async {
    final params = <String, dynamic>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    final res  = await _client.get(Endpoints.clinicDiagnoses, queryParameters: params);
    return (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> storeDiagnosis(String name) async {
    final res = await _client.post(Endpoints.clinicDiagnoses, data: {'name': name});
    return res['data'] as Map<String, dynamic>? ?? {};
  }
}
