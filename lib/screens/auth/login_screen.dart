import 'package:flutter/material.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/android_download_modal.dart';
import '../home/dashboard_screen.dart';
import 'signup_screen.dart';
import '../../services/supabase_service.dart';
import 'email_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mostrar modal de descarga para Android si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AndroidDownloadHelper.showModalIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildLargeScreenLayout(isDesktop: false),
        desktop: _buildLargeScreenLayout(isDesktop: true),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 48,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildForm(),
                const Spacer(),
                _buildSignUpPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout({required bool isDesktop}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveContainer(
              maxWidth: isDesktop ? 500 : 400,
              padding: EdgeInsets.all(isDesktop ? 48 : 32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: isDesktop ? 32 : 16,
                      offset: Offset(0, isDesktop ? 8 : 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(isDesktop ? 48 : 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(isLargeScreen: true),
                    SizedBox(height: isDesktop ? 40 : 32),
                    _buildForm(),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildSignUpPrompt(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({bool isLargeScreen = false}) {
    return Column(
      children: [
        Container(
          width: isLargeScreen ? 100 : 80,
          height: isLargeScreen ? 100 : 80,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
          ),
          child: Icon(
            Icons.medical_services_outlined,
            color: Colors.white,
            size: isLargeScreen ? 50 : 40,
          ),
        ),
        SizedBox(height: isLargeScreen ? 32 : 24),
        Text(
          'DocAI',
          style: TextStyle(
            fontSize: isLargeScreen ? 40 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isLargeScreen ? 12 : 8),
        Text(
          'Your Personal AI Doctor',
          style: TextStyle(
            fontSize: isLargeScreen ? 18 : 16,
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Fields
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 24),
        
        // Login Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Sign in with Email'),
        ),
        const SizedBox(height: 16),
        
        // Divider
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('or', style: TextStyle(color: Color(0xFF6B6B6B))),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        
        // Google Sign In
        AuthButton(
          onPressed: _handleGoogleSignIn,
          icon: Icons.g_mobiledata,
          text: 'Continue with Google',
          isOutlined: true,
        ),
        const SizedBox(height: 16),
        
        // Forgot Password
        TextButton(
          onPressed: () {},
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Color(0xFF6B6B6B)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Color(0xFF6B6B6B)),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          ),
          child: const Text(
            'Sign up',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
        return;
      }
      
      await SupabaseService.signInWithEmail(email, password);
      
      final user = SupabaseService.currentUser;
      if (user?.emailConfirmedAt == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: email),
          ),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      String errorMessage = 'Login failed';
      
      if (e.toString().contains('invalid_credentials') || 
          e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('email_not_confirmed')) {
        // Redirect to email verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: _emailController.text.trim()),
          ),
        );
        setState(() => _isLoading = false);
        return;
      } else if (e.toString().contains('too_many_requests')) {
        errorMessage = 'Too many attempts. Please try again later.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  void _handleGoogleSignIn() async {
    try {
      final success = await SupabaseService.signInWithGoogle();
      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In was cancelled'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}