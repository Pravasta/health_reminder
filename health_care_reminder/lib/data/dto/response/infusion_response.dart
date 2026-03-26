import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';
import 'package:health_care_reminder/core/utils/enum_mapper.dart';

import '../../../domain/entity/infusion_entity.dart';

/// [InfusionResponse] is a data transfer object (DTO) that represents the response received from the API
/// after performing operations related to infusions. It typically contains the necessary fields and data returned by the API after creating, fetching, updating, or deleting infusion records in the system. This class will be used to encapsulate the response data received from the remote data source when interacting with infusion-related endpoints, allowing the application to handle and process the response in a structured manner.
class InfusionResponse {
  final InfusionData data;
  final int remainingTime;
  final bool isActive;

  InfusionResponse({
    required this.data,
    required this.remainingTime,
    required this.isActive,
  });

  factory InfusionResponse.fromJson(Map<String, dynamic> json) {
    return InfusionResponse(
      data: InfusionData.fromJson(json['infusion_data']),
      remainingTime: json['remaining_time'],
      isActive: json['is_active'],
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'infusion_data': data.toJson(),
      'remaining_time': remainingTime,
      'is_active': isActive,
    };
  }

  // to InfusionEntity
  InfusionEntity toEntity() {
    return InfusionEntity(
      id: data.id,
      patientId: data.patientId,
      infusionName: data.infusionName,
      patientName: data.patientName,
      startTime: data.startTime,
      endTime: data.endTime,
      status: data.status,
      remainingTime: remainingTime,
      isActive: isActive,
    );
  }
}

/// [InfusionData] is a data transfer object (DTO) that represents the actual infusion data contained within the response from the API. It typically includes fields that describe the infusion details, such as infusion name, patient ID, infusion status, time per minute (TPM), and any other relevant information related to the infusion. This class will be used to encapsulate the specific data related to an infusion when processing the response received from the remote data source.
class InfusionData {
  final int id;
  final int patientId;
  final String infusionName;
  final String patientName;
  final DateTime startTime;
  final DateTime endTime;
  final InfusionStatusEnum status;

  InfusionData({
    required this.id,
    required this.patientId,
    required this.infusionName,
    required this.patientName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory InfusionData.fromJson(Map<String, dynamic> json) {
    return InfusionData(
      id: json['id'],
      patientId: json['patient_id'],
      infusionName: json['infusion_name'],
      patientName: json['patient_name'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: enumFromDb(InfusionStatusEnum.values, json['status']),
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'infusion_name': infusionName,
      'patient_name': patientName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }
}
