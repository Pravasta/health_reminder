part of 'activity_bloc.dart';

sealed class ActivityState {}

final class ActivityInitial extends ActivityState {}

final class ActivityLoading extends ActivityState {}

final class ActivityLoaded extends ActivityState {
  final List<ActivityEntity> activities;

  ActivityLoaded({required this.activities});
}

final class ActivityError extends ActivityState {
  final String message;

  ActivityError({required this.message});
}
