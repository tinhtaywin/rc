# Quick Start Guide - My Code Manager

## 🚀 Get Started in 3 Steps

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run the App
```bash
# For web browser (easiest way to test)
flutter run -d chrome

# For Android device/emulator
flutter run

# For iOS simulator (macOS only)
flutter run -d ios
```

### Step 3: Build APK (When Ready)
```bash
flutter build apk
```
Your APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 How to Use

### Adding Codes
1. Tap a category card on the home screen
2. Tap "Input Codes"
3. Paste your codes (one per line)
4. Tap "Save"

**Example codes you can paste:**
```
Code:ABC123,Expire:2027-12-31
Code:DEF456,Expire:2027-12-31
SimpleCode789
Code:GHI012,Expire:2028-01-01
```

### Getting a Code
1. Tap a category card
2. Tap "Get Code"
3. Your random code will be displayed
4. Tap "Copy Code" to copy it
5. Tap "Mark as Used" to delete it and increment output count

### Managing Categories
1. Tap "Settings" on the home screen
2. Tap any category to rename it
3. Use "Reset Input" or "Reset Output" to reset counts

---

## ✅ Features Checklist

- ✅ 6 default categories (60, 325, 660, 1800, 3850, 8100)
- ✅ Automatic code parsing from formatted text
- ✅ Input/Output statistics tracking
- ✅ Category renaming with database updates
- ✅ Data persistence across app restarts
- ✅ Copy to clipboard functionality
- ✅ Reset counts independently
- ✅ Material Design 3 UI

---

## 🔧 Troubleshooting

**App won't run?**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

**Need to reset everything?**
- Go to Settings → "Reset to Defaults"

**Database issues?**
- Uninstall and reinstall the app

---

## 📊 Testing the App

Try this test scenario:

1. **Add codes to category "60":**
   - Paste 5 codes
   - Verify Input count shows 5

2. **Get a code:**
   - Tap "Get Code"
   - Mark it as used
   - Verify Output count shows 1

3. **Rename category:**
   - Go to Settings
   - Rename "60" to "Premium"
   - Verify codes still work

4. **Reset counts:**
   - Reset Input → should show 0
   - Reset Output → should show 0
   - Codes should still be in database

---

## 🎯 Key Differences from Bot

| Feature | Telegram Bot | Flutter App |
|---------|-------------|-------------|
| Platform | Telegram | Mobile/Web/Desktop |
| UI | Text-based | Visual cards & buttons |
| Database | SQLite file | SQLite + SharedPreferences |
| Code Display | Text message | Formatted card with copy button |
| Navigation | Commands | Touch/Click navigation |

---

## 📝 Code Parsing Examples

The app uses the exact regex from bot.py:

```
Input: "Code:ABC123,Expiration date:2027-12-31"
Output: "ABC123"

Input: "Code:XYZ789,Status:Active"
Output: "XYZ789"

Input: "PlainCode456"
Output: "PlainCode456"

Input: "code:test123,extra"  (case-insensitive)
Output: "test123"
```

---

## 🎨 UI Overview

```
Home Screen
├── Category Grid (2 columns)
│   ├── Category Card 1 (60)
│   ├── Category Card 2 (325)
│   ├── Category Card 3 (660)
│   ├── Category Card 4 (1800)
│   ├── Category Card 5 (3850)
│   └── Category Card 6 (8100)
└── Settings Button

Manage Screen
├── Stats Display
├── Input Codes Button
├── Get Code Button
└── Back Button

Input Screen
├── Multi-line Text Field
├── Save Button
├── Clear Button
└── Back Button

Output Screen
├── Code Display
├── Mark as Used Button
├── Copy Code Button
└── Back Button

Settings Screen
├── Category List (rename)
├── Reset Input Button
├── Reset Output Button
├── Reset to Defaults Button
└── Back Button
```

---

## 💡 Pro Tips

1. **Bulk Import**: Paste hundreds of codes at once - the app handles it!
2. **Quick Copy**: Use "Copy Code" before marking as used if you need it multiple times
3. **Category Names**: Use descriptive names like "Premium", "Basic", "Trial" instead of numbers
4. **Statistics**: Track your usage patterns with input/output counts
5. **Backup**: The database is stored locally - back up your device regularly

---

## 🚀 Ready to Go!

Your app is fully functional and ready to use. Start by running:

```bash
flutter run -d chrome
```

Then add some test codes and explore all the features!

---

**Need Help?** Check the main README.md for detailed documentation.