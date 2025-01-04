// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'page/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure all widgets are initialized before Firebase
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TSB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color.fromARGB(255, 235, 235, 230),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 235, 235, 230),
          foregroundColor: const Color.fromARGB(255, 5, 5, 5),
          surfaceTintColor: Colors.white,

          elevation: 4, // Set elevation for shadow effect
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'FontMain'),
          bodyMedium: TextStyle(fontFamily: 'FontMain'),
          bodySmall: TextStyle(fontFamily: 'FontMain'),
          titleLarge: TextStyle(fontFamily: 'FontMain'),
          titleMedium: TextStyle(fontFamily: 'FontMain'),
          titleSmall: TextStyle(fontFamily: 'FontMain'),
          headlineLarge: TextStyle(fontFamily: 'FontMain'),
          headlineMedium: TextStyle(fontFamily: 'FontMain'),
          headlineSmall: TextStyle(fontFamily: 'FontMain'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(
                255, 33, 150, 243)), // Set button background color
            foregroundColor: MaterialStateProperty.all(
                Colors.white), // Set text and icon color
            elevation: MaterialStateProperty.all(4), // Set elevation
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
