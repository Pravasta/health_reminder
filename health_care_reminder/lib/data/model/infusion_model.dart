import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';
import 'package:health_care_reminder/core/utils/enum_mapper.dart';

/// [InfusionModel] this model for saaving cache infusion data
/// it will be used for triggering notification alarm and showing infusion data on home screen without fetching from API
class InfusionModel {
  final int id;
  final int patientId;
  final String patientName;
  final String infusionName;
  final DateTime startTime;
  final DateTime endTime;
  final InfusionStatusEnum status;
  final int notificationId;
  final DateTime createdAt;

  InfusionModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.infusionName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.notificationId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'infusion_name': infusionName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': enumToDb(status),
      'notification_id': notificationId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InfusionModel.fromJson(Map<String, dynamic> json) {
    return InfusionModel(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      infusionName: json['infusion_name'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: enumFromDb<InfusionStatusEnum>(
        InfusionStatusEnum.values,
        json['status'],
      ),
      notificationId: json['notification_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
