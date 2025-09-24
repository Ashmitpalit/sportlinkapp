import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SportlinkApp());
}

class SportlinkApp extends StatelessWidget {
  const SportlinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPORTLINK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        fontFamily: null,
      ),
      home: const LoginScreen(),
    );
  }
}
