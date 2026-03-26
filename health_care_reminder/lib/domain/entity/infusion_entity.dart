import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';

/// [InfusionEntity] is a class that represents the infusion data in domain layer
class InfusionEntity {
  final int id;
  final int patientId;
  final String infusionName;
  final String patientName;
  final DateTime startTime;
  final DateTime endTime;
  final InfusionStatusEnum status;
  final int remainingTime;
  final bool isActive;

  InfusionEntity({
    required this.id,
    required this.patientId,
    required this.infusionName,
    required this.patientName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.remainingTime,
    required this.isActive,
  });
}
