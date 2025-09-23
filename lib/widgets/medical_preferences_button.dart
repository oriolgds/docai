import 'package:flutter/material.dart';
import '../screens/medical_preferences_screen.dart';

class MedicalPreferencesButton extends StatelessWidget {
  final VoidCallback? onPreferencesUpdated;

  const MedicalPreferencesButton({
    Key? key,
    this.onPreferencesUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        title: const Text(
          'Personalización Médica',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const Text(
          'Configura alergias, preferencias de tratamiento y más',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
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
