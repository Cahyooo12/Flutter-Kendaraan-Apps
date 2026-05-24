class FuelLogModel {
  final int? id;
  final int vehicleId;
  final DateTime date;
  final double odometer;
  final double liters;
  final double pricePerLiter;
  final double totalCost;
  final String fuelType;
  final String? stationName;
  final bool isFullTank;
  final String? receiptImagePath;
  final String? notes;
  final DateTime createdAt;

  FuelLogModel({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.odometer,
    required this.liters,
    required this.pricePerLiter,
    required this.totalCost,
    required this.fuelType,
    this.stationName,
    this.isFullTank = true,
    this.receiptImagePath,
    this.notes,
    required this.createdAt,
  });

  factory FuelLogModel.fromMap(Map<String, dynamic> map) {
    return FuelLogModel(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      date: DateTime.parse(map['date'] as String),
      odometer: (map['odometer'] as num).toDouble(),
      liters: (map['liters'] as num).toDouble(),
      pricePerLiter: (map['price_per_liter'] as num).toDouble(),
      totalCost: (map['total_cost'] as num).toDouble(),
      fuelType: map['fuel_type'] as String,
      stationName: map['station_name'] as String?,
      isFullTank: (map['is_full_tank'] as int) == 1,
      receiptImagePath: map['receipt_image_path'] as String?,
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
      'liters': liters,
      'price_per_liter': pricePerLiter,
      'total_cost': totalCost,
      'fuel_type': fuelType,
      'station_name': stationName,
      'is_full_tank': isFullTank ? 1 : 0,
      'receipt_image_path': receiptImagePath,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FuelLogModel copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    double? odometer,
    double? liters,
    double? pricePerLiter,
    double? totalCost,
    String? fuelType,
    String? stationName,
    bool? isFullTank,
    String? receiptImagePath,
    String? notes,
    DateTime? createdAt,
  }) {
    return FuelLogModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalCost: totalCost ?? this.totalCost,
      fuelType: fuelType ?? this.fuelType,
      stationName: stationName ?? this.stationName,
      isFullTank: isFullTank ?? this.isFullTank,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
