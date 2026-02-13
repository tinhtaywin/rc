import 'package:flutter/material.dart';
import 'package:my_code_app/models/database_helper.dart';
import 'package:my_code_app/utils/code_parser.dart';

class InputScreen extends StatefulWidget {
  final String category;

  const InputScreen({super.key, required this.category});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveCodes() async {
    String text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some codes')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Split text by newline
      List<String> lines = text.split('\n');
      
      // Filter out empty lines and process each line
      List<String> validCodes = [];
      for (String line in lines) {
        String trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty) {
          String cleanedCode = CodeParser.cleanCodeText(trimmedLine);
          if (cleanedCode.isNotEmpty) {
            validCodes.add(cleanedCode);
          }
        }
      }

      if (validCodes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid codes found')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Insert codes into database
      DatabaseHelper dbHelper = DatabaseHelper();
      for (String code in validCodes) {
        await dbHelper.insertCode(widget.category, code);
      }

      // Clear the text field
      _textController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${validCodes.length} codes to ${widget.category}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving codes: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearText() {
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input: ${widget.category}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Paste codes here...\n(one per line)\n\nExamples:\nCode:ABC,Expire:2027\nCode:DEF,Expire:2027\nSimpleCode123',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveCodes,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _clearText,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
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