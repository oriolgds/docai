import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../home/dashboard_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification link to\n${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B6B6B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Check verification button
              ElevatedButton(
                onPressed: _isLoading ? null : _checkVerification,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('I\'ve verified my email'),
              ),
              const SizedBox(height: 16),
              
              // Resend email
              TextButton(
                onPressed: _resendEmail,
                child: const Text(
                  'Resend verification email',
                  style: TextStyle(color: Color(0xFF6B6B6B)),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _checkVerification() async {
    setState(() => _isLoading = true);
    
    try {
      final user = SupabaseService.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your email.'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  void _resendEmail() async {
    try {
      await SupabaseService.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
        emailRedirectTo: 'doky://email-verified',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
    }
  }
}