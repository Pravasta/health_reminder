import 'dart:convert';

import 'package:health_care_reminder/core/endpoint/app_endpoint.dart';
import 'package:health_care_reminder/core/network/default_header.dart';
import 'package:health_care_reminder/core/network/http_client.dart';
import 'package:health_care_reminder/data/dto/request/create_patient_request.dart';
import 'package:health_care_reminder/data/dto/response/default_response.dart';
import 'package:health_care_reminder/data/dto/response/patient_response_model.dart';

/// [PatientRemoteDatasource] is an abstract class that defines the contract
/// for remote data source operations related to patients. It is responsible for
/// fetching patient data from a remote API or server. This class will be implemented
/// by a concrete class that interacts with the actual API endpoints to perform operations
/// such as creating a new patient, fetching patient details, updating patient information, etc.
abstract class PatientRemoteDatasource {
  Future<DefaultResponse<String?>> createPatient({
    required CreatePatientRequest request,
  });
  Future<DefaultResponse<String?>> deletePatient({required int patientId});
  Future<DefaultResponse<List<PatientResponseModel>>> getAllPatients();
  Future<DefaultResponse<PatientResponseModel>> getPatientById({
    required int patientId,
  });
}

class PatientRemoteDatasourceImpl implements PatientRemoteDatasource {
  final CustomHttpClient _httpClient;
  final AppEndpoint _appEndpoint;

  PatientRemoteDatasourceImpl({
    required CustomHttpClient httpClient,
    required AppEndpoint appEndpoint,
  }) : _httpClient = httpClient,
       _appEndpoint = appEndpoint;

  factory PatientRemoteDatasourceImpl.create() {
    return PatientRemoteDatasourceImpl(
      httpClient: CustomHttpClient.create(),
      appEndpoint: AppEndpoint.create(),
    );
  }

  @override
  Future<DefaultResponse<String?>> createPatient({
    required CreatePatientRequest request,
  }) async {
    var url = _appEndpoint.createPatient();

    final body = jsonEncode(request.toJson());

    final response = await _httpClient.post(
      url,
      body: body,
      headers: DefaultHeader.getHeader(),
    );

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<String?>(
      message: jsonData['message'],
      data: jsonData['data'] != null ? jsonData['data'] as String : null,
    );
    return result;
  }

  @override
  Future<DefaultResponse<String?>> deletePatient({required int patientId}) {
    var url = _appEndpoint.deletePatient(patientId: patientId);

    return _httpClient.delete(url, headers: DefaultHeader.getHeader()).then((
      response,
    ) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      final result = DefaultResponse<String?>(
        message: jsonData['message'],
        data: jsonData['data'] != null ? jsonData['data'] as String : null,
      );

      return result;
    });
  }

  @override
  Future<DefaultResponse<List<PatientResponseModel>>> getAllPatients() async {
    var url = _appEndpoint.fetchPatients();
    final header = DefaultHeader.getHeader();

    final response = await _httpClient.get(url, headers: header);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final List<PatientResponseModel> patients = (jsonData['data'] as List)
        .map((e) => PatientResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DefaultResponse<List<PatientResponseModel>>(
      message: jsonData['message'],
      data: patients,
    );
  }

  @override
  Future<DefaultResponse<PatientResponseModel>> getPatientById({
    required int patientId,
  }) async {
    var url = _appEndpoint.getPatientById(patientId: patientId);
    final header = DefaultHeader.getHeader();

    final response = await _httpClient.get(url, headers: header);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final patient = PatientResponseModel.fromJson(
      jsonData['data'] as Map<String, dynamic>,
    );

    return DefaultResponse<PatientResponseModel>(
      message: jsonData['message'],
      data: patient,
    );
  }
}
