import 'package:flutter/cupertino.dart';

class StateDetailScreen extends StatelessWidget {
  final String stateName;

  const StateDetailScreen({super.key, required this.stateName});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(stateName),
        previousPageTitle: 'Back',
      ),
      child: Center(
        child: Text('You are on the $stateName detail screen.'),
      ),
    );
  }
}