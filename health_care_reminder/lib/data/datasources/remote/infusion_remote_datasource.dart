import 'dart:convert';

import 'package:health_care_reminder/core/endpoint/app_endpoint.dart';
import 'package:health_care_reminder/data/dto/request/create_infusion_request.dart';
import 'package:health_care_reminder/data/dto/response/default_response.dart';
import 'package:health_care_reminder/data/dto/response/infusion_response.dart';

import '../../../core/network/default_header.dart';
import '../../../core/network/http_client.dart';

/// [InfusionRemoteDatasource] is an abstract class that defines the contract
/// for remote data source operations related to infusions. It is responsible for
/// fetching infusion data from a remote API or server. This class will be implemented
/// by a concrete class that interacts with the actual API endpoints to perform operations
/// such as creating a new infusion, fetching infusion details, updating infusion information, etc.
abstract class InfusionRemoteDatasource {
  Future<DefaultResponse<InfusionResponse>> createInfusion({
    required CreateInfusionRequest request,
  });
  Future<DefaultResponse<List<InfusionResponse>>> getAllInfusions();
  Future<DefaultResponse<List<InfusionResponse>>> getInfusionsByPatientId({
    required int patientId,
  });
  Future<DefaultResponse<InfusionResponse?>> getInfusionsRunningByPatientId({
    required int patientId,
  });
  Future<DefaultResponse<String?>> stopInfusion({required int infusionId});
}

class InfusionRemoteDatasourceImpl implements InfusionRemoteDatasource {
  final AppEndpoint _appEndpoint;
  final CustomHttpClient _httpClient;

  InfusionRemoteDatasourceImpl({
    required AppEndpoint appEndpoint,
    required CustomHttpClient httpClient,
  }) : _appEndpoint = appEndpoint,
       _httpClient = httpClient;

  factory InfusionRemoteDatasourceImpl.create() {
    return InfusionRemoteDatasourceImpl(
      appEndpoint: AppEndpoint.create(),
      httpClient: CustomHttpClient.create(),
    );
  }

  @override
  Future<DefaultResponse<InfusionResponse>> createInfusion({
    required CreateInfusionRequest request,
  }) async {
    final url = _appEndpoint.createInfusion();

    final body = jsonEncode(request.toJson());
    final header = DefaultHeader.getHeader();

    final response = await _httpClient.post(url, body: body, headers: header);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<InfusionResponse>(
      message: jsonData['message'],
      data: InfusionResponse.fromJson(jsonData['data']),
    );
    return result;
  }

  @override
  Future<DefaultResponse<List<InfusionResponse>>> getAllInfusions() async {
    final url = _appEndpoint.fetchInfusions();

    final response = await _httpClient.get(url);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<List<InfusionResponse>>(
      message: jsonData['message'],
      data: (jsonData['data'] as List)
          .map((e) => InfusionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result;
  }

  @override
  Future<DefaultResponse<List<InfusionResponse>>> getInfusionsByPatientId({
    required int patientId,
  }) async {
    final url = _appEndpoint.getInfusionByPatientId(patientId: patientId);

    final response = await _httpClient.get(url);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<List<InfusionResponse>>(
      message: jsonData['message'],
      data: (jsonData['data'] as List)
          .map((e) => InfusionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result;
  }

  @override
  Future<DefaultResponse<InfusionResponse?>> getInfusionsRunningByPatientId({
    required int patientId,
  }) async {
    final url = _appEndpoint.getInfusionRunningByPatientId(
      patientId: patientId,
    );

    final response = await _httpClient.get(url);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<InfusionResponse?>(
      message: jsonData['message'],
      data: jsonData['data'] != null
          ? InfusionResponse.fromJson(jsonData['data'])
          : null,
    );
    return result;
  }

  @override
  Future<DefaultResponse<String?>> stopInfusion({
    required int infusionId,
  }) async {
    final url = _appEndpoint.stopInfusion(infusionId: infusionId);

    final response = await _httpClient.put(url);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<String?>(
      message: jsonData['message'],
      data: jsonData['data'] != null ? jsonData['data'] as String : null,
    );
    return result;
  }
}
