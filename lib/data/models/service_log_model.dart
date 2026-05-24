class ServiceLogModel {
  final int? id;
  final int vehicleId;
  final DateTime date;
  final double? odometer;
  final String serviceType;
  final String description;
  final double cost;
  final String? workshopName;
  final String? receiptImagePath;
  final double? nextServiceOdometer;
  final DateTime? nextServiceDate;
  final String? notes;
  final DateTime createdAt;

  ServiceLogModel({
    this.id,
    required this.vehicleId,
    required this.date,
    this.odometer,
    required this.serviceType,
    required this.description,
    required this.cost,
    this.workshopName,
    this.receiptImagePath,
    this.nextServiceOdometer,
    this.nextServiceDate,
    this.notes,
    required this.createdAt,
  });

  factory ServiceLogModel.fromMap(Map<String, dynamic> map) {
    return ServiceLogModel(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      date: DateTime.parse(map['date'] as String),
      odometer: map['odometer'] != null
          ? (map['odometer'] as num).toDouble()
          : null,
      serviceType: map['service_type'] as String,
      description: map['description'] as String,
      cost: (map['cost'] as num).toDouble(),
      workshopName: map['workshop_name'] as String?,
      receiptImagePath: map['receipt_image_path'] as String?,
      nextServiceOdometer: map['next_service_odometer'] != null
          ? (map['next_service_odometer'] as num).toDouble()
          : null,
      nextServiceDate: map['next_service_date'] != null
          ? DateTime.parse(map['next_service_date'] as String)
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'service_type': serviceType,
      'description': description,
      'cost': cost,
      'workshop_name': workshopName,
      'receipt_image_path': receiptImagePath,
      'next_service_odometer': nextServiceOdometer,
      'next_service_date': nextServiceDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ServiceLogModel copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    double? odometer,
    String? serviceType,
    String? description,
    double? cost,
    String? workshopName,
    String? receiptImagePath,
    double? nextServiceOdometer,
    DateTime? nextServiceDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return ServiceLogModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      workshopName: workshopName ?? this.workshopName,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      nextServiceOdometer: nextServiceOdometer ?? this.nextServiceOdometer,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
