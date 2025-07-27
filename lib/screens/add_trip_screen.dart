import 'package:flutter/material.dart';
import 'package:travelplates/models/trip.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final TextEditingController _tripNameController = TextEditingController();

  @override
  void dispose() {
    _tripNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('New Trip'),
        actions: [
          TextButton(
            onPressed: () {
              if (_tripNameController.text.isNotEmpty) {
                final newTrip = Trip(name: _tripNameController.text);
                Navigator.of(context).pop(newTrip);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip name cannot be empty!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _tripNameController,
                decoration: InputDecoration(
                  labelText: 'Trip Name',
                  hintText: 'Enter Trip Name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _tripNameController.clear,
                  ),
                ),
                autofocus: true,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final newTrip = Trip(name: value);
                    Navigator.of(context).pop(newTrip);
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trip name cannot be empty!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}