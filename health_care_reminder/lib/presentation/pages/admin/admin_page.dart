import 'package:flutter/material.dart';
import 'package:health_care_reminder/presentation/pages/admin/view/dashboard/dashboard_admin_view.dart';

import '../../../core/utils/screen_size.dart';
import 'view/mobile/admin_view.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: const AdminView(),
      tablet: const DashboardAdminView(),
      desktop: const DashboardAdminView(),
    );
  }
}
