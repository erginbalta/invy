import 'package:sqflite/sqflite.dart';

import '../../../database/app_database.dart';
import '../../stock_operations/models/stock_movement.dart';
import '../models/product.dart';

class DuplicateCodeException implements Exception {
  const DuplicateCodeException(this.code);

  final String code;

  @override
  String toString() => 'A product already uses $code.';
}

class MissingAreaException implements Exception {
  const MissingAreaException();
}

class ProductRepository {
  ProductRepository(this._database);

  final AppDatabase _database;

  Future<List<Product>> getActiveProducts() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT products.*, areas.name AS areaName
      FROM products
      LEFT JOIN areas ON areas.id = products.areaId
      WHERE products.isDeleted = 0
      ORDER BY products.updatedAt DESC
    ''');
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT products.*, areas.name AS areaName
      FROM products
      LEFT JOIN areas ON areas.id = products.areaId
      WHERE products.id = ? AND products.isDeleted = 0
      LIMIT 1
    ''', [id]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<Product?> findByNameAndArea({
    required String name,
    required int areaId,
  }) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT products.*, areas.name AS areaName
      FROM products
      LEFT JOIN areas ON areas.id = products.areaId
      WHERE lower(products.name) = lower(?) 
        AND products.areaId = ? 
        AND products.isDeleted = 0
      LIMIT 1
    ''', [name.trim(), areaId]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<Product?> findByCode(String code) async {
    final products = await findAllByCode(code);
    if (products.isEmpty) return null;
    return products.first;
  }

  Future<List<Product>> findAllByCode(String code) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT products.*, areas.name AS areaName
      FROM products
      LEFT JOIN areas ON areas.id = products.areaId
      WHERE products.code = ? AND products.isDeleted = 0
      ORDER BY areas.name COLLATE NOCASE ASC, products.updatedAt DESC
    ''', [code.trim()]);
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> findByCodeAndArea({
    required String code,
    required int areaId,
  }) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT products.*, areas.name AS areaName
      FROM products
      LEFT JOIN areas ON areas.id = products.areaId
      WHERE products.code = ?
        AND products.areaId = ?
        AND products.isDeleted = 0
      LIMIT 1
    ''', [code.trim(), areaId]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<Product> create({
    required String name,
    required String? code,
    required int? areaId,
    required int currentStock,
    required int minimumStock,
    String? imagePath,
  }) async {
    if (areaId == null) throw const MissingAreaException();

    final db = await _database.database;
    try {
      final id = await db.transaction<int>((txn) async {
        final now = DateTime.now();
        final savedCode = _cleanCode(code) ?? await _nextInternalCode(txn);
        final productId = await txn.insert('products', {
          'name': name.trim(),
          'code': savedCode,
          'areaId': areaId,
          'currentStock': currentStock,
          'minimumStock': minimumStock,
          'imagePath': imagePath,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'isDeleted': 0,
        });

        if (currentStock > 0) {
          await txn.insert('stock_movements', {
            'productId': productId,
            'type': StockMovementType.adjustment.value,
            'quantity': currentStock,
            'previousStock': 0,
            'newStock': currentStock,
            'createdAt': now.toIso8601String(),
            'note': null,
          });
        }

        return productId;
      });

      final product = await getById(id);
      return product!;
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw DuplicateCodeException(code?.trim() ?? '');
      }
      rethrow;
    }
  }

  Future<void> update(Product product) async {
    final db = await _database.database;
    try {
      await db.update(
        'products',
        product.copyWith(updatedAt: DateTime.now()).toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [product.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw DuplicateCodeException(product.code);
      }
      rethrow;
    }
  }

  Future<void> updateCode({
    required int productId,
    required String code,
  }) async {
    final product = await getById(productId);
    if (product == null) return;
    await update(product.copyWith(code: code.trim()));
  }

  Future<void> softDelete(int id) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'products',
        columns: ['code'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return;

      final code = rows.first['code'] as String;
      await txn.update(
        'products',
        {
          'code': '${code}__deleted__$id',
          'isDeleted': 1,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  String? _cleanCode(String? code) {
    final trimmed = code?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<String> _nextInternalCode(Transaction txn) async {
    final rows = await txn.rawQuery('''
      SELECT MAX(CAST(SUBSTR(code, 6) AS INTEGER)) AS maxCode
      FROM products
      WHERE code LIKE 'INVY-%'
    ''');
    final next = ((rows.first['maxCode'] as int?) ?? 0) + 1;
    return 'INVY-${next.toString().padLeft(6, '0')}';
  }
}
