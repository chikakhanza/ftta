import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF9B4064),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF9B4064),
          secondary: const Color(0xFFB76A8A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8EAF1),
        fontFamily: 'Serif',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
