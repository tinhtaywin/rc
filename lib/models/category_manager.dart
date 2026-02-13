import 'package:shared_preferences/shared_preferences.dart';

class CategoryManager {
  static const String _categoriesKey = 'categories';
  static final CategoryManager _instance = CategoryManager._internal();
  List<String> _categories = [];

  CategoryManager._internal();

  factory CategoryManager() => _instance;

  // Load categories from shared preferences or return defaults
  Future<List<String>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedCategories = prefs.getStringList(_categoriesKey);
    
    if (savedCategories != null && savedCategories.length == 6) {
      _categories = savedCategories;
    } else {
      // Default categories
      _categories = ["60", "325", "660", "1800", "3850", "8100"];
      await saveCategories(_categories);
    }
    
    return _categories;
  }

  // Save categories to shared preferences
  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey, categories);
    _categories = categories;
  }

  // Get current categories
  List<String> getCategories() {
    return _categories;
  }

  // Rename a category
  Future<void> renameCategory(String oldName, String newName) async {
    if (_categories.contains(oldName)) {
      int index = _categories.indexOf(oldName);
      _categories[index] = newName;
      await saveCategories(_categories);
    }
  }

  // Reset to default categories
  Future<void> resetToDefaults() async {
    _categories = ["60", "325", "660", "1800", "3850", "8100"];
    await saveCategories(_categories);
  }
}