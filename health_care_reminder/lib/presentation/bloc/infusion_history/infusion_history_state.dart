part of 'infusion_history_bloc.dart';

enum InfusionHistoryStatus { initial, loading, success, error }

class InfusionHistoryState {
  final InfusionHistoryStatus status;
  final List<InfusionEntity> infusions;
  final String message;

  InfusionHistoryState({
    this.status = InfusionHistoryStatus.initial,
    this.infusions = const [],
    this.message = '',
  });

  InfusionHistoryState copyWith({
    InfusionHistoryStatus? status,
    List<InfusionEntity>? infusions,
    String? message,
  }) {
    return InfusionHistoryState(
      status: status ?? this.status,
      infusions: infusions ?? this.infusions,
      message: message ?? this.message,
    );
  }
}
