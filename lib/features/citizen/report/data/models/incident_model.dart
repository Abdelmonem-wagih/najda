import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ─── Canonical Status Machine ─────────────────────────────────────
class IncidentStatus {
  static const String reported = 'reported';
  static const String aiAssigning = 'ai_assigning';
  static const String assigned = 'assigned';
  static const String enRoute = 'en_route';
  static const String arrived = 'arrived';
  static const String resolved = 'resolved';
  static const String unassigned = 'unassigned';
  static const String reassigned = 'reassigned';

  static String label(String status) {
    const map = {
      'reported': 'تم الإبلاغ',
      'ai_assigning': 'جاري التعيين',
      'assigned': 'تم التعيين',
      'en_route': 'في الطريق',
      'arrived': 'وصل الموقع',
      'resolved': 'مكتمل',
      'unassigned': 'غير معين',
      'reassigned': 'تمت إعادة التعيين',
    };
    return map[status] ?? status;
  }
}

class IncidentLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String geohash;

  const IncidentLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.geohash,
  });

  factory IncidentLocation.fromMap(Map<String, dynamic> map) {
    return IncidentLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      geohash: map['geohash'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'geohash': geohash,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, address, geohash];
}

class IncidentAssignment extends Equatable {
  final String? ambulanceId;
  final String? vehicleId;
  final String? driverName;
  final Timestamp? assignedAt;
  final String assignedBy; // "ai" | "admin" | "system"
  final double? aiConfidenceScore;
  final String? aiRationale;

  const IncidentAssignment({
    this.ambulanceId,
    this.vehicleId,
    this.driverName,
    this.assignedAt,
    required this.assignedBy,
    this.aiConfidenceScore,
    this.aiRationale,
  });

  factory IncidentAssignment.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const IncidentAssignment(assignedBy: 'system');
    return IncidentAssignment(
      ambulanceId: map['ambulanceId'] as String? ?? map['paramedicId'] as String?,
      vehicleId: map['vehicleId'] as String? ?? map['ambulancePlate'] as String? ?? map['ambulanceId'] as String?,
      driverName: map['driverName'] as String? ?? map['paramedicName'] as String?,
      assignedAt: map['assignedAt'] as Timestamp?,
      assignedBy: map['assignedBy'] as String? ?? 'system',
      aiConfidenceScore: (map['aiConfidenceScore'] as num?)?.toDouble(),
      aiRationale: map['aiRationale'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ambulanceId': ambulanceId,
      'vehicleId': vehicleId,
      'driverName': driverName,
      'assignedAt': assignedAt,
      'assignedBy': assignedBy,
      'aiConfidenceScore': aiConfidenceScore,
      'aiRationale': aiRationale,
    };
  }

  @override
  List<Object?> get props => [
        ambulanceId,
        vehicleId,
        driverName,
        assignedAt,
        assignedBy,
        aiConfidenceScore,
        aiRationale,
      ];
}

class AssignedHospital extends Equatable {
  final String? placeId;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String selectedBy; // "ai" | "admin"
  final Timestamp? selectedAt;

  const AssignedHospital({
    this.placeId,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    required this.selectedBy,
    this.selectedAt,
  });

  factory AssignedHospital.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AssignedHospital(selectedBy: 'admin');
    return AssignedHospital(
      placeId: map['placeId'] as String?,
      name: map['name'] as String?,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      selectedBy: map['selectedBy'] as String? ?? 'admin',
      selectedAt: map['selectedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'selectedBy': selectedBy,
      'selectedAt': selectedAt,
    };
  }

  @override
  List<Object?> get props => [
        placeId,
        name,
        address,
        latitude,
        longitude,
        selectedBy,
        selectedAt,
      ];
}

class TimelineEvent extends Equatable {
  final String event;
  final Timestamp timestamp;
  final String actor; // "system" | "admin" | userId

  const TimelineEvent({
    required this.event,
    required this.timestamp,
    required this.actor,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      event: map['event'] as String? ?? '',
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
      actor: map['actor'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event': event,
      'timestamp': timestamp,
      'actor': actor,
    };
  }

  @override
  List<Object?> get props => [event, timestamp, actor];
}

class IncidentModel extends Equatable {
  final String id;
  final String type; // "sos" | "accident" | "medical" | "fire" | "other"
  final String severity; // "critical" | "high" | "medium" | "low"
  final String status;

  final String reportedBy;
  final String? reporterPhone;
  final Timestamp reportedAt;
  final Timestamp updatedAt;

  final IncidentLocation location;
  final String? description;
  final int victimCount;

  // Incident-specific details (Added back for UI compatibility)
  final String? accidentType;
  final String? consciousnessLevel;
  final String? injuryLocation;
  final String? painLevel;
  final String? imageUrl;

  final Map<String, dynamic>? reporterMedicalProfile;
  final Map<String, dynamic>? reporterEmergencyContact;

