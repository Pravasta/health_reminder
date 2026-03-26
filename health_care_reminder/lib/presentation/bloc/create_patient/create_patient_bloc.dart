import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/domain/repositories/remote/patient_remote_repository.dart';

import '../../../data/dto/request/create_patient_request.dart';

part 'create_patient_state.dart';

class CreatePatientBloc extends Cubit<CreatePatientState> {
  CreatePatientBloc() : super(CreatePatientState());

  final PatientRemoteRepository _patientRemoteRepository =
      PatientRemoteRepositoryImpl.create();

  Future<void> createPatient(CreatePatientRequest request) async {
    emit(state.copyWith(status: CreatePatientStatus.loading));
    try {
      final message = await _patientRemoteRepository.createPatient(
        request: request,
      );
      emit(
        state.copyWith(status: CreatePatientStatus.success, message: message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CreatePatientStatus.error,
          message: e.toString(),
        ),
      );
    }
  }
}
