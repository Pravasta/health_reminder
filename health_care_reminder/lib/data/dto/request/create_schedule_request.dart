// Author : Pravasta Rama - 2026

/// [CreateScheduleRequest] A data transfer object for creating a schedule.
/// This class contains the necessary information to create a new schedule
/// for a patient undergoing a specific treatment.
class CreateScheduleRequest {
  final int patientID;
  final int treatmentID;
  final int durationMinutes;
  final String treatmentName;
  final String patientName;

  CreateScheduleRequest({
    required this.patientID,
    required this.treatmentID,
    required this.durationMinutes,
    required this.treatmentName,
    required this.patientName,
  });
}
