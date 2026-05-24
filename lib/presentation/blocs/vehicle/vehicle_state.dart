import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';

abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleModel> vehicles;
  final int selectedIndex;

  VehicleLoaded({required this.vehicles, this.selectedIndex = 0});

  VehicleModel? get selectedVehicle =>
      vehicles.isNotEmpty ? vehicles[selectedIndex] : null;

  VehicleLoaded copyWith({List<VehicleModel>? vehicles, int? selectedIndex}) {
    return VehicleLoaded(
      vehicles: vehicles ?? this.vehicles,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class VehicleError extends VehicleState {
  final String message;
  VehicleError(this.message);
}
