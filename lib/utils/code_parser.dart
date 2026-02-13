class CodeParser {
  /// Clean code text using flexible patterns
  /// 1. First try: Code:(.*?)(?:,|$) - for "Code:ABC,Expire:2027" format
  /// 2. Second try: (?:Code:)?\s*([A-Za-z0-9]+) - for simple codes with optional "Code:" prefix
  /// 3. Fallback: return trimmed text
  static String cleanCodeText(String text) {
    print('CodeParser: cleanCodeText called with: "$text"');
    
    // Pattern 1: Code:(.*?)(?:,|$) - for "Code:ABC,Expire:2027" format
    RegExp regex1 = RegExp(r'Code:(.*?)(?:,|$)', caseSensitive: false);
    Match? match1 = regex1.firstMatch(text);
    
    if (match1 != null) {
      String result = match1.group(1)!.trim();
      print('CodeParser: Pattern 1 matched, result: "$result"');
      return result;
    }
    
    // Pattern 2: (?:Code:)?\s*([A-Za-z0-9]+) - for simple codes with optional "Code:" prefix
    RegExp regex2 = RegExp(r'(?:Code:)?\s*([A-Za-z0-9]+)', caseSensitive: false);
    Match? match2 = regex2.firstMatch(text);
    
    if (match2 != null) {
      String result = match2.group(1)!.trim();
      print('CodeParser: Pattern 2 matched, result: "$result"');
      return result;
    }
    
    // Fallback: return trimmed text
    String result = text.trim();
    print('CodeParser: No pattern matched, fallback result: "$result"');
    return result;
  }
}
