import 'package:health_care_reminder/core/enum/gender_enum.dart';
import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';
import 'package:health_care_reminder/core/utils/enum_mapper.dart';

/// [PatientResponseModel]
/// This class represents the response model for patient data from the API
/// It can be used to parse the JSON response from the API when fetching patient data
class PatientResponseModel {
  final int id;
  final String name;
  final String code;
  final Gender gender;
  final InfusionStatusEnum? status;
  final int? tpm;
  final DateTime? startTime;
  final DateTime? endTime;

  PatientResponseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.gender,
    this.status,
    this.tpm,
    this.startTime,
    this.endTime,
  });

  factory PatientResponseModel.fromJson(Map<String, dynamic> json) {
    return PatientResponseModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      gender: enumFromDb(Gender.values, json['gender']),
      status: json['status'] != null
          ? enumFromDb(InfusionStatusEnum.values, json['status'])
          : null,
      tpm: json['tpm'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
    );
  }
}
