import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'config/theme.dart';
import 'screens/splash_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const WordleMasterApp());
}

class WordleMasterApp extends StatelessWidget {
  const WordleMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordleMaster',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(), // Set splashscreen as the initial screen
    );
  }
}
