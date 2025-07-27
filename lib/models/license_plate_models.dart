import 'dart:convert';

// Class for a single License plate 
// location not required because it might fail sometimes
class LicensePlate {
  final String plateNumber;
  final String imageUrl;
  final DateTime dateSeen;
  final String? locationSeen;

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
  List<LicensePlate> seenPlates;

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
      'seenPlates': LicensePlate.listToJson(seenPlates),
    };
  }

  factory StateData.fromMap(Map<String, dynamic> map) {
    return StateData(
      name: map['name'],
      abbreviation: map['abbreviation'],
      seenPlates: LicensePlate.jsonToList(map['seenPlates'] as String),
    );
  }

  @override
  String toString() {
    return 'StateData(name: $name, abbreviation: $abbreviation, seenPlates: ${seenPlates.length} plates)';
  }
}