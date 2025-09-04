import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
                    SupabaseService.currentUser?.userMetadata?['full_name'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SupabaseService.currentUser?.email ?? 'No email',
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
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
                      const Text(
                        'Premium Plan',
                        style: TextStyle(
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
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unlimited AI consultations',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Expires: March 15, 2025',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            
            // Logout
            _buildMenuItem(
              icon: Icons.logout_outlined,
              title: 'Logout',
              onTap: () => _showLogoutDialog(context),
              isDestructive: true,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFE53E3E)),
            ),
          ),
        ],
      ),
    );
  }
}