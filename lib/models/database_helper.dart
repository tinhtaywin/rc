import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    
    // For web, use a simple path. For mobile, use app documents directory
    if (kIsWeb) {
      path = 'codes.db';
    } else {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'codes.db');
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create codes table
    await db.execute('''
      CREATE TABLE codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        code_content TEXT
      )
    ''');

    // Create stats table
    await db.execute('''
      CREATE TABLE stats (
        category TEXT PRIMARY KEY,
        input_count INTEGER DEFAULT 0,
        output_count INTEGER DEFAULT 0
      )
    ''');

    // Initialize stats for default categories
    List<String> defaultCategories = ["60", "325", "660", "1800", "3850", "8100"];
    for (String category in defaultCategories) {
      await db.insert('stats', {
        'category': category,
        'input_count': 0,
        'output_count': 0,
      });
    }
  }

  // Insert code and increment input count
  Future<void> insertCode(String category, String codeContent) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Insert the code
      await txn.insert('codes', {
        'category': category,
        'code_content': codeContent,
      });
      
      // Increment input count
      await txn.rawUpdate(
        'UPDATE stats SET input_count = input_count + 1 WHERE category = ?',
        [category]
      );
    });
  }

  // Get one random code from category
  Future<Map<String, dynamic>?> getCode(String category) async {
    final db = await database;
    
    List<Map<String, dynamic>> result = await db.query(
      'codes',
      where: 'category = ?',
      orderBy: 'RANDOM()',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Delete code and increment output count
  Future<void> deleteCode(int id) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Get the category of the code being deleted
      List<Map<String, dynamic>> codeResult = await txn.query(
        'codes',
        where: 'id = ?',
        limit: 1,
      );
      
      if (codeResult.isNotEmpty) {
        String category = codeResult.first['category'] as String;
        
        // Delete the code
        await txn.delete('codes', where: 'id = ?', whereArgs: [id]);
        
        // Increment output count
        await txn.rawUpdate(
          'UPDATE stats SET output_count = output_count + 1 WHERE category = ?',
          [category]
        );
      }
    });
  }

  // Get stats for a category
  Future<Map<String, dynamic>?> getStats(String category) async {
    final db = await database;
    
    List<Map<String, dynamic>> result = await db.query(
      'stats',
      where: 'category = ?',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Get all stats
  Future<List<Map<String, dynamic>>> getAllStats() async {
    final db = await database;
    return await db.query('stats');
  }

  // Reset input counts
  Future<void> resetInputCounts() async {
    final db = await database;
    await db.rawUpdate('UPDATE stats SET input_count = 0');
  }

  // Reset output counts
  Future<void> resetOutputCounts() async {
    final db = await database;
    await db.rawUpdate('UPDATE stats SET output_count = 0');
  }

  // Update category name in all references
  Future<void> updateCategoryName(String oldName, String newName) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Update stats table
      await txn.rawUpdate(
        'UPDATE stats SET category = ? WHERE category = ?',
        [newName, oldName]
      );
      
      // Update codes table
      await txn.rawUpdate(
        'UPDATE codes SET category = ? WHERE category = ?',
        [newName, oldName]
      );
    });
  }

  // Get all codes for a category (for testing/debugging)
  Future<List<Map<String, dynamic>>> getCodesByCategory(String category) async {
    final db = await database;
    return await db.query('codes', where: 'category = ?', whereArgs: [category]);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}