// lib/models/trip.dart
import 'package:uuid/uuid.dart'; // Correct import for Uuid
import 'package:travelplates/models/plate_entry.dart'; // <--- NEW: Import PlateEntry

class Trip {
  final String id;
  String name;
  final DateTime creationDate;
  List<PlateEntry> collectedPlates; // <--- MODIFIED: Now a list of PlateEntry
  DateTime? lastEditDate;

  Trip({
    String? id,
    required this.name,
    DateTime? creationDate,
    List<PlateEntry>? collectedPlates, // <--- MODIFIED: Constructor expects PlateEntry list
    this.lastEditDate,
  })  : id = id ?? const Uuid().v4(),
        creationDate = creationDate ?? DateTime.now(),
        collectedPlates = collectedPlates ?? [] {
    this.lastEditDate = lastEditDate ?? this.creationDate;
  }

  // Convert a Trip object to a Map (JSON format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creationDate': creationDate.toIso8601String(),
      'collectedPlates': collectedPlates.map((entry) => entry.toJson()).toList(), // <--- MODIFIED: Map each PlateEntry to JSON
      'lastEditDate': lastEditDate?.toIso8601String(),
    };
  }

  // Create a Trip object from a Map (JSON format)
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      name: json['name'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      collectedPlates: (json['collectedPlates'] as List<dynamic>?) // <--- MODIFIED: Handle nullable list
          ?.map((item) => PlateEntry.fromJson(item as Map<String, dynamic>)) // <--- MODIFIED: Map each item back to PlateEntry
          .toList() ?? [], // Provide default empty list if null
      lastEditDate: json['lastEditDate'] != null
          ? DateTime.parse(json['lastEditDate'] as String)
          : null,
    );
  }
}