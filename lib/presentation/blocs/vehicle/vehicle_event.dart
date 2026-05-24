import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';

abstract class VehicleEvent {}

class LoadVehicles extends VehicleEvent {
  final int userId;
  LoadVehicles(this.userId);
}

class AddVehicle extends VehicleEvent {
  final VehicleModel vehicle;
  AddVehicle(this.vehicle);
}

class UpdateVehicle extends VehicleEvent {
  final VehicleModel vehicle;
  UpdateVehicle(this.vehicle);
}

class ArchiveVehicle extends VehicleEvent {
  final int vehicleId;
  ArchiveVehicle(this.vehicleId);
}

class SelectVehicle extends VehicleEvent {
  final int index;
  SelectVehicle(this.index);
}
