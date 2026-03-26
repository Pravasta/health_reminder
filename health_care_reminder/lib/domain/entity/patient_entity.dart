// Author: Pravasta Rama - 2026

import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';

import '../../core/enum/gender_enum.dart';

/// [PatientEntity] A domain entity class for patients.
/// This class represents the core attributes of a patient
/// used in the business logic layer.
class PatientEntity {
  final int? id;
  final String patientCode;
  final String name;
  final Gender gender;
  final InfusionStatusEnum? status;
  final int? tpm;
  final DateTime? startTime;
  final DateTime? endTime;

  PatientEntity({
    this.id,
    required this.patientCode,
    required this.name,
    required this.gender,
    this.status,
    this.tpm,
    this.startTime,
    this.endTime,
  });
}
