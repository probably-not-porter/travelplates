import 'package:flutter/material.dart';

class StateDetailScreen extends StatelessWidget {
  final String stateName;

  const StateDetailScreen({super.key, required this.stateName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stateName),
      ),
      body: Center(
        child: Text('You are on the $stateName detail screen.'),
      ),
    );
  }
}