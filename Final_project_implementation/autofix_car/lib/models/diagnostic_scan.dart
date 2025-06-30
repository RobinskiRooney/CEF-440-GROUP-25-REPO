class DiagnosticScan {
  final String? id; // Made nullable to reflect it's assigned by backend upon creation
  final String vehicleId;
  final DateTime scanDateTime;
  final String scanType; // ENUM('OBD_SCAN', 'DASHBOARD_LIGHT_SCAN', 'ENGINE_SOUND_DIAGNOSIS')
  final String summary;
  final String status; // ENUM('No Faults', 'Faults Detected', 'Needs Attention')
  final String createdByUid;

  // Type-specific fields (nullable, only one set will be non-null per scan type)
  final String? lightImageUrl;
  final String? identifiedLightName;
  final String? lightExplanation;

  final String? recordedSoundUrl;
  final String? soundDiagnosisResult;
  final List<String>? potentialCauses;

  final List<String>? dtcCodes;
  final Map<String, dynamic>? freezeFrameData;

  DiagnosticScan({
    this.id, // Now nullable, no longer required when creating a new object
    required this.vehicleId,
    required this.scanDateTime,
    required this.scanType,
    required this.summary,
    required this.status,
    required this.createdByUid,
    this.lightImageUrl,
    this.identifiedLightName,
    this.lightExplanation,
    this.recordedSoundUrl,
    this.soundDiagnosisResult,
    this.potentialCauses,
    this.dtcCodes,
    this.freezeFrameData,
  });

  factory DiagnosticScan.fromJson(Map<String, dynamic> json) {
    return DiagnosticScan(
      id: json['id'] as String?, // Parse as nullable String
      vehicleId: json['vehicle_id'] as String,
      scanDateTime: (json['scan_date_time']?._seconds != null) ? DateTime.fromMillisecondsSinceEpoch(json['scan_date_time']._seconds * 1000) : DateTime.now(),
      scanType: json['scan_type'] as String,
      summary: json['summary'] as String,
      status: json['status'] as String,
      createdByUid: json['created_by_uid'] as String,
      lightImageUrl: json['light_image_url'] as String?,
      identifiedLightName: json['identified_light_name'] as String?,
      lightExplanation: json['light_explanation'] as String?,
      recordedSoundUrl: json['recorded_sound_url'] as String?,
      soundDiagnosisResult: json['sound_diagnosis_result'] as String?,
      potentialCauses: (json['potential_causes'] as List?)?.map((e) => e as String).toList(),
      dtcCodes: (json['dtc_codes'] as List?)?.map((e) => e as String).toList(),
      freezeFrameData: json['freeze_frame_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // 'id': id, // Do not send ID to backend for creation, it generates it
      'vehicle_id': vehicleId,
      'scan_type': scanType,
      'summary': summary,
      'status': status,
      // createdByUid is from token, scanDateTime is server timestamp
    };

    // Add type-specific fields if available
    if (scanType == 'DASHBOARD_LIGHT_SCAN') {
      data['light_image_url'] = lightImageUrl;
      data['identified_light_name'] = identifiedLightName;
      data['light_explanation'] = lightExplanation;
    } else if (scanType == 'ENGINE_SOUND_DIAGNOSIS') {
      data['recorded_sound_url'] = recordedSoundUrl;
      data['sound_diagnosis_result'] = soundDiagnosisResult;
      data['potential_causes'] = potentialCauses;
    } else if (scanType == 'OBD_SCAN') {
      data['dtc_codes'] = dtcCodes;
      data['freeze_frame_data'] = freezeFrameData;
    }

    return data;
  }

  DiagnosticScan copyWith({
    String? id,
    String? vehicleId,
    DateTime? scanDateTime,
    String? scanType,
    String? summary,
    String? status,
    String? createdByUid,
    String? lightImageUrl,
    String? identifiedLightName,
    String? lightExplanation,
    String? recordedSoundUrl,
    String? soundDiagnosisResult,
    List<String>? potentialCauses,
    List<String>? dtcCodes,
    Map<String, dynamic>? freezeFrameData,
  }) {
    return DiagnosticScan(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      scanDateTime: scanDateTime ?? this.scanDateTime,
      scanType: scanType ?? this.scanType,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      createdByUid: createdByUid ?? this.createdByUid,
      lightImageUrl: lightImageUrl ?? this.lightImageUrl,
      identifiedLightName: identifiedLightName ?? this.identifiedLightName,
      lightExplanation: lightExplanation ?? this.lightExplanation,
      recordedSoundUrl: recordedSoundUrl ?? this.recordedSoundUrl,
      soundDiagnosisResult: soundDiagnosisResult ?? this.soundDiagnosisResult,
      potentialCauses: potentialCauses ?? this.potentialCauses,
      dtcCodes: dtcCodes ?? this.dtcCodes,
      freezeFrameData: freezeFrameData ?? this.freezeFrameData,
    );
  }
}
