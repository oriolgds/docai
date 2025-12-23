import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:docai/state/settings_scope.dart';

class AppHaptics {
  static void selectionClick(BuildContext context) {
    if (SettingsScope.of(context).hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  static void lightImpact(BuildContext context) {
    if (SettingsScope.of(context).hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  static void mediumImpact(BuildContext context) {
    if (SettingsScope.of(context).hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  static void heavyImpact(BuildContext context) {
    if (SettingsScope.of(context).hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}
