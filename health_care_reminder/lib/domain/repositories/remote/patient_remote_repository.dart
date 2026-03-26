import 'package:health_care_reminder/data/datasources/remote/patient_remote_datasource.dart';
import 'package:health_care_reminder/domain/entity/patient_entity.dart';

import '../../../data/dto/request/create_patient_request.dart';

/// [PatientRemoteRepository] is an abstract class that defines the contract
/// for remote repository operations related to patients. It is responsible for
/// providing an interface for the domain layer to interact with the remote data source.
/// This class will be implemented by a concrete class that interacts with the actual remote data source (e.g., API) to perform operations
/// such as creating a new patient, fetching patient details, updating patient information, etc. The repository abstracts away the details of how the data is fetched or manipulated, allowing the domain layer to work with a clean and consistent interface.
abstract class PatientRemoteRepository {
  Future<String> createPatient({required CreatePatientRequest request});
  Future<String> deletePatient({required int patientId});
  Future<List<PatientEntity>> getAllPatients();
  Future<PatientEntity> getPatientById({required int patientId});
}

class PatientRemoteRepositoryImpl implements PatientRemoteRepository {
  final PatientRemoteDatasource _remoteDatasource;

  PatientRemoteRepositoryImpl({
    required PatientRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  factory PatientRemoteRepositoryImpl.create() {
    return PatientRemoteRepositoryImpl(
      remoteDatasource: PatientRemoteDatasourceImpl.create(),
    );
  }

  @override
  Future<String> createPatient({required CreatePatientRequest request}) async {
    final response = await _remoteDatasource.createPatient(request: request);

    return response.message;
  }

  @override
  Future<String> deletePatient({required int patientId}) async {
    final response = await _remoteDatasource.deletePatient(
      patientId: patientId,
    );

    return response.message;
  }

  @override
  Future<List<PatientEntity>> getAllPatients() async {
    final response = await _remoteDatasource.getAllPatients();

    final result = response.data.map(
      (patient) => PatientEntity(
        id: patient.id,
        name: patient.name,
        patientCode: patient.code,
        gender: patient.gender,
        status: patient.status,
        endTime: patient.endTime,
        startTime: patient.startTime,
        tpm: patient.tpm,
      ),
    );

    return result.toList();
  }

  @override
  Future<PatientEntity> getPatientById({required int patientId}) async {
    final response = await _remoteDatasource.getPatientById(
      patientId: patientId,
    );

    final patient = response.data;

    return PatientEntity(
      id: patient.id,
      name: patient.name,
      patientCode: patient.code,
      gender: patient.gender,
      status: patient.status,
      endTime: patient.endTime,
      startTime: patient.startTime,
      tpm: patient.tpm,
    );
  }
}
