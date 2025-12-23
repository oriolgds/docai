import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/services/app_haptics.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.selectedLocale,
    required this.supportedLocales,
    required this.onLocaleChanged,
  });

  final Locale selectedLocale;
  final List<Locale> supportedLocales;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.language, color: borderColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    localizations.languageSelectorLabel,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: supportedLocales.map((locale) {
                final isSelected = locale == selectedLocale;
                return _LanguageChip(
                  label: _languageName(localizations, locale),
                  isSelected: isSelected,
                  onTap: () => onLocaleChanged(locale),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _languageName(AppLocalizations localizations, Locale locale) {
    switch (locale.languageCode) {
      case 'ca':
        return localizations.languageCatalan;
      case 'de':
        return localizations.languageGerman;
      case 'es':
        return localizations.languageSpanish;
      case 'fr':
        return localizations.languageFrench;
      case 'en':
      default:
        return localizations.languageEnglish;
    }
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final backgroundColor = isSelected
        ? primaryColor
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]!);

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.grey[300] : Colors.grey[800]);

    final borderColor = isSelected
        ? primaryColor
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selectionClick(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
