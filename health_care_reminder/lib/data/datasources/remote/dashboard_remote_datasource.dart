import 'dart:convert';

import 'package:health_care_reminder/data/dto/response/activity_response.dart';
import 'package:health_care_reminder/data/dto/response/dashboard_model.dart';
import 'package:health_care_reminder/data/dto/response/default_response.dart';

import '../../../core/endpoint/app_endpoint.dart';
import '../../../core/network/default_header.dart';
import '../../../core/network/http_client.dart';

/// [DashboardRemoteDatasource] is an abstract class that defines the contract
/// for remote data source operations related to the dashboard.
/// It is responsible for fetching dashboard data from a remote API or server. This class will be implemented
/// by a concrete class that interacts with the actual API endpoints to perform operations
/// such as fetching summary statistics, recent activities, or any other data needed to populate the dashboard
abstract class DashboardRemoteDatasource {
  Future<DefaultResponse<DashboardModel>> getDashboardData();
  Future<DefaultResponse<List<ActivityResponse>>> getRecentActivities();
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final AppEndpoint _appEndpoint;
  final CustomHttpClient _httpClient;

  DashboardRemoteDatasourceImpl({
    required AppEndpoint appEndpoint,
    required CustomHttpClient httpClient,
  }) : _appEndpoint = appEndpoint,
       _httpClient = httpClient;

  factory DashboardRemoteDatasourceImpl.create() {
    return DashboardRemoteDatasourceImpl(
      appEndpoint: AppEndpoint.create(),
      httpClient: CustomHttpClient.create(),
    );
  }

  @override
  Future<DefaultResponse<DashboardModel>> getDashboardData() async {
    final url = _appEndpoint.fetchDashboard();

    final header = DefaultHeader.getHeader();

    final response = await _httpClient.get(url, headers: header);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<DashboardModel>(
      message: jsonData['message'],
      data: DashboardModel.fromJson(jsonData['data']),
    );

    return result;
  }

  @override
  Future<DefaultResponse<List<ActivityResponse>>> getRecentActivities() async {
    final url = _appEndpoint.fetchRecentActivities();

    final header = DefaultHeader.getHeader();

    final response = await _httpClient.get(url, headers: header);

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    final result = DefaultResponse<List<ActivityResponse>>(
      message: jsonData['message'],
      data: (jsonData['data'] as List<dynamic>)
          .map((item) => ActivityResponse.fromJson(item))
          .toList(),
    );

    return result;
  }
}
