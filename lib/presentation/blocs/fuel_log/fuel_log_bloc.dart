import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';
import 'fuel_log_event.dart';
import 'fuel_log_state.dart';

class FuelLogBloc extends Bloc<FuelLogEvent, FuelLogState> {
  final FuelLogRepository _repository;

  FuelLogBloc(this._repository) : super(FuelLogInitial()) {
    on<LoadFuelLogs>(_onLoad);
    on<AddFuelLog>(_onAdd);
    on<UpdateFuelLog>(_onUpdate);
    on<DeleteFuelLog>(_onDelete);
  }

  Future<void> _onLoad(LoadFuelLogs event, Emitter<FuelLogState> emit) async {
    emit(FuelLogLoading());
    final result = await _repository.getByVehicle(event.vehicleId);
    result.fold(
      (error) => emit(FuelLogError(error)),
      (logs) {
        final stats = _calculateStats(logs);
        emit(FuelLogLoaded(logs: logs, stats: stats));
      },
    );
  }

  Future<void> _onAdd(AddFuelLog event, Emitter<FuelLogState> emit) async {
    final result = await _repository.add(event.fuelLog);
    result.fold(
      (error) => emit(FuelLogError(error)),
      (_) => add(LoadFuelLogs(event.fuelLog.vehicleId)),
    );
  }

  Future<void> _onUpdate(UpdateFuelLog event, Emitter<FuelLogState> emit) async {
    final result = await _repository.update(event.fuelLog);
    result.fold(
      (error) => emit(FuelLogError(error)),
      (_) => add(LoadFuelLogs(event.fuelLog.vehicleId)),
    );
  }

  Future<void> _onDelete(DeleteFuelLog event, Emitter<FuelLogState> emit) async {
    final result = await _repository.delete(event.id);
    result.fold(
      (error) => emit(FuelLogError(error)),
      (_) => add(LoadFuelLogs(event.vehicleId)),
    );
  }

  FuelStats _calculateStats(List<FuelLogModel> logs) {
    if (logs.isEmpty) {
      return FuelStats(
        totalCost: 0,
        totalLiters: 0,
        fillCount: 0,
        avgConsumption: 0,
        avgCostPerKm: 0,
        monthlyData: [],
      );
    }

    final totalCost = logs.fold(0.0, (sum, l) => sum + l.totalCost);
    final totalLiters = logs.fold(0.0, (sum, l) => sum + l.liters);
    final fillCount = logs.length;

    // Calculate consumption using full-tank-to-full-tank method
    double avgConsumption = 0;
    final fullTankLogs = logs.where((l) => l.isFullTank).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (fullTankLogs.length >= 2) {
      double totalKm = 0;
      double totalLitersForConsumption = 0;
      for (int i = 1; i < fullTankLogs.length; i++) {
        final km = fullTankLogs[i].odometer - fullTankLogs[i - 1].odometer;
        if (km > 0) {
          totalKm += km;
          totalLitersForConsumption += fullTankLogs[i].liters;
        }
      }
      if (totalLitersForConsumption > 0) {
        avgConsumption = totalKm / totalLitersForConsumption;
      }
    }

    // Cost per km
    double totalKmAll = 0;
    final sorted = List<FuelLogModel>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.length >= 2) {
      totalKmAll = sorted.last.odometer - sorted.first.odometer;
    }
    final avgCostPerKm = totalKmAll > 0 ? totalCost / totalKmAll : 0.0;

    // Monthly aggregation (last 6 months)
    final now = DateTime.now();
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final monthlyData = <MonthlyFuelData>[];

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthLogs = logs.where(
        (l) => l.date.year == targetDate.year && l.date.month == targetDate.month,
      );
      monthlyData.add(MonthlyFuelData(
        month: targetDate.month,
        year: targetDate.year,
        totalLiters: monthLogs.fold(0.0, (sum, l) => sum + l.liters),
        totalCost: monthLogs.fold(0.0, (sum, l) => sum + l.totalCost),
        label: monthNames[targetDate.month - 1],
      ));
    }

    return FuelStats(
      totalCost: totalCost,
      totalLiters: totalLiters,
      fillCount: fillCount,
      avgConsumption: avgConsumption,
      avgCostPerKm: avgCostPerKm,
      monthlyData: monthlyData,
    );
  }
}
