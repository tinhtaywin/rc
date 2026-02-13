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
    print('DatabaseHelper: _initDatabase called');
    
    String path;
    
    try {
      // For web, use a simple path. For mobile, use app documents directory
      if (kIsWeb) {
        path = 'codes.db';
        print('DatabaseHelper: Using web path: $path');
      } else {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, 'codes.db');
        print('DatabaseHelper: Using mobile path: $path');
        print('DatabaseHelper: Documents directory: ${documentsDirectory.path}');
      }
      
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      
      print('DatabaseHelper: Database opened successfully at: $path');
      return database;
    } catch (e) {
      print('DatabaseHelper: _initDatabase failed with error: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    print('DatabaseHelper: _onCreate called, creating tables...');
    
    try {
      // Create codes table
      await db.execute('''
        CREATE TABLE codes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT,
          code_content TEXT
        )
      ''');
      print('DatabaseHelper: codes table created successfully');

      // Create stats table
      await db.execute('''
        CREATE TABLE stats (
          category TEXT PRIMARY KEY,
          input_count INTEGER DEFAULT 0,
          output_count INTEGER DEFAULT 0
        )
      ''');
      print('DatabaseHelper: stats table created successfully');

      // Initialize stats for default categories
      List<String> defaultCategories = ["60", "325", "660", "1800", "3850", "8100"];
      print('DatabaseHelper: Initializing stats for ${defaultCategories.length} default categories');
      
      for (String category in defaultCategories) {
        final insertResult = await db.insert('stats', {
          'category': category,
          'input_count': 0,
          'output_count': 0,
        });
        print('DatabaseHelper: Initialized stats for category "$category" with ID: $insertResult');
      }
      
      // Verify stats table was populated
      final statsCount = await db.rawQuery('SELECT COUNT(*) as count FROM stats');
      final count = statsCount.first['count'] as int;
      print('DatabaseHelper: Stats table verification - found $count rows');
      
    } catch (e) {
      print('DatabaseHelper: _onCreate failed with error: $e');
      rethrow;
    }
  }

  // Insert code and increment input count
  Future<void> insertCode(String category, String codeContent) async {
    String trimmedCategory = category.trim();
    print('DatabaseHelper: insertCode called with category: "$category", trimmed to: "$trimmedCategory", code: "$codeContent"');
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Insert the code
        final insertResult = await txn.insert('codes', {
          'category': trimmedCategory,
          'code_content': codeContent,
        });
        print('DatabaseHelper: Code inserted with ID: $insertResult');
        
        // Increment input count
        final updateResult = await txn.rawUpdate(
          'UPDATE stats SET input_count = input_count + 1 WHERE category = ?',
          [trimmedCategory]
        );
        print('DatabaseHelper: Input count updated, rows affected: $updateResult');
        
        if (updateResult == 0) {
          print('DatabaseHelper: Warning - No stats row found for category: "$trimmedCategory"');
        }
      });
      print('DatabaseHelper: insertCode completed successfully');
    } catch (e) {
      print('DatabaseHelper: insertCode failed with error: $e');
      rethrow;
    }
  }

  // Get one random code from category
  Future<Map<String, dynamic>?> getCode(String category) async {
    String trimmedCategory = category.trim();
    print('DatabaseHelper: getCode called with category: "$category", trimmed to: "$trimmedCategory"');
    print('DatabaseHelper: Searching for: "$trimmedCategory"');
    final db = await database;
    
    try {
      // First check if any codes exist for this category
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM codes WHERE category = ?',
        [trimmedCategory]
      );
      final count = countResult.first['count'] as int;
      print('DatabaseHelper: Found $count codes for category: "$trimmedCategory"');
      
      List<Map<String, dynamic>> result = await db.query(
        'codes',
        where: 'category = ?',
        orderBy: 'RANDOM()',
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        print('DatabaseHelper: Found code with ID: ${result.first['id']}');
        return result.first;
      } else {
        print('DatabaseHelper: No codes found for category: "$trimmedCategory"');
        return null;
      }
    } catch (e) {
      print('DatabaseHelper: getCode failed with error: $e');
      rethrow;
    }
  }

  // Delete code and increment output count
  Future<void> deleteCode(int id) async {
    print('DatabaseHelper: deleteCode called with ID: $id');
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Get the category of the code being deleted
        List<Map<String, dynamic>> codeResult = await txn.query(
          'codes',
          where: 'id = ?',
          limit: 1,
        );
        
        if (codeResult.isNotEmpty) {
          String category = codeResult.first['category'] as String;
          print('DatabaseHelper: Found code with category: $category');
          
          // Delete the code
          final deleteResult = await txn.delete('codes', where: 'id = ?', whereArgs: [id]);
          print('DatabaseHelper: Code deleted, rows affected: $deleteResult');
          
          // Increment output count
          final updateResult = await txn.rawUpdate(
            'UPDATE stats SET output_count = output_count + 1 WHERE category = ?',
            [category]
          );
          print('DatabaseHelper: Output count updated, rows affected: $updateResult');
          
          if (updateResult == 0) {
            print('DatabaseHelper: Warning - No stats row found for category: $category');
          }
        } else {
          print('DatabaseHelper: Warning - No code found with ID: $id');
        }
      });
      print('DatabaseHelper: deleteCode completed successfully');
    } catch (e) {
      print('DatabaseHelper: deleteCode failed with error: $e');
      rethrow;
    }
  }

  // Get stats for a category
  Future<Map<String, dynamic>?> getStats(String category) async {
    String trimmedCategory = category.trim();
    print('DatabaseHelper: getStats called with category: "$category", trimmed to: "$trimmedCategory"');
    final db = await database;
    
    List<Map<String, dynamic>> result = await db.query(
      'stats',
      where: 'category = ?',
      limit: 1,
      whereArgs: [trimmedCategory],
    );
    
    if (result.isNotEmpty) {
      print('DatabaseHelper: Found stats for category: "$trimmedCategory"');
      return result.first;
    } else {
      print('DatabaseHelper: No stats found for category: "$trimmedCategory"');
      return null;
    }
  }

  // Get all stats
  Future<List<Map<String, dynamic>>> getAllStats() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('stats');
    print('DatabaseHelper: getAllStats returned ${result.length} stats records');
    return result;
  }

  // Reset input counts
  Future<void> resetInputCounts() async {
    final db = await database;
    int result = await db.rawUpdate('UPDATE stats SET input_count = 0');
    print('DatabaseHelper: resetInputCounts updated $result rows');
  }

  // Reset output counts
  Future<void> resetOutputCounts() async {
    final db = await database;
    int result = await db.rawUpdate('UPDATE stats SET output_count = 0');
    print('DatabaseHelper: resetOutputCounts updated $result rows');
  }

  // Update category name in all references
  Future<void> updateCategoryName(String oldName, String newName) async {
    String trimmedOldName = oldName.trim();
    String trimmedNewName = newName.trim();
    print('DatabaseHelper: updateCategoryName called - old: "$oldName" -> "$trimmedOldName", new: "$newName" -> "$trimmedNewName"');
    
    final db = await database;
    
    await db.transaction((txn) async {
      // Update stats table
      int statsResult = await txn.rawUpdate(
        'UPDATE stats SET category = ? WHERE category = ?',
        [trimmedNewName, trimmedOldName]
      );
      print('DatabaseHelper: Updated $statsResult stats records');
      
      // Update codes table
      int codesResult = await txn.rawUpdate(
        'UPDATE codes SET category = ? WHERE category = ?',
        [trimmedNewName, trimmedOldName]
      );
      print('DatabaseHelper: Updated $codesResult code records');
    });
  }

  // Get all codes for a category (for testing/debugging)
  Future<List<Map<String, dynamic>>> getCodesByCategory(String category) async {
    String trimmedCategory = category.trim();
    print('DatabaseHelper: getCodesByCategory called with category: "$category", trimmed to: "$trimmedCategory"');
    final db = await database;
    
    try {
      List<Map<String, dynamic>> result = await db.query('codes', where: 'category = ?', whereArgs: [trimmedCategory]);
      print('DatabaseHelper: Found ${result.length} codes for category: "$trimmedCategory"');
      
      for (int i = 0; i < result.length; i++) {
        print('DatabaseHelper: Code $i - ID: ${result[i]['id']}, Content: ${result[i]['code_content']}');
      }
      
      return result;
    } catch (e) {
      print('DatabaseHelper: getCodesByCategory failed with error: $e');
      rethrow;
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}