import '../injection/injection.dart';
import 'uri_helper.dart';

class AppEndpoint {
  final String _baseUrl;
  final int _port;
  final String _scheme;

  AppEndpoint({
    required String baseUrl,
    required int port,
    required String scheme,
  }) : _baseUrl = baseUrl,
       _port = port,
       _scheme = scheme;

  Uri fetchDashboard() {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/dashboard/summary',
    );
  }

  Uri fetchRecentActivities() {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/dashboard/activities',
    );
  }

  Uri fetchPatients() {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/patients',
    );
  }

  Uri deletePatient({required int patientId}) {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/patients/$patientId',
    );
  }

  Uri getPatientById({required int patientId}) {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/patients/$patientId',
    );
  }

  Uri createPatient() {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/patients',
    );
  }

  Uri createInfusion() {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/infusions',
    );
  }

  Uri fetchInfusions() {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/infusions',
    );
  }

  Uri getInfusionByPatientId({required int patientId}) {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/infusions/patient/$patientId',
    );
  }

  Uri getInfusionRunningByPatientId({required int patientId}) {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/infusions/patient/$patientId/running',
    );
  }

  Uri stopInfusion({required int infusionId}) {
    return UriHelper.createUrl(
      scheme: _scheme,
      host: _baseUrl,
      port: _port,
      path: 'api/v1/infusions/$infusionId/stop',
    );
  }

  Uri websocketUrl() {
    return UriHelper.createUrl(
      host: _baseUrl,
      port: _port,
      path: 'ws',
      scheme: _scheme == 'http' ? 'ws' : 'wss',
    );
  }

  factory AppEndpoint.create() {
    return AppEndpoint(
      baseUrl: Injection.baseUrl,
      port: Injection.port,
      scheme: Injection.schema,
    );
  }
}
