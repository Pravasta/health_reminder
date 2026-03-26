import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/infusion_entity.dart';
import '../../../domain/repositories/remote/infusion_remote_repository.dart';

part 'infusion_by_patient_state.dart';

class InfusionByPatientBloc extends Cubit<InfusionByPatientState> {
  InfusionByPatientBloc() : super(InfusionByPatientState());

  final InfusionRemoteRepository _infusionByPatientRepository =
      InfusionRemoteRepositoryImpl.create();

  Future<void> getInfusionRunningByPatientId({required int patientId}) async {
    emit(state.copyWith(status: InfusionByPatientStatus.loading));
    try {
      final infusion = await _infusionByPatientRepository
          .getRunningInfusionByPatientId(patientId: patientId);
      if (infusion != null) {
        emit(
          state.copyWith(
            status: InfusionByPatientStatus.success,
            infusion: infusion,
          ),
        );
      } else {
        emit(state.copyWith(status: InfusionByPatientStatus.success));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: InfusionByPatientStatus.error,
          message: e.toString(),
        ),
      );
    }
  }
}
