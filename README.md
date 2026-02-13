# My Code Manager - Flutter App

A Flutter code management application based on Telegram bot logic. This app manages codes across 6 categories with input/output tracking.

## Features

✅ **6 Category System** - Default categories: 60, 325, 660, 1800, 3850, 8100
✅ **Code Input** - Paste multiple codes at once with automatic parsing
✅ **Code Output** - Get random codes from any category
✅ **Statistics Tracking** - Track input and output counts per category
✅ **Category Renaming** - Rename categories with automatic database updates
✅ **Reset Functions** - Reset input/output counts independently
✅ **Data Persistence** - All data persists across app restarts using SQLite
✅ **Code Parsing** - Automatic extraction of codes from formatted text

## Code Parsing Logic

The app uses the exact parsing logic from the original bot.py:

```dart
// Input: "Code:ABC123,Expiration date:2027-12-31"
// Output: "ABC123"

// Input: "RandomCode456" (no "Code:" prefix)
// Output: "RandomCode456" (returned as-is)
```

Pattern: `Code:(.*?)(?:,|$)` (case-insensitive)

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── database_helper.dart       # SQLite database operations
│   └── category_manager.dart      # Category state management
├── screens/
│   ├── home_screen.dart           # Category grid view
│   ├── manage_screen.dart         # Category management
│   ├── input_screen.dart          # Input codes screen
│   ├── output_screen.dart         # Get/output code screen
│   └── settings_screen.dart       # Settings screen
└── utils/
    └── code_parser.dart           # Code parsing logic
```

## Database Schema

### Table: codes
```sql
CREATE TABLE codes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT,
    code_content TEXT
)
```

### Table: stats
```sql
CREATE TABLE stats (
    category TEXT PRIMARY KEY,
    input_count INTEGER DEFAULT 0,
    output_count INTEGER DEFAULT 0
)
```

## Installation & Running

### Prerequisites
- Flutter SDK (3.11.0 or higher)
- Chrome browser (for web testing)
- Android SDK (for APK building)

### Install Dependencies
```bash
flutter pub get
```

### Run in Chrome Browser (Recommended for Testing)
```bash
flutter run -d chrome
```

### Build APK for Android
```bash
flutter build apk
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Build for Other Platforms
```bash
# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows

# Linux
flutter build linux

# macOS
flutter build macos
```

## Usage Guide

### 1. Home Screen
- View all 6 categories with their input/output statistics
- Tap any category card to manage it
- Access settings via the Settings button

### 2. Manage Category Screen
- View detailed statistics for the selected category
- **Input Codes**: Add new codes to the category
- **Get Code**: Retrieve a random code from the category

### 3. Input Codes Screen
- Paste multiple codes (one per line)
- Supports formatted codes like: `Code:ABC123,Expire:2027`
- Automatically parses and extracts the code portion
- Click **Save** to add codes to the database
- Click **Clear** to clear the text field

### 4. Output Code Screen
- Displays a random code from the selected category
- **Mark as Used**: Deletes the code and increments output count
- **Copy Code**: Copies the code to clipboard
- Shows message if no codes are available

### 5. Settings Screen
- **Rename Categories**: Tap any category to rename it
- **Reset Input**: Reset all input counts to 0
- **Reset Output**: Reset all output counts to 0
- **Reset to Defaults**: Reset categories and counts to default values

## Core Operations

### Input Codes
1. User pastes multiple lines of codes
2. Each line is split by newline
3. `clean_code_text()` is applied to each line
4. Codes are inserted into the database
5. Input count is incremented for that category

### Output Code
1. Get ONE random code from the category
2. Display the code to the user
3. When "Mark as Used" is clicked:
   - Delete the code from database
   - Increment output count
   - Return to manage screen

### Rename Category
1. User enters new category name
2. Update category in CategoryManager
3. Update all database references:
   - `UPDATE stats SET category = ? WHERE category = ?`
   - `UPDATE codes SET category = ? WHERE category = ?`
4. Save to persistent storage

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3+1          # SQLite database
  path: ^1.9.0               # Path manipulation
  shared_preferences: ^2.3.1  # Persistent storage
  cupertino_icons: ^1.0.6    # iOS-style icons
```

## Technical Details

### State Management
- Uses `StatefulWidget` with `setState()` for simplicity
- Category names passed through navigation parameters
- Stats reloaded when returning to screens

### Database Operations
- Singleton pattern for DatabaseHelper
- Transactions for atomic operations
- Automatic initialization on first run

### Data Persistence
- SQLite for code storage and statistics
- SharedPreferences for category names
- All data persists across app restarts

### Error Handling
- Try-catch blocks for all database operations
- User-friendly error messages via SnackBar
- Graceful handling of empty states

## Testing

### Manual Testing Checklist
- [ ] Add codes to a category
- [ ] Get a code from a category
- [ ] Mark code as used
- [ ] Copy code to clipboard
- [ ] Rename a category
- [ ] Reset input counts
- [ ] Reset output counts
- [ ] Verify data persists after app restart
- [ ] Test with formatted codes (Code:XXX,...)
- [ ] Test with plain codes

## Troubleshooting

### Issue: Database not initializing
**Solution**: Delete the app data and restart

### Issue: Categories not saving
**Solution**: Check SharedPreferences permissions

### Issue: Codes not parsing correctly
**Solution**: Verify the code format matches the regex pattern

## Future Enhancements

- [ ] Export/Import database functionality
- [ ] Search codes within categories
- [ ] Bulk delete codes
- [ ] Category-specific statistics graphs
- [ ] Dark mode support
- [ ] Multi-language support

## License

This project is created for personal use based on the Telegram bot logic.

## Author

Created as a Flutter implementation of the Telegram bot code manager.

---

**Last Updated**: February 12, 2026