import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:med/screenpages/searchpatients.dart';

import 'addpatientscreen.dart';


class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A90E2),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              icon: Icons.person_add,
              title: 'Add Patient',
              color: const Color(0xFF50C878),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPatientScreen())),
            ),
            _buildActionCard(
              icon: Icons.search,
              title: 'Search Patient',
              color: const Color(0xFF4A90E2),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPatientScreen())),
            ),
            _buildActionCard(
              icon: Icons.medical_information,
              title: 'View Records',
              color: const Color(0xFFF39C12),
              onTap: () {}, // Add implementation
            ),
            _buildActionCard(
              icon: Icons.analytics,
              title: 'Reports',
              color: const Color(0xFFE74C3C),
              onTap: () {}, // Add implementation
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}