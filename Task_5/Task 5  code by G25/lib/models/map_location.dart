// lib/models/map_location.dart
import 'package:flutter/material.dart';

enum LocationType {
  academy,
  hotel,
  stadium,
  university,
  // Add other types as needed
}

class MapLocation {
  final String name;
  final LocationType type;
  final Offset position; // Position on the map image

  MapLocation({
    required this.name,
    required this.type,
    required this.position,
  });
}