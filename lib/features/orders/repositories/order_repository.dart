import '../../../database/app_database.dart';
import '../models/order_item.dart';
import '../models/order_list.dart';

class OrderRepository {
  OrderRepository(this._database);

  final AppDatabase _database;

  Future<List<OrderList>> getActiveOrders() async {
    final db = await _database.database;
    final rows = await db.query(
      'order_lists',
      where: 'isDeleted = 0',
      orderBy: 'updatedAt DESC',
    );
    return rows.map(OrderList.fromMap).toList();
  }

  Future<OrderList?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      'order_lists',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OrderList.fromMap(rows.first);
  }

  Future<List<OrderItem>> itemsFor(int orderId) async {
    final db = await _database.database;
    final rows = await db.query(
      'order_items',
      where: 'orderId = ? AND isDeleted = 0',
      whereArgs: [orderId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(OrderItem.fromMap).toList();
  }

  Future<OrderList> create({
    required String title,
    required List<DraftOrderItem> items,
  }) async {
    final db = await _database.database;
    final id = await db.transaction<int>((txn) async {
      final now = DateTime.now().toIso8601String();
      final orderId = await txn.insert('order_lists', {
        'title': title.trim(),
        'status': OrderStatus.waitingReceipt.value,
        'createdAt': now,
        'updatedAt': now,
        'completedAt': null,
        'isDeleted': 0,
      });

      for (final item in items) {
        await txn.insert('order_items', {
          'orderId': orderId,
          'productId': item.productId,
          'name': item.name.trim(),
          'code': item.code,
          'quantity': item.quantity,
          'createdAt': now,
          'updatedAt': now,
          'isDeleted': 0,
        });
      }

      return orderId;
    });

    return (await getById(id))!;
  }

  Future<void> markReceived(int id) async {
    final db = await _database.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'order_lists',
      {
        'status': OrderStatus.received.value,
        'updatedAt': now,
        'completedAt': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
