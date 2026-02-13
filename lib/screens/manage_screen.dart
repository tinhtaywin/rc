import 'package:flutter/material.dart';
import 'package:my_code_app/models/database_helper.dart';
import 'package:my_code_app/screens/input_screen.dart';
import 'package:my_code_app/screens/output_screen.dart';

class ManageScreen extends StatefulWidget {
  final String category;

  const ManageScreen({super.key, required this.category});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  late Future<Map<String, dynamic>?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    _statsFuture = DatabaseHelper().getStats(widget.category);
  }

  Future<void> _refreshStats() async {
    setState(() {
      _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Managing: ${widget.category}'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic>? stats = snapshot.data;
            int inputCount = stats?['input_count'] ?? 0;
            int outputCount = stats?['output_count'] ?? 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Stats for ${widget.category}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Input',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  inputCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Output',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  outputCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InputScreen(category: widget.category),
                          ),
                        ).then((_) => _refreshStats());
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Input Codes'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OutputScreen(category: widget.category),
                          ),
                        ).then((_) => _refreshStats());
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text('Get Code'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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
            );
          }
        },
      ),
    );
  }
}