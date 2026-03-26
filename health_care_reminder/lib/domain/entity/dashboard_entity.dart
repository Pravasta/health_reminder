/// [DashboardEntity] represents the data structure for the dashboard summary information.
class DashboardEntity {
  final int totalPatients;
  final int activeInfusions;
  final int endingInfusions;
  final int completedInfusions;

  DashboardEntity({
    required this.totalPatients,
    required this.activeInfusions,
    required this.endingInfusions,
    required this.completedInfusions,
  });
}
