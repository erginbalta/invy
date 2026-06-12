class Product {
  const Product({
    this.id,
    required this.name,
    required this.code,
    required this.areaId,
    this.areaName = 'General Area',
    required this.currentStock,
    required this.minimumStock,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.aggregateProductIds = const [],
  });

  final int? id;
  final String name;
  final String code;
  final int areaId;
  final String areaName;
  final int currentStock;
  final int minimumStock;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<int> aggregateProductIds;

  bool get isLowStock => currentStock <= minimumStock;
  bool get isAggregate => aggregateProductIds.length > 1;

  Product copyWith({
    int? id,
    String? name,
    String? code,
    int? areaId,
    String? areaName,
    int? currentStock,
    int? minimumStock,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    List<int>? aggregateProductIds,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      aggregateProductIds: aggregateProductIds ?? this.aggregateProductIds,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'areaId': areaId,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String,
      areaId: map['areaId'] as int,
      areaName: (map['areaName'] as String?) ?? 'General Area',
      currentStock: map['currentStock'] as int,
      minimumStock: map['minimumStock'] as int,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
