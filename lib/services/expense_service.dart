import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final ApiClient _client;
  ExpenseService(this._client);

  Future<List<ExpenseModel>> getExpenses({String? date}) async {
    final res = await _client.get(
      Endpoints.doctorExpenses,
      queryParameters: date != null ? {'date': date} : null,
    );
    
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ExpenseModel> createExpense(Map<String, dynamic> data) async {
    final res = await _client.post(Endpoints.doctorExpenses, data: data);
    return ExpenseModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> deleteExpense(int id) async {
    await _client.delete('${Endpoints.doctorExpenses}/$id');
  }
  
  Future<Map<String, dynamic>> getStats() async {
    final res = await _client.get(Endpoints.doctorReports);
    return res['data'] as Map<String, dynamic>;
  }
}
