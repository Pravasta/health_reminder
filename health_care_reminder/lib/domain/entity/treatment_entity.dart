// Author: Pravasta Rama - 2026

/// [TreatmentEntity] A domain entity class for treatments.
/// This class represents the core attributes of a treatment
/// used in the business logic layer.
class TreatmentEntity {
  final int? id;
  final String name;
  final int defaultDuration;

  TreatmentEntity({this.id, required this.name, required this.defaultDuration});
}
