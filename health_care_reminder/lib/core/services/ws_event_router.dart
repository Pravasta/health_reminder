import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_care_reminder/core/utils/screen_size.dart';
import 'package:health_care_reminder/presentation/bloc/dashboard_summary/dashboard_bloc.dart';
import 'package:health_care_reminder/presentation/bloc/infusion/infusion_bloc.dart';

import '../../presentation/bloc/activity/activity_bloc.dart';
import '../../presentation/bloc/patient_new/patient_bloc.dart';
import '../helper/dashboard_allert_helper.dart';
import 'web_socket_service.dart';

class WsEventRouter {
  late StreamSubscription _wsSub;

  final PatientBloc patientBloc;
  final InfusionBloc infusionBloc;
  final DashboardBloc dashboardBloc;
  final ActivityBloc activityBloc;
  final String deviceId;
  final BuildContext context;

  WsEventRouter({
    required this.patientBloc,
    required this.infusionBloc,
    required this.dashboardBloc,
    required this.activityBloc,
    required this.deviceId,
    required this.context,
  });

  void start() {
    _wsSub = WebSocketService().messages.listen((event) {
      if (event['device_id'] == deviceId) {
        return;
      }

      switch (event['type']) {
        case 'dashboard_update':
        case 'infusion_completed':
          patientBloc.fetchAllPatients();
          dashboardBloc.fetchDashboardSummary();
          infusionBloc.getInfusions();
          activityBloc.fetchRecentActivities();

          final payload = event['payload'] as Map<String, dynamic>?;
          final patientName =
              (payload?['patient_name'] ?? event['patient_name'] ?? 'Unknown')
                  .toString();
          if (!ScreenSize.isMobile(context)) {
            DashboardAllertHelper().receiveInfusionCompleted(
              context: context,
              patientName: patientName,
            );
          }
          break;
        case 'patient_created':
          patientBloc.fetchAllPatients();
          dashboardBloc.fetchDashboardSummary();
          activityBloc.fetchRecentActivities();
          break;
        case 'infusion_created':
        case 'infusion_stopped':
          patientBloc.fetchAllPatients();
          dashboardBloc.fetchDashboardSummary();
          infusionBloc.getInfusions();
          activityBloc.fetchRecentActivities();
          break;
        case 'patient_deleted':
          patientBloc.fetchAllPatients();
          dashboardBloc.fetchDashboardSummary();
          activityBloc.fetchRecentActivities();
          break;
      }
    });
  }

  void dispose() {
    _wsSub.cancel();
  }
}
