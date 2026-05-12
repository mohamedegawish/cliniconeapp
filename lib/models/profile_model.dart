class ProfileModel {
  final int userId;
  final String name;
  final String email;
  final String role;
  final int? clinicId;
  final DoctorProfile? doctor;

  const ProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.clinicId,
    this.doctor,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final user   = json['user']   as Map<String, dynamic>? ?? {};
    final doctor = json['doctor'] as Map<String, dynamic>?;
    return ProfileModel(
      userId:   user['id'] as int? ?? 0,
      name:     user['name'] as String? ?? '',
      email:    user['email'] as String? ?? '',
      role:     user['role'] as String? ?? '',
      clinicId: user['clinic_id'] as int?,
      doctor:   doctor != null ? DoctorProfile.fromJson(doctor) : null,
    );
  }
}

class DoctorProfile {
  final int id;
  final String name;
  final String? arabicName;
  final String? email;
  final String? phone;
  final String? specialty;
  final String? gender;
  final int? experienceYears;
  final String? qualification;
  final String? bio;
  final double price;
  final double followupPrice;
  final String? photo;
  final String? governorate;
  final String? city;
  final String? address;

  const DoctorProfile({
    required this.id,
    required this.name,
    this.arabicName,
    this.email,
    this.phone,
    this.specialty,
    this.gender,
    this.experienceYears,
    this.qualification,
    this.bio,
    required this.price,
    required this.followupPrice,
    this.photo,
    this.governorate,
    this.city,
    this.address,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> j) => DoctorProfile(
    id:              j['id'] as int? ?? 0,
    name:            j['name'] as String? ?? '',
    arabicName:      j['arabic_name'] as String?,
    email:           j['email'] as String?,
    phone:           j['phone'] as String?,
    specialty:       j['specialty'] as String?,
    gender:          j['gender'] as String?,
    experienceYears: j['experience_years'] as int?,
    qualification:   j['qualification'] as String?,
    bio:             j['bio'] as String?,
    price:           (j['price'] as num? ?? 0).toDouble(),
    followupPrice:   (j['followup_price'] as num? ?? 0).toDouble(),
    photo:           j['photo'] as String?,
    governorate:     j['governorate'] as String?,
    city:            j['city'] as String?,
    address:         j['address'] as String?,
  );
}
