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
  String get medicalDisclaimerCard =>
      'DocAI does not replace professional medical advice. The information provided is for educational purposes. For diagnoses, treatments or emergencies consult a healthcare professional.';

  @override
  String get customizeYourExperience => 'Customize your experience';

  @override
  String get updateYourInformation => 'Update your information';

  @override
  String get manageYourAlerts => 'Manage your alerts';

  @override
  String get privacySecuritySettings => 'Privacy & security settings';

  @override
  String get getHelpWhenYouNeedIt => 'Get help when you need it';

  @override
  String get learnMoreAboutDocAI => 'Learn more about DocAI';

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

  @override
  String get privacyAndSecurity => 'Privacy and Security';

  @override
  String get yourPrivacyIsOurPriority => 'Your Privacy is Our Priority';

  @override
  String get privacyIntroduction =>
      'At DocAI, we understand the importance of protecting your health information. This section explains how we collect, process and protect your personal data.';

  @override
  String get dataWeCollect => 'Data we collect';

  @override
  String get requiredAccountData => 'Account Data (Required)';

  @override
  String get requiredAccountDataDescription =>
      'To use DocAI, we need to collect certain basic information that is essential for the service to function:\n\n**Email address** To create your account, authentication, and important communications.\n**Password** Stored securely with hash to protect your account.\n**Account creation date** For auditing and technical support purposes.\n\nThis data is absolutely necessary to provide you with the service and cannot be optional.';

  @override
  String get conversationData => 'Conversation Data';

  @override
  String get conversationDataDescription =>
      'All conversations you have with DocAI are stored for:\n\n**Service continuity** To maintain the context of your medical consultations.\n**Personalized medical history** Offer more accurate recommendations based on your history.\n**Service improvement** Analyze patterns to improve responses anonymously.\n\nEach message includes:\nMessage content\nDate and time\nType of consultation\nResponse generated by AI';

  @override
  String get technicalData => 'Technical Data';

  @override
  String get technicalDataDescription =>
      'To ensure security and optimal service operation, we automatically collect:\n\n**IP address** To prevent abuse and detect suspicious activity.\n**Device information** Device type, operating system, app version.\n**Usage data** Usage frequency, functions used, session times.\n**Error logs** To identify and solve technical problems.\n\nThis information is collected automatically and is necessary for the secure operation of the service.';

  @override
  String get optionalDataYouChoose => 'Optional Data (You Choose)';

  @override
  String get medicalPreferencesData => 'Medical Preferences';

  @override
  String get medicalPreferencesDataDescription =>
      'To personalize your experience and offer more accurate recommendations, you can choose to share:\n\n**Known allergies** To avoid recommendations for medications or treatments that could cause reactions.\n**Chronic medical conditions** Diabetes, hypertension, etc., to contextualize recommendations.\n**Current medications** To detect possible drug interactions.\n**Treatment preferences** Natural vs. conventional.\n**Age range and gender** For more specific recommendations.\n\n**IMPORTANT** All this information is completely optional. You can use DocAI without providing any of this data.';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get profileInformationDescription =>
      'Optionally, you can complete your profile with:\n\n**Full name** To personalize the experience.\n**Profile photo** Only stored locally on your device.\n**Language preferences** To adapt the interface.\n**Notification settings** To control alerts.\n\nAll this information is optional and can be modified or deleted at any time from your profile.';

  @override
  String get howWeProcessYourData => 'How We Process Your Data';

  @override
  String get medicalConsultationProcessing => 'Medical Consultation Processing';

  @override
  String get medicalConsultationProcessingDescription =>
      'When you make a medical consultation to DocAI:\n\n1. Your message is sent securely to our servers using **TLS 1.3** encryption.\n2. It is combined with your medical history (if it exists) to provide context.\n3. Your medical preferences (if you have provided them) are incorporated to personalize the response.\n4. It is processed by specialized medical AI that has been trained with verified medical knowledge.\n5. The response is generated and encrypted before being sent back to your device.\n\nThis entire process occurs in real-time and is designed to protect your privacy at every step.';

  @override
  String get serviceAnalysisImprovement => 'Analysis and Service Improvement';

  @override
  String get serviceAnalysisImprovementDescription =>
      'To continuously improve DocAI, we perform data analysis anonymously:\n\n**Consultation patterns** We identify the most common types of questions to improve responses.\n**Response effectiveness** We analyze which responses are most useful.\n**Technical performance** We monitor response times and errors.\n**Health trends** We identify emerging health topics in an aggregated and anonymous manner.\n\n**IMPORTANT** This analysis is **ALWAYS** performed with anonymized data. Specific analyses will never be linked to your personal identity.';

  @override
  String get encryptionAndSecurity => 'Encryption and Security in Transit';

  @override
  String get encryptionInTransit => 'Encryption in Transit';

  @override
  String get encryptionInTransitDescription =>
      'All communication between your device and our servers is protected by multiple layers of security:\n\n**TLS 1.3 (Transport Layer Security)** The most advanced encryption protocol available.\n**Enterprise-grade SSL certificates** Validated by globally recognized certification authorities.\n**Perfect Forward Secrecy** Even if a future key is compromised, past communications remain secure.\n**HSTS (HTTP Strict Transport Security)** Ensures that all connections use HTTPS.\n\nThis means it is virtually impossible for third parties to intercept or read your data while it travels over the internet.';

  @override
  String get encryptionAtRest => 'Encryption at Rest';

  @override
  String get encryptionAtRestDescription =>
      'When your data is stored on our servers, it is protected by:\n\n**AES-256 encryption** The gold standard for data encryption.\n**Rotating encryption keys** Keys are changed periodically for greater security.\n**Distributed storage** Data is fragmented and stored in multiple secure locations.\n**Restricted access** Only authorized personnel with legitimate purpose can access the systems.\n\nEven our own technical staff cannot read your conversations without appropriate authorization processes.';

  @override
  String get passwordProtection => 'Password Protection';

  @override
  String get passwordProtectionDescription =>
      'Your password receives special security treatment:\n\n**Salted hashing** Your password is never stored in plain text.\n**bcrypt algorithm** Used by banks and high-security organizations.\n**Multiple hash rounds** Makes decrypting the password computationally prohibitive.\n**Breach detection** Continuous monitoring to detect unauthorized access attempts.\n\nNot even we can see your real password. If you forget it, we can only help you create a new one.';

  @override
  String get dataStorageAndLocation => 'Data Storage and Location';

  @override
  String get whereYourDataIsStored => 'Where Your Data is Stored';

  @override
  String get whereYourDataIsStoredDescription =>
      'Your data is stored in enterprise cloud infrastructure with the highest security certifications:\n\n**Certified data centers** ISO 27001, SOC 2 Type II, and other international standards.\n**Geographic location** Servers in Europe (GDPR compliance) and America.\n**Geographic redundancy** Backups in multiple locations to prevent data loss.\n**High availability** 99.9% uptime guaranteed.\n\nWe work only with cloud providers that comply with the strictest health regulations.';

  @override
  String get dataRetention => 'Data Retention';

  @override
  String get dataRetentionDescription =>
      'We establish clear periods for how long we retain your information:\n\n**Medical conversations** Retained while you maintain your active account.\n**Account data** Maintained until you request deletion.\n**Technical logs** Automatically deleted after 90 days.\n**Anonymous analysis data** Retained indefinitely for service improvement.\n\nYou can request complete deletion of all your data at any time.';

  @override
  String get dataBackups => 'Data Backups';

  @override
  String get dataBackupsDescription =>
      'To protect your data against accidental loss:\n\n**Automatic daily backups** Performed automatically.\n**Distributed backups** Stored in multiple geographic locations.\n**Encrypted backups** All backups maintain the same level of encryption.\n**Limited retention** Backups are deleted after 30 days.\n\nThis ensures you never lose your medical history, even in case of technical failures.';

  @override
  String get yourRightsAndControl => 'Your Rights and Control Over Your Data';

  @override
  String get rightOfAccess => 'Right of Access';

  @override
  String get rightOfAccessDescription =>
      'You have the complete right to access all the data we have about you:\n\n**Complete download** You can download all your data in readable format.\n**Detailed history** Access to all your conversations and metadata.\n**Account information** All data associated with your profile.\n**Activity logs** Record of when and how your data has been used.\n\nYou can request this information at any time from your profile or by contacting us directly.';

  @override
  String get rightOfRectification => 'Right of Rectification';

  @override
  String get rightOfRectificationDescription =>
      'You can correct any incorrect information:\n\n**Profile data** Modify name, preferences, etc., directly from the app.\n**Medical preferences** Update allergies, medications, conditions at any time.\n**Conversation correction** Request corrections of misinterpreted medical information.\n**Automatic update** Changes are applied immediately to all future conversations.\n\nKeeping your data up to date helps DocAI provide you with the best recommendations.';

  @override
  String get rightOfErasure => 'Right of Erasure';

  @override
  String get rightOfErasureDescription =>
      'You can delete your data partially or completely:\n\n**Specific conversation deletion** From chat history.\n**Complete history cleanup** Delete all conversations while maintaining the account.\n**Complete account deletion** Permanent deletion of all data.\n**30-day process** Grace period to recover accidentally deleted data.\n\nOnce the deletion process is complete, data cannot be recovered.';

  @override
  String get rightOfPortability => 'Right of Portability';

  @override
  String get rightOfPortabilityDescription =>
      'You can take your data to another service:\n\n**Standard format** Export in JSON, CSV, or PDF.\n**Complete data** Includes conversations, preferences, and metadata.\n**Simple process** Download available from account settings.\n**No restrictions** We do not charge or limit data exports.\n\nYour information belongs to you and you can take it with you whenever you wish.';

  @override
  String get additionalSecurityMeasures => 'Additional Security Measures';

  @override
  String get security247Monitoring => '24/7 Security Monitoring';

  @override
  String get security247MonitoringDescription =>
      'We protect your data with constant vigilance:\n\n**Anomaly detection** AI systems that identify suspicious patterns.\n**Real-time alerts** Immediate notification of any unusual activity.\n**Response team** Security specialists available 24 hours a day.\n**Regular audits** Monthly reviews of all security systems.\n\nAny potential threat is identified and neutralized before it can affect your data.';

  @override
  String get authenticationAccessControl => 'Authentication and Access Control';

  @override
  String get authenticationAccessControlDescription =>
      'Multiple layers of protection for your account:\n\n**Multi-factor authentication available** Optional additional protection for your account.\n**Secure sessions** Session tokens that expire automatically.\n**Device detection** Alerts when accessed from new devices.\n**Failed attempt blocking** Protection against brute force attacks.\n\nYour account is protected even if your password is compromised.';

  @override
  String get regulatoryCompliance => 'Regulatory Compliance';

  @override
  String get regulatoryComplianceDescription =>
      'We comply with the strictest privacy regulations:\n\n**GDPR (Europe)** General Data Protection Regulation.\n**HIPAA (United States)** Health Insurance Portability and Accountability Act.\n**PIPEDA (Canada)** Personal Information Protection and Electronic Documents Act.\n**Independent audits** Annual certifications by third parties.\n\nOur privacy practices are verified by external auditors specialized in digital health.';

  @override
  String get contactAndSupport => 'Contact and Support';

  @override
  String get privacyQuestions => 'Privacy Questions';

  @override
  String get privacyQuestionsDescription =>
      'If you have any questions about how we handle your data:\n\n**Privacy email** privacy@docai.app\n**Response time** Maximum 48 hours.\n**Data Protection Officer** Available for specific consultations.\n**Live chat** Immediate support during business hours.\n\nOur privacy team is specialized in answering all your personal data concerns.';

  @override
  String get reportSecurityIssues => 'Report Security Issues';

  @override
  String get reportSecurityIssuesDescription =>
      'If you discover a security issue, contact us immediately:\n\n**Security email** security@docai.app\n**Bug bounty program** Rewards for vulnerability discoveries.\n**Responsible disclosure** Established process for reporting issues.\n**Guaranteed response** Confirmation in less than 24 hours.\n\nYour help in keeping DocAI secure is invaluable and always recognized.';
}
