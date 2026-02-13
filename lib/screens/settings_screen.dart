import 'package:flutter/material.dart';
import 'package:my_code_app/models/category_manager.dart';
import 'package:my_code_app/models/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<List<String>> _categoriesFuture;
  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryManager().loadCategories();
    _dbHelper = DatabaseHelper();
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _categoriesFuture = CategoryManager().loadCategories();
    });
  }

  Future<void> _renameCategory(String oldName) async {
    TextEditingController controller = TextEditingController(text: oldName);
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'New Category Name',
              hintText: 'Enter new name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = controller.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  try {
                    // Update category in category manager
                    await CategoryManager().renameCategory(oldName, newName);
                    
                    // Update database references
                    await _dbHelper.updateCategoryName(oldName, newName);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Category renamed from "$oldName" to "$newName"')),
                    );
                    
                    Navigator.of(context).pop();
                    await _refreshCategories();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error renaming category: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid name')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetInputCounts() async {
    try {
      await _dbHelper.resetInputCounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input counts reset to 0')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting input counts: $e')),
      );
    }
  }

  Future<void> _resetOutputCounts() async {
    try {
      await _dbHelper.resetOutputCounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Output counts reset to 0')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting output counts: $e')),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset to Defaults'),
          content: const Text('This will reset all categories to the default values and reset all counts to 0. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Reset categories
                  await CategoryManager().resetToDefaults();
                  
                  // Reset counts
                  await _dbHelper.resetInputCounts();
                  await _dbHelper.resetOutputCounts();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset to defaults completed')),
                  );
                  
                  Navigator.of(context).pop();
                  await _refreshCategories();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error resetting to defaults: $e')),
                  );
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found'));
          } else {
            List<String> categories = snapshot.data!;
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rename Categories:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String category = categories[index];
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(category),
                            trailing: const Icon(Icons.edit),
                            onTap: () => _renameCategory(category),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reset Counts:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetInputCounts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Input'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _resetOutputCounts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Output'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetToDefaults,
                        icon: const Icon(Icons.settings_backup_restore),
                        label: const Text('Reset to Defaults'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}