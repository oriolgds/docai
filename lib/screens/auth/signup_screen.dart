import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/auth_button.dart';
import '../home/dashboard_screen.dart';
import '../../services/supabase_service.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 24 * 2,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const Spacer(),
              // Logo and Title
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join DocAI today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
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
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              
              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFE53E3E),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Sign Up Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Create Account'),
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
              
              // Google Sign Up
              AuthButton(
                onPressed: _handleGoogleSignUp,
                icon: Icons.g_mobiledata,
                text: 'Sign up with Google',
                isOutlined: true,
              ),
              const Spacer(),
              
              // Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Color(0xFF6B6B6B)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    // Validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
        _isLoading = false;
      });
      return;
    }
    
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }
    
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
        _isLoading = false;
      });
      return;
    }
    
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password)) {
      setState(() {
        _errorMessage = 'Password must contain both letters and digits';
        _isLoading = false;
      });
      return;
    }
    
    try {
      // Ensure Supabase is initialized
      await SupabaseService.initialize();
      
      // Register with Supabase
      final response = await SupabaseService.signUpWithEmail(email, password);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: email),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleGoogleSignUp() async {
    // Simulate Google Sign Up
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}