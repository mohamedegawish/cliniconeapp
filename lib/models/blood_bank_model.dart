class BloodBankModel {
  final int id;
  final String name;
  final String bloodType;
  final String? phone;
  final String? city;
  final String? governorate;
  final bool isAvailable;
  final String? lastDonationDate;

  const BloodBankModel({
    required this.id,
    required this.name,
    required this.bloodType,
    this.phone,
    this.city,
    this.governorate,
    this.isAvailable = true,
    this.lastDonationDate,
  });

  factory BloodBankModel.fromJson(Map<String, dynamic> json) {
    return BloodBankModel(
      id: json['id'] as int,
      name: json['name'] as String,
      bloodType: json['blood_type'] as String,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      governorate: json['governorate'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      lastDonationDate: json['last_donation_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'blood_type': bloodType,
        'phone': phone,
        'city': city,
        'governorate': governorate,
        'is_available': isAvailable,
        'last_donation_date': lastDonationDate,
      };
}
