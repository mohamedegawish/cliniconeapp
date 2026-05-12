class ClinicModel {
  final int id;
  final String name;
  final String? address;
  final String? governorate;
  final String? city;
  final String? phone;
  final bool isActive;

  const ClinicModel({
    required this.id,
    required this.name,
    this.address,
    this.governorate,
    this.city,
    this.phone,
    this.isActive = true,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'governorate': governorate,
        'city': city,
        'phone': phone,
        'is_active': isActive,
      };
}
