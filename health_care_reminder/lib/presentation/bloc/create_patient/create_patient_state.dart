part of 'create_patient_bloc.dart';

enum CreatePatientStatus { initial, loading, success, error }

class CreatePatientState {
  final CreatePatientStatus status;
  final String message;

  CreatePatientState({
    this.status = CreatePatientStatus.initial,
    this.message = '',
  });

  CreatePatientState copyWith({CreatePatientStatus? status, String? message}) {
    return CreatePatientState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
