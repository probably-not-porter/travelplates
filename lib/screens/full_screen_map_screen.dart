import 'package:travelplates/models/plate_entry.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class FullScreenMapScreen extends StatelessWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<PlateEntry> collectedPlates;

  const FullScreenMapScreen({
    super.key,
    required this.initialCenter,
    required this.initialZoom,
    required this.collectedPlates,
  });

  List<Marker> _getMapMarkers() {
    return collectedPlates.map<Marker>((plateEntry) {
      return Marker(
        point: LatLng(plateEntry.latitude, plateEntry.longitude),
        width: 80.0,
        height: 80.0,
        child: Column(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter, // Use the passed initial center
          initialZoom: initialZoom,     // Use the passed initial zoom
          minZoom: 2.0,
          maxZoom: 18.0,
          keepAlive: true, // Keep map state alive if navigating away and back
          // Allow full interaction (pan, zoom) in fullscreen mode
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.travelplates',
          ),
          MarkerLayer(
            markers: _getMapMarkers(),
          ),
        ],
      ),
    );
  }
}