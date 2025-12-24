import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/state/locale_scope.dart';
import 'package:docai/state/settings_scope.dart';
import 'package:docai/state/theme_scope.dart';
import 'package:docai/widgets/language_selector.dart';
import 'package:docai/services/app_haptics.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeController = LocaleScope.of(context);
    final settingsController = SettingsScope.of(context);
    final themeController = ThemeScope.of(context);

    final supportedLocales = AppLocalizations.supportedLocales;
    final resolvedLocale = _findLocaleMatch(
      localeController.locale ?? Localizations.localeOf(context),
      supportedLocales,
    );
    final selectedLocale = _findLocaleMatch(resolvedLocale, supportedLocales);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.menuSettings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            Text(
              localizations.settingsLanguage,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            const SizedBox(height: 12),
            LanguageSelector(
              selectedLocale: selectedLocale,
              supportedLocales: supportedLocales,
              onLocaleChanged: (locale) {
                if (locale != null) {
                  localeController.updateLocale(locale);
                }
              },
            ),

            const SizedBox(height: 32),

            // Theme Section
            Text(
              localizations.settingsTheme,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: borderColor.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  _ThemeRadioTile(
                    title: localizations.themeLight,
                    value: ThemeMode.light,
                    groupValue: themeController.themeMode,
                    icon: Icons.light_mode_outlined,
                    onChanged: (mode) {
                      AppHaptics.selectionClick(context);
                      themeController.updateThemeMode(mode!);
                    },
                  ),
                  Divider(height: 1, color: borderColor.withValues(alpha: 0.1)),
                  _ThemeRadioTile(
                    title: localizations.themeDark,
                    value: ThemeMode.dark,
                    groupValue: themeController.themeMode,
                    icon: Icons.dark_mode_outlined,
                    onChanged: (mode) {
                      AppHaptics.selectionClick(context);
                      themeController.updateThemeMode(mode!);
                    },
                  ),
                  Divider(height: 1, color: borderColor.withValues(alpha: 0.1)),
                  _ThemeRadioTile(
                    title: localizations.themeSystem,
                    value: ThemeMode.system,
                    groupValue: themeController.themeMode,
                    icon: Icons.brightness_auto,
                    onChanged: (mode) {
                      AppHaptics.selectionClick(context);
                      themeController.updateThemeMode(mode!);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Haptics Section
            Text(
              localizations.settingsHaptics,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: borderColor.withValues(alpha: 0.3), width: 1.5),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Text(
                  localizations.settingsHapticsLabel,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: settingsController.hapticsEnabled,
                onChanged: (value) {
                  AppHaptics.selectionClick(context);
                  settingsController.setHapticsEnabled(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Locale _findLocaleMatch(Locale target, List<Locale> options) {
    return options.firstWhere(
      (locale) => locale.languageCode == target.languageCode,
      orElse: () => options.first,
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final IconData icon;
  final ValueChanged<ThemeMode?> onChanged;

  const _ThemeRadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, color: textColor.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
