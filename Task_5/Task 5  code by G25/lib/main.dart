// main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/landing_page.dart';
void main() {
  runApp(const AutoFixApp());
}

class AutoFixApp extends StatelessWidget {
  const AutoFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoFix',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      // home: const LoginPage(), // Start with landing page (login)
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}