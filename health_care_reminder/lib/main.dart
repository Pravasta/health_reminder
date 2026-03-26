import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_care_reminder/core/database/database.dart';
import 'package:health_care_reminder/core/endpoint/app_endpoint.dart';
import 'package:health_care_reminder/core/services/web_socket_service.dart';
import 'core/services/device_id_service.dart';
import 'core/services/notification_service.dart';
import 'main_app.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // INIT DATABASE
  // =========================
  final db = DatabaseHelper();
  await db.database;

  final deviceId = await DeviceIdService.getDeviceId();
  // =========================
  // INIT SERVICES
  // =========================
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();

  final appEndpoint = AppEndpoint.create();
  final stringFromURI = appEndpoint.websocketUrl().toString();

  WebSocketService().connect(stringFromURI);

  // =========================
  // UI CONFIG
  // =========================
  final data = MediaQueryData.fromView(
    WidgetsBinding.instance.platformDispatcher.views.first,
  );
  final isTablet = data.size.shortestSide >= 600;

  if (!isTablet) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(MyApp(deviceId: deviceId));
}
