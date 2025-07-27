// lib/data/initial_states.dart

import '../models/license_plate_models.dart'; // Import your models

final List<String> usStateNames = [
  'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
  'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
  'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
  'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
  'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
  'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
  'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
  'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia',
  'Washington', 'West Virginia', 'Wisconsin', 'Wyoming', 'Other'
];

// Optional: A function to create initial StateData objects if you need them pre-populated
List<StateData> createInitialStateData() {
  return usStateNames.map((name) {
    String abbreviation = name.substring(0,2).toUpperCase(); // Simple placeholder
    if (name == 'New York') abbreviation = 'NY'; // Example specific abbreviation
    // You'd have a more robust way to get real abbreviations
    return StateData(name: name, abbreviation: abbreviation);
  }).toList();
}