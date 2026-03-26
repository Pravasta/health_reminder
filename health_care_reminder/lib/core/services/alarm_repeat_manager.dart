// // Author : Pravasta Rama - 2026

// import 'package:health_care_reminder/core/services/alarm_service.dart';

// /// [AlarmRepeatManager] A class responsible for managing alarm repeats.
// /// This class can be expanded to include functionalities such as
// /// scheduling repeated alarms, canceling repeated alarms, and updating
// /// repeat intervals.
// class AlarmRepeatManager {
//   final AlarmService _alarmService;

//   AlarmRepeatManager(this._alarmService);

//   /// Schedule alarm utama + repeat
//   Future<void> scheduleRepeatingAlarm({
//     required int scheduleId,
//     required int firstTriggerMillis,
//     int repeatIntervalSeconds = 300,
//     int maxRepeatCount = 6,
//     String? title,
//     String? body,
//   }) async {
//     // 1️⃣ Alarm UTAMA (index 0)
//     await _alarmService.scheduleAlarm(
//       scheduleID: scheduleId,
//       triiggerTimeInMillis: firstTriggerMillis,
//       title: title ?? 'Health Care Reminder',
//       body: body ?? 'Segera lakukan tindakan kesehatan Anda!',
//       payload: scheduleId.toString(), // 🔥 WAJIB
//     );

//     // 2️⃣ Alarm REPEAT (index mulai 1)
//     for (int i = 1; i <= maxRepeatCount; i++) {
//       final triggerAt = firstTriggerMillis + (i * repeatIntervalSeconds * 1000);

//       final repeatAlarmId = _repeatId(scheduleId, i);

//       await _alarmService.scheduleAlarm(
//         scheduleID: repeatAlarmId,
//         triiggerTimeInMillis: triggerAt,
//         title: title ?? 'Health Care Reminder',
//         body: body ?? 'Segera lakukan tindakan kesehatan Anda!',
//         payload: scheduleId.toString(), // 🔥 TETAP scheduleId
//       );

//       print(
//         'Scheduled repeat alarm #$i | id=$repeatAlarmId | time=${DateTime.fromMillisecondsSinceEpoch(triggerAt)}',
//       );
//     }
//   }

//   /// Cancel alarm utama + semua repeat
//   Future<void> cancelRepeatingAlarm(int scheduleId) async {
//     // Cancel alarm utama
//     await _alarmService.cancelAlarm(scheduleId);

//     // Cancel semua repeat
//     for (int i = 1; i <= 30; i++) {
//       final alarmId = _repeatId(scheduleId, i);
//       await _alarmService.cancelAlarm(alarmId);
//     }
//   }

//   /// repeat alarm ID generator
//   int _repeatId(int scheduleId, int index) {
//     return scheduleId * 100 + index;
//   }

//   /// Payload sudah scheduleId → method ini OPTIONAL
//   int getOriginalScheduleId(int payload) {
//     return payload;
//   }
// }
