import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../services/user_stats_service.dart';
import '../../widgets/medical_preferences_button.dart';
import '../../widgets/medical_preferences_status.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/share_modal.dart';
import '../auth/login_screen.dart';
import '../medical_preferences_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import 'privacy_security_screen.dart';
import 'account_deletion_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;
  final VoidCallback? onNavigateToBackup;
  final bool scrollToApiKey;

  const ProfileScreen({
    super.key,
    this.onNavigateToHistory,
    this.onNavigateToBackup,
    this.scrollToApiKey = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserStatsService _statsService = UserStatsService();
  UserStats? _userStats;
  bool _isLoadingStats = true;
  bool _hasApiKey = false;
  bool _isVerifyingApiKey = false;
  String? _apiKeyLastUpdated;
  final GlobalKey _apiKeySectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserStats();
    _loadApiKeyStatus();

    if (widget.scrollToApiKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToApiKeySection();
      });
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await _statsService.getUserStats();
      if (mounted) {
        setState(() {
          _userStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userStats = UserStats.empty();
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadApiKeyStatus() async {
    try {
      final hasKey = await SupabaseService.hasUserApiKey('openrouter');
      final keys = await SupabaseService.getUserApiKeys();
      final openRouterKey = keys.where((k) => k['provider'] == 'openrouter').firstOrNull;

      if (mounted) {
        setState(() {
          _hasApiKey = hasKey;
          _apiKeyLastUpdated = openRouterKey?['updated_at'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasApiKey = false;
          _apiKeyLastUpdated = null;
        });
      }
    }
  }

  void _scrollToApiKeySection() {
    final context = _apiKeySectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserStats();
          await _loadApiKeyStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(l10n),
              const SizedBox(height: 24),
              _buildStatsSection(l10n),
              const SizedBox(height: 24),
              _buildApiKeySection(l10n),
              const SizedBox(height: 24),
              _buildMedicalSection(l10n),
              const SizedBox(height: 24),
              _buildSettingsSection(l10n, localeProvider),
              const SizedBox(height: 24),
              _buildDangerZone(l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (SupabaseService.currentUser?.email ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SupabaseService.currentUser?.userMetadata?['full_name'] ?? l10n.user,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SupabaseService.currentUser?.email ?? l10n.noEmail,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  l10n.consultations,
                  _isLoadingStats ? '...' : '${_userStats?.totalConversations ?? 0}',
                  Icons.chat_bubble_outline,
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
              Expanded(
                child: _buildStatItem(
                  l10n.lastUsage,
                  _isLoadingStats ? '...' : (_userStats?.formattedLastActivity ?? l10n.never),
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF2E7D32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySection(AppLocalizations l10n) {
    return Container(
      key: _apiKeySectionKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key, size: 20, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Clave API de OpenRouter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (_hasApiKey)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Configurada',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _hasApiKey
                ? 'Tu clave API está configurada y lista para usar'
                : 'Configura tu clave API para acceder a DocAI',
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 16),
          if (_hasApiKey) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isVerifyingApiKey ? null : _verifyApiKey,
                    icon: _isVerifyingApiKey
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified, size: 16),
                    label: Text(_isVerifyingApiKey ? 'Verificando...' : 'Verificar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showApiKeyDialog,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Cambiar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF757575),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _removeApiKey,
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Eliminar clave API'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showApiKeyDialog,
                icon: const Icon(Icons.vpn_key, size: 18),
                label: const Text('Configurar Clave API'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital, size: 20, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(
                l10n.medicalPreferences,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.configureMedicalInfo,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 16),
          const MedicalPreferencesStatus(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: MedicalPreferencesButton(
              onPreferencesUpdated: () {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.medicalPreferencesUpdated),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(AppLocalizations l10n, LocaleProvider? localeProvider) {
    final items = [
      _SettingItem(
        icon: Icons.language,
        title: l10n.languageSettings,
        onTap: () => _showLanguageSelector(context, localeProvider),
      ),
      _SettingItem(
        icon: Icons.share,
        title: l10n.share,
        onTap: () => ShareModal.show(context),
      ),
      _SettingItem(
        icon: Icons.security,
        title: l10n.privacySecurity,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
          );
        },
      ),
      _SettingItem(
        icon: Icons.help_outline,
        title: l10n.helpSupport,
        onTap: () => _navigateToHelpSupport(),
      ),
      _SettingItem(
        icon: FontAwesomeIcons.xTwitter,
        title: 'X (Twitter)',
        onTap: () async {
          final url = Uri.parse('https://x.com/docaiapp');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      ),
      _SettingItem(
        icon: Icons.info_outline,
        title: l10n.about,
        onTap: () => _navigateToAbout(),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, size: 20, color: const Color(0xFF757575)),
                title: Text(
                  item.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF757575)),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDangerZone(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Color(0xFFD32F2F)),
            title: Text(
              l10n.deleteAccount,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFFD32F2F)),
            onTap: () => _navigateToAccountDeletion(context),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context, l10n),
            icon: const Icon(Icons.logout, size: 18),
            label: Text(l10n.logout),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToHelpSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  Future<void> _navigateToAccountDeletion(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountDeletionScreen()),
    );

    if (result == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showLanguageSelector(BuildContext context, LocaleProvider? localeProvider) {
    if (localeProvider == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.selectLanguageTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            LanguageSelector(
              onLocaleChanged: (locale) {
                localeProvider.onLocaleChanged(locale);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) return 'hoy';
      if (difference.inDays == 1) return 'ayer';
      if (difference.inDays < 7) return 'hace ${difference.inDays} días';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'desconocido';
    }
  }

  Future<void> _verifyApiKey() async {
    setState(() => _isVerifyingApiKey = true);

    try {
      final result = await SupabaseService.client.functions.invoke(
        'verify-api-key',
        body: {
          'apiKey': await SupabaseService.getUserApiKey('openrouter'),
          'provider': 'openrouter',
        },
      );

      if (result.status == 200 && result.data?['valid'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clave API verificada correctamente'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La clave API no es válida'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar clave: $e'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifyingApiKey = false);
      }
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Configurar Clave API'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para usar DocAI, necesitas configurar tu propia clave API de OpenRouter.',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Clave API',
                  hintText: 'sk-or-v1-...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://openrouter.ai/keys');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text(
                  '¿No tienes clave? Obtén una en OpenRouter',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final apiKey = controller.text.trim();
                      if (apiKey.isEmpty) return;

                      setState(() => isLoading = true);

                      try {
                        await SupabaseService.setUserApiKey('openrouter', apiKey);
                        await _loadApiKeyStatus();

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Clave API configurada correctamente'),
                              backgroundColor: Color(0xFF2E7D32),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar clave: $e'),
                              backgroundColor: const Color(0xFFD32F2F),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Eliminar clave API'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu clave API? Ya no podrás usar DocAI hasta que configures una nueva clave.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService.deleteUserApiKey('openrouter');
        await _loadApiKeyStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clave API eliminada'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar clave: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
