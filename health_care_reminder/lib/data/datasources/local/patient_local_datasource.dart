// Author: Pravasta Rama - 2026

import 'package:health_care_reminder/core/exception/database_exception.dart';
import 'package:health_care_reminder/data/model/patient_model.dart';

import '../../../core/database/database.dart';

/// [PatientLocalDatasource] An abstract class defining local data source
/// operations for patient data.
abstract class PatientLocalDatasource {
  Future<void> insertPatient(PatientModel patient);
  Future<List<PatientModel>> getAllPatients();
  Future<PatientModel?> getPatientByCode(String patientCode);
  Future<PatientModel?> getPatientById(int id);
  Future<bool> isPatientCodeExists(String patientCode);
  Future<void> deletePatient(int id);
}

/// [PatientLocalDatasourceImpl] Implementation of [PatientLocalDatasource].
/// This class uses [DatabaseHelper] to perform local database operations
/// related to patient data.
class PatientLocalDatasourceImpl implements PatientLocalDatasource {
  final DatabaseHelper databaseHelper;

  PatientLocalDatasourceImpl({required this.databaseHelper});

  factory PatientLocalDatasourceImpl.create() {
    final databaseHelper = DatabaseHelper();

    return PatientLocalDatasourceImpl(databaseHelper: databaseHelper);
  }

  @override
  Future<void> deletePatient(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete('patients', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseDeleteException('Failed to delete patient: $e');
    }
  }

  @override
  Future<List<PatientModel>> getAllPatients() async {
    try {
      final db = await databaseHelper.database;

      final maps = await db.rawQuery('''
          SELECT 
            p.*,
            s.status AS schedule_status
          FROM patients p
          LEFT JOIN schedules s ON s.id = (
            SELECT id
            FROM schedules
            WHERE patient_id = p.id
            ORDER BY 
              CASE status
                WHEN 'active' THEN 1
                WHEN 'expired' THEN 2
                WHEN 'completed' THEN 3
                WHEN 'canceled' THEN 4
              END,
              created_at DESC
            LIMIT 1
          )
          ORDER BY p.created_at DESC;
        ''');

      // Optional: Keep minimal logging for debugging
      // print('Loaded ${maps.length} patients');

      return List.generate(maps.length, (i) {
        return PatientModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseReadException('Failed to read patients: $e');
    }
  }

  @override
  Future<PatientModel?> getPatientByCode(String patientCode) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        where: 'patient_code = ?',
        whereArgs: [patientCode],
      );
      if (maps.isNotEmpty) {
        return PatientModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseReadException('Failed to read patient by code: $e');
    }
  }

  @override
  Future<PatientModel?> getPatientById(int id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return PatientModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseReadException('Failed to read patient by id: $e');
    }
  }

  @override
  Future<void> insertPatient(PatientModel patient) async {
    try {
      final db = await databaseHelper.database;
      await db.insert('patients', patient.toJson());
    } catch (e) {
      throw DatabaseInsertException('Failed to insert patient: $e');
    }
  }

  @override
  Future<bool> isPatientCodeExists(String patientCode) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        where: 'patient_code = ?',
        whereArgs: [patientCode],
      );
      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseReadException('Failed to check if patient code exists: $e');
    }
  }
}
