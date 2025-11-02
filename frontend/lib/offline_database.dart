import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineDatabase {
  static Database? _database;
  static const String _databaseName = 'medguard_offline.db';
  static const int _databaseVersion = 1;

  static const String _medicinesTable = 'medicines';
  static const String _syncStatusTable = 'sync_status';
  static const String _columnGtin = 'gtin';
  static const String _columnProductName = 'product_name';
  static const String _columnGenericName = 'generic_name';
  static const String _columnManufacturer = 'manufacturer';
  static const String _columnRegistrationNumber = 'registration_number';
  static const String _columnDosageForm = 'dosage_form';
  static const String _columnStrength = 'strength';
  static const String _columnPackSize = 'pack_size';
  static const String _columnExpiryDate = 'expiry_date';
  static const String _columnShelfLife = 'shelf_life';
  static const String _columnPackagingType = 'packaging_type';
  static const String _columnMarketingAuthHolder = 'marketing_auth_holder';
  static const String _columnLocalTechRep = 'local_tech_rep';
  static const String _columnRegistrationDate = 'registration_date';
  static const String _columnLicenseExpiryDate = 'license_expiry_date';
  static const String _columnCountry = 'country';
  static const String _columnLastUpdated = 'last_updated';
  static const String _columnIsVerified = 'is_verified';
  static const String _columnLastSync = 'last_sync';
  static const String _columnTotalRecords = 'total_records';
  static const String _columnSyncStatus = 'sync_status';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create medicines table
    await db.execute('''
      CREATE TABLE $_medicinesTable (
        $_columnGtin TEXT PRIMARY KEY,
        $_columnProductName TEXT NOT NULL,
        $_columnGenericName TEXT,
        $_columnManufacturer TEXT,
        $_columnRegistrationNumber TEXT,
        $_columnDosageForm TEXT,
        $_columnStrength TEXT,
        $_columnPackSize TEXT,
        $_columnExpiryDate TEXT,
        $_columnShelfLife TEXT,
        $_columnPackagingType TEXT,
        $_columnMarketingAuthHolder TEXT,
        $_columnLocalTechRep TEXT,
        $_columnRegistrationDate TEXT,
        $_columnLicenseExpiryDate TEXT,
        $_columnCountry TEXT,
        $_columnLastUpdated INTEGER NOT NULL,
        $_columnIsVerified INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create sync status table
    await db.execute('''
      CREATE TABLE $_syncStatusTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnLastSync INTEGER NOT NULL,
        $_columnTotalRecords INTEGER NOT NULL,
        $_columnSyncStatus TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_medicines_gtin ON $_medicinesTable($_columnGtin)
    ''');

    await db.execute('''
      CREATE INDEX idx_medicines_verified ON $_medicinesTable($_columnIsVerified)
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for future versions
    }
  }

  // Medicine CRUD operations
  static Future<void> insertMedicine(Map<String, dynamic> medicine) async {
    final db = await database;
    await db.insert(
      _medicinesTable,
      medicine,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertMedicines(
      List<Map<String, dynamic>> medicines) async {
    final db = await database;
    final batch = db.batch();

    for (var medicine in medicines) {
      batch.insert(
        _medicinesTable,
        medicine,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  static Future<Map<String, dynamic>?> getMedicineByGtin(String gtin) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _medicinesTable,
      where: '$_columnGtin = ?',
      whereArgs: [gtin],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllMedicines() async {
    final db = await database;
    return await db.query(_medicinesTable, orderBy: '$_columnProductName ASC');
  }

  static Future<List<Map<String, dynamic>>> getVerifiedMedicines() async {
    final db = await database;
    return await db.query(
      _medicinesTable,
      where: '$_columnIsVerified = ?',
      whereArgs: [1],
      orderBy: '$_columnProductName ASC',
    );
  }

  static Future<int> getMedicineCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_medicinesTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<int> getVerifiedMedicineCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_medicinesTable WHERE $_columnIsVerified = ?',
      [1],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Sync status operations
  static Future<void> updateSyncStatus({
    required int lastSync,
    required int totalRecords,
    required String syncStatus,
  }) async {
    final db = await database;
    await db.delete(_syncStatusTable);
    await db.insert(_syncStatusTable, {
      _columnLastSync: lastSync,
      _columnTotalRecords: totalRecords,
      _columnSyncStatus: syncStatus,
    });
  }

  static Future<Map<String, dynamic>?> getSyncStatus() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _syncStatusTable,
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Offline mode management
  static Future<bool> isOfflineModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('offline_mode_enabled') ?? false;
  }

  static Future<void> setOfflineModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline_mode_enabled', enabled);
  }

  static Future<bool> hasOfflineData() async {
    final count = await getMedicineCount();
    return count > 0;
  }

  static Future<int> getOfflineDataSize() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_medicinesTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Clear all offline data
  static Future<void> clearOfflineData() async {
    final db = await database;
    await db.delete(_medicinesTable);
    await db.delete(_syncStatusTable);
  }

  // Search medicines
  static Future<List<Map<String, dynamic>>> searchMedicines(
      String query) async {
    final db = await database;
    return await db.query(
      _medicinesTable,
      where: '''
        $_columnProductName LIKE ? OR 
        $_columnGenericName LIKE ? OR 
        $_columnManufacturer LIKE ? OR 
        $_columnGtin LIKE ?
      ''',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: '$_columnProductName ASC',
    );
  }

  // Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    final totalMedicines = await getMedicineCount();
    final verifiedMedicines = await getVerifiedMedicineCount();
    final syncStatus = await getSyncStatus();

    return {
      'total_medicines': totalMedicines,
      'verified_medicines': verifiedMedicines,
      'unverified_medicines': totalMedicines - verifiedMedicines,
      'last_sync': syncStatus?[_columnLastSync],
      'sync_status': syncStatus?[_columnSyncStatus],
    };
  }

  // Close database
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
