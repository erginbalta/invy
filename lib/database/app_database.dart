import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    final current = _database;
    if (current != null) return current;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'invy.db');
    final database = await openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _create,
      onUpgrade: _upgrade,
    );
    _database = database;
    return database;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE areas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        areaId INTEGER NOT NULL,
        currentStock INTEGER NOT NULL DEFAULT 0,
        minimumStock INTEGER NOT NULL DEFAULT 0,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(areaId) REFERENCES areas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        previousStock INTEGER NOT NULL,
        newStock INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY(productId) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_products_code ON products(code)',
    );
    await db.execute('''
      CREATE UNIQUE INDEX idx_products_code_area_active
      ON products(code, areaId)
      WHERE isDeleted = 0
    ''');
    await db.execute(
      'CREATE INDEX idx_products_area ON products(areaId)',
    );
    await db.execute(
      'CREATE INDEX idx_movements_product ON stock_movements(productId)',
    );

    await _createOrderTables(db);
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS areas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          isDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      final now = DateTime.now().toIso8601String();
      final existing = await db.query(
        'areas',
        where: 'name = ? AND isDeleted = 0',
        whereArgs: ['General Area'],
        limit: 1,
      );
      final generalAreaId = existing.isEmpty
          ? await db.insert('areas', {
              'name': 'General Area',
              'createdAt': now,
              'updatedAt': now,
              'isDeleted': 0,
            })
          : existing.first['id'] as int;

      final productColumns = await db.rawQuery('PRAGMA table_info(products)');
      final hasAreaId = productColumns.any((column) => column['name'] == 'areaId');
      if (!hasAreaId) {
        await db.execute('ALTER TABLE products ADD COLUMN areaId INTEGER');
      }
      await db.update(
        'products',
        {'areaId': generalAreaId, 'updatedAt': now},
        where: 'areaId IS NULL',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_area ON products(areaId)',
      );
    }

    if (oldVersion < 3) {
      await _createOrderTables(db);
    }

    if (oldVersion < 4) {
      await _migrateProductsToV4(db);
      await _softDeleteEmptyGeneralArea(db);
    }
  }

  Future<void> _migrateProductsToV4(Database db) async {
    final tables = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: "type = 'table' AND name = 'products'",
      limit: 1,
    );
    if (tables.isEmpty) return;

    await db.execute('PRAGMA foreign_keys = OFF');
    await db.execute('DROP INDEX IF EXISTS idx_products_code');
    await db.execute('DROP INDEX IF EXISTS idx_products_area');
    await db.execute('DROP INDEX IF EXISTS idx_products_code_area_active');
    await db.execute('DROP INDEX IF EXISTS idx_movements_product');
    await db.execute('DROP INDEX IF EXISTS idx_order_items_order');
    await db.execute('ALTER TABLE products RENAME TO products_old_v4');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        areaId INTEGER NOT NULL,
        currentStock INTEGER NOT NULL DEFAULT 0,
        minimumStock INTEGER NOT NULL DEFAULT 0,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(areaId) REFERENCES areas(id)
      )
    ''');
    await db.execute('''
      INSERT INTO products (
        id, name, code, areaId, currentStock, minimumStock,
        imagePath, createdAt, updatedAt, isDeleted
      )
      SELECT
        id, name, code, areaId, currentStock, minimumStock,
        imagePath, createdAt, updatedAt, isDeleted
      FROM products_old_v4
    ''');

    await db.execute('ALTER TABLE stock_movements RENAME TO stock_movements_old_v4');
    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        previousStock INTEGER NOT NULL,
        newStock INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY(productId) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      INSERT INTO stock_movements (
        id, productId, type, quantity, previousStock, newStock, createdAt, note
      )
      SELECT id, productId, type, quantity, previousStock, newStock, createdAt, note
      FROM stock_movements_old_v4
    ''');
    await db.execute('DROP TABLE stock_movements_old_v4');

    await db.execute('ALTER TABLE order_items RENAME TO order_items_old_v4');
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId INTEGER,
        name TEXT NOT NULL,
        code TEXT,
        quantity INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(orderId) REFERENCES order_lists(id) ON DELETE CASCADE,
        FOREIGN KEY(productId) REFERENCES products(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      INSERT INTO order_items (
        id, orderId, productId, name, code, quantity,
        createdAt, updatedAt, isDeleted
      )
      SELECT
        id, orderId, productId, name, code, quantity,
        createdAt, updatedAt, isDeleted
      FROM order_items_old_v4
    ''');
    await db.execute('DROP TABLE order_items_old_v4');

    await db.execute('DROP TABLE products_old_v4');
    await db.execute('CREATE INDEX idx_products_code ON products(code)');
    await db.execute('CREATE INDEX idx_products_area ON products(areaId)');
    await db.execute('''
      CREATE UNIQUE INDEX idx_products_code_area_active
      ON products(code, areaId)
      WHERE isDeleted = 0
    ''');
    await db.execute('CREATE INDEX idx_movements_product ON stock_movements(productId)');
    await db.execute('CREATE INDEX idx_order_items_order ON order_items(orderId)');
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _softDeleteEmptyGeneralArea(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate('''
      UPDATE areas
      SET isDeleted = 1, updatedAt = ?
      WHERE name = 'General Area'
        AND isDeleted = 0
        AND NOT EXISTS (
          SELECT 1 FROM products
          WHERE products.areaId = areas.id
            AND products.isDeleted = 0
        )
    ''', [now]);
  }

  Future<void> _createOrderTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        completedAt TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId INTEGER,
        name TEXT NOT NULL,
        code TEXT,
        quantity INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(orderId) REFERENCES order_lists(id) ON DELETE CASCADE,
        FOREIGN KEY(productId) REFERENCES products(id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(orderId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_order_lists_status ON order_lists(status)',
    );
  }

  Future<void> resetAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('stock_movements');
      await txn.delete('order_items');
      await txn.delete('order_lists');
      await txn.delete('products');
      await txn.delete('areas');
      await txn.delete('app_settings');
      await txn.delete('sqlite_sequence', where: 'name IN (?, ?, ?, ?, ?)', whereArgs: [
        'products',
        'stock_movements',
        'areas',
        'order_lists',
        'order_items',
      ]);
    });
  }
}
