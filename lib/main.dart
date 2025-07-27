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
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TripListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}