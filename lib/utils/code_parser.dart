class CodeParser {
  /// Clean code text using the exact logic from bot.py
  /// Pattern: Code:(.*?)(?:,|$)
  /// If match found, return captured group
  /// Else return trimmed text
  static String cleanCodeText(String text) {
    // Regex to find text between "Code:" and first comma or end of line
    RegExp regex = RegExp(r'Code:(.*?)(?:,|$)', caseSensitive: false);
    Match? match = regex.firstMatch(text);
    
    if (match != null) {
      return match.group(1)!.trim();
    }
    
    return text.trim();
  }
}