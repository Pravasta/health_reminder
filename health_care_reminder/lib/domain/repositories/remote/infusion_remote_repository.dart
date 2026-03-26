import 'package:health_care_reminder/data/dto/request/create_infusion_request.dart';
import 'package:health_care_reminder/data/model/infusion_model.dart';
import 'package:health_care_reminder/domain/entity/infusion_entity.dart';

import '../../../core/enum/infusion_status_enum.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/datasources/local/infusion_local_datasource.dart';
import '../../../data/datasources/remote/infusion_remote_datasource.dart';

/// [InfusionRemoteRepository] is an abstract class that defines the contract for repository
/// operations related to infusions. It is responsible for handling the business logic of fetching
/// infusion data from a remote data source, such as an API or server. This class will be implemented
/// by a concrete class that interacts with the actual API endpoints to perform operations such as
/// fetching infusion details, creating new infusions, updating infusion information, etc.
abstract class InfusionRemoteRepository {
  Future<InfusionEntity> createInfusion({
    required CreateInfusionRequest request,
  });
  Future<String> stopInfusion({required int infusionId});
  Future<List<InfusionEntity>> getAllInfusions();
  Future<List<InfusionEntity>> getInfusionsByPatientId({
    required int patientId,
  });
  Future<InfusionEntity?> getRunningInfusionByPatientId({
    required int patientId,
  });
}

class InfusionRemoteRepositoryImpl implements InfusionRemoteRepository {
  final InfusionRemoteDatasource _infusionRemoteDatasource;
  final InfusionLocalDatasource _infusionLocalDatasource;
  final NotificationService _notificationService;

  InfusionRemoteRepositoryImpl({
    required InfusionRemoteDatasource infusionRemoteDatasource,
    required InfusionLocalDatasource infusionLocalDatasource,
    required NotificationService notificationService,
  }) : _infusionRemoteDatasource = infusionRemoteDatasource,
       _infusionLocalDatasource = infusionLocalDatasource,
       _notificationService = notificationService;

  factory InfusionRemoteRepositoryImpl.create() {
    return InfusionRemoteRepositoryImpl(
      infusionRemoteDatasource: InfusionRemoteDatasourceImpl.create(),
      infusionLocalDatasource: InfusionLocalDatasourceImpl.create(),
      notificationService: NotificationService(),
    );
  }

  @override
  Future<InfusionEntity> createInfusion({
    required CreateInfusionRequest request,
  }) async {
    final response = await _infusionRemoteDatasource.createInfusion(
      request: request,
    );
    final responseData = response.data;

    print(
      '[InfusionRemoteRepositoryImpl] createInfusion response data: ${responseData.toJson()}',
    );

    final infusionEntity = responseData.toEntity();

    final notificationId = infusionEntity.id.hashCode;

    await _notificationService.scheduleNotification(
      notificationId: notificationId,
      patientName: infusionEntity.patientName,
      scheduledTime: infusionEntity.endTime,
    );

    final infusionModel = InfusionModel(
      id: infusionEntity.id,
      patientId: infusionEntity.patientId,
      patientName: infusionEntity.patientName,
      infusionName: infusionEntity.infusionName,
      startTime: infusionEntity.startTime,
      endTime: infusionEntity.endTime,
      status: infusionEntity.status,
      notificationId: notificationId,
      createdAt: DateTime.now(),
    );

    await _infusionLocalDatasource.cacheInfusionData(
      infusionModel: infusionModel,
    );

    return infusionEntity;
  }

  @override
  Future<List<InfusionEntity>> getAllInfusions() async {
    final response = await _infusionRemoteDatasource.getAllInfusions();
    final responseData = response.data;

    final infusionEntities = responseData
        .map((infusionResponseModel) => infusionResponseModel.toEntity())
        .toList();

    for (final infusion in infusionEntities) {
      if (infusion.status != InfusionStatusEnum.running) {
        final cached = await _infusionLocalDatasource.getCachedInfusionDataById(
          infusionId: infusion.id,
        );

        if (cached != null) {
          await _notificationService.cancelNotification(cached.notificationId);
          await _infusionLocalDatasource.deleteInfusion(
            infusionId: infusion.id,
          );
        }
      }
    }

    return infusionEntities;
  }

  @override
  Future<List<InfusionEntity>> getInfusionsByPatientId({
    required int patientId,
  }) async {
    final response = await _infusionRemoteDatasource.getInfusionsByPatientId(
      patientId: patientId,
    );
    final responseData = response.data;

    final infusionEntities = responseData
        .map((infusionResponseModel) => infusionResponseModel.toEntity())
        .toList();

    return infusionEntities;
  }

  @override
  Future<InfusionEntity?> getRunningInfusionByPatientId({
    required int patientId,
  }) async {
    final response = await _infusionRemoteDatasource
        .getInfusionsRunningByPatientId(patientId: patientId);
    final responseData = response.data;

    return responseData?.toEntity();
  }

  @override
  Future<String> stopInfusion({required int infusionId}) async {
    final response = await _infusionRemoteDatasource.stopInfusion(
      infusionId: infusionId,
    );

    final cached = await _infusionLocalDatasource.getCachedInfusionDataById(
      infusionId: infusionId,
    );

    if (cached != null) {
      await _notificationService.cancelNotification(cached.notificationId);

      await _infusionLocalDatasource.updateInfusionStatus(
        infusionId: infusionId,
        status: InfusionStatusEnum.stopped,
      );
    }

    return response.message;
  }
}
