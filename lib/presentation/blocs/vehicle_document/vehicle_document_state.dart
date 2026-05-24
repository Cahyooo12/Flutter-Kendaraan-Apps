import 'package:flutter_kendaraanku_app/data/models/vehicle_document_model.dart';

abstract class VehicleDocumentState {}

class VehicleDocumentInitial extends VehicleDocumentState {}

class VehicleDocumentLoading extends VehicleDocumentState {}

class VehicleDocumentLoaded extends VehicleDocumentState {
  final List<VehicleDocumentModel> docs;
  final List<VehicleDocumentModel> filteredDocs;
  final String? activeType;
  final Map<String, int> typeCounts;
  final VehicleDocumentModel? mostUrgent;

  VehicleDocumentLoaded({
    required this.docs,
    required this.filteredDocs,
    required this.typeCounts,
    this.activeType,
    this.mostUrgent,
  });
}

class VehicleDocumentError extends VehicleDocumentState {
  final String message;
  VehicleDocumentError(this.message);
}
