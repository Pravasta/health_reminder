import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/domain/repositories/remote/infusion_remote_repository.dart';

import '../../../domain/entity/infusion_entity.dart';

part 'infusion_state.dart';

class InfusionBloc extends Cubit<InfusionState> {
  InfusionBloc() : super(InfusionState());

  final InfusionRemoteRepository _infusionRemoteRepository =
      InfusionRemoteRepositoryImpl.create();

  Future<void> stopInfusion({required int infusionId}) async {
    emit(state.copyWith(status: InfusionStatus.stopping));
    try {
      final message = await _infusionRemoteRepository.stopInfusion(
        infusionId: infusionId,
      );
      emit(
        state.copyWith(
          status: InfusionStatus.stopped,
          message: message,
          clearInfusion: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: InfusionStatus.stopError, message: e.toString()),
      );
    }
  }

  Future<void> getInfusions() async {
    emit(state.copyWith(status: InfusionStatus.loading));
    try {
      final infusions = await _infusionRemoteRepository.getAllInfusions();
      emit(
        state.copyWith(status: InfusionStatus.success, infusions: infusions),
      );
    } catch (e) {
      emit(state.copyWith(status: InfusionStatus.error, message: e.toString()));
    }
  }
}
