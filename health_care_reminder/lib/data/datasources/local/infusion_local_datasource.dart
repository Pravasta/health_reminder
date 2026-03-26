import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';
import 'package:health_care_reminder/core/exception/database_exception.dart';
import 'package:health_care_reminder/data/model/infusion_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database.dart';

/// [InfusionLocalDatasource] is responsible for handling data from remote
/// data to cache in local storage, such as a database or shared preferences.
/// This class will be implemented by a concrete class that interacts with the actual local storage mechanism to perform operations such as caching infusion data, retrieving cached infusion data, clearing cached infusion data, etc.
abstract class InfusionLocalDatasource {
  Future<void> cacheInfusionData({required InfusionModel infusionModel});
  Future<List<InfusionModel>> getCachedInfusionData();
  Future<InfusionModel?> getCachedInfusionDataById({required int infusionId});
  Future<void> updateInfusionStatus({
    required int infusionId,
    required InfusionStatusEnum status,
  });
  Future<List<InfusionModel>> getActiveInfusions();
  Future<void> deleteInfusion({required int infusionId});
}

class InfusionLocalDatasourceImpl implements InfusionLocalDatasource {
  final DatabaseHelper daatabaseHelper;

  InfusionLocalDatasourceImpl({required this.daatabaseHelper});

  factory InfusionLocalDatasourceImpl.create() {
    final databaseHelper = DatabaseHelper();

    return InfusionLocalDatasourceImpl(daatabaseHelper: databaseHelper);
  }

  @override
  Future<void> cacheInfusionData({required InfusionModel infusionModel}) async {
    try {
      final db = await daatabaseHelper.database;

      await db.insert(
        'infusion_cache',
        infusionModel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseReadException('Failed to cache infusion data: $e');
    }
  }

  @override
  Future<List<InfusionModel>> getCachedInfusionData() async {
    try {
      final db = await daatabaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query('infusion_cache');

      return List.generate(maps.length, (i) {
        return InfusionModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseReadException('Failed to get cached infusion data: $e');
    }
  }

  @override
  Future<InfusionModel?> getCachedInfusionDataById({
    required int infusionId,
  }) async {
    try {
      final db = await daatabaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'infusion_cache',
        where: 'id = ?',
        whereArgs: [infusionId],
      );

      if (maps.isNotEmpty) {
        return InfusionModel.fromJson(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      throw DatabaseReadException(
        'Failed to get cached infusion data by id: $e',
      );
    }
  }

  @override
  Future<void> updateInfusionStatus({
    required int infusionId,
    required InfusionStatusEnum status,
  }) async {
    try {
      final db = await daatabaseHelper.database;

      await db.update(
        'infusion_cache',
        {'status': status.toString().split('.').last},
        where: 'id = ?',
        whereArgs: [infusionId],
      );
    } catch (e) {
      throw DatabaseReadException('Failed to update infusion status: $e');
    }
  }

  @override
  Future<List<InfusionModel>> getActiveInfusions() async {
    try {
      final db = await daatabaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'infusion_cache',
        where: 'status = ?',
        whereArgs: ['active'],
      );

      return List.generate(maps.length, (i) {
        return InfusionModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseReadException('Failed to get active infusions: $e');
    }
  }

  @override
  Future<void> deleteInfusion({required int infusionId}) async {
    try {
      final db = await daatabaseHelper.database;

      await db.delete(
        'infusion_cache',
        where: 'id = ?',
        whereArgs: [infusionId],
      );
    } catch (e) {
      throw DatabaseReadException('Failed to delete infusion: $e');
    }
  }
}
