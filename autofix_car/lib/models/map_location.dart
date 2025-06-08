// lib/models/map_location.dart
import 'package:flutter/material.dart'; // Ensure Offset is recognized

enum LocationType { academy, hotel, stadium, university, mechanicShop }

class MapLocation {
  final String name;
  final LocationType type;
  final Offset position;
  final String? phoneNumber; // <-- ADD THIS LINE (optional as not all locations might have a direct contact)

  MapLocation({
    required this.name,
    required this.type,
    required this.position,
    this.phoneNumber, // <-- ADD THIS LINE to constructor
  });
}