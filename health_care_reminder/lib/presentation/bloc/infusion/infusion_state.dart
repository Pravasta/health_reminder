part of 'infusion_bloc.dart';

enum InfusionStatus {
  initial,
  loading,
  success,
  error,
  stopping,
  stopped,
  stopError,
}

final class InfusionState {
  final InfusionStatus status;
  final List<InfusionEntity> infusions;
  final InfusionEntity? infusion;
  final String message;

  InfusionState({
    this.status = InfusionStatus.initial,
    this.infusions = const [],
    this.infusion,
    this.message = '',
  });

  InfusionState copyWith({
    InfusionStatus? status,
    List<InfusionEntity>? infusions,
    InfusionEntity? infusion,
    bool clearInfusion = false,
    String? message,
  }) {
    return InfusionState(
      status: status ?? this.status,
      infusions: infusions ?? this.infusions,
      infusion: clearInfusion ? null : (infusion ?? this.infusion),
      message: message ?? this.message,
    );
  }
}
