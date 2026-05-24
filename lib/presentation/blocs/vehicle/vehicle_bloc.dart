import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository _repository;

  VehicleBloc(this._repository) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoad);
    on<AddVehicle>(_onAdd);
    on<UpdateVehicle>(_onUpdate);
    on<ArchiveVehicle>(_onArchive);
    on<SelectVehicle>(_onSelect);
  }

  Future<void> _onLoad(LoadVehicles event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    final result = await _repository.getByUser(event.userId);
    result.fold(
      (error) => emit(VehicleError(error)),
      (vehicles) => emit(VehicleLoaded(vehicles: vehicles)),
    );
  }

  Future<void> _onAdd(AddVehicle event, Emitter<VehicleState> emit) async {
    final result = await _repository.add(event.vehicle);
    result.fold(
      (error) => emit(VehicleError(error)),
      (_) {
        add(LoadVehicles(event.vehicle.userId));
      },
    );
  }

  Future<void> _onUpdate(
      UpdateVehicle event, Emitter<VehicleState> emit) async {
    final result = await _repository.update(event.vehicle);
    result.fold(
      (error) => emit(VehicleError(error)),
      (_) {
        if (state is VehicleLoaded) {
          add(LoadVehicles(event.vehicle.userId));
        }
      },
    );
  }

  Future<void> _onArchive(
      ArchiveVehicle event, Emitter<VehicleState> emit) async {
    final currentState = state;
    final result = await _repository.archive(event.vehicleId);
    result.fold(
      (error) => emit(VehicleError(error)),
      (_) {
        if (currentState is VehicleLoaded &&
            currentState.vehicles.isNotEmpty) {
          add(LoadVehicles(currentState.vehicles.first.userId));
        }
      },
    );
  }

  void _onSelect(SelectVehicle event, Emitter<VehicleState> emit) {
    if (state is VehicleLoaded) {
      emit((state as VehicleLoaded).copyWith(selectedIndex: event.index));
    }
  }
}
