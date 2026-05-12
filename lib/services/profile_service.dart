import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/profile_model.dart';

class ProfileService {
  final ApiClient _client;
  ProfileService(this._client);

  Future<ProfileModel> getProfile() async {
    final res  = await _client.get(Endpoints.profile);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return ProfileModel.fromJson(data);
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? specialty,
    String? phone,
    String? bio,
    String? qualification,
    int? experienceYears,
    String? governorate,
    String? city,
    String? address,
  }) async {
    final body = <String, dynamic>{};
    if (name != null)           body['name']             = name;
    if (email != null)          body['email']            = email;
    if (specialty != null)      body['specialty']        = specialty;
    if (phone != null)          body['phone']            = phone;
    if (bio != null)            body['bio']              = bio;
    if (qualification != null)  body['qualification']    = qualification;
    if (experienceYears != null) body['experience_years'] = experienceYears;
    if (governorate != null)    body['governorate']      = governorate;
    if (city != null)           body['city']             = city;
    if (address != null)        body['address']          = address;
    await _client.put(Endpoints.profileUpdate, data: body);
  }

  Future<String> updatePhoto(String filePath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: 'photo.jpg'),
    });
    final res = await _client.dio.post(
      Endpoints.profilePhoto,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final body = res.data as Map<String, dynamic>;
    return body['data']?['photo'] as String? ?? '';
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _client.put(Endpoints.profilePassword, data: {
      'current_password':          currentPassword,
      'new_password':              newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    });
  }
}
