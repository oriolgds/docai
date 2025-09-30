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

  @override
  String get yourPersonalAIDoctor => 'Tu Doctor de IA Personal';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contraseña';

  @override
  String get pleaseEnterEmail => 'Por favor ingresa tu email';

  @override
  String get pleaseEnterValidEmail =>
      'Por favor ingresa una dirección de email válida';

  @override
  String get pleaseEnterPassword => 'Por favor ingresa tu contraseña';

  @override
  String get signInWithEmail => 'Iniciar sesión con Email';

  @override
  String get or => 'o';

  @override
  String get signingIn => 'Iniciando sesión...';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta? ';

  @override
  String get signUp => 'Regístrate';

  @override
  String get emailVerificationRequired => 'Verificación de Email Requerida';

  @override
  String get emailVerificationMessage =>
      'Tu dirección de email necesita ser verificada antes de poder iniciar sesión.';

  @override
  String get verifyEmailButton => 'Verificar Email';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get resetPasswordMessage =>
      'Ingresa tu dirección de email para recibir un enlace de restablecimiento de contraseña.';

  @override
  String get emailAddress => 'Dirección de Email';

  @override
  String get sendResetLink => 'Enviar Enlace de Restablecimiento';

  @override
  String get passwordResetSent =>
      '¡Enlace de restablecimiento de contraseña enviado! Revisa tu email.';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get joinDocAI => 'Únete a DocAI hoy';

  @override
  String get enterEmailAddress => 'Ingresa tu dirección de email';

  @override
  String get createStrongPassword => 'Crea una contraseña segura';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get confirmYourPassword => 'Confirma tu contraseña';

  @override
  String get passwordRequirements => 'Requisitos de contraseña:';

  @override
  String get atLeast8Characters => 'Al menos 8 caracteres';

  @override
  String get containsUppercase => 'Contiene letra mayúscula';

  @override
  String get containsLowercase => 'Contiene letra minúscula';

  @override
  String get containsNumber => 'Contiene número';

  @override
  String get pleaseEnterEmailAddress =>
      'Por favor ingresa tu dirección de email';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordNeedsUppercase =>
      'La contraseña debe contener al menos una letra mayúscula';

  @override
  String get passwordNeedsLowercase =>
      'La contraseña debe contener al menos una letra minúscula';

  @override
  String get passwordNeedsNumber =>
      'La contraseña debe contener al menos un número';

  @override
  String get pleaseConfirmPassword => 'Por favor confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get accountCreatedSuccess =>
      '¡Cuenta creada exitosamente! Por favor revisa tu email para la verificación.';

  @override
  String get accountAlreadyExists =>
      'Ya existe una cuenta con este email. Por favor intenta iniciar sesión.';

  @override
  String get signingUp => 'Registrándose...';

  @override
  String get signUpWithGoogle => 'Registrarse con Google';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get helloImDocai => 'Hola, soy Docai. ¿En qué puedo ayudarte hoy?';

  @override
  String get newConversation => 'Nueva conversación';

  @override
  String get viewHistory => 'Ver historial';

  @override
  String get medicalNotice => 'Aviso médico';

  @override
  String get understood => 'Entendido';

  @override
  String get newConversationConfirm =>
      '¿Estás seguro de que quieres iniciar una nueva conversación?';

  @override
  String get deleteHistory => 'Eliminar historial';

  @override
  String get deleteHistoryConfirm =>
      '¿Estás seguro de que quieres eliminar todo el historial de chats? Esta acción no se puede deshacer y eliminará todas las conversaciones tanto localmente como en la nube.';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get deletingHistory => 'Eliminando historial...';

  @override
  String get historyDeletedSuccess => 'Historial eliminado correctamente';

  @override
  String errorDeletingHistory(String error) {
    return 'Error al eliminar historial: $error';
  }

  @override
  String get personalizeYourExperience => 'Personaliza tu experiencia';

  @override
  String get personalizeExperienceMessage =>
      'Para ofrecerte recomendaciones más precisas y personalizadas, configura tus preferencias médicas, alergias y condiciones.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get personalize => 'Personalizar';

  @override
  String get configureRegeneration => 'Configurar regeneración';

  @override
  String get advancedReasoning => 'Razonamiento avanzado';

  @override
  String get advancedReasoningDescription =>
      'Docai proporcionará un análisis paso a paso más detallado.';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get syncError =>
      'Error en la sincronización. Toca refrescar para intentar de nuevo.';

  @override
  String get conversationsLocalOnly =>
      'Conversaciones guardadas solo en este dispositivo';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get syncedLessThanMinute => 'Sincronizado hace menos de un minuto';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Sincronizado hace ${minutes}m';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Sincronizado hace ${hours}h';
  }

  @override
  String syncedDaysAgo(int days) {
    return 'Sincronizado hace ${days}d';
  }

  @override
  String get autoSyncEnabled => 'Sincronización automática habilitada';

  @override
  String get cloudSyncEnabled => 'Sincronización en la nube habilitada';

  @override
  String get cloudSyncDisabled => 'Sincronización en la nube deshabilitada';

  @override
  String get syncCompleted => 'Sincronización completada';

  @override
  String syncErrorMessage(String error) {
    return 'Error en sincronización: $error';
  }

  @override
  String get history => 'Historial';

  @override
  String get dashboard => 'Panel';

  @override
  String get chat => 'Chat';

  @override
  String get home => 'Inicio';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get close => 'Cerrar';

  @override
  String get done => 'Listo';

  @override
  String get settings => 'Configuración';

  @override
  String get search => 'Buscar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get warning => 'Advertencia';

  @override
  String get info => 'Información';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirmar';

  @override
  String get medications => 'Medicamentos';

  @override
  String get naturalRemedies => 'Remedios Naturales';

  @override
  String get symptoms => 'Síntomas';

  @override
  String get diagnosis => 'Diagnóstico';

  @override
  String get treatment => 'Tratamiento';

  @override
  String get prescription => 'Receta';

  @override
  String get dosage => 'Dosis';

  @override
  String get sideEffects => 'Efectos Secundarios';

  @override
  String get contraindications => 'Contraindicaciones';

  @override
  String get medicalHistory => 'Historial Médico';

  @override
  String get familyHistory => 'Historial Familiar';

  @override
  String get allergicReactions => 'Reacciones Alérgicas';

  @override
  String get typeYourMessage => 'Escribe tu mensaje...';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get askDocAI => 'Pregúntale a DocAI';

  @override
  String get thinking => 'Pensando...';

  @override
  String get processing => 'Procesando...';

  @override
  String get generatingResponse => 'Generando respuesta...';

  @override
  String get noMessagesYet => 'Aún no hay mensajes';

  @override
  String get startConversation => 'Inicia una conversación con DocAI';

  @override
  String get conversationHistory => 'Historial de Conversación';

  @override
  String get messageOptions => 'Opciones de Mensaje';

  @override
  String get copyMessage => 'Copiar Mensaje';

  @override
  String get reportMessage => 'Reportar Mensaje';

  @override
  String get deleteMessage => 'Eliminar Mensaje';

  @override
  String get noHistoryYet => 'Aún no hay historial';

  @override
  String get clearHistory => 'Limpiar Historial';

  @override
  String get exportHistory => 'Exportar Historial';

  @override
  String get importHistory => 'Importar Historial';

  @override
  String get deleteConversation => 'Eliminar Conversación';

  @override
  String get conversationDeleted => 'Conversación eliminada';

  @override
  String get historyCleared => 'Historial limpiado';

  @override
  String get lastActivity => 'Última actividad';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastWeek => 'Semana pasada';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get older => 'Más antiguo';

  @override
  String get language => 'Idioma';

  @override
  String get changeLanguage => 'Cambiar Idioma';

  @override
  String get languageChanged => 'Idioma cambiado';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get systemLanguage => 'Idioma del Sistema';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get networkError => 'Error de red';

  @override
  String get connectionFailed => 'Conexión fallida';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get requestTimeout => 'Tiempo de espera agotado';

  @override
  String get serverError => 'Error del servidor';

  @override
  String get notFound => 'No encontrado';

  @override
  String get unauthorized => 'No autorizado';

  @override
  String get forbidden => 'Prohibido';

  @override
  String get badRequest => 'Solicitud incorrecta';

  @override
  String get medicalDisclaimer => 'Descargo Médico';

  @override
  String get medicalDisclaimerText =>
      'DocAI proporciona información general de salud y no debe reemplazar el consejo, diagnóstico o tratamiento médico profesional. Siempre consulta con profesionales de la salud calificados para preocupaciones médicas.';

  @override
  String get emergencyWarning => 'Advertencia de Emergencia';

  @override
  String get emergencyWarningText =>
      'Si estás experimentando una emergencia médica, por favor llama a los servicios de emergencia inmediatamente o ve a la sala de emergencias más cercana.';

  @override
  String get notMedicalAdvice => 'Esto no es consejo médico';

  @override
  String get consultDoctor => 'Por favor consulta a un médico';

  @override
  String get seekImmediateHelp => 'Busca ayuda médica inmediata';

  @override
  String get medicalProfileConfigured => 'Perfil Médico Configurado';

  @override
  String get medicalProfileIncomplete => 'Perfil Médico Incompleto';

  @override
  String get medicalProfileConfiguredDescription =>
      'Tu perfil médico está configurado. DocAI puede proporcionar consejos más personalizados.';

  @override
  String get medicalProfileIncompleteDescription =>
      'Configura tu perfil médico para recibir consejos más precisos y personalizados.';

  @override
  String yearsOld(int age) {
    return '$age años';
  }

  @override
  String allergiesCount(int count) {
    return '$count alergias';
  }

  @override
  String get naturalMedicine => 'Medicina natural';

  @override
  String get conventionalMedicine => 'Medicina convencional';

  @override
  String get integralMedicine => 'Medicina integral';

  @override
  String conditionsCount(int count) {
    return '$count condiciones';
  }

  @override
  String get medicalPersonalization => 'Personalización Médica';

  @override
  String get configureMedicalPreferences =>
      'Configure allergies, treatment preferences and more';
}
