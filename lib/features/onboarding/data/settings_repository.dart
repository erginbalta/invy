import '../../../database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class LocalSetup {
  const LocalSetup({
    required this.isComplete,
    this.usageType,
    this.businessName,
  });

  final bool isComplete;
  final String? usageType;
  final String? businessName;
}

class SettingsRepository {
  SettingsRepository(this._database);

  final AppDatabase _database;

  Future<LocalSetup> getSetup() async {
    final db = await _database.database;
    final rows = await db.query('app_settings');
    final settings = {
      for (final row in rows) row['key'] as String: row['value'] as String?,
    };

    return LocalSetup(
      isComplete: settings['onboardingComplete'] == 'true',
      usageType: settings['usageType'],
      businessName: settings['businessName'],
    );
  }

  Future<void> saveSetup({
    required String usageType,
    String? businessName,
  }) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.insert(
        'app_settings',
        {'key': 'onboardingComplete', 'value': 'true'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_settings',
        {'key': 'usageType', 'value': usageType},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_settings',
        {'key': 'businessName', 'value': businessName},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> updateUsageType({
    required String usageType,
    String? businessName,
  }) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.insert(
        'app_settings',
        {'key': 'usageType', 'value': usageType},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_settings',
        {'key': 'businessName', 'value': businessName},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<String> getLanguagePreference() async {
    final db = await _database.database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['languagePreference'],
      limit: 1,
    );
    if (rows.isEmpty) return 'system';
    return (rows.first['value'] as String?) ?? 'system';
  }

  Future<void> saveLanguagePreference(String preference) async {
    final db = await _database.database;
    await db.insert(
      'app_settings',
      {'key': 'languagePreference', 'value': preference},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
