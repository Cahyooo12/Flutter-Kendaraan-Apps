import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/core/services/notification_service.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_document_model.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_document_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_repository.dart';
import 'vehicle_document_event.dart';
import 'vehicle_document_state.dart';

class VehicleDocumentBloc
    extends Bloc<VehicleDocumentEvent, VehicleDocumentState> {
  final VehicleDocumentRepository _repository;
  final VehicleRepository _vehicleRepository;
  final NotificationService _notifier;

  VehicleDocumentBloc(
    this._repository, {
    VehicleRepository? vehicleRepository,
    NotificationService? notifier,
  })  : _vehicleRepository = vehicleRepository ?? VehicleRepository(),
        _notifier = notifier ?? NotificationService.instance,
        super(VehicleDocumentInitial()) {
    on<LoadDocuments>(_onLoad);
    on<FilterDocuments>(_onFilter);
    on<AddDocument>(_onAdd);
    on<UpdateDocument>(_onUpdate);
    on<DeleteDocument>(_onDelete);
  }

  Future<void> _onLoad(
      LoadDocuments event, Emitter<VehicleDocumentState> emit) async {
    emit(VehicleDocumentLoading());
    final result = await _repository.getByUser(event.userId);
    result.fold(
      (error) => emit(VehicleDocumentError(error)),
      (docs) => emit(_buildLoaded(docs, null)),
    );
  }

  Future<void> _onFilter(
      FilterDocuments event, Emitter<VehicleDocumentState> emit) async {
    final result = await _repository.getByUser(event.userId);
    result.fold(
      (error) => emit(VehicleDocumentError(error)),
      (docs) => emit(_buildLoaded(docs, event.type)),
    );
  }

  Future<void> _onAdd(
      AddDocument event, Emitter<VehicleDocumentState> emit) async {
    final result = await _repository.add(event.doc);
    await result.fold(
      (error) async => emit(VehicleDocumentError(error)),
      (insertedId) async {
        await _scheduleFor(event.doc, insertedId);
        add(LoadDocuments(event.userId));
      },
    );
  }

  Future<void> _onUpdate(
      UpdateDocument event, Emitter<VehicleDocumentState> emit) async {
    final result = await _repository.update(event.doc);
    await result.fold(
      (error) async => emit(VehicleDocumentError(error)),
      (_) async {
        final id = event.doc.id;
        if (id != null) {
          await _notifier.cancelDocumentReminder(id);
          await _scheduleFor(event.doc, id);
        }
        add(LoadDocuments(event.userId));
      },
    );
  }

  Future<void> _onDelete(
      DeleteDocument event, Emitter<VehicleDocumentState> emit) async {
    final result = await _repository.delete(event.id);
    await result.fold(
      (error) async => emit(VehicleDocumentError(error)),
      (_) async {
        await _notifier.cancelDocumentReminder(event.id);
        add(LoadDocuments(event.userId));
      },
    );
  }

  Future<void> _scheduleFor(VehicleDocumentModel doc, int id) async {
    final expiry = doc.expiryDate;
    if (expiry == null) return;
    final vResult = await _vehicleRepository.getById(doc.vehicleId);
    final vehicleName = vResult.fold((_) => 'Kendaraan Anda', (v) => v.name);
    await _notifier.scheduleDocumentReminder(
      documentId: id,
      documentType: doc.documentType,
      vehicleName: vehicleName,
      expiryDate: expiry,
    );
  }

  VehicleDocumentLoaded _buildLoaded(
      List<VehicleDocumentModel> docs, String? activeType) {
    final typeCounts = <String, int>{};
    for (final d in docs) {
      typeCounts[d.documentType] = (typeCounts[d.documentType] ?? 0) + 1;
    }

    final filtered = activeType == null
        ? docs
        : docs.where((d) => d.documentType == activeType).toList();

    VehicleDocumentModel? urgent;
    for (final d in docs) {
      final days = d.daysUntilExpiry;
      if (days == null) continue;
      if (days < 0) continue;
      if (days > 60) continue;
      if (urgent == null || days < (urgent.daysUntilExpiry ?? 99999)) {
        urgent = d;
      }
    }

    return VehicleDocumentLoaded(
      docs: docs,
      filteredDocs: filtered,
      typeCounts: typeCounts,
      activeType: activeType,
      mostUrgent: urgent,
    );
  }
}
