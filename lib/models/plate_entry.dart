// lib/models/plate_entry.dart
class PlateEntry {
  final String plateName;
  final double latitude;
  final double longitude;
  final DateTime timestamp; // Optional: To record when it was captured

  PlateEntry({
    required this.plateName,
    required this.latitude,
    required this.longitude,
    DateTime? timestamp, // Make timestamp optional in constructor
  }) : timestamp = timestamp ?? DateTime.now(); // Default to now if not provided

  // Convert a PlateEntry object to a Map (JSON format)
  Map<String, dynamic> toJson() {
    return {
      'plateName': plateName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a PlateEntry object from a Map (JSON format)
  factory PlateEntry.fromJson(Map<String, dynamic> json) {
    return PlateEntry(
      plateName: json['plateName'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}