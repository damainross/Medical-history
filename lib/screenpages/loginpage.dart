
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'mainscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Force refresh user's data from Firebase
      await userCredential.user!.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

// Fetch user document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      String status = userDoc['status'] ?? 'pending';
      String role = userDoc['role'] ?? '';

// Special handling for non-Site Admin roles (e.g., Doctor, Nurse)
      if (role != 'site admin') {
// Require email verification for non-Site Admins
        if (!refreshedUser!.emailVerified) {
          String msg;
          if (status == 'approved') {
            msg = 'Your account is approved, but please verify your email to proceed.';
          } else if (status == 'pending') {
            msg = 'Your account is pending approval by the site admin. They will review your details and approve or disapprove soon. Please also verify your email.';
          } else {
            msg = 'Your account is yet to be approved. Please contact the administrator';
          }
          setState(() {
            _errorMessage = msg;
            _isLoading = false;
          });
          return;
        }
      }

// Common status check for all roles
      if (status == 'approved' || status == 'verified') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Color(0xFF50C878),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(role: role)),
          );
        }
      } else if (status == 'disapproved') {
        setState(() {
          _errorMessage = 'Your account has been disapproved. Contact administrator.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Your account is pending approval by the site admin. They will review your details and approve or disapprove soon.';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg;

      switch (e.code) {
        case 'invalid-email':
          errorMsg = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMsg = 'This account has been disabled. Please contact support.';
          break;
        case 'user-not-found':
          errorMsg = 'No account found with this email.';
          break;
        case 'wrong-password':
          errorMsg = 'Incorrect password. Please try again.';
          break;
        default:
          errorMsg = 'Login failed. Please check your credentials and try again.';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF4A90E2)),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value!.isEmpty || !value.contains('@') ? 'Invalid email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outlined, color: Color(0xFF4A90E2)),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
// Implement forgot password
                            },
                            child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF4A90E2))),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2))),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: const Text(
                                'Log In',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
