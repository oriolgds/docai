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
  String get preferredMedicineType => 'Tipo de Medicina Preferida';

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
  String get medicalDisclaimerCard =>
      'DocAI no reemplaza el consejo médico profesional. La información proporcionada es con fines educativos. Para diagnósticos, tratamientos o emergencias consulta a un profesional de la salud.';

  @override
  String get customizeYourExperience => 'Personaliza tu experiencia';

  @override
  String get updateYourInformation => 'Actualiza tu información';

  @override
  String get manageYourAlerts => 'Gestiona tus alertas';

  @override
  String get privacySecuritySettings =>
      'Configuración de privacidad y seguridad';

  @override
  String get getHelpWhenYouNeedIt => 'Obtén ayuda cuando la necesites';

  @override
  String get learnMoreAboutDocAI => 'Aprende más sobre DocAI';

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
      'Configura alergias, preferencias de tratamiento y más';

  @override
  String get privacyAndSecurity => 'Privacidad y Seguridad';

  @override
  String get yourPrivacyIsOurPriority => 'Tu Privacidad es Nuestra Prioridad';

  @override
  String get privacyIntroduction =>
      'En DocAI, entendemos la importancia de proteger tu información de salud. Esta sección explica cómo recopilamos, procesamos y protegemos tus datos personales.';

  @override
  String get dataWeCollect => 'Datos que recopilamos';

  @override
  String get requiredAccountData => 'Datos de Cuenta (Requeridos)';

  @override
  String get requiredAccountDataDescription =>
      'Para usar DocAI, necesitamos recopilar cierta información básica que es esencial para que el servicio funcione:\n\n**Dirección de email** Para crear tu cuenta, autenticación y comunicaciones importantes.\n**Contraseña** Almacenada de forma segura con hash para proteger tu cuenta.\n**Fecha de creación de cuenta** Para propósitos de auditoría y soporte técnico.\n\nEstos datos son absolutamente necesarios para proporcionarte el servicio y no pueden ser opcionales.';

  @override
  String get conversationData => 'Datos de Conversación';

  @override
  String get conversationDataDescription =>
      'Todas las conversaciones que tienes con DocAI se almacenan para:\n\n**Continuidad del servicio** Para mantener el contexto de tus consultas médicas.\n**Historial médico personalizado** Ofrecer recomendaciones más precisas basadas en tu historial.\n**Mejora del servicio** Analizar patrones para mejorar respuestas de forma anónima.\n\nCada mensaje incluye:\nContenido del mensaje\nFecha y hora\nTipo de consulta\nRespuesta generada por IA';

  @override
  String get technicalData => 'Datos Técnicos';

  @override
  String get technicalDataDescription =>
      'Para garantizar la seguridad y el funcionamiento óptimo del servicio, recopilamos automáticamente:\n\n**Dirección IP** Para prevenir abuso y detectar actividad sospechosa.\n**Información del dispositivo** Tipo de dispositivo, sistema operativo, versión de la app.\n**Datos de uso** Frecuencia de uso, funciones utilizadas, tiempos de sesión.\n**Registros de errores** Para identificar y resolver problemas técnicos.\n\nEsta información se recopila automáticamente y es necesaria para el funcionamiento seguro del servicio.';

  @override
  String get optionalDataYouChoose => 'Datos Opcionales (Tú Eliges)';

  @override
  String get medicalPreferencesData => 'Preferencias Médicas';

  @override
  String get medicalPreferencesDataDescription =>
      'Para personalizar tu experiencia y ofrecer recomendaciones más precisas, puedes elegir compartir:\n\n**Alergias conocidas** Para evitar recomendaciones de medicamentos o tratamientos que podrían causar reacciones.\n**Condiciones médicas crónicas** Diabetes, hipertensión, etc., para contextualizar recomendaciones.\n**Medicamentos actuales** Para detectar posibles interacciones medicamentosas.\n**Preferencias de tratamiento** Natural vs. convencional.\n**Rango de edad y género** Para recomendaciones más específicas.\n\n**IMPORTANTE** Toda esta información es completamente opcional. Puedes usar DocAI sin proporcionar ninguno de estos datos.';

  @override
  String get profileInformation => 'Información del Perfil';

  @override
  String get profileInformationDescription =>
      'Opcionalmente, puedes completar tu perfil con:\n\n**Nombre completo** Para personalizar la experiencia.\n**Foto de perfil** Solo se almacena localmente en tu dispositivo.\n**Preferencias de idioma** Para adaptar la interfaz.\n**Configuración de notificaciones** Para controlar alertas.\n\nToda esta información es opcional y puede ser modificada o eliminada en cualquier momento desde tu perfil.';

  @override
  String get howWeProcessYourData => 'Cómo Procesamos Tus Datos';

  @override
  String get medicalConsultationProcessing =>
      'Procesamiento de Consultas Médicas';

  @override
  String get medicalConsultationProcessingDescription =>
      'Cuando realizas una consulta médica a DocAI:\n\n1. Tu mensaje se envía de forma segura a nuestros servidores usando encriptación **TLS 1.3**.\n2. Se combina con tu historial médico (si existe) para proporcionar contexto.\n3. Se incorporan tus preferencias médicas (si las has proporcionado) para personalizar la respuesta.\n4. Se procesa por IA médica especializada que ha sido entrenada con conocimiento médico verificado.\n5. La respuesta se genera y encripta antes de ser enviada de vuelta a tu dispositivo.\n\nTodo este proceso ocurre en tiempo real y está diseñado para proteger tu privacidad en cada paso.';

  @override
  String get serviceAnalysisImprovement => 'Análisis y Mejora del Servicio';

  @override
  String get serviceAnalysisImprovementDescription =>
      'Para mejorar continuamente DocAI, realizamos análisis de datos de forma anónima:\n\n**Patrones de consulta** Identificamos los tipos de preguntas más comunes para mejorar respuestas.\n**Efectividad de respuestas** Analizamos qué respuestas son más útiles.\n**Rendimiento técnico** Monitoreamos tiempos de respuesta y errores.\n**Tendencias de salud** Identificamos temas de salud emergentes de manera agregada y anónima.\n\n**IMPORTANTE** Este análisis se realiza **SIEMPRE** con datos anonimizados. Los análisis específicos nunca se vincularán a tu identidad personal.';

  @override
  String get encryptionAndSecurity => 'Encriptación y Seguridad en Tránsito';

  @override
  String get encryptionInTransit => 'Encriptación en Tránsito';

  @override
  String get encryptionInTransitDescription =>
      'Toda la comunicación entre tu dispositivo y nuestros servidores está protegida por múltiples capas de seguridad:\n\n**TLS 1.3 (Transport Layer Security)** El protocolo de encriptación más avanzado disponible.\n**Certificados SSL de nivel empresarial** Validados por autoridades de certificación reconocidas globalmente.\n**Perfect Forward Secrecy** Incluso si una clave futura se ve comprometida, las comunicaciones pasadas permanecen seguras.\n**HSTS (HTTP Strict Transport Security)** Garantiza que todas las conexiones usen HTTPS.\n\nEsto significa que es virtualmente imposible para terceros interceptar o leer tus datos mientras viajan por internet.';

  @override
  String get encryptionAtRest => 'Encriptación en Reposo';

  @override
  String get encryptionAtRestDescription =>
      'Cuando tus datos se almacenan en nuestros servidores, están protegidos por:\n\n**Encriptación AES-256** El estándar de oro para encriptación de datos.\n**Claves de encriptación rotativas** Las claves se cambian periódicamente para mayor seguridad.\n**Almacenamiento distribuido** Los datos se fragmentan y almacenan en múltiples ubicaciones seguras.\n**Acceso restringido** Solo personal autorizado con propósito legítimo puede acceder a los sistemas.\n\nIncluso nuestro propio personal técnico no puede leer tus conversaciones sin procesos de autorización apropiados.';

  @override
  String get passwordProtection => 'Protección de Contraseñas';

  @override
  String get passwordProtectionDescription =>
      'Tu contraseña recibe un tratamiento de seguridad especial:\n\n**Hashing con sal** Tu contraseña nunca se almacena en texto plano.\n**Algoritmo bcrypt** Usado por bancos y organizaciones de alta seguridad.\n**Múltiples rondas de hash** Hace que descifrar la contraseña sea computacionalmente prohibitivo.\n**Detección de brechas** Monitoreo continuo para detectar intentos de acceso no autorizado.\n\nNi siquiera nosotros podemos ver tu contraseña real. Si la olvidas, solo podemos ayudarte a crear una nueva.';

  @override
  String get dataStorageAndLocation => 'Almacenamiento y Ubicación de Datos';

  @override
  String get whereYourDataIsStored => 'Dónde se Almacenan Tus Datos';

  @override
  String get whereYourDataIsStoredDescription =>
      'Tus datos se almacenan en infraestructura de nube empresarial con las más altas certificaciones de seguridad:\n\n**Centros de datos certificados** ISO 27001, SOC 2 Type II, y otros estándares internacionales.\n**Ubicación geográfica** Servidores en Europa (cumplimiento GDPR) y América.\n**Redundancia geográfica** Respaldos en múltiples ubicaciones para prevenir pérdida de datos.\n**Alta disponibilidad** 99.9% de tiempo de actividad garantizado.\n\nTrabajamos solo con proveedores de nube que cumplen con las regulaciones de salud más estrictas.';

  @override
  String get dataRetention => 'Retención de Datos';

  @override
  String get dataRetentionDescription =>
      'Establecemos períodos claros para cuánto tiempo retenemos tu información:\n\n**Conversaciones médicas** Retenidas mientras mantengas tu cuenta activa.\n**Datos de cuenta** Mantenidos hasta que solicites la eliminación.\n**Registros técnicos** Eliminados automáticamente después de 90 días.\n**Datos de análisis anónimos** Retenidos indefinidamente para mejora del servicio.\n\nPuedes solicitar la eliminación completa de todos tus datos en cualquier momento.';

  @override
  String get dataBackups => 'Respaldos de Datos';

  @override
  String get dataBackupsDescription =>
      'Para proteger tus datos contra pérdida accidental:\n\n**Respaldos diarios automáticos** Realizados automáticamente.\n**Respaldos distribuidos** Almacenados en múltiples ubicaciones geográficas.\n**Respaldos encriptados** Todos los respaldos mantienen el mismo nivel de encriptación.\n**Retención limitada** Los respaldos se eliminan después de 30 días.\n\nEsto garantiza que nunca pierdas tu historial médico, incluso en caso de fallas técnicas.';

  @override
  String get yourRightsAndControl => 'Tus Derechos y Control Sobre Tus Datos';

  @override
  String get rightOfAccess => 'Derecho de Acceso';

  @override
  String get rightOfAccessDescription =>
      'Tienes el derecho completo de acceder a todos los datos que tenemos sobre ti:\n\n**Descarga completa** Puedes descargar todos tus datos en formato legible.\n**Historial detallado** Acceso a todas tus conversaciones y metadatos.\n**Información de cuenta** Todos los datos asociados con tu perfil.\n**Registros de actividad** Registro de cuándo y cómo se han usado tus datos.\n\nPuedes solicitar esta información en cualquier momento desde tu perfil o contactándonos directamente.';

  @override
  String get rightOfRectification => 'Derecho de Rectificación';

  @override
  String get rightOfRectificationDescription =>
      'Puedes corregir cualquier información incorrecta:\n\n**Datos de perfil** Modificar nombre, preferencias, etc., directamente desde la app.\n**Preferencias médicas** Actualizar alergias, medicamentos, condiciones en cualquier momento.\n**Corrección de conversaciones** Solicitar correcciones de información médica mal interpretada.\n**Actualización automática** Los cambios se aplican inmediatamente a todas las conversaciones futuras.\n\nMantener tus datos actualizados ayuda a DocAI a proporcionarte las mejores recomendaciones.';

  @override
  String get rightOfErasure => 'Derecho de Eliminación';

  @override
  String get rightOfErasureDescription =>
      'Puedes eliminar tus datos parcial o completamente:\n\n**Eliminación de conversación específica** Desde el historial de chat.\n**Limpieza completa del historial** Eliminar todas las conversaciones manteniendo la cuenta.\n**Eliminación completa de cuenta** Eliminación permanente de todos los datos.\n**Proceso de 30 días** Período de gracia para recuperar datos eliminados accidentalmente.\n\nUna vez que el proceso de eliminación esté completo, los datos no pueden ser recuperados.';

  @override
  String get rightOfPortability => 'Derecho de Portabilidad';

  @override
  String get rightOfPortabilityDescription =>
      'Puedes llevar tus datos a otro servicio:\n\n**Formato estándar** Exportar en JSON, CSV, o PDF.\n**Datos completos** Incluye conversaciones, preferencias y metadatos.\n**Proceso simple** Descarga disponible desde configuración de cuenta.\n**Sin restricciones** No cobramos ni limitamos las exportaciones de datos.\n\nTu información te pertenece y puedes llevarla contigo cuando desees.';

  @override
  String get additionalSecurityMeasures => 'Medidas de Seguridad Adicionales';

  @override
  String get security247Monitoring => 'Monitoreo de Seguridad 24/7';

  @override
  String get security247MonitoringDescription =>
      'Protegemos tus datos con vigilancia constante:\n\n**Detección de anomalías** Sistemas de IA que identifican patrones sospechosos.\n**Alertas en tiempo real** Notificación inmediata de cualquier actividad inusual.\n**Equipo de respuesta** Especialistas en seguridad disponibles las 24 horas del día.\n**Auditorías regulares** Revisiones mensuales de todos los sistemas de seguridad.\n\nCualquier amenaza potencial se identifica y neutraliza antes de que pueda afectar tus datos.';

  @override
  String get authenticationAccessControl => 'Autenticación y Control de Acceso';

  @override
  String get authenticationAccessControlDescription =>
      'Múltiples capas de protección para tu cuenta:\n\n**Autenticación multifactor disponible** Protección adicional opcional para tu cuenta.\n**Sesiones seguras** Tokens de sesión que expiran automáticamente.\n**Detección de dispositivos** Alertas cuando se accede desde nuevos dispositivos.\n**Bloqueo de intentos fallidos** Protección contra ataques de fuerza bruta.\n\nTu cuenta está protegida incluso si tu contraseña se ve comprometida.';

  @override
  String get regulatoryCompliance => 'Cumplimiento Regulatorio';

  @override
  String get regulatoryComplianceDescription =>
      'Cumplimos con las regulaciones de privacidad más estrictas:\n\n**GDPR (Europa)** Reglamento General de Protección de Datos.\n**HIPAA (Estados Unidos)** Ley de Portabilidad y Responsabilidad del Seguro de Salud.\n**PIPEDA (Canadá)** Ley de Protección de Información Personal y Documentos Electrónicos.\n**Auditorías independientes** Certificaciones anuales por terceros.\n\nNuestras prácticas de privacidad son verificadas por auditores externos especializados en salud digital.';

  @override
  String get contactAndSupport => 'Contacto y Soporte';

  @override
  String get privacyQuestions => 'Preguntas sobre Privacidad';

  @override
  String get privacyQuestionsDescription =>
      'Si tienes alguna pregunta sobre cómo manejamos tus datos:\n\n**Email de privacidad** privacy@docai.app\n**Tiempo de respuesta** Máximo 48 horas.\n**Oficial de Protección de Datos** Disponible para consultas específicas.\n**Chat en vivo** Soporte inmediato durante horario comercial.\n\nNuestro equipo de privacidad está especializado en responder todas tus inquietudes sobre datos personales.';

  @override
  String get reportSecurityIssues => 'Reportar Problemas de Seguridad';

  @override
  String get reportSecurityIssuesDescription =>
      'Si descubres un problema de seguridad, contáctanos inmediatamente:\n\n**Email de seguridad** security@docai.app\n**Programa de recompensas por errores** Recompensas por descubrimiento de vulnerabilidades.\n**Divulgación responsable** Proceso establecido para reportar problemas.\n**Respuesta garantizada** Confirmación en menos de 24 horas.\n\nTu ayuda para mantener DocAI seguro es invaluable y siempre reconocida.';

  @override
  String get quickAccess => 'Accesos rápidos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get share => 'Compartir';

  @override
  String get backup => 'Backup';

  @override
  String get consultations => 'Consultas';

  @override
  String get lastUsage => 'Último uso';

  @override
  String get satisfaction => 'Satisfacción';

  @override
  String get never => 'Nunca';

  @override
  String get configureMedicalInfo => 'Configura tu información médica';

  @override
  String get enjoyAllFeatures => 'Disfruta de todas las funciones';

  @override
  String get manage => 'Gestionar';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get changeAppLanguage => 'Cambiar idioma de la app';

  @override
  String get privacyAndSecuritySettings => 'Privacidad y seguridad';

  @override
  String get helpCenter => 'Centro de ayuda';

  @override
  String get projectInformation => 'Información del proyecto';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountDescription =>
      'Eliminar permanentemente tu cuenta y todos los datos asociados';

  @override
  String get dangerous => 'Peligroso';

  @override
  String get quickSettings => 'Configuración rápida';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get location => 'Ubicación';

  @override
  String get selectLanguageTitle => 'Seleccionar idioma';

  @override
  String get premiumPlanTitle => 'Plan Premium';

  @override
  String get unlimitedConsultationsFeature => 'Consultas ilimitadas';

  @override
  String get priorityAccess => 'Acceso prioritario';

  @override
  String get completeHistory => 'Historial completo';

  @override
  String get premiumSupport => 'Soporte premium';

  @override
  String get cancelPlan => 'Cancelar plan';

  @override
  String get cloudSyncTitle => 'Sincronizar con la Nube';

  @override
  String get syncCompleteTitle => 'Sincronización Completada';

  @override
  String get syncingTitle => 'Sincronizando...';

  @override
  String get syncCompleteDescription =>
      'Tu historial se ha sincronizado correctamente con la nube. Ahora puedes acceder a él desde cualquier dispositivo.';

  @override
  String get syncingDescription =>
      'Estamos guardando tu historial de forma segura en la nube...';

  @override
  String get cloudSyncDescription =>
      'Respalda tu historial de conversaciones en la nube para mantenerlo seguro y accesible desde cualquier dispositivo.';

  @override
  String get security => 'Seguridad';

  @override
  String get endToEndEncryption => 'Encriptación de extremo a extremo';

  @override
  String get multiDevice => 'Multi-dispositivo';

  @override
  String get accessFromAnywhere => 'Accede desde cualquier lugar';

  @override
  String get automaticBackup => 'Respaldo Automático';

  @override
  String get continuousSync => 'Sincronización continua';

  @override
  String get syncNow => 'Sincronizar Ahora';

  @override
  String get notNowButton => 'Ahora No';

  @override
  String get historySyncedSuccessfully => 'Historial sincronizado exitosamente';

  @override
  String get typeYourMedicalQuery => 'Escribe tu consulta médica...';

  @override
  String get generatingResponseMessage => 'Generando respuesta...';

  @override
  String get send => 'Enviar';

  @override
  String get cancelGeneration => 'Cancelar';

  @override
  String get scrollToBottom => 'Ir al final';

  @override
  String get reasoning => 'Razonamiento';

  @override
  String get medicalDisclaimerCardText =>
      'DocAI no reemplaza el consejo médico profesional. La información proporcionada es con fines educativos. Para diagnósticos, tratamientos o emergencias consulta a un profesional de la salud.';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mié';

  @override
  String get thursday => 'Jue';

  @override
  String get friday => 'Vie';

  @override
  String get saturday => 'Sáb';

  @override
  String get sunday => 'Dom';

  @override
  String get deleteConversationConfirm =>
      '¿Estás seguro de que quieres eliminar esta conversación?';

  @override
  String get medicalPersonalizationTitle => 'Personalización Médica';

  @override
  String get importantNotice => 'Aviso Importante';

  @override
  String get docaiDisclaimer =>
      'DocAI no sustituye el consejo médico profesional. La información proporcionada tiene fines educativos. Para diagnósticos, tratamientos o emergencias consulta a un profesional de la salud.';

  @override
  String get dateOfBirth => 'Fecha de Nacimiento';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get preferNotToSay => 'Prefiero no decir';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get heightCm => 'Altura (cm)';

  @override
  String get allergiesAndIntolerances => 'Alergias e Intolerancias';

  @override
  String get generalAllergies => 'Alergias Generales';

  @override
  String get medicationAllergies => 'Alergias a Medicamentos';

  @override
  String get foodIntolerances => 'Intolerancias Alimentarias';

  @override
  String get treatmentPreferences => 'Preferencias de Tratamiento';

  @override
  String get both => 'Ambas';

  @override
  String get medicationsToAvoid => 'Medicamentos a Evitar';

  @override
  String get preferredTreatments => 'Tratamientos Preferidos';

  @override
  String get previousSurgeries => 'Cirugías Previas';

  @override
  String get smokingHabit => 'Hábito de Fumar';

  @override
  String get formerSmoker => 'Ex-fumador';

  @override
  String get lightSmoker => 'Fumador ligero';

  @override
  String get moderateSmoker => 'Fumador moderado';

  @override
  String get heavySmoker => 'Fumador intenso';

  @override
  String get alcoholConsumption => 'Consumo de Alcohol';

  @override
  String get occasional => 'Ocasional';

  @override
  String get frequent => 'Frecuente';

  @override
  String get daily => 'Diario';

  @override
  String get exerciseFrequency => 'Frecuencia de Ejercicio';

  @override
  String get intense => 'Intenso';

  @override
  String get dietType => 'Tipo de Dieta';

  @override
  String get omnivore => 'Omnívora';

  @override
  String get vegetarian => 'Vegetariana';

  @override
  String get vegan => 'Vegana';

  @override
  String get pescatarian => 'Pescatariana';

  @override
  String get keto => 'Cetogénica';

  @override
  String get mediterranean => 'Mediterránea';

  @override
  String get emergencyContact => 'Contacto de Emergencia';

  @override
  String get contactName => 'Nombre del Contacto';

  @override
  String get emergencyPhone => 'Teléfono de Emergencia';

  @override
  String get additionalPreferences => 'Preferencias Adicionales';

  @override
  String get preferredLanguage => 'Idioma Preferido';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get catalan => 'Catalán';

  @override
  String get french => 'Francés';

  @override
  String get german => 'Alemán';

  @override
  String get communicationStyle => 'Estilo de Comunicación';

  @override
  String get direct => 'Directo';

  @override
  String get detailed => 'Detallado';

  @override
  String get gentle => 'Suave';

  @override
  String get other => 'Otro';

  @override
  String get lifestyle => 'Estilo de Vida';

  @override
  String get moderate => 'Moderado';

  @override
  String get none => 'Ninguno';

  @override
  String get light => 'Ligero';

  @override
  String get balanced => 'Balanceado';

  @override
  String get maintenanceMode => 'Modo de mantenimiento';

  @override
  String get maintenanceModeMessage =>
      'El chat está temporalmente deshabilitado por mantenimiento. Por favor, inténtalo más tarde.';
}
