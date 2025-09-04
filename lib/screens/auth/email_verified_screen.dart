import 'package:flutter/material.dart';
import '../home/dashboard_screen.dart';

class EmailVerifiedScreen extends StatelessWidget {
  const EmailVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Email Verified!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your email has been successfully verified.\nYou can now access your account.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B6B6B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  (route) => false,
                ),
                child: const Text('Continue to App'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}