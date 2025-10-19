import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddVitalsScreen extends StatefulWidget {
  final String patientSsn;
  const AddVitalsScreen({super.key, required this.patientSsn});

  @override
  State<AddVitalsScreen> createState() => _AddVitalsScreenState();
}

class _AddVitalsScreenState extends State<AddVitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _temperatureController = TextEditingController();
  final _heartbeatController = TextEditingController();
  final _weightController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveVitals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('vitals').add({
        'patient_ssn': widget.patientSsn,
        'temperature': double.parse(_temperatureController.text),
        'heartbeat': int.parse(_heartbeatController.text),
        'weight': double.parse(_weightController.text),
        'blood_sugar': double.parse(_bloodSugarController.text),
        'blood_pressure': _bloodPressureController.text,
        'recorded_by': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vitals recorded successfully!'),
            backgroundColor: Color(0xFF50C878),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vitals'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                  prefixIcon: Icon(Icons.thermostat, color: Color(0xFF4A90E2)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heartbeatController,
                decoration: const InputDecoration(
                  labelText: 'Heartbeat (bpm)',
                  prefixIcon: Icon(Icons.favorite, color: Color(0xFF4A90E2)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.scale, color: Color(0xFF4A90E2)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bloodSugarController,
                decoration: const InputDecoration(
                  labelText: 'Blood Sugar (mmol/L)',
                  prefixIcon: Icon(Icons.water_drop, color: Color(0xFF4A90E2)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bloodPressureController,
                decoration: const InputDecoration(
                  labelText: 'Blood Pressure (mmHg)',
                  prefixIcon: Icon(Icons.monitor_heart, color: Color(0xFF4A90E2)),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _saveVitals,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Vitals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _heartbeatController.dispose();
    _weightController.dispose();
    _bloodSugarController.dispose();
    _bloodPressureController.dispose();
    super.dispose();
  }
}