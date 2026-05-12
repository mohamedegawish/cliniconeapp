class AppointmentModel {
  final int id;
  final int? doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String appointmentDate;
  final String startTime;
  final String? endTime;
  final String status;
  final String? patientName;
  final String? patientPhone;
  final int? patientId;
  final String? notes;
  final int? queueNumber;
  final bool isPaid;
  final double totalPrice;
  final String? checkupType; // Keeping this for backward compatibility

  const AppointmentModel({
    required this.id,
    this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.appointmentDate,
    required this.startTime,
    this.endTime,
    required this.status,
    this.patientName,
    this.patientPhone,
    this.patientId,
    this.notes,
    this.queueNumber,
    this.checkupType,
    this.isPaid = false,
    this.totalPrice = 0,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>?;
    final patient = json['patient'] as Map<String, dynamic>?;
    
    // Notes or checkupType might be used interchangeably from different endpoints
    final notesValue = json['notes'] as String?;
    
    return AppointmentModel(
      id: json['id'] as int,
      doctorId: json['doctor_id'] as int?,
      doctorName: json['doctor_name'] as String? ?? doctor?['name'] as String? ?? '',
      doctorSpecialty: json['doctor_specialty'] as String? ?? doctor?['specialty'] as String? ?? '',
      appointmentDate: json['appointment_date'] as String? ?? json['date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? json['time'] as String? ?? '',
      endTime: json['end_time'] as String?,
      status: json['status'] as String? ?? 'pending',
      patientName: json['patient_name'] as String? ?? patient?['full_name'] as String?,
      patientPhone: json['patient_phone'] as String? ?? patient?['phone'] as String?,
      patientId: json['patient_id'] as int? ?? patient?['id'] as int?,
      notes: notesValue,
      checkupType: notesValue, // Alias checkupType to notes
      queueNumber: json['queue_number'] as int?,
      isPaid: json['is_paid'] == true || json['is_paid'] == 1,
      totalPrice: double.tryParse('${json['total_price'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'doctor_specialty': doctorSpecialty,
        'appointment_date': appointmentDate,
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'patient_id': patientId,
        'notes': notes,
        'checkup_type': checkupType,
        'queue_number': queueNumber,
      };

  bool get isUpcoming => status == 'pending' || status == 'confirmed';
  bool get isPast => status == 'completed' || status == 'cancelled';

  String get statusAr {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'pending':
        return 'قيد الانتظار';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // Alias for old code using .date
  String get date => appointmentDate;
  // Alias for old code using .time
  String get time => startTime;

  /// Splits "2024-10-12" → day "12", month index 10
  String get dayStr {
    final parts = appointmentDate.split('-');
    return parts.length == 3 ? parts[2] : '--';
  }

  String get monthStr {
    final parts = appointmentDate.split('-');
    if (parts.length < 2) return '--';
    final idx = int.tryParse(parts[1]) ?? 0;
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return idx >= 1 && idx <= 12 ? months[idx] : '--';
  }
}
