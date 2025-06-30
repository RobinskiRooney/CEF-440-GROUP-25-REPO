// lib/widgets/map_section.dart
import 'package:flutter/material.dart';
import '../models/map_location.dart';

class MapSection extends StatelessWidget {
  final List<MapLocation> mapLocations;
  final Function(MapLocation) onLocationTap;

  const MapSection({
    super.key,
    required this.mapLocations,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Fixed height for the map section
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Placeholder background for the map
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Placeholder for the map image
            // You should replace 'assets/map_placeholder.png' with your actual map image
            Image.asset(
              'assets/map_placeholder.png', // This asset needs to be added to your pubspec.yaml
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 50, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Map Image Not Found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Add assets/map_placeholder.png',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Map markers
            ...mapLocations.map((location) {
              return Positioned(
                left: location.position.dx,
                top: location.position.dy,
                child: GestureDetector(
                  onTap: () => onLocationTap(location),
                  child: Tooltip( // Added Tooltip for better UX
                    message: location.name,
                    child: Icon(
                      Icons.location_on,
                      color: location.type == LocationType.academy
                          ? Colors.purple
                          : location.type == LocationType.hotel
                              ? Colors.orange
                              : location.type == LocationType.stadium
                                  ? Colors.green
                                  : location.type == LocationType.university
                                      ? Colors.red
                                      : Colors.blue, // Default color
                      size: 30,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}