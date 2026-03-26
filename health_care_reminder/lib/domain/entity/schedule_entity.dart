// Author: Pravasta Rama - 2026

import 'package:health_care_reminder/core/enum/schedule_status_enum.dart';

import '../../data/model/patient_model.dart';
import '../../data/model/treatment_model.dart';

/// [ScheduleEntity] A domain entity class for schedules.
/// This class represents the core attributes of a schedule
/// used in the business logic layer.
class ScheduleEntity {
  final int? id;
  final int patientID;
  final int treatmentID;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime? alarmTime;
  final ScheduleStatusEnum status;
  final PatientModel? patient;
  final TreatmentModel? treatment;

  ScheduleEntity({
    this.id,
    required this.patientID,
    required this.treatmentID,
    required this.startTime,
    required this.endTime,
    this.alarmTime,
    required this.status,
    this.patient,
    this.treatment,
  });
}
