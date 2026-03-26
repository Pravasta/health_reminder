import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/domain/entity/patient_entity.dart';
import 'package:health_care_reminder/domain/repositories/remote/patient_remote_repository.dart';

part 'patient_state.dart';

class PatientBloc extends Cubit<PatientState> {
  PatientBloc() : super(PatientState());

  final PatientRemoteRepository _patientRemoteRepository =
      PatientRemoteRepositoryImpl.create();

  Future<void> fetchAllPatients() async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final patients = await _patientRemoteRepository.getAllPatients();
      emit(state.copyWith(status: PatientStatus.success, patients: patients));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.error, message: e.toString()));
    }
  }

  Future<void> getPatientById(int patientId) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final patient = await _patientRemoteRepository.getPatientById(
        patientId: patientId,
      );
      emit(state.copyWith(status: PatientStatus.success, patient: patient));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.error, message: e.toString()));
    }
  }

  Future<void> deletePatient(int patientId) async {
    emit(state.copyWith(status: PatientStatus.deleting));
    try {
      final message = await _patientRemoteRepository.deletePatient(
        patientId: patientId,
      );
      emit(state.copyWith(status: PatientStatus.deleted, message: message));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.error, message: e.toString()));
    }
  }
}
