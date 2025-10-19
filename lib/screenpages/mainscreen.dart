import 'package:flutter/material.dart';

import 'SiteAdminScreen.dart';
import 'doctorscreen.dart';
import 'nursescreen.dart';


class MainScreen extends StatelessWidget {
  final String role;

  const MainScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return role == 'nurse'
        ? const NurseScreen()
        : role == 'doctor'
        ? const DoctorScreen()
        : const SiteAdminScreen();
  }
}