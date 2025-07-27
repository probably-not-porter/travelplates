// lib/screens/state_detail_screen.dart
import 'package:flutter/cupertino.dart'; // Make sure this import is here

class StateDetailScreen extends StatelessWidget {
  final String stateName;

  const StateDetailScreen({super.key, required this.stateName});

  @override
  Widget build(BuildContext context) {
    // This is the absolute minimum you need for a navigation screen.
    // It should *never* freeze unless there's a fundamental Flutter or device issue.
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(stateName),
        previousPageTitle: 'Back', // Simple back title
      ),
      child: Center( // Center content
        child: Text('You are on the $stateName detail screen.'), // Simple text
      ),
    );
  }
}