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
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      
      if (contents.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(contents); // This line can throw if content is malformed
      
      final List<Trip> loadedTrips = jsonList.map((json) => Trip.fromJson(json)).toList();
      return loadedTrips;
    } catch (e) {
      try {
        final file = await _localFile;
        if (await file.exists()) {
          await file.delete();
        }
      } catch (deleteError) {
        print('TripStorage: Error deleting corrupted file: $deleteError');
      }
      return [];
    }
  }

  static Future<File> saveTrips(List<Trip> trips) async {
    final file = await _localFile;
    final List<Map<String, dynamic>> jsonList = trips.map((trip) => trip.toJson()).toList();
    final String jsonString = json.encode(jsonList);
    return file.writeAsString(jsonString, flush: true);
  }
}