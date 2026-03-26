/// [DashboardModel] is a data model class that represents the structure of the dashboard data received from the API.
class DashboardModel {
  final int totalPatients;
  final int activeInfusions;
  final int endingInfusions;
  final int completedInfusions;

  DashboardModel({
    required this.totalPatients,
    required this.activeInfusions,
    required this.endingInfusions,
    required this.completedInfusions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalPatients: json['total_patients'] as int,
      activeInfusions: json['active_infusions'] as int,
      endingInfusions: json['ending_infusions'] as int,
      completedInfusions: json['completed'] as int,
    );
  }
}
