import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';

abstract class ServiceLogEvent {}

class LoadServiceLogs extends ServiceLogEvent {
  final int vehicleId;
  LoadServiceLogs(this.vehicleId);
}

class AddServiceLog extends ServiceLogEvent {
  final ServiceLogModel serviceLog;
  AddServiceLog(this.serviceLog);
}

class UpdateServiceLog extends ServiceLogEvent {
  final ServiceLogModel serviceLog;
  UpdateServiceLog(this.serviceLog);
}

class DeleteServiceLog extends ServiceLogEvent {
  final int id;
  final int vehicleId;
  DeleteServiceLog(this.id, this.vehicleId);
}

class FilterByCategory extends ServiceLogEvent {
  final int vehicleId;
  final String? category;
  FilterByCategory(this.vehicleId, this.category);
}
