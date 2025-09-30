import 'package:flutter/material.dart';
import '../models/user_medical_preferences.dart';
import '../services/medical_preferences_service.dart';
import '../l10n/generated/app_localizations.dart'; // Agregar import

class MedicalPreferencesStatus extends StatefulWidget {
  const MedicalPreferencesStatus({Key? key}) : super(key: key);

  @override
  State<MedicalPreferencesStatus> createState() => _MedicalPreferencesStatusState();
}

class _MedicalPreferencesStatusState extends State<MedicalPreferencesStatus> {
  final MedicalPreferencesService _service = MedicalPreferencesService();
  UserMedicalPreferences? _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      _preferences = await _service.getUserMedicalPreferences();
    } catch (e) {
      // Error silencioso para este widget informativo
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Obtener localizaciones
    
    if (_isLoading) {
      return const Card(
        color: Colors.black54,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return Card(
      color: _preferences != null ? Colors.green : Colors.orange,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _preferences != null ? Icons.check_circle : Icons.info,
                  color: _preferences != null ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _preferences != null
                        ? l10n.medicalProfileConfigured
                        : l10n.medicalProfileIncomplete,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _preferences != null
                  ? l10n.medicalProfileConfiguredDescription
                  : l10n.medicalProfileIncompleteDescription,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            if (_preferences != null) ...[
              const SizedBox(height: 12),
              _buildPreferencesSummary(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSummary(AppLocalizations l10n) {
    if (_preferences == null) return const SizedBox.shrink();

    final summary = <String>[];

    // Información básica
    if (_preferences!.dateOfBirth != null) {
      final age = DateTime.now().difference(_preferences!.dateOfBirth!).inDays ~/ 365;
      summary.add(l10n.yearsOld(age));
    }

    // Alergias
    if (_preferences!.allergies.isNotEmpty) {
      summary.add(l10n.allergiesCount(_preferences!.allergies.length));
    }

    // Preferencias de medicina
    switch (_preferences!.medicinePreference) {
      case 'natural':
        summary.add(l10n.naturalMedicine);
        break;
      case 'conventional':
        summary.add(l10n.conventionalMedicine);
        break;
      case 'both':
        summary.add(l10n.integralMedicine);
        break;
    }

    // Condiciones crónicas
    if (_preferences!.chronicConditions.isNotEmpty) {
      summary.add(l10n.conditionsCount(_preferences!.chronicConditions.length));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: summary.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