  final IncidentAssignment? assignment;
  final AssignedHospital? assignedHospital;
  final List<TimelineEvent> timeline;

  final Timestamp? resolvedAt;

  const IncidentModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.status,
    required this.reportedBy,
    this.reporterPhone,
    required this.reportedAt,
    required this.updatedAt,
    required this.location,
    this.description,
    this.victimCount = 1,
    this.accidentType,
    this.consciousnessLevel,
    this.injuryLocation,
    this.painLevel,
    this.imageUrl,
    this.reporterMedicalProfile,
    this.reporterEmergencyContact,
    this.assignment,
    this.assignedHospital,
    this.timeline = const [],
    this.resolvedAt,
  });

  // Getters for backward compatibility
  String get incidentType => type;
  Timestamp get createdAt => reportedAt;
  String get address => location.address ?? '';
  String get patientName => reporterMedicalProfile?['patientName'] ?? 'Anonymous';
  String get phoneNumber => reporterPhone ?? '';

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'status': status,
      'reportedBy': reportedBy,
      'reporterPhone': reporterPhone,
      'reportedAt': reportedAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'location': location.toMap(),
      'description': description,
      'victimCount': victimCount,
      'accidentType': accidentType,
      'consciousnessLevel': consciousnessLevel,
      'injuryLocation': injuryLocation,
      'painLevel': painLevel,
      'imageUrl': imageUrl,
      'reporterMedicalProfile': reporterMedicalProfile,
      'reporterEmergencyContact': reporterEmergencyContact,
      if (assignment != null) 'assignment': assignment!.toMap(),
      if (assignedHospital != null) 'assignedHospital': assignedHospital!.toMap(),
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'resolvedAt': resolvedAt,
    };
  }

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return IncidentModel(
      id: doc.id,
      type: d['type'] as String? ?? d['incidentType'] as String? ?? 'other',
      severity: d['severity'] as String? ?? 'low',
      status: d['status'] as String? ?? IncidentStatus.reported,
      reportedBy: d['reportedBy'] as String? ?? d['patientUid'] as String? ?? 'anonymous',
      reporterPhone: d['reporterPhone'] as String? ?? d['phoneNumber'] as String?,
      reportedAt: d['reportedAt'] as Timestamp? ?? d['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: d['updatedAt'] as Timestamp? ?? Timestamp.now(),
      location: d['location'] != null 
          ? IncidentLocation.fromMap(Map<String, dynamic>.from(d['location']))
          : IncidentLocation(
              latitude: (d['latitude'] as num?)?.toDouble() ?? 0,
              longitude: (d['longitude'] as num?)?.toDouble() ?? 0,
              address: d['address'] as String?,
              geohash: d['geohash'] as String? ?? '',
            ),
      description: d['description'] as String?,
      victimCount: d['victimCount'] as int? ?? 1,
      accidentType: d['accidentType'] as String?,
      consciousnessLevel: d['consciousnessLevel'] as String?,
      injuryLocation: d['injuryLocation'] as String?,
      painLevel: d['painLevel'] as String?,
      imageUrl: d['imageUrl'] as String?,
      reporterMedicalProfile: d['reporterMedicalProfile'] is Map<String, dynamic> ? d['reporterMedicalProfile'] : null,
      reporterEmergencyContact: d['reporterEmergencyContact'] is Map<String, dynamic> ? d['reporterEmergencyContact'] : null,
      assignment: d['assignment'] != null
          ? IncidentAssignment.fromMap(Map<String, dynamic>.from(d['assignment']))
          : d['assignedAmbulanceId'] != null 
              ? IncidentAssignment(
                  ambulanceId: d['assignedAmbulanceId'] as String?,
                  driverName: d['assignedParamedicName'] as String?,
                  vehicleId: d['assignedAmbulanceId'] as String?,
                  assignedBy: 'system',
                )
              : null,
      assignedHospital: d['assignedHospital'] != null
          ? AssignedHospital.fromMap(Map<String, dynamic>.from(d['assignedHospital']))
          : d['suggestedHospitalName'] != null
              ? AssignedHospital(name: d['suggestedHospitalName'] as String?, selectedBy: 'ai')
              : null,
      timeline: (d['timeline'] as List? ?? [])
          .map((e) => TimelineEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      resolvedAt: d['resolvedAt'] as Timestamp? ?? d['completedAt'] as Timestamp?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        severity,
        status,
        reportedBy,
        reporterPhone,
        reportedAt,
        updatedAt,
        location,
        description,
        victimCount,
        accidentType,
        consciousnessLevel,
        injuryLocation,
        painLevel,
        imageUrl,
        reporterMedicalProfile,
        reporterEmergencyContact,
        assignment,
        assignedHospital,
        timeline,
        resolvedAt,
      ];
}


