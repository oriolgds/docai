import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/localization_service.dart';

class LanguageSelector extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  
  const LanguageSelector({
    super.key,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(
          Icons.language_outlined,
          color: Colors.black,
        ),
        title: const Text(
          'Language / Idioma',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          LocalizationService.getLanguageName(currentLocale.languageCode),
          style: const TextStyle(
            color: Color(0xFF6B6B6B),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF9E9E9E),
        ),
        onTap: () => _showLanguageDialog(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: const Color(0xFFFAFAFA),
      ),
    );
  }
  
  void _showLanguageDialog(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language / Seleccionar Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocalizationService.supportedLocales.map((locale) {
            final isSelected = locale.languageCode == currentLocale.languageCode;
            final languageName = LocalizationService.getLanguageName(locale.languageCode);
            
            return ListTile(
              title: Text(
                languageName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[700],
                ),
              ),
              leading: Radio<String>(
                value: locale.languageCode,
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    _changeLanguage(context, Locale(value));
                  }
                },
              ),
              onTap: () => _changeLanguage(context, locale),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / Cancelar'),
          ),
        ],
      ),
    );
  }
  
  void _changeLanguage(BuildContext context, Locale locale) {
    LocalizationService.saveLocale(locale);
    onLocaleChanged(locale);
    Navigator.pop(context);
    
    // Show confirmation snackbar
    final languageName = LocalizationService.getLanguageName(locale.languageCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale.languageCode == 'es' 
              ? 'Idioma cambiado a $languageName'
              : 'Language changed to $languageName',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}