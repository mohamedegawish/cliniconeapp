import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/appointment_model.dart';

class QueueService {
  final ApiClient _client;
  QueueService(this._client);

  Future<Map<String, dynamic>> getQueue(int doctorId) async {
    final res = await _client.get('${Endpoints.doctorQueue}/$doctorId');
    final data = res['data'] as Map<String, dynamic>;
    
    return {
      'current_appointment': data['current_appointment'] != null 
          ? AppointmentModel.fromJson(data['current_appointment']) 
          : null,
      'remaining_count': data['remaining_count'] as int? ?? 0,
    };
  }

  Future<Map<String, dynamic>> advanceQueue(int doctorId) async {
    final res = await _client.put('${Endpoints.doctorQueue}/$doctorId/advance');
    final data = res['data'] as Map<String, dynamic>;
    
    return {
      'current_appointment': data['current_appointment'] != null 
          ? AppointmentModel.fromJson(data['current_appointment']) 
          : null,
      'remaining_count': data['remaining_count'] as int? ?? 0,
    };
  }
}
