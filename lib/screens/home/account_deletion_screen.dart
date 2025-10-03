import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/login_screen.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _warningAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _warningAnimation;
  
  final TextEditingController _confirmationController = TextEditingController();
  final FocusNode _confirmationFocus = FocusNode();
  bool _isLoading = false;
  bool _hasReadWarnings = false;
  bool _confirmationMatches = false;
  String _confirmationText = '';
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _warningAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _warningAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _warningAnimationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
    
    _confirmationController.addListener(_onConfirmationChanged);
  }
  
  void _onConfirmationChanged() {
    final text = _confirmationController.text.trim();
    setState(() {
      _confirmationText = text;
      _confirmationMatches = text.toLowerCase() == 'eliminar cuenta';
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _warningAnimationController.dispose();
    _confirmationController.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Eliminar cuenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning Header
                    _buildWarningHeader(),
                    const SizedBox(height: 24),
                    
                    // Data that will be deleted
                    _buildDataDeletionInfo(l10n),
                    const SizedBox(height: 24),
                    
                    // Important warnings
                    _buildWarningsSection(l10n),
                    const SizedBox(height: 24),
                    
                    // Confirmation checkbox
                    _buildConfirmationCheckbox(l10n),
                    const SizedBox(height: 16),
                    
                    // Confirmation text input
                    _buildConfirmationInput(l10n),
                    const SizedBox(height: 32),
                    
                    // Delete button
                    _buildDeleteButton(l10n),
                    const SizedBox(height: 16),
                    
                    // Cancel button
                    _buildCancelButton(l10n),
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
  
  Widget _buildWarningHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Acción irreversible!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE74C3C),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Esta acción no se puede deshacer. Todos tus datos serán eliminados permanentemente.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6C757D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataDeletionInfo(AppLocalizations l10n) {
    final dataItems = [
      _DataItem(
        icon: Icons.person_outline,
        title: 'Información personal',
        description: 'Email, nombre, preferencias de usuario',
        color: const Color(0xFF6C5CE7),
      ),
      _DataItem(
        icon: Icons.chat_bubble_outline,
        title: 'Historial de conversaciones',
        description: 'Todas las consultas médicas y respuestas',
        color: const Color(0xFF00CEC9),
      ),
      _DataItem(
        icon: Icons.medical_information_outlined,
        title: 'Preferencias médicas',
        description: 'Condiciones, alergias, medicamentos',
        color: const Color(0xFF00B894),
      ),
      _DataItem(
        icon: Icons.cloud_off_outlined,
        title: 'Datos de respaldo',
        description: 'Configuraciones y datos sincronizados',
        color: const Color(0xFFE84393),
      ),
      _DataItem(
        icon: Icons.subscriptions_outlined,
        title: 'Información de suscripción',
        description: 'Planes, pagos y facturación',
        color: const Color(0xFFE17055),
      ),
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.delete_forever_outlined,
                color: Color(0xFFE74C3C),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Datos que serán eliminados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dataItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildDataItem(item),
                if (index < dataItems.length - 1) const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildDataItem(_DataItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6C757D).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWarningsSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB400).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFFFFB400),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Importante - Lee antes de continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWarningItem(
            '• Una vez eliminada, tu cuenta no podrá ser recuperada',
            Icons.block,
          ),
          _buildWarningItem(
            '• Todos tus datos médicos y conversaciones se perderán para siempre',
            Icons.medical_information,
          ),
          _buildWarningItem(
            '• Si tienes una suscripción activa, se cancelará automáticamente',
            Icons.money_off,
          ),
          _buildWarningItem(
            '• Deberás crear una nueva cuenta si deseas usar DocAI nuevamente',
            Icons.person_add_alt_1,
          ),
          _buildWarningItem(
            '• Esta acción se procesará inmediatamente y no hay período de gracia',
            Icons.timer_off,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWarningItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFE74C3C),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.substring(2), // Remove bullet point
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6C757D),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmationCheckbox(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _warningAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.7 + (_warningAnimation.value * 0.3),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hasReadWarnings 
                ? const Color(0xFFE8F5E8) 
                : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasReadWarnings 
                  ? const Color(0xFF00B894) 
                  : const Color(0xFFDDD),
                width: _hasReadWarnings ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _hasReadWarnings,
                  onChanged: (value) {
                    setState(() {
                      _hasReadWarnings = value ?? false;
                    });
                    if (value == true) {
                      _warningAnimationController.forward();
                    } else {
                      _warningAnimationController.reverse();
                    }
                  },
                  activeColor: const Color(0xFF00B894),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'He leído y entiendo todas las advertencias anteriores',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildConfirmationInput(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Para confirmar, escribe "ELIMINAR CUENTA" (sin comillas):',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _confirmationController,
            focusNode: _confirmationFocus,
            decoration: InputDecoration(
              hintText: 'Escribe "ELIMINAR CUENTA"',
              hintStyle: TextStyle(
                color: const Color(0xFF6C757D).withOpacity(0.6),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _confirmationMatches 
                    ? const Color(0xFF00B894) 
                    : const Color(0xFFDDD),
                  width: _confirmationMatches ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2E7D32),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: _confirmationMatches
                ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00B894),
                    size: 20,
                  )
                : null,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDeleteButton(AppLocalizations l10n) {
    final isEnabled = _hasReadWarnings && _confirmationMatches && !_isLoading;
    
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isEnabled
          ? const LinearGradient(
              colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
            )
          : null,
        color: isEnabled ? null : const Color(0xFFBDC3C7),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _deleteAccount : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...
                [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Eliminando cuenta...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...
                [
                  const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Eliminar mi cuenta permanentemente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCancelButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C757D).withOpacity(0.3)),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _deleteAccount() async {
    if (!_hasReadWarnings || !_confirmationMatches) return;
    
    // Show final confirmation dialog
    final confirmed = await _showFinalConfirmationDialog();
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _performAccountDeletion();
      
      if (mounted) {
        // Navigate to login screen and clear the stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu cuenta ha sido eliminada exitosamente'),
            backgroundColor: Color(0xFF00B894),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la cuenta: $e'),
            backgroundColor: const Color(0xFFE74C3C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  Future<bool> _showFinalConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE74C3C),
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirmación final',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          '¿Estás completamente seguro de que deseas eliminar tu cuenta? Esta acción es irreversible y todos tus datos se perderán para siempre.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6C757D),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No, conservar mi cuenta',
              style: TextStyle(
                color: Color(0xFF6C757D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sí, eliminar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  Future<void> _performAccountDeletion() async {
    final user = SupabaseService.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    
    try {
      // Step 1: Delete all user conversations and messages
      await SupabaseService.clearAllConversations();
      
      // Step 2: Delete user preferences
      await SupabaseService.client
          .from('user_preferences')
          .delete()
          .eq('user_id', user.id);
      
      // Step 3: Delete any subscription data (if exists)
      await SupabaseService.client
          .from('subscriptions')
          .delete()
          .eq('user_id', user.id);
      
      // Step 4: Delete any user stats or analytics data
      await SupabaseService.client
          .from('user_stats')
          .delete()
          .eq('user_id', user.id);
      
      // Step 5: Delete the user account (this must be last)
      await SupabaseService.client.auth.admin.deleteUser(user.id);
      
      // Step 6: Sign out locally
      await SupabaseService.signOut();
      
    } catch (e) {
      throw Exception('Error durante la eliminación: $e');
    }
  }
}

// Helper class for data items
class _DataItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  
  _DataItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}