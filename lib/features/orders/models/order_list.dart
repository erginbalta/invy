enum OrderStatus {
  draft('DRAFT'),
  waitingReceipt('WAITING_RECEIPT'),
  received('RECEIVED');

  const OrderStatus(this.value);

  final String value;

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.draft,
    );
  }
}

class OrderList {
  const OrderList({
    this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.isDeleted = false,
  });

  final int? id;
  final String title;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final bool isDeleted;

  factory OrderList.fromMap(Map<String, Object?> map) {
    return OrderList(
      id: map['id'] as int?,
      title: map['title'] as String,
      status: OrderStatus.fromValue(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(map['completedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
