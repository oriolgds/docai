import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Privacidad y Seguridad',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 24),
                    _buildDataCollectionSection(),
                    const SizedBox(height: 24),
                    _buildOptionalDataSection(),
                    const SizedBox(height: 24),
                    _buildDataProcessingSection(),
                    const SizedBox(height: 24),
                    _buildEncryptionSection(),
                    const SizedBox(height: 24),
                    _buildDataStorageSection(),
                    const SizedBox(height: 24),
                    _buildUserRightsSection(),
                    const SizedBox(height: 24),
                    _buildSecurityMeasuresSection(),
                    const SizedBox(height: 24),
                    _buildContactSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE84393), Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE84393).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Tu Privacidad es Nuestra Prioridad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'En DocAI, entendemos la importancia de proteger tu información de salud. Esta sección explica cómo recopilamos, procesamos y protegemos tus datos personales.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCollectionSection() {
    return _buildSection(
      icon: Icons.data_usage,
      iconColor: const Color(0xFF6C5CE7),
      title: 'Datos que Recopilamos',
      content: [
        _buildSubSection(
          'Datos de Cuenta (Obligatorios)',
          'Para poder utilizar DocAI, necesitamos recopilar cierta información básica que es esencial para el funcionamiento del servicio:\n\n'
          '• **Dirección de correo electrónico**: Para crear tu cuenta, autenticación, y comunicaciones importantes\n'
          '• **Contraseña**: Almacenada de forma segura con hash para proteger tu cuenta\n'
          '• **Fecha de creación de cuenta**: Para fines de auditoría y soporte técnico\n\n'
          'Estos datos son absolutamente necesarios para proporcionarte el servicio y no pueden ser opcionales.',
        ),
        _buildSubSection(
          'Datos de Conversaciones',
          'Todas las conversaciones que mantienes con DocAI se almacenan para:\n\n'
          '• **Continuidad del servicio**: Poder mantener el contexto de tus consultas médicas\n'
          '• **Historial médico personalizado**: Ofrecer recomendaciones más precisas basadas en tu historial\n'
          '• **Mejora del servicio**: Analizar patrones para mejorar las respuestas (de forma anónima)\n\n'
          'Cada mensaje incluye:\n'
          '• Contenido del mensaje\n'
          '• Fecha y hora\n'
          '• Tipo de consulta\n'
          '• Respuesta generada por la IA',
        ),
        _buildSubSection(
          'Datos Técnicos',
          'Para garantizar la seguridad y funcionamiento óptimo del servicio, recopilamos automáticamente:\n\n'
          '• **Dirección IP**: Para prevenir abuso y detectar actividad sospechosa\n'
          '• **Información del dispositivo**: Tipo de dispositivo, sistema operativo, versión de la app\n'
          '• **Datos de uso**: Frecuencia de uso, funciones utilizadas, tiempos de sesión\n'
          '• **Logs de errores**: Para identificar y solucionar problemas técnicos\n\n'
          'Esta información se recopila automáticamente y es necesaria para la operación segura del servicio.',
        ),
      ],
    );
  }

  Widget _buildOptionalDataSection() {
    return _buildSection(
      icon: Icons.tune,
      iconColor: const Color(0xFF00B894),
      title: 'Datos Opcionales (Tu Eliges)',
      content: [
        _buildSubSection(
          'Preferencias Médicas',
          'Para personalizar tu experiencia y ofrecer recomendaciones más precisas, puedes optar por compartir:\n\n'
          '• **Alergias conocidas**: Para evitar recomendaciones de medicamentos o tratamientos que podrían causarte reacciones\n'
          '• **Condiciones médicas crónicas**: Diabetes, hipertensión, etc., para contextualizar las recomendaciones\n'
          '• **Medicamentos actuales**: Para detectar posibles interacciones medicamentosas\n'
          '• **Preferencias de tratamiento**: Natural vs. convencional\n'
          '• **Rango de edad y género**: Para recomendaciones más específicas\n\n'
          '**IMPORTANTE**: Toda esta información es completamente opcional. Puedes usar DocAI sin proporcionar ninguno de estos datos.',
        ),
        _buildSubSection(
          'Información de Perfil',
          'Opcionalmente, puedes completar tu perfil con:\n\n'
          '• **Nombre completo**: Para personalizar la experiencia\n'
          '• **Foto de perfil**: Solo se almacena localmente en tu dispositivo\n'
          '• **Preferencias de idioma**: Para adaptar la interfaz\n'
          '• **Configuraciones de notificaciones**: Para controlar las alertas\n\n'
          'Toda esta información es opcional y puede ser modificada o eliminada en cualquier momento desde tu perfil.',
        ),
      ],
    );
  }

  Widget _buildDataProcessingSection() {
    return _buildSection(
      icon: Icons.settings_applications,
      iconColor: const Color(0xFFFFB400),
      title: 'Cómo Procesamos tus Datos',
      content: [
        _buildSubSection(
          'Procesamiento de Consultas Médicas',
          'Cuando realizas una consulta médica a DocAI:\n\n'
          '1. **Tu mensaje se envía de forma segura** a nuestros servidores utilizando encriptación TLS 1.3\n'
          '2. **Se combina con tu historial médico** (si existe) para proporcionar contexto\n'
          '3. **Se incorporan tus preferencias médicas** (si las has proporcionado) para personalizar la respuesta\n'
          '4. **Se procesa mediante IA médica especializada** que ha sido entrenada con conocimiento médico verificado\n'
          '5. **La respuesta se genera y encripta** antes de enviarse de vuelta a tu dispositivo\n\n'
          'Todo este proceso ocurre en tiempo real y está diseñado para proteger tu privacidad en cada paso.',
        ),
        _buildSubSection(
          'Análisis y Mejora del Servicio',
          'Para mejorar continuamente DocAI, realizamos análisis de datos de forma anónima:\n\n'
          '• **Patrones de consultas**: Identificamos tipos de preguntas más comunes para mejorar respuestas\n'
          '• **Efectividad de respuestas**: Analizamos qué respuestas son más útiles\n'
          '• **Rendimiento técnico**: Monitoreamos tiempos de respuesta y errores\n'
          '• **Tendencias de salud**: Identificamos temas de salud emergentes (de forma agregada y anónima)\n\n'
          '**IMPORTANTE**: Este análisis se realiza SIEMPRE con datos anonimizados. Nunca se vincularán análisis específicos a tu identidad personal.',
        ),
      ],
    );
  }

  Widget _buildEncryptionSection() {
    return _buildSection(
      icon: Icons.lock,
      iconColor: const Color(0xFFE74C3C),
      title: 'Encriptación y Seguridad en Tránsito',
      content: [
        _buildSubSection(
          'Encriptación en Tránsito',
          'Toda la comunicación entre tu dispositivo y nuestros servidores está protegida por múltiples capas de seguridad:\n\n'
          '• **TLS 1.3 (Transport Layer Security)**: El protocolo de encriptación más avanzado disponible\n'
          '• **Certificados SSL de grado empresarial**: Validados por autoridades certificadoras reconocidas mundialmente\n'
          '• **Perfect Forward Secrecy**: Incluso si una clave futura se compromete, las comunicaciones pasadas permanecen seguras\n'
          '• **HSTS (HTTP Strict Transport Security)**: Garantiza que todas las conexiones usen HTTPS\n\n'
          'Esto significa que es prácticamente imposible que terceros intercepten o lean tus datos mientras viajan por internet.',
        ),
        _buildSubSection(
          'Encriptación en Reposo',
          'Cuando tus datos se almacenan en nuestros servidores, están protegidos por:\n\n'
          '• **Encriptación AES-256**: El estándar de oro para encriptación de datos\n'
          '• **Claves de encriptación rotativas**: Las claves se cambian periódicamente para mayor seguridad\n'
          '• **Almacenamiento distribuido**: Los datos se fragmentan y almacenan en múltiples ubicaciones seguras\n'
          '• **Acceso restringido**: Solo personal autorizado con propósito legítimo puede acceder a los sistemas\n\n'
          'Incluso nuestro propio personal técnico no puede leer tus conversaciones sin los procesos de autorización apropiados.',
        ),
        _buildSubSection(
          'Protección de Contraseñas',
          'Tu contraseña recibe un tratamiento especial de seguridad:\n\n'
          '• **Hash con sal (Salted Hashing)**: Tu contraseña nunca se almacena en texto plano\n'
          '• **Algoritmo bcrypt**: Utilizado por bancos y organizaciones de alta seguridad\n'
          '• **Múltiples rondas de hash**: Hace que descifrar la contraseña sea computacionalmente prohibitivo\n'
          '• **Detección de brechas**: Monitoreo continuo para detectar intentos de acceso no autorizados\n\n'
          'Ni siquiera nosotros podemos ver tu contraseña real. Si la olvidas, solo podemos ayudarte a crear una nueva.',
        ),
      ],
    );
  }

  Widget _buildDataStorageSection() {
    return _buildSection(
      icon: Icons.storage,
      iconColor: const Color(0xFF00CEC9),
      title: 'Almacenamiento y Ubicación de Datos',
      content: [
        _buildSubSection(
          'Dónde se Almacenan tus Datos',
          'Tus datos se almacenan en infraestructura de nube empresarial con las más altas certificaciones de seguridad:\n\n'
          '• **Centros de datos certificados**: ISO 27001, SOC 2 Type II, y otros estándares internacionales\n'
          '• **Ubicación geográfica**: Servidores en Europa (cumplimiento GDPR) y América\n'
          '• **Redundancia geográfica**: Copias de seguridad en múltiples ubicaciones para prevenir pérdida de datos\n'
          '• **Alta disponibilidad**: 99.9% de tiempo de actividad garantizado\n\n'
          'Trabajamos únicamente con proveedores de nube que cumplen con las regulaciones de salud más estrictas.',
        ),
        _buildSubSection(
          'Retención de Datos',
          'Establecemos períodos claros para cuánto tiempo conservamos tu información:\n\n'
          '• **Conversaciones médicas**: Se conservan mientras mantengas tu cuenta activa\n'
          '• **Datos de cuenta**: Se mantienen hasta que solicites la eliminación\n'
          '• **Logs técnicos**: Se eliminan automáticamente después de 90 días\n'
          '• **Datos anónimos de análisis**: Se conservan indefinidamente para mejora del servicio\n\n'
          'Puedes solicitar la eliminación completa de todos tus datos en cualquier momento.',
        ),
        _buildSubSection(
          'Copias de Seguridad',
          'Para proteger tus datos contra pérdidas accidentales:\n\n'
          '• **Copias automáticas diarias**: Se realizan de forma automática\n'
          '• **Copias distribuidas**: Almacenadas en múltiples ubicaciones geográficas\n'
          '• **Copias encriptadas**: Todas las copias mantienen el mismo nivel de encriptación\n'
          '• **Retención limitada**: Las copias se eliminan después de 30 días\n\n'
          'Esto garantiza que nunca pierdas tu historial médico, incluso en caso de fallas técnicas.',
        ),
      ],
    );
  }

  Widget _buildUserRightsSection() {
    return _buildSection(
      icon: Icons.account_balance,
      iconColor: const Color(0xFF6C5CE7),
      title: 'Tus Derechos y Control sobre tus Datos',
      content: [
        _buildSubSection(
          'Derecho de Acceso',
          'Tienes el derecho completo de acceder a todos los datos que tenemos sobre ti:\n\n'
          '• **Descarga completa**: Puedes descargar todos tus datos en formato legible\n'
          '• **Historial detallado**: Acceso a todas tus conversaciones y metadatos\n'
          '• **Información de cuenta**: Todos los datos asociados con tu perfil\n'
          '• **Logs de actividad**: Registro de cuándo y cómo se han utilizado tus datos\n\n'
          'Puedes solicitar esta información en cualquier momento desde tu perfil o contactándonos directamente.',
        ),
        _buildSubSection(
          'Derecho de Rectificación',
          'Puedes corregir cualquier información incorrecta:\n\n'
          '• **Datos de perfil**: Modificar nombre, preferencias, etc., directamente desde la app\n'
          '• **Preferencias médicas**: Actualizar alergias, medicamentos, condiciones en cualquier momento\n'
          '• **Corrección de conversaciones**: Solicitar correcciones de información médica mal interpretada\n'
          '• **Actualización automática**: Los cambios se aplican inmediatamente a todas las conversaciones futuras\n\n'
          'Mantener tus datos actualizados ayuda a DocAI a brindarte las mejores recomendaciones.',
        ),
        _buildSubSection(
          'Derecho de Eliminación',
          'Puedes eliminar tus datos parcial o completamente:\n\n'
          '• **Eliminación de conversaciones específicas**: Desde el historial de chat\n'
          '• **Limpieza de historial completo**: Eliminar todas las conversaciones manteniendo la cuenta\n'
          '• **Eliminación de cuenta completa**: Borrado permanente de todos los datos\n'
          '• **Proceso de 30 días**: Período de gracia para recuperar datos eliminados accidentalmente\n\n'
          'Una vez completado el proceso de eliminación, los datos no pueden ser recuperados.',
        ),
        _buildSubSection(
          'Derecho de Portabilidad',
          'Puedes llevarte tus datos a otro servicio:\n\n'
          '• **Formato estándar**: Exportación en JSON, CSV, o PDF\n'
          '• **Datos completos**: Incluye conversaciones, preferencias, y metadatos\n'
          '• **Proceso simple**: Descarga disponible desde configuraciones de cuenta\n'
          '• **Sin restricciones**: No cobramos ni limitamos las exportaciones de datos\n\n'
          'Tu información te pertenece y puedes llevártela cuando desees.',
        ),
      ],
    );
  }

  Widget _buildSecurityMeasuresSection() {
    return _buildSection(
      icon: Icons.shield,
      iconColor: const Color(0xFF00B894),
      title: 'Medidas de Seguridad Adicionales',
      content: [
        _buildSubSection(
          'Monitoreo de Seguridad 24/7',
          'Protegemos tus datos con vigilancia constante:\n\n'
          '• **Detección de anomalías**: Sistemas de IA que identifican patrones sospechosos\n'
          '• **Alertas en tiempo real**: Notificación inmediata de cualquier actividad inusual\n'
          '• **Equipo de respuesta**: Especialistas en seguridad disponibles las 24 horas\n'
          '• **Auditorías regulares**: Revisiones mensuales de todos los sistemas de seguridad\n\n'
          'Cualquier amenaza potencial se identifica y neutraliza antes de que pueda afectar tus datos.',
        ),
        _buildSubSection(
          'Autenticación y Control de Acceso',
          'Múltiples capas de protección para tu cuenta:\n\n'
          '• **Autenticación multifactor disponible**: Protección adicional opcional para tu cuenta\n'
          '• **Sesiones seguras**: Tokens de sesión que expiran automáticamente\n'
          '• **Detección de dispositivos**: Alertas cuando se accede desde dispositivos nuevos\n'
          '• **Bloqueo por intentos fallidos**: Protección contra ataques de fuerza bruta\n\n'
          'Tu cuenta está protegida incluso si tu contraseña se ve comprometida.',
        ),
        _buildSubSection(
          'Cumplimiento Normativo',
          'Cumplimos con las regulaciones de privacidad más estrictas:\n\n'
          '• **GDPR (Europa)**: Reglamento General de Protección de Datos\n'
          '• **HIPAA (Estados Unidos)**: Ley de Portabilidad y Responsabilidad del Seguro Médico\n'
          '• **PIPEDA (Canadá)**: Ley de Protección de Información Personal\n'
          '• **Auditorías independientes**: Certificaciones anuales por terceros\n\n'
          'Nuestras prácticas de privacidad son verificadas por auditores externos especializados en salud digital.',
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      icon: Icons.contact_support,
      iconColor: const Color(0xFFE84393),
      title: 'Contacto y Soporte',
      content: [
        _buildSubSection(
          'Preguntas sobre Privacidad',
          'Si tienes cualquier pregunta sobre cómo manejamos tus datos:\n\n'
          '• **Email de privacidad**: privacy@docai.app\n'
          '• **Tiempo de respuesta**: Máximo 48 horas\n'
          '• **Oficial de Protección de Datos**: Disponible para consultas específicas\n'
          '• **Chat en vivo**: Soporte inmediato durante horas hábiles\n\n'
          'Nuestro equipo de privacidad está especializado en responder todas tus inquietudes sobre datos personales.',
        ),
        _buildSubSection(
          'Reportar Problemas de Seguridad',
          'Si descubres un problema de seguridad, contáctanos inmediatamente:\n\n'
          '• **Email de seguridad**: security@docai.app\n'
          '• **Programa de bug bounty**: Recompensas por descubrimientos de vulnerabilidades\n'
          '• **Divulgación responsable**: Proceso establecido para reportar problemas\n'
          '• **Respuesta garantizada**: Confirmación en menos de 24 horas\n\n'
          'Tu ayuda para mantener DocAI seguro es invaluable y siempre es reconocida.',
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...content,
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}