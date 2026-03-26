part of 'patient_bloc.dart';

enum PatientStatus { initial, loading, success, error, deleted, deleting }

class PatientState {
  final PatientStatus status;
  final String? message;
  final List<PatientEntity> patients;
  final PatientEntity? patient;

  PatientState({
    this.status = PatientStatus.initial,
    this.message,
    this.patients = const [],
    this.patient,
  });

  PatientState copyWith({
    PatientStatus? status,
    String? message,
    List<PatientEntity>? patients,
    PatientEntity? patient,
  }) {
    return PatientState(
      status: status ?? this.status,
      message: message ?? this.message,
      patients: patients ?? this.patients,
      patient: patient ?? this.patient,
    );
  }

  @override
  String toString() {
    return 'PatientState{status: $status, message: $message, patients: $patients, patient: $patient}';
  }
}
