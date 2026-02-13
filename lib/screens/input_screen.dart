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
    print('InputScreen: _saveCodes called with text: "$text"');
    print('InputScreen: Category: ${widget.category}');
    
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
      print('InputScreen: Split text into ${lines.length} lines');
      
      // Filter out empty lines and process each line
      List<String> validCodes = [];
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i];
        String trimmedLine = line.trim();
        print('InputScreen: Processing line $i: "$trimmedLine"');
        
        if (trimmedLine.isNotEmpty) {
          String cleanedCode = CodeParser.cleanCodeText(trimmedLine);
          print('InputScreen: Cleaned code: "$cleanedCode"');
          
          if (cleanedCode.isNotEmpty) {
            validCodes.add(cleanedCode);
            print('InputScreen: Added valid code: "$cleanedCode"');
          } else {
            print('InputScreen: Code is empty after cleaning');
          }
        } else {
          print('InputScreen: Line is empty, skipping');
        }
      }

      print('InputScreen: Found ${validCodes.length} valid codes: $validCodes');

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
      print('InputScreen: Starting database insertion...');
      
      for (int i = 0; i < validCodes.length; i++) {
        String code = validCodes[i];
        print('InputScreen: Inserting code $i: "$code" into category: ${widget.category}');
        await dbHelper.insertCode(widget.category, code);
        print('InputScreen: Successfully inserted code $i');
      }

      // Clear the text field
      _textController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${validCodes.length} codes to ${widget.category}'),
        ),
      );
      
      print('InputScreen: _saveCodes completed successfully');
    } catch (e) {
      print('InputScreen: Error in _saveCodes: $e');
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