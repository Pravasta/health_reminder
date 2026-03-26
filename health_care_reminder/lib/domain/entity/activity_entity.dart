class ActivityEntity {
  final String type;
  final int patientId;
  final String message;
  final DateTime createdAt;

  ActivityEntity({
    required this.type,
    required this.patientId,
    required this.message,
    required this.createdAt,
  });
}
