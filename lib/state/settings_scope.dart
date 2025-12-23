import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const _hapticsPrefKey = 'haptics_enabled';
  bool _hapticsEnabled = true;

  bool get hapticsEnabled => _hapticsEnabled;

  void setHapticsEnabled(bool enabled) {
    if (_hapticsEnabled == enabled) {
      return;
    }
    _hapticsEnabled = enabled;
    notifyListeners();
    unawaited(_persistHaptics(enabled));
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if not set
    _hapticsEnabled = prefs.getBool(_hapticsPrefKey) ?? true;
    notifyListeners();
  }

  Future<void> _persistHaptics(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsPrefKey, enabled);
  }
}

class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    required SettingsController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope not found in context');
    return scope!.notifier!;
  }
}
