import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../widgets/medical_preferences_button.dart';
import '../../widgets/medical_preferences_status.dart';
import '../../widgets/language_selector.dart';
import '../auth/login_screen.dart';
import 'personalization_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import 'privacy_security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _statsAnimation;

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
    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _statsAnimationController, 
        curve: Curves.easeOutBack,
      ),
    );
    
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _statsAnimationController.forward();
    });
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showQuickSettings(context, l10n),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.black87,
                    size: 22,
                  ),
                ),
              ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Compact Profile Header con stats
                    _buildUltraCompactProfileHeader(l10n),
                    const SizedBox(height: 16),

                    // Quick Stats Row
                    _buildQuickStatsRow(l10n),
                    const SizedBox(height: 20),

                    // Quick Actions Grid
                    _buildQuickActionsGrid(l10n),
                    const SizedBox(height: 20),

                    // Medical & Subscription Combined
                    _buildMedicalSubscriptionSection(l10n),
                    const SizedBox(height: 20),

                    // Responsive Menu Items (más compactos)
                    _buildCompactMenuItems(l10n, localeProvider),

                    const SizedBox(height: 20),

                    // Enhanced Logout Button
                    _buildLogoutButton(l10n),
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

  Widget _buildUltraCompactProfileHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar compacto
          Hero(
            tag: 'profile-avatar',
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          // Info del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SupabaseService.currentUser?.userMetadata?['full_name'] ??
                      l10n.user,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  SupabaseService.currentUser?.email ?? l10n.noEmail,
                  style: const TextStyle(
                    color: Color(0xFF6C757D),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.active,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botón de editar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {},
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Color(0xFF6C757D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '42',
                  'Consultas',
                  Icons.chat_bubble_outline,
                  const Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '28d',
                  'Último uso',
                  Icons.access_time,
                  const Color(0xFF00B894),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '95%',
                  'Satisfacción',
                  Icons.thumb_up_alt_outlined,
                  const Color(0xFFE17055),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(AppLocalizations l10n) {
    final quickActions = [
      _QuickAction(
        icon: Icons.history,
        label: 'Historial',
        color: const Color(0xFF6C5CE7),
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.favorite_outline,
        label: 'Favoritos',
        color: const Color(0xFFE84393),
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.share,
        label: 'Compartir',
        color: const Color(0xFF00B894),
        onTap: () => _shareProfile(l10n),
      ),
      _QuickAction(
        icon: Icons.backup,
        label: 'Backup',
        color: const Color(0xFFFFB400),
        onTap: () {},
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: quickActions.map((action) => _buildQuickActionItem(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(_QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalSubscriptionSection(AppLocalizations l10n) {
    return Row(
      children: [
        // Medical preferences - más compacto
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Color(0xFF6C5CE7),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Médico',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const MedicalPreferencesStatus(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Configurar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Subscription - compacto
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Premium',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.active,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Consultas\nilimitadas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _showSubscriptionDetails(l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Gestionar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMenuItems(
    AppLocalizations l10n,
    LocaleProvider? localeProvider,
  ) {
    final menuItems = [
      _MenuItemData(
        icon: Icons.tune,
        title: l10n.personalization,
        subtitle: 'Personaliza tu experiencia',
        color: const Color(0xFF6C5CE7),
        onTap: () => _navigateToPersonalization(context),
      ),
      _MenuItemData(
        icon: Icons.language,
        title: 'Idioma',
        subtitle: 'Cambiar idioma de la app',
        color: const Color(0xFF00CEC9),
        onTap: () => _showLanguageSelector(context, localeProvider),
      ),
      _MenuItemData(
        icon: Icons.security,
        title: l10n.privacySecurity,
        subtitle: 'Privacidad y seguridad',
        color: const Color(0xFFE84393),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
          );
        },
      ),
      _MenuItemData(
        icon: Icons.help_outline,
        title: l10n.helpSupport,
        subtitle: 'Centro de ayuda',
        color: const Color(0xFF00B894),
        onTap: () {},
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;
          
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, color: item.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Color(0xFF2D3436),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (item.subtitle != null) const SizedBox(height: 2),
                              if (item.subtitle != null)
                                Text(
                                  item.subtitle!,
                                  style: TextStyle(
                                    color: const Color(0xFF6C757D).withOpacity(0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF6C757D).withOpacity(0.5),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: const Color(0xFF6C757D).withOpacity(0.1),
                  indent: 50,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE74C3C).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context, l10n),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: const Color(0xFFE74C3C), size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.logout,
                  style: const TextStyle(
                    color: Color(0xFFE74C3C),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Nuevos métodos para funcionalidades adicionales
  void _showQuickSettings(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Configuración rápida',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickSettingItem(Icons.dark_mode, 'Modo oscuro', false, (value) {}),
            _buildQuickSettingItem(Icons.notifications, 'Notificaciones', true, (value) {}),
            _buildQuickSettingItem(Icons.location_on, 'Ubicación', true, (value) {}),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettingItem(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, LocaleProvider? localeProvider) {
    if (localeProvider == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccionar idioma',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              LanguageSelector(
                onLocaleChanged: (locale) {
                  localeProvider.onLocaleChanged(locale);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _shareProfile(AppLocalizations l10n) {
    // Implementar funcionalidad de compartir perfil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Función de compartir próximamente'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSubscriptionDetails(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Plan Premium',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          l10n.premiumPlan,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem('Consultas ilimitadas', Icons.chat),
                    _buildFeatureItem('Acceso prioritario', Icons.flash_on),
                    _buildFeatureItem('Historial completo', Icons.history),
                    _buildFeatureItem('Soporte premium', Icons.headset_mic),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE74C3C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar plan',
                        style: TextStyle(color: Color(0xFFE74C3C)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Gestionar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPersonalization(BuildContext context) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PersonalizationScreen(),
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

    if (result == true) {
      setState(() {});
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
}

// Clases auxiliares
class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}