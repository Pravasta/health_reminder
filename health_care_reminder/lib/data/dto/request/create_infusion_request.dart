/// [CreateInfusionRequest] is a data transfer object (DTO) that represents the request payload
/// for creating a new infusion. It typically contains the necessary fields and data required to create an infusion record in the system. This class will be used when making API calls to the remote data source to create a new infusion entry, encapsulating all the relevant information needed for that operation.
class CreateInfusionRequest {
  final int patientId;
  final String infusionName;
  final int tpm;
  final String deviceId;
  final int? customTime;

  CreateInfusionRequest({
    required this.patientId,
    required this.infusionName,
    required this.tpm,
    required this.deviceId,
    this.customTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'infusion_name': infusionName,
      'tpm': tpm,
      'device_id': deviceId,
      if (customTime != null) 'custom_time': customTime,
    };
  }
}
