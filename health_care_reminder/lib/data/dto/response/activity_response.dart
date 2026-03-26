/// [ActivityResponse] represents the response model for activity-related API calls.
class ActivityResponse {
  final int id;
  final String type;
  final int patientId;
  final String message;
  final DateTime createdAt;

  ActivityResponse({
    required this.id,
    required this.type,
    required this.patientId,
    required this.message,
    required this.createdAt,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      id: json['id'],
      type: json['type'],
      patientId: json['patient_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
