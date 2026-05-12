import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _client;
  DashboardService(this._client);

  Future<DashboardModel> getDashboard() async {
    final res  = await _client.get(Endpoints.clinicDashboard);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return DashboardModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final res = await _client.get(Endpoints.adminStats);
    return res['data'] as Map<String, dynamic>? ?? {};
  }
}
