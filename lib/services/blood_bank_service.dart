import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/blood_bank_model.dart';

class BloodBankService {
  final ApiClient _client;
  BloodBankService(this._client);

  Future<List<BloodBankModel>> getDonors({
    String? bloodType,
    String? governorate,
  }) async {
    final params = <String, dynamic>{};
    if (bloodType != null) params['blood_type'] = bloodType;
    if (governorate != null) params['governorate'] = governorate;

    final res = await _client.get(
      Endpoints.publicBloodBank,
      queryParameters: params,
    );
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => BloodBankModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> registerDonor(Map<String, dynamic> data) async {
    await _client.post(Endpoints.bloodBankRegister, data: data);
  }

  Future<List<BloodBankModel>> adminGetDonors() async {
    final res = await _client.get(Endpoints.adminBloodBank);
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => BloodBankModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
