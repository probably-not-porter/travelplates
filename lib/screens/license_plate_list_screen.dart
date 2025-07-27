// lib/screens/license_plate_list_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelplates/models/plate_entry.dart';

class LicensePlateListScreen extends StatefulWidget {
  final bool isSelectionMode;

  const LicensePlateListScreen({super.key, this.isSelectionMode = false});

  @override
  State<LicensePlateListScreen> createState() => _LicensePlateListScreenState();
}

class _LicensePlateListScreenState extends State<LicensePlateListScreen> {
  final List<String> _usStates = [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware',
    'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky',
    'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico',
    'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
    'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
    'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
  ];

  bool _isLoading = false; // <--- NEW: State variable to control loading spinner

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Please enable them to capture location.')),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied. Cannot capture location.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in app settings.')),
      );
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('LicensePlateListScreen: Captured Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('LicensePlateListScreen: Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: ${e.toString()}')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a State Plate'),
      ),
      body: Stack( // <--- NEW: Wrap body in a Stack to allow overlaying widgets
        children: [
          ListView.builder(
            itemCount: _usStates.length,
            itemBuilder: (context, index) {
              final stateName = _usStates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(stateName),
                  trailing: widget.isSelectionMode
                      ? const Icon(Icons.add_location_alt)
                      : null,
                  onTap: _isLoading // <--- MODIFIED: Disable onTap if loading
                      ? null // Setting onTap to null disables the tile
                      : () async {
                          if (widget.isSelectionMode) {
                            setState(() {
                              _isLoading = true; // <--- NEW: Show spinner when tap begins
                            });

                            Position? currentPosition = await _getCurrentLocation();

                            if (currentPosition != null) {
                              final plateEntry = PlateEntry(
                                plateName: stateName,
                                latitude: currentPosition.latitude,
                                longitude: currentPosition.longitude,
                                timestamp: DateTime.now(),
                              );
                              print('Plate Selected & Ready to Pop: ${plateEntry.plateName} at Lat: ${plateEntry.latitude}, Lon: ${plateEntry.longitude}');
                              // We don't set _isLoading to false here because Navigator.pop
                              // will unmount this widget, so setState will be cancelled.
                              Navigator.of(context).pop(plateEntry);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Location not captured. Plate not added.')),
                              );
                              setState(() {
                                _isLoading = false; // <--- NEW: Hide spinner if location fails and we don't pop
                              });
                              // If location cannot be obtained, we pop null, indicating no plate added
                              Navigator.of(context).pop(null);
                            }
                          }
                        },
                ),
              );
            },
          ),
          if (_isLoading) // <--- NEW: Conditional spinner overlay
            Container(
              // This container acts as a semi-transparent overlay
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(), // The actual spinner
              ),
            ),
        ],
      ),
    );
  }
}