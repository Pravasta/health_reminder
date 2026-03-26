part of 'create_infusion_bloc.dart';

enum CreateInfusionStatus { initial, loading, success, error }

class CreateInfusionState {
  final CreateInfusionStatus status;
  final InfusionEntity? infusion;
  final String message;

  CreateInfusionState({
    this.status = CreateInfusionStatus.initial,
    this.infusion,
    this.message = '',
  });

  CreateInfusionState copyWith({
    CreateInfusionStatus? status,
    InfusionEntity? infusion,
    String? message,
  }) {
    return CreateInfusionState(
      status: status ?? this.status,
      infusion: infusion ?? this.infusion,
      message: message ?? this.message,
    );
  }
}
