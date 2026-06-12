import 'package:sqflite/sqflite.dart';

import '../../../database/app_database.dart';
import '../models/area.dart';

class AreaInUseException implements Exception {
  const AreaInUseException();
}

class AreaRepository {
  AreaRepository(this._database);

  static const generalAreaName = 'General Area';

  final AppDatabase _database;

  Future<List<Area>> getActiveAreas() async {
    final db = await _database.database;
    final rows = await db.query(
      'areas',
      where: 'isDeleted = 0',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Area.fromMap).toList();
  }

  Future<int> ensureGeneralArea() async {
    final db = await _database.database;
    return db.transaction((txn) => ensureGeneralAreaInTransaction(txn));
  }

  Future<int> ensureGeneralAreaInTransaction(Transaction txn) async {
    final rows = await txn.query(
      'areas',
      columns: ['id'],
      where: 'name = ? AND isDeleted = 0',
      whereArgs: [generalAreaName],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['id'] as int;

    final now = DateTime.now();
    return txn.insert('areas', {
      'name': generalAreaName,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isDeleted': 0,
    });
  }

  Future<Area> create(String name) async {
    final db = await _database.database;
    final now = DateTime.now();
    final id = await db.insert('areas', {
      'name': name.trim(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isDeleted': 0,
    });
    return (await getById(id))!;
  }

  Future<Area?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      'areas',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Area.fromMap(rows.first);
  }

  Future<void> rename({
    required int id,
    required String name,
  }) async {
    final db = await _database.database;
    await db.update(
      'areas',
      {
        'name': name.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> softDelete(int id) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      final products = await txn.query(
        'products',
        columns: ['id'],
        where: 'areaId = ? AND isDeleted = 0',
        whereArgs: [id],
        limit: 1,
      );
      if (products.isNotEmpty) throw const AreaInUseException();

      await txn.update(
        'areas',
        {
          'isDeleted': 1,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
