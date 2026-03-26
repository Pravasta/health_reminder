import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/domain/repositories/remote/dashboard_remote_repository.dart';

import '../../../domain/entity/activity_entity.dart';

part 'activity_state.dart';

class ActivityBloc extends Cubit<ActivityState> {
  ActivityBloc() : super(ActivityInitial());

  final DashboardRemoteRepositoryImpl _dashboardRemoteRepository =
      DashboardRemoteRepositoryImpl.create();

  Future<void> fetchRecentActivities() async {
    emit(ActivityLoading());
    try {
      final activities = await _dashboardRemoteRepository.getRecentActivities();
      emit(ActivityLoaded(activities: activities));
    } catch (e) {
      emit(ActivityError(message: e.toString()));
    }
  }
}
