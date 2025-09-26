// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'DocAI';

  @override
  String get profile => 'Perfil';

  @override
  String get personalization => 'Personalización';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get privacySecurity => 'Privacidad y Seguridad';

  @override
  String get helpSupport => 'Ayuda y Soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get noEmail => 'Sin email';

  @override
  String get user => 'Usuario';

  @override
  String get premiumPlan => 'Plan Premium';

  @override
  String get active => 'Activo';

  @override
  String get unlimitedConsultations => 'Consultas de IA ilimitadas';

  @override
  String get expiresOn => 'Expira: 15 de marzo, 2025';

  @override
  String get medicalPreferencesUpdated => 'Preferencias médicas actualizadas';

  @override
  String get logoutConfirmTitle => 'Cerrar Sesión';

  @override
  String get logoutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get personalizeExperience => 'Personaliza tu experiencia';

  @override
  String get personalizeDescription =>
      'Ayúdanos a ofrecerte recomendaciones más precisas y personalizadas.';

  @override
  String get basicInformation => 'Información básica';

  @override
  String get ageRange => 'Rango de edad';

  @override
  String get gender => 'Género';

  @override
  String get medicalPreferences => 'Preferencias médicas';

  @override
  String get preferredMedicineType => 'Tipo de medicina preferida';

  @override
  String get medicalInformation => 'Información médica';

  @override
  String get allergies => 'Alergias';

  @override
  String get allergiesHint =>
      'Ej: penicilina, frutos secos, polen (separadas por comas)';

  @override
  String get chronicConditions => 'Condiciones crónicas';

  @override
  String get chronicConditionsHint =>
      'Ej: diabetes, hipertensión, asma (separadas por comas)';

  @override
  String get currentMedications => 'Medicamentos actuales';

  @override
  String get currentMedicationsHint =>
      'Ej: aspirina, omeprazol (separados por comas)';

  @override
  String get additionalNotes => 'Notas adicionales';

  @override
  String get additionalInformation => 'Información adicional';

  @override
  String get additionalInformationHint =>
      'Cualquier otra información relevante para tu atención médica...';

  @override
  String get disclaimerText =>
      'Esta información nos ayuda a personalizar las respuestas, pero no reemplaza una consulta médica profesional.';

  @override
  String get preferencesSavedSuccess => 'Preferencias guardadas correctamente';

  @override
  String errorLoadingPreferences(String error) {
    return 'Error al cargar preferencias: $error';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get userNotFound => 'Usuario no encontrado';
}
