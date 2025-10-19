
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:med/screenpages/verificationpage.dart';
import 'package:med/screenpages/blank_screen.dart'; // Add this import

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _facilityNameController = TextEditingController();
  String? _selectedRole;
  String? _selectedFacility;
  bool _isLoading = false;
  bool _isLoadingFacilities = true;
  String? _errorMessage;
  bool _agreeToTerms = false;
  List<Map<String, String>> _facilities = [];
  StreamSubscription<User?>? _authSubscription; // Email verification listener

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _facilityNameController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    try {
      print('Starting fetch from Firestore...');
      final snapshot = await FirebaseFirestore.instance.collection('medical_facilities').get();
      print('Snapshot size: ${snapshot.size}');
      print('Snapshot docs: ${snapshot.docs.map((doc) => doc.id).toList()}');

      final facilitiesList = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Doc data: $data');
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Unnamed Facility',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _facilities = facilitiesList;
          _isLoadingFacilities = false;
        });
      }
    } catch (e) {
      print('Firestore error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Unstable network.';
          _isLoadingFacilities = false;
        });
      }
    }
  }

// Email verification listener
  void _startEmailVerificationListener(User user) {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? currentUser) async {
      if (currentUser != null && currentUser.emailVerified && currentUser.uid == user.uid) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc['role'] == 'site admin' && userDoc['status'] == 'pending') {
          try {
            await FirebaseFunctions.instance.httpsCallable('onEmailVerified').call();
          } catch (e) {
            print('Error calling function: $e');
          }
        }
        _authSubscription?.cancel();
// Navigate to blank screen upon verification
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BlankScreen()),
          );
        }
      }
    });
  }

  Future<void> _signUp() async {
    print('🔥 SIGNUP BUTTON PRESSED');
    print('Form valid: ${_formKey.currentState!.validate()}');
    print('Terms agreed: $_agreeToTerms');
    print('Email: "${_emailController.text}"');
    print('Role: $_selectedRole');
    print('Facility: $_selectedFacility');

    if (!_formKey.currentState!.validate()) {
      print('❌ FORM INVALID');
      setState(() => _errorMessage = 'Please fix form errors');
      return;
    }

    if (!_agreeToTerms) {
      print('❌ TERMS NOT AGREED');
      setState(() => _errorMessage = 'Please agree to the terms');
      return;
    }

    if (_selectedRole == 'Site Admin' && _facilityNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter facility name');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    print('✅ LOADING STARTED');

    try {
      print('🔐 Creating user: ${_emailController.text.trim()}');
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('✅ USER CREATED: ${userCredential.user!.uid}');

      print('📧 Sending verification email...');
      await userCredential.user!.sendEmailVerification();
      print('✅ EMAIL SENT');

      String? facilityId;
      Map<String, dynamic> userData = {
        'email': _emailController.text.trim(),
        'role': _selectedRole!.toLowerCase(),
        'created_at': FieldValue.serverTimestamp(),
      };

      if (_selectedRole == 'Site Admin') {
// ✅ SITE ADMIN: Create facility + auto-approve
        print('🏥 Creating facility for Site Admin...');
        DocumentReference facilityRef = await FirebaseFirestore.instance.collection('medical_facilities').add({
          'name': _facilityNameController.text.trim(),
          'official_email': _emailController.text.trim(),
          'address': '',
          'phone': '',
          'created_at': FieldValue.serverTimestamp(),
        });
        facilityId = facilityRef.id;
        print('✅ FACILITY CREATED: $facilityId');

        userData.addAll({
          'facility_id': facilityId,
          'status': 'pending', // Cloud Function will set to 'approved'
        });

      } else {
// ✅ DOCTOR/NURSE: Normal facility matching
        facilityId = _selectedFacility;
        final facilitySnapshot = await FirebaseFirestore.instance
            .collection('medical_facilities')
            .where('official_email', isEqualTo: _emailController.text.trim())
            .limit(1)
            .get();

        if (facilitySnapshot.docs.isNotEmpty) {
          facilityId = facilitySnapshot.docs.first.id;
          print('✅ Facility matched: $facilityId');
        }

        userData.addAll({
          'facility_id': facilityId ?? '',
          'status': facilityId != null ? 'verified' : 'pending',
        });
      }

// Save user to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);
      print('✅ USER SAVED');

      _startEmailVerificationListener(userCredential.user!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedRole == 'Site Admin'
                ? 'Facility created! Check your email.'
                : 'Account created! Check your email.'),
            backgroundColor: Color(0xFF50C878),
            action: SnackBarAction(
              label: 'Resend',
              textColor: Colors.white,
              onPressed: () => userCredential.user!.sendEmailVerification(),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: _emailController.text.trim(),
              isFacilityVerified: facilityId != null && _selectedRole != 'Site Admin',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('🔥 AUTH ERROR: ${e.code}');
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      print('💥 ERROR: $e');
      setState(() {
        _errorMessage = 'Unexpected error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password too weak (6+ characters)';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Auth error: ${code}';
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
                            'Create Account',
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
                          validator: (value) => value!.length < 6 ? 'Password too short' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF4A90E2)),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          value: _selectedRole,
                          items: ['Doctor', 'Nurse', 'Site Admin'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                          onChanged: (value) => setState(() => _selectedRole = value),
                          validator: (value) => value == null ? 'Select a role' : null,
                        ),
                        const SizedBox(height: 16),
                        if (_selectedRole == 'Site Admin')
                          TextFormField(
                            controller: _facilityNameController,
                            decoration: const InputDecoration(
                              labelText: 'Facility Name *',
                              prefixIcon: Icon(Icons.local_hospital, color: Color(0xFF4A90E2)),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) => value!.isEmpty ? 'Required for Site Admin' : null,
                          )
                        else
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Medical Facility *',
                              prefixIcon: Icon(Icons.local_hospital, color: Color(0xFF4A90E2)),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            value: _selectedFacility,
                            items: _isLoadingFacilities
                                ? [const DropdownMenuItem(value: null, child: Text('Loading...'))]
                                : _facilities.isEmpty
                                ? [const DropdownMenuItem(value: null, child: Text('No facilities'))]
                                : _facilities.map((f) => DropdownMenuItem(
                                value: f['id'],
                                child: Text(f['name']!)
                            )).toList(),
                            onChanged: _isLoadingFacilities || _facilities.isEmpty
                                ? null
                                : (value) => setState(() => _selectedFacility = value),
                            validator: (value) => value == null ? 'Select a facility' : null,
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) => setState(() => _agreeToTerms = value!),
                              activeColor: const Color(0xFF4A90E2),
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to the Terms of Service and Privacy Policy',
                                style: TextStyle(color: Color(0xFF666666)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity, // Full width!
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : () {
                              print('🚀 BUTTON TAPPED!'); // Debug
                              _signUp();
                            },
                            child: _isLoading
                                ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Creating...', style: TextStyle(fontSize: 16)),
                              ],
                            )
                                : const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
