class PrescriptionTemplateModel {
  final int id;
  final String name;
  final List<TemplateItemModel> items;

  const PrescriptionTemplateModel({required this.id, required this.name, required this.items});

  factory PrescriptionTemplateModel.fromJson(Map<String, dynamic> json) => PrescriptionTemplateModel(
    id:    json['id'] as int,
    name:  json['name'] as String? ?? '',
    items: (json['items'] as List? ?? [])
        .map((i) => TemplateItemModel.fromJson(i as Map<String, dynamic>))
        .toList(),
  );
}

class TemplateItemModel {
  final int id;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? route;
  final String? duration;
  final String? instructions;

  const TemplateItemModel({
    required this.id,
    required this.name,
    this.dosage, this.frequency, this.route, this.duration, this.instructions,
  });

  factory TemplateItemModel.fromJson(Map<String, dynamic> j) => TemplateItemModel(
    id:           j['id'] as int,
    name:         j['name'] as String? ?? '',
    dosage:       j['dosage'] as String?,
    frequency:    j['frequency'] as String?,
    route:        j['route'] as String?,
    duration:     j['duration'] as String?,
    instructions: j['instructions'] as String?,
  );

  Map<String, dynamic> toMedEntry() => {
    'name': name,
    if (dosage != null) 'dosage': dosage,
    if (frequency != null) 'frequency': frequency,
    if (route != null) 'route': route,
    if (duration != null) 'duration': duration,
    if (instructions != null) 'instructions': instructions,
  };
}
