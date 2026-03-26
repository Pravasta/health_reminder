import 'package:flutter/material.dart';
import 'package:health_care_reminder/presentation/pages/admin/view/dashboard/features/main_dashboard/main_dashboard_view.dart';
import 'package:health_care_reminder/presentation/pages/admin/view/dashboard/features/patient/patient_dashboard_view.dart';

import '../../../../../core/theme/app_colors.dart';
import 'layout/sidebar.dart';
import 'widgets/dashboard_header.dart';

class DashboardAdminView extends StatefulWidget {
  const DashboardAdminView({super.key});

  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  bool isCollapsed = false;
  int selectedIndex = 0;

  List<Widget> get _contentViews => [
    const MainDashboardView(),
    const PatientDashboardView(),
  ];

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = isCollapsed ? 80 : 260;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sidebarWidth,
            child: Sidebar(
              selectedIndex: selectedIndex,
              isCollapsed: isCollapsed,
              onToggle: () {
                setState(() {
                  isCollapsed = !isCollapsed;
                });
              },
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),

          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 20),

                DashboardHeader(
                  title: switch (selectedIndex) {
                    0 => 'Dashboard',
                    1 => 'Pasien',
                    _ => 'Dashboard',
                  },
                  subtitle: switch (selectedIndex) {
                    0 => 'Selamat Datang Kembali',
                    1 => 'Kelola Pasien Anda',
                    _ => 'Dashboard',
                  },
                ),
                const Divider(height: 1, color: AppColors.greyColor),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _contentViews[selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
