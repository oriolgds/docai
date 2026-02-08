import 'dart:io';

void main() async {
  final now = DateTime.now();
  final isChristmas =
      (now.month == 12 && now.day >= 1) || (now.month == 1 && now.day <= 7);

  print('Current date: ${now.toIso8601String()}');
  print('Is Christmas season: $isChristmas');

  final configFile = File('flutter_launcher_icons.yaml');
  final pubspecFile = File('pubspec.yaml');

  // We need to determine where the config is.
  // Based on the user's pubspec.yaml, it seems to be in pubspec.yaml itself.
  // However, it's safer to have a separate config file or modify pubspec.yaml directly.
  // Let's modify pubspec.yaml since that's what was viewed earlier.

  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  String content = pubspecFile.readAsStringSync();

  final regularIconPath = 'assets/logo/logo.jpg';
  final xmasIconPath = 'assets/logo/xmas.png';

  final targetIconPath = isChristmas ? xmasIconPath : regularIconPath;

  // Regex to find variable image_path in flutter_launcher_icons section
  // It looks for indentation, image_path: "..."

  // We need to be careful not to mess up the file structure.
  // The structure viewed in pubspec.yaml was:
  // flutter_launcher_icons:
  //   android: "launcher_icon"
  //   ios: true
  //   image_path: "assets/logo/xmas.png"  <-- We want to change this
  //   min_sdk_android: 16
  //   ...

  // Note: There might be multiple image_paths (e.g. for web, windows).
  // The user request implied "app icon", which usually means the main mobile one.
  // The pubspec had:
  // flutter_launcher_icons:
  //   ...
  //   image_path: "assets/logo/xmas.png"
  //   ...
  //   web:
  //     image_path: "assets/logo/logo.jpg"
  //   windows:
  //     image_path: "assets/logo/logo.jpg"

  // We should change ALL of them to be consistent?
  // The user said "also the app icon".
  // Let's update all occurrences of image_path within the flutter_launcher_icons section.

  // Simple replacement strategy:
  // We will replace specific lines if they match known patterns to ensure safety.

  bool changed = false;

  // Update main image_path
  if (content.contains('image_path: "assets/logo/logo.jpg"') && isChristmas) {
    content = content.replaceAll(
      'image_path: "assets/logo/logo.jpg"',
      'image_path: "$xmasIconPath"',
    );
    changed = true;
  } else if (content.contains('image_path: "assets/logo/xmas.png"') &&
      !isChristmas) {
    content = content.replaceAll(
      'image_path: "assets/logo/xmas.png"',
      'image_path: "$regularIconPath"',
    );
    changed = true;
  }

  if (changed) {
    print(
      'Updating pubspec.yaml to use ${isChristmas ? "Christmas" : "Regular"} icons...',
    );
    pubspecFile.writeAsStringSync(content);

    print('Running flutter_launcher_icons...');
    final result = await Process.run('dart', ['run', 'flutter_launcher_icons']);
    print(result.stdout);
    print(result.stderr);

    if (result.exitCode == 0) {
      print('Icons updated successfully!');
    } else {
      print('Error updating icons.');
      exit(result.exitCode);
    }
  } else {
    print('No changes needed. pubspec.yaml is already set correctly.');
    // Run it anyway just in case? No, save time.
  }
}
