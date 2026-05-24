import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';

abstract class FuelLogState {}

class FuelLogInitial extends FuelLogState {}

class FuelLogLoading extends FuelLogState {}

class FuelLogLoaded extends FuelLogState {
  final List<FuelLogModel> logs;
  final FuelStats stats;

  FuelLogLoaded({required this.logs, required this.stats});
}

class FuelLogError extends FuelLogState {
  final String message;
  FuelLogError(this.message);
}

class FuelStats {
  final double totalCost;
  final double totalLiters;
  final int fillCount;
  final double avgConsumption; // km per liter
  final double avgCostPerKm;
  final List<MonthlyFuelData> monthlyData;

  FuelStats({
    required this.totalCost,
    required this.totalLiters,
    required this.fillCount,
    required this.avgConsumption,
    required this.avgCostPerKm,
    required this.monthlyData,
  });
}

class MonthlyFuelData {
  final int month;
  final int year;
  final double totalLiters;
  final double totalCost;
  final String label; // "Jan", "Feb", etc.

  MonthlyFuelData({
    required this.month,
    required this.year,
    required this.totalLiters,
    required this.totalCost,
    required this.label,
  });
}
