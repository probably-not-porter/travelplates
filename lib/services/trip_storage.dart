import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:travelplates/models/trip.dart';

class TripStorage {
  static const String _fileName = 'trips.json';

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  static Future<List<Trip>> loadTrips() async {
    try {
      final file = await _localFile;
      print('TripStorage: Attempting to load from file: ${file.path}');

      if (!await file.exists()) {
        print('TripStorage: File does not exist, returning empty list.');
        return [];
      }

      final contents = await file.readAsString();
      print('TripStorage: Raw content read: ${contents.length > 500 ? contents.substring(0, 500) + '...' : contents}');
      
      if (contents.isEmpty) {
        print('TripStorage: File content is empty, returning empty list.');
        return [];
      }

      final List<dynamic> jsonList = json.decode(contents); // This line can throw if content is malformed
      print('TripStorage: Decoded JSON list successfully.');
      
      final List<Trip> loadedTrips = jsonList.map((json) => Trip.fromJson(json)).toList();
      print('TripStorage: Successfully loaded ${loadedTrips.length} trips.');
      for (var trip in loadedTrips) {
        print('TripStorage: Loaded Trip "${trip.name}" with ${trip.collectedPlates.length} plates.');
      }
      return loadedTrips;
    } catch (e) {
      print('TripStorage: !!! ERROR loading trips: $e');
      try {
        final file = await _localFile;
        if (await file.exists()) {
          await file.delete();
          print('TripStorage: Deleted corrupted trips.json to prevent further errors.');
        }
      } catch (deleteError) {
        print('TripStorage: Error deleting corrupted file: $deleteError');
      }
      return [];
    }
  }

  static Future<File> saveTrips(List<Trip> trips) async {
    final file = await _localFile;
    print('TripStorage: Attempting to save to file: ${file.path}');

    final List<Map<String, dynamic>> jsonList = trips.map((trip) => trip.toJson()).toList();
    final String jsonString = json.encode(jsonList);
    print('TripStorage: Raw content to save: ${jsonString.length > 500 ? jsonString.substring(0, 500) + '...' : jsonString}');
    print('TripStorage: Saving ${trips.length} trips.');

    return file.writeAsString(jsonString, flush: true);
  }
}