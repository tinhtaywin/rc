import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_code_app/models/database_helper.dart';

class OutputScreen extends StatefulWidget {
  final String category;

  const OutputScreen({super.key, required this.category});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  late Future<Map<String, dynamic>?> _codeFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    _codeFuture = DatabaseHelper().getCode(widget.category);
  }

  Future<void> _refreshCode() async {
    setState(() {
      _loadCode();
    });
  }

  Future<void> _markAsUsed(int codeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseHelper().deleteCode(codeId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code marked as used')),
      );
      
      // Pop back to manage screen after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking code as used: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyCodeToClipboard(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Code: ${widget.category}'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _codeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic>? codeData = snapshot.data;
            
            if (codeData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No codes available for this category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ],
                ),
              );
            }

            String code = codeData['code_content'] as String;
            int codeId = codeData['id'] as int;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          '🎫 Your Code:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          code,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
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
                      onPressed: _isLoading ? null : () => _markAsUsed(codeId),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Used'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _copyCodeToClipboard(code),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Code'),
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
      bottomNavigationBar: _isLoading
          ? LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}