import '../../../database/app_database.dart';
import '../models/stock_movement.dart';

class StockBelowZeroException implements Exception {
  const StockBelowZeroException();
}

class ProductNotFoundException implements Exception {
  const ProductNotFoundException();
}

class StockMovementRepository {
  StockMovementRepository(this._database);

  final AppDatabase _database;

  Future<List<StockMovement>> forProduct(int productId) async {
    final db = await _database.database;
    final rows = await db.query(
      'stock_movements',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(StockMovement.fromMap).toList();
  }

  Future<void> stockIn({
    required int productId,
    required int quantity,
    String? note,
  }) {
    return _record(
      productId: productId,
      type: StockMovementType.stockIn,
      quantity: quantity,
      note: note,
    );
  }

  Future<void> stockOut({
    required int productId,
    required int quantity,
    String? note,
  }) {
    return _record(
      productId: productId,
      type: StockMovementType.stockOut,
      quantity: quantity,
      note: note,
    );
  }

  Future<void> transfer({
    required int sourceProductId,
    required int targetProductId,
    required int quantity,
  }) async {
    if (quantity <= 0) return;
    if (sourceProductId == targetProductId) return;

    final db = await _database.database;
    await db.transaction((txn) async {
      final sourceRows = await txn.query(
        'products',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [sourceProductId],
        limit: 1,
      );
      final targetRows = await txn.query(
        'products',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [targetProductId],
        limit: 1,
      );
      if (sourceRows.isEmpty || targetRows.isEmpty) {
        throw const ProductNotFoundException();
      }

      final sourcePrevious = sourceRows.first['currentStock'] as int;
      final targetPrevious = targetRows.first['currentStock'] as int;
      final sourceNew = sourcePrevious - quantity;
      final targetNew = targetPrevious + quantity;
      if (sourceNew < 0) throw const StockBelowZeroException();

      final now = DateTime.now().toIso8601String();
      await txn.update(
        'products',
        {
          'currentStock': sourceNew,
          'updatedAt': now,
        },
        where: 'id = ?',
        whereArgs: [sourceProductId],
      );
      await txn.update(
        'products',
        {
          'currentStock': targetNew,
          'updatedAt': now,
        },
        where: 'id = ?',
        whereArgs: [targetProductId],
      );

      await txn.insert('stock_movements', {
        'productId': sourceProductId,
        'type': StockMovementType.stockOut.value,
        'quantity': quantity,
        'previousStock': sourcePrevious,
        'newStock': sourceNew,
        'createdAt': now,
        'note': 'TRANSFER_OUT',
      });
      await txn.insert('stock_movements', {
        'productId': targetProductId,
        'type': StockMovementType.stockIn.value,
        'quantity': quantity,
        'previousStock': targetPrevious,
        'newStock': targetNew,
        'createdAt': now,
        'note': 'TRANSFER_IN',
      });
    });
  }

  Future<void> adjustTo({
    required int productId,
    required int newStock,
    String? note,
  }) async {
    if (newStock < 0) throw const StockBelowZeroException();

    final db = await _database.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'products',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [productId],
        limit: 1,
      );
      if (rows.isEmpty) throw const ProductNotFoundException();

      final previousStock = rows.first['currentStock'] as int;
      final quantity = (newStock - previousStock).abs();
      final now = DateTime.now();

      await txn.update(
        'products',
        {
          'currentStock': newStock,
          'updatedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [productId],
      );

      await txn.insert('stock_movements', {
        'productId': productId,
        'type': StockMovementType.adjustment.value,
        'quantity': quantity,
        'previousStock': previousStock,
        'newStock': newStock,
        'createdAt': now.toIso8601String(),
        'note': _cleanNote(note),
      });
    });
  }

  Future<void> _record({
    required int productId,
    required StockMovementType type,
    required int quantity,
    String? note,
  }) async {
    if (quantity <= 0) return;

    final db = await _database.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'products',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [productId],
        limit: 1,
      );
      if (rows.isEmpty) throw const ProductNotFoundException();

      final previousStock = rows.first['currentStock'] as int;
      final newStock = switch (type) {
        StockMovementType.stockIn => previousStock + quantity,
        StockMovementType.stockOut => previousStock - quantity,
        StockMovementType.adjustment => previousStock,
      };

      if (newStock < 0) throw const StockBelowZeroException();

      final now = DateTime.now();
      await txn.update(
        'products',
        {
          'currentStock': newStock,
          'updatedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [productId],
      );

      await txn.insert('stock_movements', {
        'productId': productId,
        'type': type.value,
        'quantity': quantity,
        'previousStock': previousStock,
        'newStock': newStock,
        'createdAt': now.toIso8601String(),
        'note': _cleanNote(note),
      });
    });
  }

  String? _cleanNote(String? note) {
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
