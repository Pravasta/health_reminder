// Author: Pravasta Rama - 2026

import 'package:health_care_reminder/core/enum/schedule_status_enum.dart';
import 'package:health_care_reminder/core/utils/enum_mapper.dart';
import 'package:health_care_reminder/data/model/patient_model.dart';
import 'package:health_care_reminder/data/model/treatment_model.dart';

/// [ScheduleModel] A data model class for schedules.
/// This class is responsible for converting schedule data
/// to and from JSON format for database storage.
class ScheduleModel {
  final int? id;
  final int patientID;
  final int treatmentID;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime? alarmTime;
  final ScheduleStatusEnum status;
  final DateTime createdAt;
  final PatientModel? patient;
  final TreatmentModel? treatment;

  ScheduleModel({
    this.id,
    required this.patientID,
    required this.treatmentID,
    required this.startTime,
    required this.endTime,
    this.alarmTime,
    required this.status,
    required this.createdAt,
    this.patient,
    this.treatment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientID,
      'treatment_id': treatmentID,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'alarm_time': alarmTime?.toIso8601String(),
      'status': enumToDb(status),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      patientID: json['patient_id'],
      treatmentID: json['treatment_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      alarmTime: json['alarm_time'] != null
          ? DateTime.parse(json['alarm_time'])
          : null,
      status: enumFromDb(ScheduleStatusEnum.values, json['status']),
      createdAt: DateTime.parse(json['created_at']),
      patient: json['patient'] != null
          ? PatientModel.fromJson(json['patient'])
          : null,
      treatment: json['treatment'] != null
          ? TreatmentModel.fromJson(json['treatment'])
          : null,
    );
  }

  // copyWith method to create a copy of ScheduleModel with modified fields
  ScheduleModel copyWith({
    int? id,
    int? patientID,
    int? treatmentID,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? alarmTime,
    ScheduleStatusEnum? status,
    DateTime? createdAt,
    PatientModel? patient,
    TreatmentModel? treatment,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      patientID: patientID ?? this.patientID,
      treatmentID: treatmentID ?? this.treatmentID,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      alarmTime: alarmTime ?? this.alarmTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      patient: patient ?? this.patient,
      treatment: treatment ?? this.treatment,
    );
  }
}
