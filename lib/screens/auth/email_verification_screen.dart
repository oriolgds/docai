import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../home/dashboard_screen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> with TickerProviderStateMixin {
  bool _isChecking = false;
  bool _isResending = false;
  String? _message;
  bool _isSuccess = false;
  DateTime? _lastResendTime;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPeriodicCheck();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  void _startPeriodicCheck() {
    // Check verification status every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkVerificationSilently();
        _startPeriodicCheck();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
        ),
        title: const Text('Email Verification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Animated Icon
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _isSuccess ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: (_isSuccess ? Colors.green : Colors.orange).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isSuccess ? Icons.check_circle : Icons.email_outlined,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                _isSuccess ? 'Email Verified!' : 'Check Your Email',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                _isSuccess 
                    ? 'Your email has been successfully verified. You can now access all features.'
                    : 'We sent a verification link to\n${widget.email}\n\nClick the link in your email to verify your account.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B6B6B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Status Message
              if (_message != null) ..[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _isSuccess 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.error_outline,
                        color: _isSuccess ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action Buttons
              if (!_isSuccess) ..[
                // Check verification button
                ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Check Verification Status'),
                ),
                const SizedBox(height: 16),
                
                // Resend email button
                OutlinedButton(
                  onPressed: _canResend() ? _resendEmail : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
                          _resendCooldown > 0 
                              ? 'Resend in ${_resendCooldown}s'
                              : 'Resend Verification Email',
                        ),
                ),
                const SizedBox(height: 24),
                
                // Help text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Didn\'t receive the email?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your spam or junk mail folder\n• Make sure you entered the correct email address\n• Wait a few minutes for delivery\n• Try resending the verification email',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ..[
                // Continue button when verified
                ElevatedButton(
                  onPressed: _continueToApp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Continue to DocAI',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Alternative action
              if (!_isSuccess)
                TextButton(
                  onPressed: _proceedWithoutVerification,
                  child: const Text(
                    'Continue without verification (limited features)',
                    style: TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canResend() {
    if (_lastResendTime == null) return true;
    final timeSince = DateTime.now().difference(_lastResendTime!);
    return timeSince.inSeconds >= 60 && !_isResending;
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });
        if (_resendCooldown <= 0) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });
    
    try {
      // Refresh user session first
      await SupabaseService.client.auth.refreshSession();
      
      final user = SupabaseService.currentUser;
      if (user?.emailConfirmedAt != null) {
        setState(() {
          _isSuccess = true;
          _message = 'Email successfully verified!';
        });
        _pulseController.stop();
        
        // Auto-continue after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _continueToApp();
        });
      } else {
        setState(() {
          _message = 'Email not verified yet. Please check your email and click the verification link.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error checking verification status. Please try again.';
      });
    }
    
    setState(() => _isChecking = false);
  }

  Future<void> _checkVerificationSilently() async {
    if (_isSuccess || _isChecking) return;
    
    try {
      await SupabaseService.client.auth.refreshSession();
      final user = SupabaseService.currentUser;
      if (user?.emailConfirmedAt != null) {
        setState(() {
          _isSuccess = true;
          _message = 'Email successfully verified!';
        });
        _pulseController.stop();
      }
    } catch (e) {
      // Silently fail for background checks
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
      _message = null;
    });
    
    try {
      await SupabaseService.resendVerificationEmail(widget.email);
      setState(() {
        _message = 'Verification email sent! Please check your inbox and spam folder.';
        _lastResendTime = DateTime.now();
      });
      _startResendCooldown();
    } catch (e) {
      setState(() {
        _message = 'Failed to send verification email. Please try again later.';
      });
    }
    
    setState(() => _isResending = false);
  }

  void _continueToApp() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  void _proceedWithoutVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue Without Verification?'),
        content: const Text(
          'You can use DocAI without email verification, but some features may be limited. You can verify your email later from your profile settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _continueToApp();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}