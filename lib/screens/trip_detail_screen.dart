// lib/screens/trip_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:travelplates/models/trip.dart';
import 'package:travelplates/models/plate_entry.dart';
import 'package:travelplates/screens/license_plate_list_screen.dart';
import 'package:travelplates/services/trip_storage.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travelplates/data/state_centroids.dart'; // Ensure this import is correct

// <--- NEW: Flutter Map Imports ---
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng
// <--- END NEW IMPORTS ---


class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  bool _hasChanges = false;
  // <--- NEW: Map Controller for potential future use (optional) ---
  final MapController _mapController = MapController();
  // <--- END NEW ---


  void _addPlateToTrip(PlateEntry newPlateEntry) {
    setState(() {
      if (!widget.trip.collectedPlates.any((entry) => entry.plateName == newPlateEntry.plateName)) {
        widget.trip.collectedPlates.add(newPlateEntry);
        widget.trip.lastEditDate = DateTime.now();
        _hasChanges = true;
        print('TripDetailScreen: Added plate. _hasChanges = $_hasChanges');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${newPlateEntry.plateName} already collected for this trip!')),
        );
      }
    });
  }

  void _onPlateDismissed(int index, DismissDirection direction) {
    final PlateEntry plateToRemove = widget.trip.collectedPlates[index];

    setState(() {
      widget.trip.collectedPlates.removeAt(index);
      widget.trip.lastEditDate = DateTime.now();
      _hasChanges = true;
      print('TripDetailScreen: Removed plate. _hasChanges = $_hasChanges');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${plateToRemove.plateName}'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              widget.trip.collectedPlates.insert(index, plateToRemove);
              widget.trip.lastEditDate = DateTime.now();
              _hasChanges = true;
              print('TripDetailScreen: Undid plate removal. _hasChanges = $_hasChanges');
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getDistanceToCentroid(PlateEntry plateEntry) {
    final centroidData = usStateCentroids[plateEntry.plateName];

    if (centroidData == null) {
      return 'Centroid not found';
    }

    final double stateLat = centroidData['lat']!;
    final double stateLon = centroidData['lon']!;

    final double distanceInMeters = Geolocator.distanceBetween(
      plateEntry.latitude,
      plateEntry.longitude,
      stateLat,
      stateLon,
    );

    final double distanceInMiles = distanceInMeters * 0.000621371;

    if (distanceInMiles < 0.5) {
      return 'Very close to center';
    } else if (distanceInMiles < 100) {
      return '${distanceInMiles.toStringAsFixed(1)} miles from center';
    } else {
      return '${distanceInMiles.round()} miles from center';
    }
  }

  // --- NEW: Helper to get map markers from collected plates ---
  List<Marker> _getMapMarkers() {
    return widget.trip.collectedPlates.map<Marker>((plateEntry) { // <--- MODIFIED this line
      return Marker(
        point: LatLng(plateEntry.latitude, plateEntry.longitude),
        width: 80.0,
        height: 80.0,
        child: Column( // <--- MODIFIED this line (from builder to child)
          children: [
            Icon(Icons.location_on, color: Colors.red[700], size: 30),
            Text(
              plateEntry.plateName.substring(0, 3).toUpperCase(),
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      );
    }).toList();
  }

  // --- NEW: Helper to get initial map center and zoom ---
  LatLng _getInitialMapCenter() {
    if (widget.trip.collectedPlates.isEmpty) {
      // Default to approximate center of US if no plates
      return const LatLng(39.8283, -98.5795); // Geographic center of the contiguous US
    }

    // Calculate average of all collected plate locations
    double latSum = 0;
    double lonSum = 0;
    for (var plate in widget.trip.collectedPlates) {
      latSum += plate.latitude;
      lonSum += plate.longitude;
    }
    return LatLng(latSum / widget.trip.collectedPlates.length, lonSum / widget.trip.collectedPlates.length);
  }

  double _getInitialMapZoom() {
    if (widget.trip.collectedPlates.length <= 1) {
      return 5.0; // Zoom in for a single or no plate
    }
    // You might want more sophisticated logic here to calculate zoom based on spread
    // For now, a slightly zoomed out view for multiple plates
    return 4.0;
  }
  // --- END NEW HELPERS ---

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        final tripToReturn = _hasChanges ? widget.trip : null;
        print('TripDetailScreen: PopScope invoked. _hasChanges=$_hasChanges. Returning: ${tripToReturn != null ? 'Trip object' : 'null'}');
        Navigator.of(context).pop(tripToReturn);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.trip.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final tripToReturn = _hasChanges ? widget.trip : null;
              print('TripDetailScreen: AppBar back button pressed. _hasChanges=$_hasChanges. Returning: ${tripToReturn != null ? 'Trip object' : 'null'}');
              Navigator.of(context).pop(tripToReturn);
            },
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final PlateEntry? selectedPlateEntry = await Navigator.of(context).push(
                  MaterialPageRoute<PlateEntry>(
                    builder: (context) => const LicensePlateListScreen(
                      isSelectionMode: true,
                    ),
                  ),
                );

                if (selectedPlateEntry != null) {
                  _addPlateToTrip(selectedPlateEntry);
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: SafeArea(
          child: Column( // Main Column to hold collapsible list and map
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // <--- MODIFIED: Collapsible Plate List with ExpansionTile ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0), // Adjust padding
                child: Card( // Wrap in Card for better visual separation
                  margin: const EdgeInsets.all(0),
                  child: ExpansionTile(
                    initiallyExpanded: true, // Start expanded
                    title: Text(
                      'Collected Plates (${widget.trip.collectedPlates.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    children: [
                      // Only show the ListView.builder if there are plates, otherwise a message
                      if (widget.trip.collectedPlates.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No plates collected for this trip yet.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true, // <--- IMPORTANT for ListView inside ExpansionTile
                          physics: const NeverScrollableScrollPhysics(), // <--- IMPORTANT to prevent inner scrolling
                          itemCount: widget.trip.collectedPlates.length,
                          itemBuilder: (context, index) {
                            final plateEntry = widget.trip.collectedPlates[index];
                            final String formattedTimestamp = DateFormat('MMM d, HH:mm').format(plateEntry.timestamp);
                            final String distanceString = _getDistanceToCentroid(plateEntry);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjusted padding
                              child: Dismissible(
                                key: ValueKey(plateEntry.plateName),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  _onPlateDismissed(index, direction);
                                },
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 1.0,
                                  child: ListTile(
                                    title: Text(
                                      plateEntry.plateName,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          distanceString,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'Spotted: $formattedTimestamp',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // <--- NEW: Map Window ---
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Expanded( // Use Expanded to give the map remaining space
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    elevation: 2.0,
                    clipBehavior: Clip.antiAlias, // For rounded corners
                    child: FlutterMap(
                      mapController: _mapController, // Assign controller
                      options: MapOptions(
                        initialCenter: _getInitialMapCenter(), // Center map based on plates or default
                        initialZoom: _getInitialMapZoom(),     // Initial zoom
                        minZoom: 2.0, // Allow zooming out to world view
                        maxZoom: 18.0, // Allow zooming in
                        keepAlive: true, // Keep map state alive if parent widget rebuilds
                        // Optional: Disable interaction if it's just for display
                        // interactionOptions: const InteractionOptions(
                        //   flags: ~InteractiveFlag.all, // Disable all interaction
                        // ),
                      ),
                      children: [
                        TileLayer(
                          // OpenStreetMap tiles
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.travelplates', // Replace with your package name
                        ),
                        MarkerLayer(
                          markers: _getMapMarkers(), // Add markers for collected plates
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}