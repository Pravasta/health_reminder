import 'package:health_care_reminder/domain/entity/dashboard_entity.dart';

import '../../../data/datasources/remote/dashboard_remote_datasource.dart';
import '../../entity/activity_entity.dart';

/// [DashboardRemoteRepository] defines the contract for dashboard-related data operations.
abstract class DashboardRemoteRepository {
  Future<DashboardEntity> getDashboardData();
  Future<List<ActivityEntity>> getRecentActivities();
}

class DashboardRemoteRepositoryImpl implements DashboardRemoteRepository {
  final DashboardRemoteDatasource _dashboardRemoteDatasource;

  DashboardRemoteRepositoryImpl({
    required DashboardRemoteDatasource dashboardRemoteDatasource,
  }) : _dashboardRemoteDatasource = dashboardRemoteDatasource;

  factory DashboardRemoteRepositoryImpl.create() {
    return DashboardRemoteRepositoryImpl(
      dashboardRemoteDatasource: DashboardRemoteDatasourceImpl.create(),
    );
  }

  @override
  Future<DashboardEntity> getDashboardData() async {
    final response = await _dashboardRemoteDatasource.getDashboardData();

    final dashboardEntity = DashboardEntity(
      totalPatients: response.data.totalPatients,
      activeInfusions: response.data.activeInfusions,
      completedInfusions: response.data.completedInfusions,
      endingInfusions: response.data.endingInfusions,
    );

    return dashboardEntity;
  }

  @override
  Future<List<ActivityEntity>> getRecentActivities() async {
    final response = await _dashboardRemoteDatasource.getRecentActivities();

    return response.data.map((activity) {
      return ActivityEntity(
        type: activity.type,
        patientId: activity.patientId,
        message: activity.message,
        createdAt: activity.createdAt,
      );
    }).toList();
  }
}
