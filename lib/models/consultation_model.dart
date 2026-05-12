class ConsultationModel {
  final int id;
  final int appointmentId;
  final int? patientId;
  final int? doctorId;
  final int? clinicId;
  final String? symptoms;
  final String diagnosis;
  final String? treatment;
  final String? notes;
  final VitalsModel? vitals;
  final List<ConsultationMedicationModel> medications;
  final ConsultationPatientModel? patient;
  final ConsultationDoctorModel? doctor;
  final String? createdAt;

  const ConsultationModel({
    required this.id,
    required this.appointmentId,
    this.patientId,
    this.doctorId,
    this.clinicId,
    this.symptoms,
    required this.diagnosis,
    this.treatment,
    this.notes,
    this.vitals,
    this.medications = const [],
    this.patient,
    this.doctor,
    this.createdAt,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id:            json['id'] as int,
      appointmentId: json['appointment_id'] as int,
      patientId:     json['patient_id'] as int?,
      doctorId:      json['doctor_id'] as int?,
      clinicId:      json['clinic_id'] as int?,
      symptoms:      json['symptoms'] as String?,
      diagnosis:     json['diagnosis'] as String? ?? '',
      treatment:     json['treatment'] as String?,
      notes:         json['notes'] as String?,
      vitals: json['vitals'] != null
          ? VitalsModel.fromJson(json['vitals'] as Map<String, dynamic>)
          : null,
      medications: (json['medications'] as List? ?? [])
          .map((m) => ConsultationMedicationModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      patient: json['patient'] != null
          ? ConsultationPatientModel.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
      doctor: json['doctor'] != null
          ? ConsultationDoctorModel.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
    );
  }
}

class VitalsModel {
  final String? bp;
  final String? temp;
  final String? pulse;
  final String? hr;
  final String? rr;
  final String? spo2;
  final String? weight;
  final String? height;

  const VitalsModel({this.bp, this.temp, this.pulse, this.hr, this.rr, this.spo2, this.weight, this.height});

  factory VitalsModel.fromJson(Map<String, dynamic> j) => VitalsModel(
    bp: j['bp'] as String?, temp: j['temp'] as String?,
    pulse: j['pulse'] as String?, hr: j['hr'] as String?,
    rr: j['rr'] as String?, spo2: j['spo2'] as String?,
    weight: j['weight'] as String?, height: j['height'] as String?,
  );

  bool get isEmpty => bp == null && temp == null && pulse == null && hr == null && rr == null && spo2 == null && weight == null && height == null;
}

class ConsultationMedicationModel {
  final int id;
  final int? medicationId;
  final String name;
  final String? generic;
  final String? dosage;
  final String? frequency;
  final String? route;
  final String? duration;
  final String? instructions;

  const ConsultationMedicationModel({
    required this.id,
    this.medicationId,
    required this.name,
    this.generic, this.dosage, this.frequency,
    this.route, this.duration, this.instructions,
  });

  factory ConsultationMedicationModel.fromJson(Map<String, dynamic> j) =>
    ConsultationMedicationModel(
      id:            j['id'] as int,
      medicationId:  j['medication_id'] as int?,
      name:          j['name'] as String? ?? '',
      generic:       j['generic'] as String?,
      dosage:        j['dosage'] as String?,
      frequency:     j['frequency'] as String?,
      route:         j['route'] as String?,
      duration:      j['duration'] as String?,
      instructions:  j['instructions'] as String?,
    );
}

class ConsultationPatientModel {
  final int id;
  final String fullName;
  final String? phone;
  final int? age;
  final String? gender;

  const ConsultationPatientModel({required this.id, required this.fullName, this.phone, this.age, this.gender});

  factory ConsultationPatientModel.fromJson(Map<String, dynamic> j) =>
    ConsultationPatientModel(
      id:       j['id'] as int,
      fullName: j['full_name'] as String? ?? '',
      phone:    j['phone'] as String?,
      age:      j['age'] as int?,
      gender:   j['gender'] as String?,
    );
}

class ConsultationDoctorModel {
  final int id;
  final String name;
  final String? specialty;

  const ConsultationDoctorModel({required this.id, required this.name, this.specialty});

  factory ConsultationDoctorModel.fromJson(Map<String, dynamic> j) =>
    ConsultationDoctorModel(id: j['id'] as int, name: j['name'] as String? ?? '', specialty: j['specialty'] as String?);
}
