import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dto/request/create_infusion_request.dart';
import '../../../domain/entity/infusion_entity.dart';
import '../../../domain/repositories/remote/infusion_remote_repository.dart';

part 'create_infusion_state.dart';

class CreateInfusionBloc extends Cubit<CreateInfusionState> {
  CreateInfusionBloc() : super(CreateInfusionState());

  final InfusionRemoteRepository _infusionRemoteRepository =
      InfusionRemoteRepositoryImpl.create();

  Future<void> createInfusion({required CreateInfusionRequest request}) async {
    emit(state.copyWith(status: CreateInfusionStatus.loading));
    try {
      final infusion = await _infusionRemoteRepository.createInfusion(
        request: request,
      );
      emit(
        state.copyWith(
          status: CreateInfusionStatus.success,
          infusion: infusion,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateInfusionStatus.error,
          message: e.toString(),
        ),
      );
    }
  }
}
