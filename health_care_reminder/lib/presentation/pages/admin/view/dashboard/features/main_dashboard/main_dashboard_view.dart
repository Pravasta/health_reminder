import 'package:flutter/material.dart';
import 'package:health_care_reminder/presentation/pages/admin/view/dashboard/features/main_dashboard/component/dashboard_live_monitoring.dart';
import 'package:health_care_reminder/presentation/pages/admin/view/dashboard/features/main_dashboard/component/dashboard_recent_activities.dart';

import 'component/dashboard_summary.dart';

class MainDashboardView extends StatelessWidget {
  const MainDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: double.infinity,

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardSummary(),
            const SizedBox(height: 16),
            const DashboardLiveMonitoring(),
            const SizedBox(height: 16),
            const DashboardRecentActivities(),
          ],
        ),
      ),
    );
  }
}
