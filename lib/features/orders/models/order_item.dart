class OrderItem {
  const OrderItem({
    this.id,
    required this.orderId,
    this.productId,
    required this.name,
    this.code,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final int? id;
  final int orderId;
  final int? productId;
  final String name;
  final String? code;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  factory OrderItem.fromMap(Map<String, Object?> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['orderId'] as int,
      productId: map['productId'] as int?,
      name: map['name'] as String,
      code: map['code'] as String?,
      quantity: map['quantity'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}

class DraftOrderItem {
  const DraftOrderItem({
    this.productId,
    required this.name,
    this.code,
    required this.quantity,
  });

  final int? productId;
  final String name;
  final String? code;
  final int quantity;
}
