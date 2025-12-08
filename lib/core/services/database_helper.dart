import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/local_clothing_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wardrobe.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clothing_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        gender TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  // Insert a new clothing item
  Future<int> insertClothingItem(LocalClothingItem item) async {
    final db = await database;
    return await db.insert('clothing_items', item.toMap());
  }

  // Get all clothing items
  Future<List<LocalClothingItem>> getAllClothingItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clothing_items');
    return List.generate(maps.length, (i) {
      return LocalClothingItem.fromMap(maps[i]);
    });
  }

  // Get clothing items by category and gender
  Future<List<LocalClothingItem>> getClothingItemsByCategoryAndGender(
    String category,
    String gender,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothing_items',
      where: 'category = ? AND gender = ?',
      whereArgs: [category.toLowerCase(), gender],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return LocalClothingItem.fromMap(maps[i]);
    });
  }

  // Get clothing items by gender
  Future<List<LocalClothingItem>> getClothingItemsByGender(
    String gender,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothing_items',
      where: 'gender = ?',
      whereArgs: [gender],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return LocalClothingItem.fromMap(maps[i]);
    });
  }

  // Delete a clothing item
  Future<int> deleteClothingItem(int id) async {
    final db = await database;
    return await db.delete('clothing_items', where: 'id = ?', whereArgs: [id]);
  }

  // Update a clothing item
  Future<int> updateClothingItem(LocalClothingItem item) async {
    final db = await database;
    return await db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Get count of items by category and gender
  Future<int> getItemCountByCategoryAndGender(
    String category,
    String gender,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM clothing_items WHERE category = ? AND gender = ?',
      [category.toLowerCase(), gender],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Clear all data from database
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('clothing_items');
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
