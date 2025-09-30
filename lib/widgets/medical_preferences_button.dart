import 'package:flutter/material.dart';
import '../screens/medical_preferences_screen.dart';
import '../l10n/generated/app_localizations.dart';

class MedicalPreferencesButton extends StatelessWidget {
  final VoidCallback? onPreferencesUpdated;

  const MedicalPreferencesButton({Key? key, this.onPreferencesUpdated})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.medical_services,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          l10n.medicalPersonalization,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          l10n.medicalPersonalizationDescription,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MedicalPreferencesScreen(),
            ),
          );

          // Si se guardaron cambios, ejecutar callback
          if (result == true && onPreferencesUpdated != null) {
            onPreferencesUpdated!();
          }
        },
      ),
    );
  }
}