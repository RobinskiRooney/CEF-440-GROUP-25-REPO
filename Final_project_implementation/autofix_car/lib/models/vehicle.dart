class Vehicle {
  final String id;
  final String ownerUid;
  final String make;
  final String model;
  final int year;
  final String vin;
  final String nickname;
  final String healthStatus;
  final DateTime? lastScanDate;
  final DateTime? createdAt;

  Vehicle({
    required this.id,
    required this.ownerUid,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.nickname,
    required this.healthStatus,
    this.lastScanDate,
    this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      ownerUid: json['owner_uid'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      vin: json['VIN'] as String,
      nickname: json['nickname'] as String,
      healthStatus: json['health_status'] as String,
      lastScanDate: (json['last_scan_date']?._seconds != null) ? DateTime.fromMillisecondsSinceEpoch(json['last_scan_date']._seconds * 1000) : null,
      createdAt: (json['createdAt']?._seconds != null) ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']._seconds * 1000) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_uid': ownerUid,
      'make': make,
      'model': model,
      'year': year,
      'VIN': vin,
      'nickname': nickname,
      'health_status': healthStatus,
      // last_scan_date and createdAt are typically managed by backend
    };
  }

  Vehicle copyWith({
    String? id,
    String? ownerUid,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? nickname,
    String? healthStatus,
    DateTime? lastScanDate,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      nickname: nickname ?? this.nickname,
      healthStatus: healthStatus ?? this.healthStatus,
      lastScanDate: lastScanDate ?? this.lastScanDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
