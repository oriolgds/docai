import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../widgets/medical_preferences_button.dart';
import '../../widgets/medical_preferences_status.dart';
import '../auth/login_screen.dart';
import 'personalization_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    SupabaseService.currentUser?.userMetadata?['full_name'] ?? l10n.user,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SupabaseService.currentUser?.email ?? l10n.noEmail,
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Medical Preferences Status Card
            const MedicalPreferencesStatus(),
            const SizedBox(height: 16),
            
            // Medical Preferences Button
            MedicalPreferencesButton(
              onPreferencesUpdated: () {
                setState(() {}); // Refresh the status card
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.medicalPreferencesUpdated),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Subscription Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Color(0xFF333333)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.premiumPlan,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.active,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.unlimitedConsultations,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.expiresOn,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Responsive Menu Items
            _buildResponsiveMenuItems(l10n),
            
            const SizedBox(height: 16),
            
            // Logout (always full width)
            _buildMenuItem(
              icon: Icons.logout_outlined,
              title: l10n.logout,
              onTap: () => _showLogoutDialog(context, l10n),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveMenuItems(AppLocalizations l10n) {
    final menuItems = [
      _MenuItemData(
        icon: Icons.tune,
        title: l10n.personalization,
        onTap: () => _navigateToPersonalization(context),
      ),
      _MenuItemData(
        icon: Icons.person_outline,
        title: l10n.editProfile,
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.notifications_outlined,
        title: l10n.notifications,
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.security_outlined,
        title: l10n.privacySecurity,
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.help_outline,
        title: l10n.helpSupport,
        onTap: () {},
      ),
      _MenuItemData(
        icon: Icons.info_outline,
        title: l10n.about,
        onTap: () {},
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use grid layout for screens wider than 600px (tablet/desktop)
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildGridMenuItem(
                icon: item.icon,
                title: item.title,
                onTap: item.onTap,
              );
            },
          );
        } else {
          // Use vertical list for mobile screens
          return Column(
            children: menuItems.map((item) => _buildMenuItem(
              icon: item.icon,
              title: item.title,
              onTap: item.onTap,
            )).toList(),
          );
        }
      },
    );
  }

  Widget _buildGridMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9E9E9E),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? const Color(0xFFE53E3E) : Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? const Color(0xFFE53E3E) : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF9E9E9E),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: const Color(0xFFFAFAFA),
      ),
    );
  }

  Future<void> _navigateToPersonalization(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalizationScreen(),
      ),
    );
    
    // Optionally refresh the profile if preferences were saved
    if (result == true) {
      // Could add a setState here if ProfileScreen becomes stateful
      // and needs to update based on new preferences
    }
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Color(0xFFE53E3E)),
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
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}