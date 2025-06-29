class UserProfile {
  final String
  uid; // Corresponds to `uid` in your previous model, used as `uid` in EditProfilePage
  final String email;
  final String? name;
  final String?
  id; // Added: Corresponds to `id` in EditProfilePage (distinct from uid/UID)
  final String?
  userLocation; // Renamed from `location` to match EditProfilePage
  final String?
  imageUrl; // Added: For profile image URL, used in EditProfilePage
  final String? carModel;
  final String?
  mobileContact; // Renamed from `contact` to match EditProfilePage
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role; // Added: For user role, if applicable

  UserProfile({
    required this.uid, // Kept as required
    required this.email, // Kept as required
    this.name,
    this.id, // Now a field in the constructor
    this.userLocation, // Renamed
    this.imageUrl, // Now a field in the constructor
    this.carModel,
    this.mobileContact, // Renamed
    this.createdAt,
    this.updatedAt,
    this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      id: json['id'] as String? ?? '',
      userLocation: json['user_location'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      carModel: json['car_model'] as String? ?? '',
      role: json['role'] as String? ?? '',
      mobileContact: json['mobile_contact'] as String? ?? '',
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  static DateTime? _parseTimestamp(dynamic ts) {
    if (ts == null) return null;
    if (ts is String) {
      return DateTime.tryParse(ts);
    }
    if (ts is Map && ts['seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch((ts['seconds'] as int) * 1000);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      // 'uid' is typically the document ID in Firestore for user profiles, not a field to send.
      // 'email' is usually managed by authentication, not directly updatable via user profile.
      'name': name,
      'id': id, // Include if your backend needs to store this specific ID
      'user_location':
          userLocation, // Match backend field name if different from `location`
      'image_url': imageUrl, // Include if you're uploading image URLs
      'car_model': carModel,
      'role': role, // Include if your backend supports user roles
      'mobile_contact':
          mobileContact, // Match backend field name if different from `contact`
      // createdAt and updatedAt are typically set by the backend server
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? id, // Added to copyWith
    String? userLocation, // Renamed
    String? imageUrl, // Added to copyWith
    String? carModel,
    String? role,
    String? mobileContact, // Renamed
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      id: id ?? this.id, // Included in copyWith
      userLocation: userLocation ?? this.userLocation,
      imageUrl: imageUrl ?? this.imageUrl, // Included in copyWith
      carModel: carModel ?? this.carModel,
      role: role ?? this.role,
      mobileContact: mobileContact ?? this.mobileContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
