// lib/models/license_plate_models.dart
import 'dart:convert'; // Required for jsonEncode/jsonDecode

class LicensePlate {
  final String plateNumber;
  final String imageUrl; // URL or local asset path
  final DateTime dateSeen;
  final String? locationSeen; // Optional field

  LicensePlate({
    required this.plateNumber,
    required this.imageUrl,
    required this.dateSeen,
    this.locationSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'plateNumber': plateNumber,
      'imageUrl': imageUrl,
      'dateSeen': dateSeen.toIso8601String(), // Store DateTime as ISO string
      'locationSeen': locationSeen,
    };
  }

  factory LicensePlate.fromMap(Map<String, dynamic> map) {
    return LicensePlate(
      plateNumber: map['plateNumber'],
      imageUrl: map['imageUrl'],
      dateSeen: DateTime.parse(map['dateSeen']),
      locationSeen: map['locationSeen'],
    );
  }

  // Helper methods for list serialization (if storing list as JSON string in DB)
  static String listToJson(List<LicensePlate> plates) {
    return jsonEncode(plates.map((p) => p.toMap()).toList());
  }

  static List<LicensePlate> jsonToList(String jsonString) {
    if (jsonString.isEmpty) return []; // Handle empty string case
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((item) => LicensePlate.fromMap(item as Map<String, dynamic>)).toList();
  }

  @override
  String toString() {
    return 'LicensePlate(plateNumber: $plateNumber, dateSeen: $dateSeen)';
  }
}

class StateData {
  final String name;
  final String abbreviation;
  List<LicensePlate> seenPlates; // List of plates seen for this state

  StateData({
    required this.name,
    required this.abbreviation,
    List<LicensePlate>? seenPlates,
  }) : seenPlates = seenPlates ?? [];

  void addPlate(LicensePlate plate) {
    seenPlates.add(plate);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'abbreviation': abbreviation,
      'seenPlates': LicensePlate.listToJson(seenPlates), // Use helper for nested list
    };
  }

  factory StateData.fromMap(Map<String, dynamic> map) {
    return StateData(
      name: map['name'],
      abbreviation: map['abbreviation'],
      seenPlates: LicensePlate.jsonToList(map['seenPlates'] as String), // Use helper for nested list
    );
  }

  @override
  String toString() {
    return 'StateData(name: $name, abbreviation: $abbreviation, seenPlates: ${seenPlates.length} plates)';
  }
}