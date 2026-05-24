class VehicleModel {
  final int? id;
  final int userId;
  final String name;
  final String type; // motor, mobil, lainnya
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final String color;
  final String? imagePath;
  final double initialOdometer;
  final String fuelType;
  final double? tankCapacity;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.color,
    this.imagePath,
    required this.initialOdometer,
    required this.fuelType,
    this.tankCapacity,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      plateNumber: map['plate_number'] as String,
      color: map['color'] as String,
      imagePath: map['image_path'] as String?,
      initialOdometer: (map['initial_odometer'] as num).toDouble(),
      fuelType: map['fuel_type'] as String,
      tankCapacity: map['tank_capacity'] != null
          ? (map['tank_capacity'] as num).toDouble()
          : null,
      isActive: (map['is_active'] as int) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'brand': brand,
      'model': model,
      'year': year,
      'plate_number': plateNumber,
      'color': color,
      'image_path': imagePath,
      'initial_odometer': initialOdometer,
      'fuel_type': fuelType,
      'tank_capacity': tankCapacity,
      'is_active': isActive ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VehicleModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    String? brand,
    String? model,
    int? year,
    String? plateNumber,
    String? color,
    String? imagePath,
    double? initialOdometer,
    String? fuelType,
    double? tankCapacity,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      initialOdometer: initialOdometer ?? this.initialOdometer,
      fuelType: fuelType ?? this.fuelType,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
