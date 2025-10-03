import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '/l10n/generated/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String email = 'oriolginger2008@gmail.com';
  static const String phone = '+34 644881520';
  static const String whatsappUrl = 'https://wa.me/34644881520';

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:$email?subject=DocAI - Soporte');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado al portapapeles'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ayuda y Soporte',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black87, Colors.grey],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Soporte DocAI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estamos aquí para ayudarte',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact information
            const Text(
              'Información de Contacto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Email card
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: 'Correo Electrónico',
              subtitle: email,
              description: 'Envíanos un email para consultas generales',
              onTap: _launchEmail,
              onLongPress: () => _copyToClipboard(context, email, 'Email'),
            ),
            const SizedBox(height: 12),
            
            // Phone card
            _buildContactCard(
              context,
              icon: Icons.phone_outlined,
              title: 'Teléfono',
              subtitle: phone,
              description: 'Llámanos para soporte urgente',
              onTap: _launchPhone,
              onLongPress: () => _copyToClipboard(context, phone, 'Número de teléfono'),
            ),
            const SizedBox(height: 12),
            
            // WhatsApp card
            _buildContactCard(
              context,
              icon: Icons.chat_outlined,
              title: 'WhatsApp',
              subtitle: phone,
              description: 'Chatea con nosotros vía WhatsApp',
              onTap: _launchWhatsApp,
              onLongPress: () => _copyToClipboard(context, phone, 'Número de WhatsApp'),
            ),
            const SizedBox(height: 32),
            
            // FAQ Section
            const Text(
              'Preguntas Frecuentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFAQCard(
              question: '¿Cómo funciona DocAI?',
              answer: 'DocAI utiliza inteligencia artificial avanzada para proporcionar información médica personalizada. Simplemente haz tu consulta y recibirás una respuesta detallada.',
            ),
            const SizedBox(height: 12),
            
            _buildFAQCard(
              question: '¿Es seguro usar DocAI?',
              answer: 'Sí, DocAI está diseñado con las mejores prácticas de seguridad. Sin embargo, recuerda que es una herramienta de información y no reemplaza la consulta médica profesional.',
            ),
            const SizedBox(height: 12),
            
            _buildFAQCard(
              question: '¿Puedo usar DocAI sin conexión?',
              answer: 'Actualmente DocAI requiere conexión a internet para funcionar, ya que utiliza modelos de IA en la nube para proporcionar las mejores respuestas.',
            ),
            const SizedBox(height: 32),
            
            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Desarrollado con ♥ por Oriol Giner Díaz',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard({required String question, required String answer}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}