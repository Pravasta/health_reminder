import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/domain/entity/dashboard_entity.dart';
import 'package:health_care_reminder/domain/repositories/remote/dashboard_remote_repository.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Cubit<DashboardState> {
  DashboardBloc() : super(DashboardInitial());

  final DashboardRemoteRepository _dashboardRemoteRepository =
      DashboardRemoteRepositoryImpl.create();

  Future<void> fetchDashboardSummary() async {
    emit(DashboardLoading());
    try {
      final dashboard = await _dashboardRemoteRepository.getDashboardData();
      emit(DashboardSuccess(summary: dashboard));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}
