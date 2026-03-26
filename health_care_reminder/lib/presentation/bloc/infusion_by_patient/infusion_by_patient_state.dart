part of 'infusion_by_patient_bloc.dart';

enum InfusionByPatientStatus { initial, loading, success, error }

class InfusionByPatientState {
  final InfusionByPatientStatus status;
  final InfusionEntity? infusion;
  final String message;

  InfusionByPatientState({
    this.status = InfusionByPatientStatus.initial,
    this.infusion,
    this.message = '',
  });

  InfusionByPatientState copyWith({
    InfusionByPatientStatus? status,
    InfusionEntity? infusion,
    String? message,
  }) {
    return InfusionByPatientState(
      status: status ?? this.status,
      infusion: infusion ?? this.infusion,
      message: message ?? this.message,
    );
  }
}
