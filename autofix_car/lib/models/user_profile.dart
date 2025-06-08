// lib/models/user_profile.dart
class UserProfile {
  final String userId; // Crucial for Firestore, even if not used for local files
  final String name;
  final String id;
  final String userLocation;
  final String imageUrl; // This will still hold the *original* network URL
  final String email;
  final String carModel;
  final String mobileContact;

  UserProfile({
    required this.userId,
    required this.name,
    required this.id,
    required this.userLocation,
    required this.imageUrl,
    required this.email,
    required this.carModel,
    required this.mobileContact,
  });

  // ... (fromMap, toMap, copyWith methods if you have them, not strictly needed for this local-only image logic)
  UserProfile copyWith({
    String? name,
    String? id,
    String? userLocation,
    String? imageUrl,
    String? email,
    String? carModel,
    String? mobileContact,
  }) {
    return UserProfile(
      userId: this.userId,
      name: name ?? this.name,
      id: id ?? this.id,
      userLocation: userLocation ?? this.userLocation,
      imageUrl: imageUrl ?? this.imageUrl, // Keep existing if not provided
      email: email ?? this.email,
      carModel: carModel ?? this.carModel,
      mobileContact: mobileContact ?? this.mobileContact,
    );
  }
}