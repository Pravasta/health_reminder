// Author: Pravasta Rama - 2026

import 'package:health_care_reminder/data/model/treatment_model.dart';

import '../../../core/database/database.dart';
import '../../../core/exception/database_exception.dart';

/// [TreatmentLocalDatasource] An abstract class defining local data source
/// operations for treatments.
abstract class TreatmentLocalDatasource {
  Future<List<TreatmentModel>> getAllTreatments();
}

/// [TreatmentLocalDatasourceImpl] Implementation of TreatmentLocalDatasource
/// using a local database.
class TreatmentLocalDatasourceImpl implements TreatmentLocalDatasource {
  final DatabaseHelper _databaseHelper;

  TreatmentLocalDatasourceImpl(this._databaseHelper);

  factory TreatmentLocalDatasourceImpl.create() {
    return TreatmentLocalDatasourceImpl(DatabaseHelper());
  }

  @override
  Future<List<TreatmentModel>> getAllTreatments() async {
    final db = await _databaseHelper.database;

    try {
      final maps = await db.query('treatments');
      return maps.map((map) => TreatmentModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseReadException(
        'Failed to read treatments from database: $e',
      );
    }
  }
}
