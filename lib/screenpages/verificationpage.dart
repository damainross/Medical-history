import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'loginpage.dart';

class VerificationScreen extends StatelessWidget {
  final String email;
  final bool isFacilityVerified;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.isFacilityVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 80,
                color: const Color(0xFF4A90E2),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification link to $email. Please check your inbox and verify your account.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666)),
              ),
              if (isFacilityVerified)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Your facility has been automatically verified.',
                    style: TextStyle(color: Color(0xFF50C878), fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Go to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}