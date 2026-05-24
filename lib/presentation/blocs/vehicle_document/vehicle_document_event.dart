import 'package:flutter_kendaraanku_app/data/models/vehicle_document_model.dart';

abstract class VehicleDocumentEvent {}

class LoadDocuments extends VehicleDocumentEvent {
  final int userId;
  LoadDocuments(this.userId);
}

class FilterDocuments extends VehicleDocumentEvent {
  final int userId;
  final String? type;
  FilterDocuments(this.userId, this.type);
}

class AddDocument extends VehicleDocumentEvent {
  final VehicleDocumentModel doc;
  final int userId;
  AddDocument(this.doc, this.userId);
}

class UpdateDocument extends VehicleDocumentEvent {
  final VehicleDocumentModel doc;
  final int userId;
  UpdateDocument(this.doc, this.userId);
}

class DeleteDocument extends VehicleDocumentEvent {
  final int id;
  final int userId;
  DeleteDocument(this.id, this.userId);
}
