// Author: Pravasta Rama - 2026

import 'package:health_care_reminder/core/database/database.dart';
import 'package:health_care_reminder/core/enum/schedule_status_enum.dart';
import 'package:health_care_reminder/core/exception/database_exception.dart';

import 'package:health_care_reminder/data/model/schedule_model.dart';

import '../../model/patient_model.dart';
import '../../model/treatment_model.dart';

/// [ScheduleLocalDatasource] An abstract class defining local data source
/// operations for schedules.
abstract class ScheduleLocalDatasource {
  Future<int> insertSchedule(ScheduleModel schedule);
  Future<ScheduleModel?> getActiveScheduleByPatientCode(String patientCode);
  Future<void> updateStatus(int scheduleID, ScheduleStatusEnum status);
  Future<ScheduleModel?> getScheduleById(int scheduleID);
  Future<List<ScheduleModel>> getSchedulesByPatientId(int patientId);
}

/// [ScheduleLocalDatasourceImpl] Implementation of ScheduleLocalDatasource
/// using a local database.
class ScheduleLocalDatasourceImpl implements ScheduleLocalDatasource {
  final DatabaseHelper _databaseHelper;

  ScheduleLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<ScheduleModel?> getActiveScheduleByPatientCode(
    String patientCode,
  ) async {
    final db = await _databaseHelper.database;

    try {
      final result = await db.rawQuery(
        '''
          SELECT s.*
            FROM schedules s
          INNER JOIN patients p ON p.id = s.patient_id
            WHERE p.patient_code = ? AND s.status = '${ScheduleStatusEnum.active.name}'
          ORDER BY s.end_time ASC
          LIMIT 1
        ''',
        [patientCode],
      );

      if (result.isEmpty) {
        return null;
      }

      // Get Patient Model from the first result
      final patientResult = await db.rawQuery(
        '''
          SELECT *
            FROM patients
           WHERE patient_code = ?
        ''',
        [patientCode],
      );

      if (patientResult.isEmpty) {
        return null;
      }

      // Get Treatment Model from the first result
      final treatmentResult = await db.rawQuery(
        '''
          SELECT *
            FROM treatments
           WHERE id = ?
        ''',
        [result.first['treatment_id']],
      );

      if (treatmentResult.isEmpty) {
        return null;
      }

      final dataResult = ScheduleModel.fromJson(result.first);

      final scheduleWithRelations = dataResult.copyWith(
        patient: PatientModel.fromJson(patientResult.first),
        treatment: TreatmentModel.fromJson(treatmentResult.first),
      );

      return scheduleWithRelations;
    } catch (e) {
      throw DatabaseReadException('Failed to read schedule: $e');
    }
  }

  @override
  Future<int> insertSchedule(ScheduleModel schedule) async {
    final db = await _databaseHelper.database;

    try {
      return await db.insert('schedules', schedule.toJson());
    } catch (e) {
      throw DatabaseInsertException('Failed to insert schedule: $e');
    }
  }

  @override
  Future<void> updateStatus(int scheduleID, ScheduleStatusEnum status) async {
    final db = await _databaseHelper.database;

    try {
      await db.update(
        'schedules',
        {'status': status.name},
        where: 'id = ?',
        whereArgs: [scheduleID],
      );
    } catch (e) {
      throw DatabaseUpdateException("Failed to update schedule: $e");
    }
  }

  @override
  Future<ScheduleModel?> getScheduleById(int scheduleID) async {
    final db = await _databaseHelper.database;

    try {
      final result = await db.query(
        'schedules',
        where: 'id = ?',
        whereArgs: [scheduleID],
      );

      if (result.isEmpty) {
        return null;
      }

      // Get Patient Model from the result
      final patientResult = await db.rawQuery(
        '''
          SELECT *
            FROM patients
           WHERE id = ?
        ''',
        [result.first['patient_id']],
      );

      if (patientResult.isEmpty) {
        return null;
      }

      // Get Treatment Model from the result
      final treatmentResult = await db.rawQuery(
        '''
          SELECT *
            FROM treatments
           WHERE id = ?
        ''',
        [result.first['treatment_id']],
      );

      if (treatmentResult.isEmpty) {
        return null;
      }

      final dataResult = ScheduleModel.fromJson(result.first);

      final scheduleWithRelations = dataResult.copyWith(
        patient: PatientModel.fromJson(patientResult.first),
        treatment: TreatmentModel.fromJson(treatmentResult.first),
      );

      return scheduleWithRelations;
    } catch (e) {
      throw DatabaseReadException('Failed to read schedule by id: $e');
    }
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByPatientId(int patientId) async {
    final db = await _databaseHelper.database;

    try {
      final result = await db.query(
        'schedules',
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );

      List<ScheduleModel> schedules = [];

      for (var row in result) {
        // Get Treatment Model from the result
        final treatmentResult = await db.rawQuery(
          '''
            SELECT *
              FROM treatments
             WHERE id = ?
          ''',
          [row['treatment_id']],
        );

        if (treatmentResult.isEmpty) {
          continue;
        }

        final dataResult = ScheduleModel.fromJson(row);

        final scheduleWithRelations = dataResult.copyWith(
          treatment: TreatmentModel.fromJson(treatmentResult.first),
        );

        schedules.add(scheduleWithRelations);
      }

      return schedules;
    } catch (e) {
      throw DatabaseReadException('Failed to read schedules by patient id: $e');
    }
  }
}
