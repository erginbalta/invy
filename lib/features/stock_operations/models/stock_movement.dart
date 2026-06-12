enum StockMovementType {
  stockIn('IN'),
  stockOut('OUT'),
  adjustment('ADJUSTMENT');

  const StockMovementType(this.value);

  final String value;

  static StockMovementType fromValue(String value) {
    return StockMovementType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => StockMovementType.adjustment,
    );
  }
}

class StockMovement {
  const StockMovement({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.createdAt,
    this.note,
  });

  final int? id;
  final int productId;
  final StockMovementType type;
  final int quantity;
  final int previousStock;
  final int newStock;
  final DateTime createdAt;
  final String? note;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'type': type.value,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory StockMovement.fromMap(Map<String, Object?> map) {
    return StockMovement(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      type: StockMovementType.fromValue(map['type'] as String),
      quantity: map['quantity'] as int,
      previousStock: map['previousStock'] as int,
      newStock: map['newStock'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      note: map['note'] as String?,
    );
  }
}
