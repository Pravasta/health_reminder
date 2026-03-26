import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Top-level function for handling notification actions in background/killed state.
/// MUST be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse details,
) async {
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  final plugin = FlutterLocalNotificationsPlugin();

  final payload = details.payload;
  if (payload == null) return;

  final data = jsonDecode(payload);
  final notifId = int.tryParse(data['notificationId'].toString());
  final patientName = data['patientName'] as String?;

  if (notifId == null || patientName == null) return;

  switch (details.actionId) {
    case 'SNOOZE_ACTION':
      // Cancel old notification first
      await plugin.cancel(id: notifId);

      // Schedule new notification 5 minutes from now
      final snoozeTime = DateTime.now().add(const Duration(minutes: 5));

      await plugin.zonedSchedule(
        id: notifId,
        title: "Infusion Reminder",
        body: "It's time for $patientName's infusion.",
        scheduledDate: tz.TZDateTime.from(snoozeTime, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationService.channelId,
            NotificationService.channelName,
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
            autoCancel: false,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('alarm_sound'),
            fullScreenIntent: true,
            actions: const [
              AndroidNotificationAction(
                'SNOOZE_ACTION',
                'Tunda 5 Menit',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                'COMPLETE_ACTION',
                'Selesai',
                showsUserInterface: true,
              ),
            ],
          ),
        ),
        payload: jsonEncode({
          'notificationId': notifId,
          'patientName': patientName,
        }),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      break;

    case 'COMPLETE_ACTION':
      await plugin.cancel(id: notifId);
      break;
  }
}

/// [NotificationService] is responsible for managing notifications in the app
/// includes scheduling, showing, and canceling notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'infusion_channel';
  static const String channelName = 'Infusion Reminder';

  final StreamController<void> _refreshController =
      StreamController.broadcast();

  Stream<void> get onInfusionUpdated => _refreshController.stream;

  Future<void> requestPermission() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
      );

      await androidPlugin.createNotificationChannel(channel);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  Future<void> scheduleNotification({
    required int notificationId,
    required String patientName,
    required DateTime scheduledTime,
  }) async {
    final dataPayload = {
      'notificationId': notificationId,
      'patientName': patientName,
    };

    print(
      '[NotificationService] Scheduling notification (ID: $notificationId) for patient: $patientName at ${scheduledTime.toIso8601String()}',
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: "Infusion Reminder",
      body: "It's time for $patientName's infusion.",
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
          playSound: true,
          fullScreenIntent: true,
          sound: const RawResourceAndroidNotificationSound('alarm_sound'),
          actions: const [
            AndroidNotificationAction(
              'SNOOZE_ACTION',
              'Tunda 5 Menit',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'COMPLETE_ACTION',
              'Selesai',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: jsonEncode(dataPayload),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(id: notificationId);
  }

  Future<void> rescheduleNotification({
    required int notificationId,
    required String patientName,
  }) async {
    await cancelNotification(notificationId);

    final nextTimeSchedule = DateTime.now().add(const Duration(minutes: 5));

    await scheduleNotification(
      notificationId: notificationId,
      patientName: patientName,
      scheduledTime: nextTimeSchedule,
    );
  }

  Future<void> _onNotificationResponse(NotificationResponse details) async {
    final payload = details.payload;

    if (payload == null) return;

    final data = jsonDecode(payload);

    final notifId = data['notificationId'];
    final patientName = data['patientName'];

    final notificationID = int.tryParse(notifId.toString());

    if (notificationID == null) return;

    switch (details.actionId) {
      case 'SNOOZE_ACTION':
        await rescheduleNotification(
          notificationId: notificationID,
          patientName: patientName,
        );
        break;

      case 'COMPLETE_ACTION':
        await cancelNotification(notificationID);
        // Delay to ensure UI is fully resumed before triggering refresh
        Future.delayed(const Duration(milliseconds: 500), () {
          _refreshController.add(null);
        });
        break;

      default:
        // user tap body notif → do nothing
        break;
    }
  }

  Future<void> rescheduleOnAppStart({
    required int notificationId,
    required String patientName,
    required DateTime endTime,
  }) async {
    if (endTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        notificationId: notificationId,
        patientName: patientName,
        scheduledTime: endTime,
      );
    }
  }
}
