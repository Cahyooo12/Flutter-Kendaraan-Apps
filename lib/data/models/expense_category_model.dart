class ExpenseCategoryModel {
  final int? id;
  final String name;
  final String icon;
  final bool isDefault;

  ExpenseCategoryModel({
    this.id,
    required this.name,
    required this.icon,
    this.isDefault = true,
  });

  factory ExpenseCategoryModel.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
