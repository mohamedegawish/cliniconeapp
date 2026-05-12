class PatientModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? bloodType;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final int? age;

  const PatientModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.bloodType,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.age,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as int,
      name: (json['name'] ?? json['full_name'] ?? 'بدون اسم') as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      bloodType: json['blood_type'] as String?,
      dateOfBirth: json['date_of_birth'] ?? json['birth_date'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      age: json['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'blood_type': bloodType,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'address': address,
        'age': age,
      };
}
