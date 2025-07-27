import 'package:flutter/material.dart';
import 'package:travelplates/models/trip.dart';
import 'package:travelplates/screens/add_trip_screen.dart';
import 'package:travelplates/screens/trip_detail_screen.dart';
import 'package:travelplates/services/trip_storage.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  List<Trip> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final loadedTrips = await TripStorage.loadTrips();
    setState(() {
      // Sort trips by lastEditDate, newest first
      _trips = loadedTrips..sort((a, b) => (b.lastEditDate ?? b.creationDate).compareTo(a.lastEditDate ?? a.creationDate));
    });
  }

  Future<void> _saveTrips() async {
    await TripStorage.saveTrips(_trips);
  }

  void _addTrip(Trip newTrip) {
    setState(() {
      _trips.add(newTrip);
      _trips.sort((a, b) => (b.lastEditDate ?? b.creationDate).compareTo(a.lastEditDate ?? a.creationDate)); // Re-sort
    });
    print('TripListScreen: Adding new trip "${newTrip.name}". Calling _saveTrips.');
    _saveTrips();
  }

  void _confirmAndDeleteTrip(Trip trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trip?'),
          content: Text('Are you sure you want to delete "${trip.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _trips.removeWhere((t) => t.id == trip.id);
                  // No need to sort here, loadTrips will re-sort
                });
                print('TripListScreen: Deleting trip "${trip.name}". Calling _saveTrips.');
                await _saveTrips();
                await _loadTrips();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Trip "${trip.name}" deleted.')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTripDetail(Trip trip) async {
    final Trip? updatedTrip = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripDetailScreen(trip: trip),
      ),
    );

    print('TripListScreen: _navigateToTripDetail received result. updatedTrip is null: ${updatedTrip == null}');

    if (updatedTrip != null) {
      print('TripListScreen: Received updatedTrip for ID: ${updatedTrip.id} with ${updatedTrip.collectedPlates.length} plates.');
      final int index = _trips.indexWhere((t) => t.id == updatedTrip.id);
      if (index != -1) {
        setState(() {
          _trips[index] = updatedTrip; // Replace the old trip with the updated one
          _trips.sort((a, b) => (b.lastEditDate ?? b.creationDate).compareTo(a.lastEditDate ?? a.creationDate)); // Re-sort after update
        });
        print('TripListScreen: About to save trips (after edit to trip ID: ${updatedTrip.id})...');
        await _saveTrips();
        print('TripListScreen: Trips saved. About to reload...');
        await _loadTrips();
        print('TripListScreen: Trips reloaded.');
      } else {
        print('TripListScreen: Error: updatedTrip ID not found in _trips list! This should not happen.');
      }
    } else {
      print('TripListScreen: TripDetailScreen popped with no changes or null trip.');
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 10) { // Very short time
      return 'just now';
    } else if (difference.inMinutes < 1) { // Between 10 seconds and 1 minute
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) { // Minutes
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) { // Hours
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) { // Days
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) { // Weeks (approx. 4 weeks)
      final weeks = (difference.inDays / 7).floor(); // Use floor to avoid "5 weeks ago" for 29 days
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) { // Months (approx. 12 months)
      final months = (difference.inDays / 30).floor(); // Use floor
      return '$months month${months == 1 ? '' : 's'} ago';
    } else { // Years
      final years = (difference.inDays / 365).floor(); // Use floor
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newTrip = await Navigator.of(context).push(
                MaterialPageRoute<Trip>(
                  builder: (context) => const AddTripScreen(),
                  fullscreenDialog: true,
                ),
              );
              if (newTrip != null) {
                _addTrip(newTrip);
              }
            },
          ),
        ],
      ),
      body: _trips.isEmpty
          ? Center(
              child: Text(
                'No trips yet! Tap + to create one.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                final String formattedTimeAgo = _formatTimeAgo(trip.lastEditDate ?? trip.creationDate);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () => _navigateToTripDetail(trip),
                      onLongPress: () => _confirmAndDeleteTrip(trip),
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${trip.collectedPlates.length} / 50 states',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'Edited $formattedTimeAgo',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}