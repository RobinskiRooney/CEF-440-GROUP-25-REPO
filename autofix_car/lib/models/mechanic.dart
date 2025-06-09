class Mechanic {
  final String? id; // Made nullable to reflect it's assigned by backend or might be null initially
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final double rating;
  final String verificationStatus; // 'Verified', 'Unverified'
  final double latitude;
  final double longitude;
  final List<String> specialties;
  final DateTime? createdAt; // Nullable DateTime

  Mechanic({
    this.id, // No longer required in constructor
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    this.rating = 0.0,
    this.verificationStatus = 'Unverified',
    required this.latitude,
    required this.longitude,
    this.specialties = const [],
    this.createdAt,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'] as String?, // Correctly parses as nullable String
      name: json['name'] as String? ?? '', // Added null-aware operator with default empty string
      address: json['address'] as String? ?? '', // Added null-aware operator with default empty string
      phone: json['phone'] as String? ?? '', // Added null-aware operator with default empty string
      email: json['email'] as String?,
      website: json['website'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      verificationStatus: json['verification_status'] as String? ?? 'Unverified',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0, // Added null-aware operator with default 0.0
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0, // Added null-aware operator with default 0.0
      specialties: (json['specialties'] as List?)?.map((e) => e as String).toList() ?? [],
      // UPDATED: More robust parsing for createdAt from JSON
      createdAt: (json['createdAt'] is Map && json['createdAt'].containsKey('_seconds'))
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']['_seconds'] * 1000)
          : null, // Safely handles cases where _seconds might be missing or json['createdAt'] isn't a Map
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Don't send ID to backend for creation, it generates it
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'rating': rating,
      'verification_status': verificationStatus,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      // createdAt handled by backend via serverTimestamp()
    };
  }

  Mechanic copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? website,
    double? rating,
    String? verificationStatus,
    double? latitude,
    double? longitude,
    List<String>? specialties,
    DateTime? createdAt,
  }) {
    return Mechanic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specialties: specialties ?? this.specialties,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
