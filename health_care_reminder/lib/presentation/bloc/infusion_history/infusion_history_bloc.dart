import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/domain/repositories/remote/infusion_remote_repository.dart';

import '../../../domain/entity/infusion_entity.dart';

part 'infusion_history_state.dart';

class InfusionHistoryBloc extends Cubit<InfusionHistoryState> {
  InfusionHistoryBloc() : super(InfusionHistoryState());

  final InfusionRemoteRepository _infusionHistoryRepository =
      InfusionRemoteRepositoryImpl.create();

  Future<void> getInfusionsByPatientId({required int patientId}) async {
    emit(state.copyWith(status: InfusionHistoryStatus.loading));
    try {
      final infusions = await _infusionHistoryRepository
          .getInfusionsByPatientId(patientId: patientId);
      emit(
        state.copyWith(
          status: InfusionHistoryStatus.success,
          infusions: infusions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InfusionHistoryStatus.error,
          message: e.toString(),
        ),
      );
    }
  }
}
