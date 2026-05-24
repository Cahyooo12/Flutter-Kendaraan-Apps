import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';

abstract class ServiceLogState {}

class ServiceLogInitial extends ServiceLogState {}

class ServiceLogLoading extends ServiceLogState {}

class ServiceLogLoaded extends ServiceLogState {
  final List<ServiceLogModel> logs;
  final ServiceStats stats;
  final String? activeFilter;

  ServiceLogLoaded({
    required this.logs,
    required this.stats,
    this.activeFilter,
  });
}

class ServiceLogError extends ServiceLogState {
  final String message;
  ServiceLogError(this.message);
}

class ServiceStats {
  final double totalCost;
  final int serviceCount;
  final double avgCost;
  final Map<String, int> categoryCounts;

  ServiceStats({
    required this.totalCost,
    required this.serviceCount,
    required this.avgCost,
    required this.categoryCounts,
  });
}
