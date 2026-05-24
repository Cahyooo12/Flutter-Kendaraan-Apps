import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/core/services/notification_service.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';
import 'service_log_event.dart';
import 'service_log_state.dart';

class ServiceLogBloc extends Bloc<ServiceLogEvent, ServiceLogState> {
  final ServiceLogRepository _repository;
  final VehicleRepository _vehicleRepository;
  final NotificationService _notifier;

  ServiceLogBloc(
    this._repository, {
    VehicleRepository? vehicleRepository,
    NotificationService? notifier,
  })  : _vehicleRepository = vehicleRepository ?? VehicleRepository(),
        _notifier = notifier ?? NotificationService.instance,
        super(ServiceLogInitial()) {
    on<LoadServiceLogs>(_onLoad);
    on<AddServiceLog>(_onAdd);
    on<UpdateServiceLog>(_onUpdate);
    on<DeleteServiceLog>(_onDelete);
    on<FilterByCategory>(_onFilter);
  }

  Future<void> _onLoad(LoadServiceLogs event, Emitter<ServiceLogState> emit) async {
    emit(ServiceLogLoading());
    final result = await _repository.getByVehicle(event.vehicleId);
    result.fold(
      (error) => emit(ServiceLogError(error)),
      (logs) {
        final stats = _calculateStats(logs);
        emit(ServiceLogLoaded(logs: logs, stats: stats));
      },
    );
  }

  Future<void> _onAdd(AddServiceLog event, Emitter<ServiceLogState> emit) async {
    final result = await _repository.add(event.serviceLog);
    await result.fold(
      (error) async => emit(ServiceLogError(error)),
      (insertedId) async {
        await _scheduleFor(event.serviceLog, insertedId);
        add(LoadServiceLogs(event.serviceLog.vehicleId));
      },
    );
  }

  Future<void> _onUpdate(UpdateServiceLog event, Emitter<ServiceLogState> emit) async {
    final result = await _repository.update(event.serviceLog);
    await result.fold(
      (error) async => emit(ServiceLogError(error)),
      (_) async {
        final id = event.serviceLog.id;
        if (id != null) {
          await _notifier.cancelServiceReminder(id);
          await _scheduleFor(event.serviceLog, id);
        }
        add(LoadServiceLogs(event.serviceLog.vehicleId));
      },
    );
  }

  Future<void> _onDelete(DeleteServiceLog event, Emitter<ServiceLogState> emit) async {
    final result = await _repository.delete(event.id);
    await result.fold(
      (error) async => emit(ServiceLogError(error)),
      (_) async {
        await _notifier.cancelServiceReminder(event.id);
        add(LoadServiceLogs(event.vehicleId));
      },
    );
  }

  Future<void> _scheduleFor(ServiceLogModel log, int id) async {
    final nextDate = log.nextServiceDate;
    if (nextDate == null) return;
    final vResult = await _vehicleRepository.getById(log.vehicleId);
    final vehicleName = vResult.fold((_) => 'Kendaraan Anda', (v) => v.name);
    await _notifier.scheduleServiceReminder(
      serviceLogId: id,
      description: log.description,
      vehicleName: vehicleName,
      nextServiceDate: nextDate,
    );
  }

  Future<void> _onFilter(FilterByCategory event, Emitter<ServiceLogState> emit) async {
    emit(ServiceLogLoading());

    // Always get full data for stats
    final allResult = await _repository.getByVehicle(event.vehicleId);
    if (allResult.isLeft()) {
      emit(ServiceLogError(allResult.fold((l) => l, (_) => 'Unknown error')));
      return;
    }
    final allLogs = allResult.getOrElse(() => <ServiceLogModel>[]);
    final stats = _calculateStats(allLogs);

    if (event.category == null) {
      emit(ServiceLogLoaded(logs: allLogs, stats: stats));
      return;
    }

    final filteredResult =
        await _repository.getByCategory(event.vehicleId, event.category!);
    filteredResult.fold(
      (error) => emit(ServiceLogError(error)),
      (filteredLogs) => emit(ServiceLogLoaded(
        logs: filteredLogs,
        stats: stats,
        activeFilter: event.category,
      )),
    );
  }

  ServiceStats _calculateStats(List<ServiceLogModel> logs) {
    if (logs.isEmpty) {
      return ServiceStats(
        totalCost: 0,
        serviceCount: 0,
        avgCost: 0,
        categoryCounts: {},
      );
    }

    final totalCost = logs.fold(0.0, (sum, l) => sum + l.cost);
    final serviceCount = logs.length;
    final avgCost = totalCost / serviceCount;

    final categoryCounts = <String, int>{};
    for (final log in logs) {
      categoryCounts[log.serviceType] =
          (categoryCounts[log.serviceType] ?? 0) + 1;
    }

    return ServiceStats(
      totalCost: totalCost,
      serviceCount: serviceCount,
      avgCost: avgCost,
      categoryCounts: categoryCounts,
    );
  }
}
