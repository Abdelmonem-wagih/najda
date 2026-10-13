import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

class MedicalProfile extends Equatable {
  final String? bloodType;
  final List<String> chronicDiseases;
  final List<String> currentMeds;
  final List<String> allergies;
  final String? notes;

  const MedicalProfile({
    this.bloodType,
    this.chronicDiseases = const [],
    this.currentMeds = const [],
    this.allergies = const [],
    this.notes,
  });

  factory MedicalProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const MedicalProfile();

    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.isNotEmpty) return val.split(',').map((e) => e.trim()).toList();
      return [];
    }

    return MedicalProfile(
      bloodType: map['bloodType'] as String?,
      chronicDiseases: parseList(map['chronicDiseases']),
      currentMeds: parseList(map['currentMeds'] ?? map['currentMedications']),
      allergies: parseList(map['allergies']),
      notes: map['notes'] as String? ?? map['additionalInfo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodType': bloodType,
      'chronicDiseases': chronicDiseases,
      'currentMeds': currentMeds,
      'allergies': allergies,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [bloodType, chronicDiseases, currentMeds, allergies, notes];
}

class EmergencyContact extends Equatable {
  final String name;
  final String phone;
  final String? relation;

  const EmergencyContact({
    required this.name,
    required this.phone,
    this.relation,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const EmergencyContact(name: '', phone: '');
    return EmergencyContact(
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      relation: map['relation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
    };
  }

  @override
  List<Object?> get props => [name, phone, relation];
}

class UserModel extends Equatable {
  final String id; // Matches uid
  final String role; // "citizen" | "paramedic" | "admin"
  final String? phoneNumber;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? nationalId; // Added back
  final String? profileImageUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  final MedicalProfile medicalProfile;
  final EmergencyContact emergencyContactData; // Renamed from emergencyContact

  // Ambulances-specific
  final bool isOnline;             // true = working shift, false = off duty
  final String status;             // "available" | "assigned" | "on_mission" | "arrived" | "to_hospital"
  final String? currentIncidentId;
  final String? currentIncidentType;  // "incident" | "critical"
  final String? ambulanceId;
  final String? plateNumber;
  final String? fcmToken;
  final double? latitude;
  final double? longitude;
  final double? bearing;
  final String? area;
  final Timestamp? lastActiveAt;

  // Backward compatibility getter
  String? get currentAmbulanceId => ambulanceId;

  const UserModel({
    required this.id,
    required this.role,
    this.phoneNumber,
    this.email,
    this.firstName,
    this.lastName,
    this.nationalId,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    required this.medicalProfile,
    required this.emergencyContactData,
    this.isOnline = true,
    this.status = 'available',
    this.currentIncidentId,
    this.currentIncidentType,
    this.ambulanceId,
    this.plateNumber,
    this.fcmToken,
    this.latitude,
    this.longitude,
    this.bearing,
    this.area,
    this.lastActiveAt,
  });

  // Helper for backward compatibility or display
  String get fullName => '${firstName ?? ""} ${lastName ?? ""}'.trim();
  String? get phone => phoneNumber;
  String get emergencyContact => emergencyContactData.phone;
  String get emergencyContactPhone => emergencyContactData.phone;
  List<String> get chronicDiseases => medicalProfile.chronicDiseases;
  List<String> get allergies => medicalProfile.allergies;
  List<String> get currentMedications => medicalProfile.currentMeds;
  String? get additionalInfo => medicalProfile.notes;


  bool get isCitizen => role == AppConstants.roleCitizen;
  bool get isAmbulances => role == AppConstants.roleAmbulances;
  bool get isAdmin => role == AppConstants.roleAdmin;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    // Robust parsing for MedicalProfile
    MedicalProfile medical;
    final medRaw = map['medicalProfile'];
    if (medRaw is Map<String, dynamic>) {
      medical = MedicalProfile.fromMap(medRaw);
    } else {
      medical = const MedicalProfile();
    }

    // Robust parsing for EmergencyContact (handles legacy String phone)
    EmergencyContact contact;
    final contactRaw = map['emergencyContact'];
    if (contactRaw is Map<String, dynamic>) {
      contact = EmergencyContact.fromMap(contactRaw);
    } else if (contactRaw is String) {
      contact = EmergencyContact(name: 'Emergency Contact', phone: contactRaw);
    } else {
      contact = const EmergencyContact(name: '', phone: '');
    }

    return UserModel(
      id: uid,
      role: map['role'] as String? ?? '',
      phoneNumber: (map['phoneNumber'] ?? map['phone']) as String?,
      email: map['email'] as String?,
      firstName: (map['firstName'] ?? map['fullName'] ?? '').toString().split(' ').first,
      lastName: (map['firstName'] ?? map['fullName'] ?? '').toString().contains(' ') 
          ? (map['firstName'] ?? map['fullName'] ?? '').toString().split(' ').sublist(1).join(' ')
          : '',
      nationalId: map['nationalId']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
      medicalProfile: medical,
      emergencyContactData: contact,
      isOnline: (map['isOnline'] ?? true) as bool,
      status: (map['status'] ?? map['availabilityStatus'] ?? 'available').toString(),
      currentIncidentId: map['currentIncidentId']?.toString(),
      currentIncidentType: map['currentIncidentType']?.toString(),
      ambulanceId: (map['ambulanceId'] ?? map['currentAmbulanceId'] ?? map['vehicleId'])?.toString(),
      plateNumber: map['plateNumber']?.toString(),
      fcmToken: map['fcmToken']?.toString(),
      latitude: (map['latitude'] ?? map['lat'] as num?)?.toDouble(),
      longitude: (map['longitude'] ?? map['lng'] as num?)?.toDouble(),
      bearing: (map['bearing'] as num?)?.toDouble() ?? 0,
      area: map['area']?.toString(),
      lastActiveAt: map['lastActiveAt'] as Timestamp? ?? map['lastSeen'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'role': role,
      'phoneNumber': phoneNumber,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'medicalProfile': medicalProfile.toMap(),
      'emergencyContact': emergencyContactData.toMap(),
      'isOnline': isOnline,
      'status': status,
      'currentIncidentId': currentIncidentId,
      'currentIncidentType': currentIncidentType,
      'ambulanceId': ambulanceId,
      'plateNumber': plateNumber,
      'fcmToken': fcmToken,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (latitude != null) 'lat': latitude,
      if (longitude != null) 'lng': longitude,
      if (bearing != null) 'bearing': bearing,
      if (area != null) 'area': area,
      if (lastActiveAt != null) 'lastActiveAt': lastActiveAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? role,
    String? phoneNumber,
    String? email,
    String? firstName,
    String? lastName,
    String? nationalId,
    String? profileImageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    MedicalProfile? medicalProfile,
    EmergencyContact? emergencyContactData,
    bool? isOnline,
    String? status,
    String? currentIncidentId,
    String? currentIncidentType,
    String? ambulanceId,
    String? plateNumber,
    String? fcmToken,
    double? latitude,
    double? longitude,
    double? bearing,
    String? area,
    Timestamp? lastActiveAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nationalId: nationalId ?? this.nationalId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicalProfile: medicalProfile ?? this.medicalProfile,
      emergencyContactData: emergencyContactData ?? this.emergencyContactData,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      currentIncidentId: currentIncidentId ?? this.currentIncidentId,
      currentIncidentType: currentIncidentType ?? this.currentIncidentType,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      plateNumber: plateNumber ?? this.plateNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bearing: bearing ?? this.bearing,
      area: area ?? this.area,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        role,
        phoneNumber,
        email,
        firstName,
        lastName,
        nationalId,
        profileImageUrl,
        createdAt,
        updatedAt,
        medicalProfile,
        emergencyContactData,
        isOnline,
        status,
        currentIncidentId,
        currentIncidentType,
        ambulanceId,
        plateNumber,
        fcmToken,
        latitude,
        longitude,
        bearing,
        area,
        lastActiveAt,
      ];
}




typedef AppUser = UserModel;
