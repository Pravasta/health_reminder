import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_care_reminder/core/enum/app_snackbar_type.dart';
import 'package:health_care_reminder/core/helper/app_snackbar.dart';

import '../services/alarm_service.dart';

/// [DashboardAllertHelper] is a helper class for managing dashboard alerts.
class DashboardAllertHelper {
  static final DashboardAllertHelper _instance =
      DashboardAllertHelper._internal();

  factory DashboardAllertHelper() {
    return _instance;
  }

  DashboardAllertHelper._internal();

  final List<String> _completedPatients = [];
  Timer? _bufferTimer;

  void receiveInfusionCompleted({
    required BuildContext context,
    required String patientName,
  }) {
    _completedPatients.add(patientName);

    _bufferTimer?.cancel();
    _bufferTimer = Timer(const Duration(seconds: 2), () {
      _showAlert(context);
    });
  }

  void _showAlert(BuildContext context) {
    if (_completedPatients.isEmpty) return;

    final count = _completedPatients.length;

    String message;

    if (count == 1) {
      message = "Infusion completed — ${_completedPatients.first}";
    } else {
      message = "$count infusions completed";
    }

    AppSnackbar.showCustomSnackbar(
      context: context,
      type: AppSnackbarType.success,
      title: 'Informasi',
      message: message,
      onDismiss: () {
        // Clear the list after the snackbar is dismissed
        _completedPatients.clear();
        AlarmService().stopAlarm();
      },
    );

    AlarmService().playAlarm();

    _completedPatients.clear();
  }
}
