import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:med/screenpages/patientdetailscreen.dart';

class SearchPatientScreen extends StatefulWidget {
  const SearchPatientScreen({super.key});

  @override
  State<SearchPatientScreen> createState() => _SearchPatientScreenState();
}

class _SearchPatientScreenState extends State<SearchPatientScreen> {
  final _ssnController = TextEditingController();
  bool _isSearching = false;

  Future<void> _searchPatient() async {
    if (_ssnController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter TRN'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      print('🔍 Doctor searching for SSN: ${_ssnController.text.trim()}');

      DocumentSnapshot patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(_ssnController.text.trim())
          .get();

      if (patientDoc.exists) {
        print('✅ Patient found: ${patientDoc['name']}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailsScreen(
              patientSsn: _ssnController.text.trim(),
            ),
          ),
        );
      } else {
        print('❌ Patient not found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Log the error to Firestore under the searched patient's document
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(_ssnController.text.trim())
          .collection('logs')
          .add({
        'type': 'search_error',
        'error': e.toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'searchedBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown_user',
      });

      print('💥 Search error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Patient', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 80,
                      color: Color(0xFF4A90E2),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Find Patient Records',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter patient TRN to view medical records',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _ssnController,
                      decoration: InputDecoration(
                        labelText: 'Patient TRN *',
                        prefixIcon: const Icon(Icons.person_search, color: Color(0xFF4A90E2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _searchPatient(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSearching ? null : _searchPatient,
                        icon: _isSearching
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.search),
                        label: Text(
                          _isSearching ? 'Searching...' : 'Search Patient',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ssnController.dispose();
    super.dispose();
  }
}