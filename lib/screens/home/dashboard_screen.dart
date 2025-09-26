import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/android_download_modal.dart';
import '../auth/login_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Callback para cambiar de tab
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Método para ir a la tab de chat y iniciar nueva conversación
  void _goToChatAndStartNew() {
    setState(() {
      _currentIndex = 0; // Índice de la tab de chat
    });
    // Enviar callback al ChatScreen para que inicie nueva conversación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_screens[0] is ChatScreen) {
        // El ChatScreen se encargará de detectar este cambio
      }
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _validateSession();
    
    // Inicializar las pantallas con los callbacks de navegación
    _screens = [
      ChatScreen(
        onNavigateToHistory: () => _changeTab(1),
      ),
      HistoryScreen(
        onNavigateToChat: () => _changeTab(0),
        onStartNewChat: _goToChatAndStartNew,
      ),
      const ProfileScreen(),
    ];
    
    // Mostrar modal de descarga para Android si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AndroidDownloadHelper.showModalIfNeeded(context);
    });
  }

  final List<NavigationDestination> _navigationDestinations = [
    const NavigationDestination(
      icon: Icon(Icons.chat_outlined),
      selectedIcon: Icon(Icons.chat, color: Colors.white),
      label: 'Chat',
    ),
    const NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history, color: Colors.white),
      label: 'History',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person, color: Colors.white),
      label: 'Profile',
    ),
  ];

  void _validateSession() {
    final user = SupabaseService.currentUser;
    if (user == null || user.emailConfirmedAt == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: Colors.black,
        destinations: _navigationDestinations,
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail for tablet
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              indicatorColor: Colors.black,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.chat_outlined),
                  selectedIcon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.history_outlined),
                  selectedIcon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: const Text('Profile'),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Extended Navigation Rail for desktop
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'DocAI',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Navigation Items
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        _buildDesktopNavItem(
                          icon: Icons.chat_outlined,
                          selectedIcon: Icons.chat,
                          label: 'Chat',
                          isSelected: _currentIndex == 0,
                          onTap: () => setState(() => _currentIndex = 0),
                        ),
                        _buildDesktopNavItem(
                          icon: Icons.history_outlined,
                          selectedIcon: Icons.history,
                          label: 'Historial',
                          isSelected: _currentIndex == 1,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                        _buildDesktopNavItem(
                          icon: Icons.person_outline,
                          selectedIcon: Icons.person,
                          label: 'Perfil',
                          isSelected: _currentIndex == 2,
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}