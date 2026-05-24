class VehicleDocumentModel {
  final int? id;
  final int vehicleId;
  final String documentType; // STNK, BPKB, SIM, Asuransi, Pajak, Lainnya
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? imagePath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleDocumentModel({
    this.id,
    required this.vehicleId,
    required this.documentType,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.imagePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPermanent => expiryDate == null;

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry =
        DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.difference(today).inDays;
  }

  factory VehicleDocumentModel.fromMap(Map<String, dynamic> map) {
    return VehicleDocumentModel(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      documentType: map['document_type'] as String,
      documentNumber: map['document_number'] as String?,
      issueDate: map['issue_date'] != null
          ? DateTime.parse(map['issue_date'] as String)
          : null,
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      imagePath: map['image_path'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'document_type': documentType,
      'document_number': documentNumber,
      'issue_date': issueDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'image_path': imagePath,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VehicleDocumentModel copyWith({
    int? id,
    int? vehicleId,
    String? documentType,
    String? documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? imagePath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleDocumentModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VehicleDocumentTypes {
  static const stnk = 'STNK';
  static const bpkb = 'BPKB';
  static const sim = 'SIM';
  static const asuransi = 'Asuransi';
  static const pajak = 'Pajak Tahunan';
  static const lainnya = 'Lainnya';

  static const all = [stnk, bpkb, sim, asuransi, pajak, lainnya];
}
