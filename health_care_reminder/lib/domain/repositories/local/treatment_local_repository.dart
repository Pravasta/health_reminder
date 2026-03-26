// Author : Pravasta Rama - 2026

import 'package:dartz/dartz.dart';
import 'package:health_care_reminder/core/exception/database_exception.dart';
import 'package:health_care_reminder/core/exception/database_failure.dart';
import 'package:health_care_reminder/domain/entity/treatment_entity.dart';

import '../../../data/datasources/local/treatment_local_datasource.dart';

/// [TreatmentLocalRepository] An abstract class defining local repository
/// operations for treatments.
abstract class TreatmentLocalRepository {
  Future<Either<Failure, List<TreatmentEntity>>> getAllTreatments();
}

/// [TreatmentLocalRepositoryImpl] Implementation of TreatmentLocalRepository
/// using a local data source.
class TreatmentLocalRepositoryImpl implements TreatmentLocalRepository {
  final TreatmentLocalDatasource _localDatasource;

  TreatmentLocalRepositoryImpl(this._localDatasource);

  factory TreatmentLocalRepositoryImpl.create() {
    return TreatmentLocalRepositoryImpl(TreatmentLocalDatasourceImpl.create());
  }

  @override
  Future<Either<Failure, List<TreatmentEntity>>> getAllTreatments() async {
    try {
      final treatments = await _localDatasource.getAllTreatments();

      final treatmentEntities = treatments
          .map(
            (treatmentModel) => TreatmentEntity(
              id: treatmentModel.id,
              name: treatmentModel.name,
              defaultDuration: treatmentModel.defaultDuration,
            ),
          )
          .toList();
      return Right(treatmentEntities);
    } on DatabaseException {
      return Left(DatabaseFailure('Failed to fetch treatments'));
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch treatments: $e'));
    }
  }
}
