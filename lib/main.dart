import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SportlinkApp());
}

class SportlinkApp extends StatefulWidget {
  const SportlinkApp({super.key});

  @override
  State<SportlinkApp> createState() => _SportlinkAppState();
}

class _SportlinkAppState extends State<SportlinkApp> {
  late final AuthServiceApi auth;

  @override
  void initState() {
    super.initState();
    auth = AuthServiceApi(
        baseUrl: const String.fromEnvironment('AUTH_API_URL',
            defaultValue: 'http://localhost:3000'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPORTLINK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: SplashScreen(auth: auth),
    );
  }
}
