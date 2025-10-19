import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:med/screenpages/loginpage.dart';
import 'package:med/screenpages/welcomepage.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyCd4hz_9u2PbtkJFExCkRDtFAudW4RmApU", appId: "1:1094713461297:web:160ffe909fac0de455a310", messagingSenderId: "1094713461297", projectId: "medhis-88846"));

  runApp(MaterialApp(
    home: const LoginScreen(),
    routes: {
      '/login': (context) => const LoginScreen(),
    },
  ));runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Medical App',
      home: WelcomeScreen()
    );
  }
}

