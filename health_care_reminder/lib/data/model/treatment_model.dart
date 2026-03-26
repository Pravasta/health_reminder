// Author: Pravasta Rama - 2026

/// [TreatmentModel] A data model class for treatments.
/// This class is responsible for converting treatment data
/// to and from JSON format for database storage.
class TreatmentModel {
  final int? id;
  final String name;
  final int defaultDuration;
  final String? description;

  TreatmentModel({
    this.id,
    required this.name,
    required this.defaultDuration,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'default_duration': defaultDuration,
      'description': description,
    };
  }

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'],
      name: json['name'],
      defaultDuration: json['default_duration'],
      description: json['description'],
    );
  }
}
