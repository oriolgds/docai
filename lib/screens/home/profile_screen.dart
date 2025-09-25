import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../widgets/medical_preferences_button.dart';
import '../../widgets/medical_preferences_status.dart';
import '../../widgets/language_selector.dart';
import '../auth/login_screen.dart';
import 'personalization_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0, 0.3),
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
            fontSize: 28,
            fontWeight: FontWeight.w600,
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
                onTap: () {},
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.black87,
                    size: 24,
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
                    
                    // Enhanced Profile Header
                    _buildProfileHeader(l10n),
                    const SizedBox(height: 32),
                    
                    // Medical Preferences Section
                    _buildMedicalSection(l10n),
                    const SizedBox(height: 24),
                    
                    // Enhanced Subscription Card
                    _buildSubscriptionCard(l10n),
                    const SizedBox(height: 32),
                    
                    // Responsive Menu Items
                    _buildResponsiveMenuItems(l10n, localeProvider),
                    
                    const SizedBox(height: 24),
                    
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

  Widget _buildProfileHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profile-avatar',
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D3436), Color(0xFF636E72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            SupabaseService.currentUser?.userMetadata?['full_name'] ?? l10n.user,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              SupabaseService.currentUser?.email ?? l10n.noEmail,
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF6C5CE7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Medical Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const MedicalPreferencesStatus(),
          const SizedBox(height: 16),
          MedicalPreferencesButton(
            onPreferencesUpdated: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.medicalPreferencesUpdated),
                  backgroundColor: const Color(0xFF00B894),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3436), Color(0xFF636E72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3436).withOpacity(0.3),
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
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.premiumPlan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.active,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.unlimitedConsultations,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.expiresOn,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveMenuItems(AppLocalizations l10n, LocaleProvider? localeProvider) {
    final menuItems = [
      _MenuItemData(
        icon: Icons.tune,
        title: l10n.personalization,
        subtitle: 'Customize your experience',
        color: const Color(0xFF6C5CE7),
        onTap: () => _navigateToPersonalization(context),
      ),
      _MenuItemData(
        icon: Icons.person_outline,
        title: l10n.editProfile,
        subtitle: 'Update your information',
        color: const Color(0xFF00B894),
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.notifications,
        title: l10n.notifications,
        subtitle: 'Manage your alerts',
        color: const Color(0xFFFFB400),
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.security,
        title: l10n.privacySecurity,
        subtitle: 'Privacy & security settings',
        color: const Color(0xFFE84393),
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.help_outline,
        title: l10n.helpSupport,
        subtitle: 'Get help when you need it',
        color: const Color(0xFF00CEC9),
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.info_outline,
        title: l10n.about,
        subtitle: 'Learn more about DocAI',
        color: const Color(0xFF636E72),
        onTap: () {},
      ),
    ];

    return Column(
      children: [
        // Language selector
        if (localeProvider != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
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
            child: LanguageSelector(
              onLocaleChanged: localeProvider.onLocaleChanged,
            ),
          ),
        
        // Menu items grid/list
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return _buildModernMenuItem(item);
                },
              );
            } else {
              return Column(
                children: menuItems
                    .map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _buildModernMenuItem(item),
                        ))
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildModernMenuItem(_MenuItemData item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.04),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF2D3436),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (item.subtitle != null)
                      const SizedBox(height: 4),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          color: const Color(0xFF6C757D).withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF6C757D).withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE74C3C).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context, l10n),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: const Color(0xFFE74C3C),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.logout,
                  style: const TextStyle(
                    color: Color(0xFFE74C3C),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
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
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeOutQuart),
              ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.logoutConfirmTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: const TextStyle(
            color: Color(0xFF6C757D),
            fontSize: 15,
          ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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