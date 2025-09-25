# Localization Setup for DocAI

## Overview
This directory contains the localization files for DocAI, supporting both English and Spanish.

## File Structure
```
lib/l10n/
├── app_en.arb          # English translations (template)
├── app_es.arb          # Spanish translations
├── generated/          # Auto-generated files (do not edit manually)
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   └── app_localizations_es.dart
└── README.md          # This file
```

## Setup Instructions

### 1. Dependencies
Make sure you have these dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
  shared_preferences: ^2.3.3

flutter:
  uses-material-design: true
  generate: true
```

### 2. Generate Localization Files
After adding or modifying translations in the `.arb` files, run:

```bash
flutter gen-l10n
```

Or simply:

```bash
flutter pub get
```

### 3. Usage in Widgets
To use translations in your widgets:

```dart
import '../../l10n/generated/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.profile); // Uses the translated string
  }
}
```

### 4. Adding New Translations

1. Add the key and English translation to `app_en.arb`:
```json
{
  "myNewKey": "My new text",
  "@myNewKey": {
    "description": "Description of what this text is for"
  }
}
```

2. Add the Spanish translation to `app_es.arb`:
```json
{
  "myNewKey": "Mi nuevo texto"
}
```

3. Run `flutter gen-l10n` to generate the Dart files

4. Use in your widget:
```dart
Text(l10n.myNewKey)
```

### 5. Parameterized Translations
For translations with parameters:

**app_en.arb:**
```json
{
  "welcomeUser": "Welcome, {userName}!",
  "@welcomeUser": {
    "description": "Welcome message with username",
    "placeholders": {
      "userName": {
        "type": "String",
        "description": "The user's name"
      }
    }
  }
}
```

**app_es.arb:**
```json
{
  "welcomeUser": "¡Bienvenido, {userName}!"
}
```

**Usage:**
```dart
Text(l10n.welcomeUser('John'))
```

## Supported Languages
- English (en) - Template language
- Spanish (es) - Translated language

## Language Switching
Users can switch languages using the `LanguageSelector` widget in the profile screen. The selected language is persisted using `SharedPreferences`.

## Notes
- The `app_en.arb` file serves as the template and contains all metadata
- The `app_es.arb` file only needs the key-value pairs for translations
- Auto-generated files in the `generated/` folder should never be edited manually
- After adding new translations, always run `flutter gen-l10n` before testing

## Testing Different Locales
You can test different locales by:

1. Using the language selector in the app
2. Changing your device/emulator language
3. Running the app with a specific locale:
   ```bash
   flutter run --dart-define=FLUTTER_LOCALE=es
   ```
