class MedicationModel {
  final int id;
  final String name;
  final String? generic;
  final String? defaultDosage;
  final String? defaultFrequency;
  final String? defaultRoute;
  final String? defaultDuration;
  final String? defaultInstructions;
  bool isFavorite;
  final bool isMine;

  MedicationModel({
    required this.id,
    required this.name,
    this.generic,
    this.defaultDosage,
    this.defaultFrequency,
    this.defaultRoute,
    this.defaultDuration,
    this.defaultInstructions,
    required this.isFavorite,
    required this.isMine,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) => MedicationModel(
    id:                  json['id'] as int,
    name:                json['name'] as String? ?? '',
    generic:             json['generic'] as String?,
    defaultDosage:       json['default_dosage'] as String?,
    defaultFrequency:    json['default_frequency'] as String?,
    defaultRoute:        json['default_route'] as String?,
    defaultDuration:     json['default_duration'] as String?,
    defaultInstructions: json['default_instructions'] as String?,
    isFavorite:          json['is_favorite'] as bool? ?? false,
    isMine:              json['is_mine'] as bool? ?? false,
  );
}
