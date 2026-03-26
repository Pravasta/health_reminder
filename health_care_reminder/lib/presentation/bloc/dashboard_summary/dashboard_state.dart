part of 'dashboard_bloc.dart';

sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardSuccess extends DashboardState {
  final DashboardEntity summary;

  DashboardSuccess({required this.summary});
}

final class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}
