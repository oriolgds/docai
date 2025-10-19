import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../services/user_stats_service.dart';
import '../../widgets/medical_preferences_button.dart';
import '../../widgets/medical_preferences_status.dart';
import '../../widgets/share_modal.dart';
import '../auth/login_screen.dart';
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

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  final UserStatsService _statsService = UserStatsService();
  UserStats? _userStats;
  bool _isLoadingStats = true;

  // BYOK state
  bool _hasApiKey = false;
  String? _apiKeyLastUpdated;

  // Scroll key for API key section
  final GlobalKey _apiKeySectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuart,
          ),
        );

    _animationController.forward();
    _loadUserStats();
    _loadApiKeyStatus();

    // Scroll to API key section if requested
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
        // Animar estadísticas después de cargar
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _statsAnimationController.forward();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userStats = UserStats.empty();
          _isLoadingStats = false;
        });
        _statsAnimationController.forward();
      }
    }
  }

  Future<void> _loadApiKeyStatus() async {
    try {
      final hasKey = await SupabaseService.hasUserApiKey('openrouter');
      final keys = await SupabaseService.getUserApiKeys();
      final openRouterKey = keys
          .where((k) => k['provider'] == 'openrouter')
          .firstOrNull;

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
        alignment: 0.1, // Align slightly below the top
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D1F),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _navigateToSettings(context, l10n, localeProvider),
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF6F767E),
              size: 24,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadUserStats();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Header
                      _buildProfileHeader(l10n),
                      const SizedBox(height: 24),

                      // Stats Section
                      _buildStatsSection(l10n),
                      const SizedBox(height: 24),

                      // API Key Section
                      _buildApiKeySection(l10n),
                      const SizedBox(height: 16),

                      // Medical Section
                      _buildMedicalSection(l10n),
                      const SizedBox(height: 24),

                      // Menu Items
                      _buildMenuItems(l10n, localeProvider),
                      const SizedBox(height: 16),

                      // Danger Zone
                      _buildDangerZone(l10n),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getUserInitials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SupabaseService.currentUser?.userMetadata?['full_name'] ??
                      l10n.user,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SupabaseService.currentUser?.email ?? l10n.noEmail,
                  style: const TextStyle(
                    color: Color(0xFF6F767E),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Edit Button
          IconButton(
            onPressed: () => _showEditProfileDialog(l10n),
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: Color(0xFF6F767E),
            ),
            tooltip: 'Editar perfil',
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
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D1F),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  _isLoadingStats
                      ? '...'
                      : '${_userStats?.totalConversations ?? 0}',
                  l10n.consultations,
                  Icons.chat_bubble_outline,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE9ECEF),
              ),
              Expanded(
                child: _buildStatItem(
                  _isLoadingStats
                      ? '...'
                      : (_userStats?.formattedLastActivity ?? l10n.never),
                  l10n.lastUsage,
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6F767E), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D1F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6F767E),
            ),
            textAlign: TextAlign.center,
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
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                color: const Color(0xFF6F767E),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.medicalPreferences,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1D1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.configureMedicalInfo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F767E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                    backgroundColor: const Color(0xFF4A90E2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
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
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.vpn_key_outlined,
                color: const Color(0xFF6F767E),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OpenRouter API Key',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1D1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hasApiKey
                          ? 'Tu clave API está configurada'
                          : 'Configura tu clave para usar DocAI',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F767E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_hasApiKey) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Configurada ${_apiKeyLastUpdated != null ? '• ${_formatDate(_apiKeyLastUpdated!)}' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showApiKeyDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6F767E),
                      side: const BorderSide(color: Color(0xFFE9ECEF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cambiar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _removeApiKey,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53E3E),
                      side: const BorderSide(color: Color(0xFFE9ECEF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showApiKeyDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Configurar API Key',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItems(
    AppLocalizations l10n,
    LocaleProvider? localeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: l10n.history,
            onTap: _navigateToHistoryTab,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.cloud_upload_outlined,
            title: l10n.backup,
            onTap: _navigateToBackupTab,
          ),
          _buildDivider(),
          _buildLanguageMenuItem(l10n, localeProvider),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security,
            title: l10n.privacySecurity,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: l10n.helpSupport,
            onTap: _navigateToHelpSupport,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.share_outlined,
            title: l10n.share,
            onTap: () => ShareModal.show(context),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: l10n.about,
            onTap: _navigateToAbout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6F767E),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1D1F),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9A9FA5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageMenuItem(
    AppLocalizations l10n,
    LocaleProvider? localeProvider,
  ) {
    if (localeProvider == null) {
      return _buildMenuItem(
        icon: Icons.language,
        title: l10n.languageSettings,
        onTap: () {},
      );
    }

    final currentLocale = Localizations.localeOf(context);
    final languages = {
      'en': 'English',
      'es': 'Español'
    };

    return PopupMenuButton<String>(
      offset: const Offset(0, 0),
      onSelected: (languageCode) {
        final newLocale = Locale(languageCode);
        localeProvider.onLocaleChanged(newLocale);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageCode == 'es'
                  ? 'Idioma cambiado a ${languages[languageCode]}'
                  : languageCode == 'ca'
                      ? 'Idioma canviat a ${languages[languageCode]}'
                      : 'Language changed to ${languages[languageCode]}',
            ),
            backgroundColor: const Color(0xFF4A90E2),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      itemBuilder: (context) => languages.entries.map((entry) {
        final isSelected = entry.key == currentLocale.languageCode;
        return PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Color(0xFF4A90E2),
                  size: 20,
                )
              else
                const SizedBox(width: 20),
              const SizedBox(width: 12),
              Text(
                entry.value,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF4A90E2)
                      : const Color(0xFF1A1D1F),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(
              Icons.language,
              color: Color(0xFF6F767E),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.languageSettings,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1D1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    languages[currentLocale.languageCode] ?? 'English',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6F767E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.expand_more,
              color: Color(0xFF9A9FA5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF5F7FA),
      indent: 52,
    );
  }

  Widget _buildDangerZone(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zona de peligro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D1F),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context, l10n),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53E3E),
                side: const BorderSide(color: Color(0xFFE9ECEF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                l10n.logout,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _navigateToAccountDeletion(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53E3E),
                side: const BorderSide(color: Color(0xFFFFE5E5)),
                backgroundColor: const Color(0xFFFFF5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                l10n.deleteAccount,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _getUserInitials() {
    final fullName = SupabaseService.currentUser?.userMetadata?['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName[0].toUpperCase();
    }
    final email = SupabaseService.currentUser?.email;
    return email != null && email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }

  void _showEditProfileDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'La funcionalidad de edición de perfil estará disponible próximamente.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6F767E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(
    BuildContext context,
    AppLocalizations l10n,
    LocaleProvider? localeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración rápida',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D1F),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.security, color: Color(0xFF6F767E)),
              title: Text(l10n.privacySecurity),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF9A9FA5)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Navigation methods using tabs
  void _navigateToHistoryTab() {
    if (widget.onNavigateToHistory != null) {
      widget.onNavigateToHistory!();
    }
  }

  void _navigateToBackupTab() {
    if (widget.onNavigateToHistory != null) {
      widget.onNavigateToHistory!();
    }
  }

  void _navigateToHelpSupport() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HelpSupportScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutQuart)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToAbout() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AboutScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutQuart)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // Navigation method for account deletion
  Future<void> _navigateToAccountDeletion(BuildContext context) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AccountDeletionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutQuart)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    // If account was deleted, the user should already be redirected to login
    // This is just a safety check
    if (result == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.logoutConfirmTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: const TextStyle(color: Color(0xFF6C757D), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontWeight: FontWeight.w500,
              ),
            ),
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
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.logout,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // BYOK methods
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'hoy';
      } else if (difference.inDays == 1) {
        return 'ayer';
      } else if (difference.inDays < 7) {
        return 'hace ${difference.inDays} días';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'desconocido';
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.vpn_key,
                  color: Color(0xFF6C5CE7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Configurar Clave API de OpenRouter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para usar DocAI, necesitas configurar tu propia clave API de OpenRouter. Esta se almacenará de forma segura y encriptada.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Clave API',
                  hintText: 'sk-or-v1-...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                child: Text(
                  '¿No tienes clave? Obtén una en OpenRouter',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
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
                        await SupabaseService.setUserApiKey(
                          'openrouter',
                          apiKey,
                        );
                        await _loadApiKeyStatus();

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Clave API configurada correctamente',
                              ),
                              backgroundColor: Color(0xFF00B894),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar clave: $e'),
                              backgroundColor: Color(0xFFE74C3C),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              backgroundColor: const Color(0xFFE74C3C),
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
            backgroundColor: Color(0xFF00B894),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar clave: $e'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    }
  }
}
