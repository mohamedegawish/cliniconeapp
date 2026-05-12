class DoctorModel {
  final int id;
  final String name;
  final String specialty;
  final String? governorate;
  final String? city;
  final double rating;
  final int reviewCount;
  final String? about;
  final int? experience;
  final double? consultationFee;
  final String? imageUrl;
  final String? location;
  // Admin fields
  final String? email;
  final String? phone;
  final String? status;
  final int? experienceYears;
  final String? qualification;
  final List<Map<String, dynamic>>? clinics;
  final int? clinicsCount;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.governorate,
    this.city,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.about,
    this.experience,
    this.consultationFee,
    this.imageUrl,
    this.location,
    this.email,
    this.phone,
    this.status,
    this.experienceYears,
    this.qualification,
    this.clinics,
    this.clinicsCount,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      specialty: json['specialty'] as String? ?? '',
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      about: json['about'] ?? json['bio'] as String?,
      experience: json['experience'] as int?,
      consultationFee: (json['consultation_fee'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      location: (json['location'] ?? json['clinic_name']) as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      experienceYears: json['experience_years'] as int?,
      qualification: json['qualification'] as String?,
      clinics: (json['clinics'] as List?)?.cast<Map<String, dynamic>>(),
      clinicsCount: json['clinics_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'governorate': governorate,
        'city': city,
        'rating': rating,
        'review_count': reviewCount,
        'about': about,
        'experience': experience,
        'consultation_fee': consultationFee,
        'image_url': imageUrl,
        'location': location,
        'email': email,
        'phone': phone,
        'status': status,
        'experience_years': experienceYears,
        'qualification': qualification,
        'clinics': clinics,
        'clinics_count': clinicsCount,
      };
}
