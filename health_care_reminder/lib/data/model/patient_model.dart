import 'package:health_care_reminder/core/enum/gender_enum.dart';
import 'package:health_care_reminder/core/enum/schedule_status_enum.dart';

import '../../core/utils/enum_mapper.dart';

/// [PatientModel] A data model class for patients.
/// This class is responsible for converting patient data
/// to and from JSON format for database storage.
class PatientModel {
  final int? id;
  final String patientCode;
  final String name;
  final int? age;
  final Gender gender;
  final DateTime createdAt;

  final ScheduleStatusEnum? scheduleStatus;

  PatientModel({
    this.id,
    required this.patientCode,
    required this.name,
    this.age,
    required this.gender,
    required this.createdAt,
    this.scheduleStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_code': patientCode,
      'name': name,
      'age': age,
      'gender': enumToDb(gender),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      patientCode: json['patient_code'],
      name: json['name'],
      age: json['age'],
      gender: enumFromDb(Gender.values, json['gender']),
      createdAt: DateTime.parse(json['created_at']),
      scheduleStatus: json['schedule_status'] != null
          ? enumFromDb(ScheduleStatusEnum.values, json['schedule_status'])
          : null,
    );
  }
}
