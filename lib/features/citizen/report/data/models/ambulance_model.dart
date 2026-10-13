import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AmbulanceLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final Timestamp updatedAt;

  const AmbulanceLocation({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.updatedAt,
  });

  factory AmbulanceLocation.fromMap(Map<String, dynamic>? map) {
    if (map == null) return AmbulanceLocation(latitude: 0, longitude: 0, updatedAt: Timestamp.now());
    return AmbulanceLocation(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      heading: (map['heading'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, heading, speed, updatedAt];
}

class BaseLocation extends Equatable {
  final double latitude;
  final double longitude;

  const BaseLocation({
    required this.latitude,
    required this.longitude,
  });

  factory BaseLocation.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const BaseLocation(latitude: 0.0, longitude: 0.0);
    return BaseLocation(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude];
}

class AmbulanceModel extends Equatable {
  final String id;
  final String plateNumber;
  final String vehicleType; // "basic" | "advanced" | "icu"
  final String status;
  final AmbulanceLocation? currentLocation;
  final String? assignedIncidentId;
  final String? assignedHospitalId;
  final String? uid;
  final String? driverName;
  final String? baseStationId;
  final BaseLocation? baseLocation;
  final String? geohash;
  final Timestamp lastActiveAt;

  const AmbulanceModel({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.status,
    this.currentLocation,
    this.assignedIncidentId,
    this.assignedHospitalId,
    this.uid,
    this.driverName,
    this.baseStationId,
    this.baseLocation,
    this.geohash,
    required this.lastActiveAt,
  });

  factory AmbulanceModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    
    // Support both nested 'currentLocation' and flat 'lat'/'lng' fields
    AmbulanceLocation? loc;
    if (d['currentLocation'] != null) {
      loc = AmbulanceLocation.fromMap(Map<String, dynamic>.from(d['currentLocation']));
    } else if (d['lat'] != null && d['lng'] != null) {
      loc = AmbulanceLocation(
        latitude: (d['lat'] as num).toDouble(),
        longitude: (d['lng'] as num).toDouble(),
        updatedAt: d['updatedAt'] as Timestamp? ?? d['lastActiveAt'] as Timestamp? ?? Timestamp.now(),
        heading: (d['heading'] as num?)?.toDouble(),
        speed: (d['speed'] as num?)?.toDouble(),
      );
    }

    return AmbulanceModel(
      id: doc.id,
      plateNumber: d['plateNumber'] as String? ?? d['id'] as String? ?? '',
      vehicleType: d['vehicleType'] as String? ?? 'basic',
      status: d['status'] as String? ?? 'offline',
      currentLocation: loc,
      assignedIncidentId: d['assignedIncidentId'] as String? ?? d['missionId'] as String?,
      assignedHospitalId: d['assignedHospitalId'] as String?,
      uid: d['uid'] as String? ?? d['paramedicId'] as String?,
      driverName: d['driverName'] as String? ?? d['paramedicName'] as String?,
      baseStationId: d['baseStationId'] as String?,
      baseLocation: d['baseLocation'] != null
          ? BaseLocation.fromMap(Map<String, dynamic>.from(d['baseLocation']))
          : (d['baseLat'] != null && d['baseLng'] != null)
            ? BaseLocation(latitude: (d['baseLat'] as num).toDouble(), longitude: (d['baseLng'] as num).toDouble())
            : null,
      geohash: d['geohash'] as String?,
      lastActiveAt: d['lastActiveAt'] as Timestamp? ?? d['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'vehicleType': vehicleType,
      'status': status,
      if (currentLocation != null) ...{
        'currentLocation': currentLocation!.toMap(),
        'lat': currentLocation!.latitude,
        'lng': currentLocation!.longitude,
      },
      'assignedIncidentId': assignedIncidentId,
      'assignedHospitalId': assignedHospitalId,
      'uid': uid,
      'driverName': driverName,
      'baseStationId': baseStationId,
      if (baseLocation != null) 'baseLocation': baseLocation!.toMap(),
      'geohash': geohash,
      'lastActiveAt': lastActiveAt,
      'updatedAt': lastActiveAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        plateNumber,
        vehicleType,
        status,
        currentLocation,
        assignedIncidentId,
        assignedHospitalId,
        uid,
        driverName,
        baseStationId,
        baseLocation,
        geohash,
        lastActiveAt,
      ];
}
