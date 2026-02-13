import 'package:flutter/material.dart';
import 'package:my_code_app/models/category_manager.dart';
import 'package:my_code_app/models/database_helper.dart';
import 'package:my_code_app/screens/manage_screen.dart';
import 'package:my_code_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> _categoriesFuture;
  late Future<List<Map<String, dynamic>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _categoriesFuture = CategoryManager().loadCategories();
    _statsFuture = DatabaseHelper().getAllStats();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RC Special'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _categoriesFuture,
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (categorySnapshot.hasError) {
            return Center(child: Text('Error: ${categorySnapshot.error}'));
          } else if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found'));
          } else {
            List<String> categories = categorySnapshot.data!;
            
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(categories[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        ).then((_) => _refreshData());
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
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

  Widget _buildCategoryCard(String category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _statsFuture,
      builder: (context, statsSnapshot) {
        if (statsSnapshot.connectionState == ConnectionState.waiting) {
          return _buildCardSkeleton(category);
        } else if (statsSnapshot.hasError) {
          return _buildCardError(category);
        } else if (!statsSnapshot.hasData) {
          return _buildCardSkeleton(category);
        } else {
          Map<String, dynamic>? stats;
          for (var stat in statsSnapshot.data!) {
            if (stat['category'] == category) {
              stats = stat;
              break;
            }
          }
          
          return _buildCardWithData(category, stats);
        }
      },
    );
  }

  Widget _buildCardSkeleton(String category) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageScreen(category: category),
            ),
          ).then((_) => _refreshData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardError(String category) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageScreen(category: category),
            ),
          ).then((_) => _refreshData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Error loading stats'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWithData(String category, Map<String, dynamic>? stats) {
    int inputCount = stats?['input_count'] ?? 0;
    int outputCount = stats?['output_count'] ?? 0;

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageScreen(category: category),
            ),
          ).then((_) => _refreshData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Input: $inputCount',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Output: $outputCount',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}