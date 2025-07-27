// lib/main.dart
import 'package:flutter/material.dart';
import 'package:travelplates/screens/trip_list_screen.dart';

void main() {
  runApp(const PlateTrackerApp());
}

class PlateTrackerApp extends StatelessWidget {
  const PlateTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License Plate Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme( // <--- REMOVED 'const' HERE
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          // Material 3 defaults are quite good, so you might not need extensive customization here.
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme( // <--- REMOVED 'const' HERE
          backgroundColor: Colors.blueGrey[900], // Dark mode AppBar background
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TripListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}