import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelplates/models/plate_entry.dart';

class LicensePlateListScreen extends StatefulWidget {
  final bool isSelectionMode;
  final List<PlateEntry> currentTripPlates;

  const LicensePlateListScreen({
    super.key,
    this.isSelectionMode = false,
    this.currentTripPlates = const [], // Default to an empty list
  });

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

  List<String> _displayStates = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filterStates(); // Call filter states when the widget is initialized
  }

  void _filterStates() {
    if (widget.isSelectionMode && widget.currentTripPlates.isNotEmpty) {
      final Set<String> collectedPlateNames = widget.currentTripPlates.map((entry) => entry.plateName).toSet();
      _displayStates = _usStates.where((state) => !collectedPlateNames.contains(state)).toList();
    } else {
      _displayStates = List.from(_usStates);
    }
  }


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
      return position;
    } catch (e) {
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
      body: Stack(
        children: [
          _displayStates.isEmpty && widget.isSelectionMode
              ? const Center(
                  child: Text(
                    'All states collected for this trip!\nNo new states to add.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _displayStates.length, // Use the filtered list
                  itemBuilder: (context, index) {
                    final stateName = _displayStates[index]; // Use the filtered list
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(stateName),
                        trailing: widget.isSelectionMode
                            ? const Icon(Icons.add_location_alt)
                            : null,
                        onTap: _isLoading
                            ? null // Setting onTap to null disables the tile
                            : () async {
                                if (widget.isSelectionMode) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  Position? currentPosition = await _getCurrentLocation();

                                  if (currentPosition != null) {
                                    final plateEntry = PlateEntry(
                                      plateName: stateName,
                                      latitude: currentPosition.latitude,
                                      longitude: currentPosition.longitude,
                                      timestamp: DateTime.now(),
                                    );
                                    Navigator.of(context).pop(plateEntry);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Location not captured. Plate not added.')),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    // Pop null if location isn't captured to signal no plate was added successfully
                                    Navigator.of(context).pop(null);
                                  }
                                }
                              },
                      ),
                    );
                  },
                ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}