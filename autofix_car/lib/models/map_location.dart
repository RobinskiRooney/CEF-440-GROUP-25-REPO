import 'package:flutter/material.dart';

// Enum for different types of locations on the map
enum LocationType {
  academy,
  hotel,
  stadium,
  university,
  other, // Generic type for any other locations
}

// Model for a specific location on the map
class MapLocation {
  final String name;
  final LocationType type;
  final Offset position; // Used for static map representation (if not Google Maps LatLng)
  final String? phoneNumber; // Optional phone number for the location

  const MapLocation({
    required this.name,
    required this.type,
    required this.position,
    this.phoneNumber,
  });
}
