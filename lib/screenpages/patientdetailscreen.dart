import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addvitalsscreen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientSsn;
  const PatientDetailsScreen({super.key, required this.patientSsn});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, dynamic>? patientData;
  List<Map<String, dynamic>> vitals = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      DocumentSnapshot patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientSsn)
          .get();

      if (patientDoc.exists) {
        QuerySnapshot vitalsSnapshot = await FirebaseFirestore.instance
            .collection('vitals')
            .where('patient_ssn', isEqualTo: widget.patientSsn)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        setState(() {
          patientData = patientDoc.data() as Map<String, dynamic>;
          vitals = vitalsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patientData?['name'] ?? 'Patient Details'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: patientData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Info Card
            _buildInfoCard('Personal Information', [
              _buildInfoRow('Name', patientData!['name']),
              _buildInfoRow('DOB', patientData!['dob']),
              _buildInfoRow('Address', patientData!['address']),
              _buildInfoRow('Contact', patientData!['contact_info']),
            ]),
            const SizedBox(height: 16),

            // Emergency Contact Card
            _buildInfoCard('Emergency Contact', [
              _buildInfoRow('Name', patientData!['emergency_contact']?['name'] ?? ''),
              _buildInfoRow('Phone', patientData!['emergency_contact']?['phone'] ?? ''),
            ]),
            const SizedBox(height: 16),

            // Medical History Card
            _buildInfoCard('Medical History', [
              _buildInfoRow('Past Illnesses', patientData!['history']?['past_illnesses'] ?? ''),
              _buildInfoRow('Surgeries', patientData!['history']?['surgeries'] ?? ''),
              _buildInfoRow('Family History', patientData!['history']?['family_history'] ?? ''),
            ]),
            const SizedBox(height: 16),

            // Symptoms, Signs, Diagnoses, Medications
            _buildListCard('Symptoms', patientData!['symptoms'] ?? []),
            _buildListCard('Signs', patientData!['signs'] ?? []),
            _buildListCard('Diagnoses', patientData!['diagnoses'] ?? []),
            _buildListCard('Medications', patientData!['medications'] ?? []),
            const SizedBox(height: 16),

            // Recent Vitals Card
            _buildVitalsCard(vitals),
            const SizedBox(height: 16),

            // Add Vitals Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVitalsScreen(patientSsn: widget.patientSsn),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Vitals', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items.map<Widget>((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• $item'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsCard(List<Map<String, dynamic>> vitals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Vitals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${vitals.length} records'),
              ],
            ),
            const Divider(),
            ...vitals.map((vital) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${vital['timestamp']?.toDate().toString().substring(0, 16)}')),
                  Expanded(child: Text('Temp: ${vital['temperature']}°C')),
                  Expanded(child: Text('Pulse: ${vital['heartbeat']} bpm')),
                  Expanded(child: Text('Weight: ${vital['weight']} kg')),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}