// lib/models/mechanic.dart
class Mechanic {
  final String name;
  final String address;
  final String location;
  final String imageUrl;
  final double rating;
  final bool isVerified;

  Mechanic({
    required this.name,
    required this.address,
    required this.location,
    required this.imageUrl,
    required this.rating,
    this.isVerified = false,
  });
}