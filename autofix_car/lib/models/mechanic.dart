// lib/models/mechanic.dart
class Mechanic {
  final String name;
  final String address;
  final String location;
  final String imageUrl;
  final double rating;
  final bool isVerified;
  final String phoneNumber; // <-- ADD THIS LINE

  Mechanic({
    required this.name,
    required this.address,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.isVerified,
    required this.phoneNumber, // <-- ADD THIS LINE to constructor
  });
}