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
    return MedicalProfile(
      bloodType: map['bloodType'] as String?,
      chronicDiseases: List<String>.from(map['chronicDiseases'] ?? []),
      currentMeds: List<String>.from(map['currentMeds'] ?? map['currentMedications'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
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

  // Paramedic-specific
  final String? currentAmbulanceId;
  final String? status; // "active" | "inactive" | "on_duty" | "off_duty"
  final bool isAvailable;
  final String? fcmToken;
  final double? latitude;
  final double? longitude;

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
    this.currentAmbulanceId,
    this.status,
    this.isAvailable = true,
    this.fcmToken,
    this.latitude,
    this.longitude,
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


  bool get isCitizen => role == 'citizen';
  bool get isParamedic => role == 'paramedic';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      id: uid,
      role: map['role'] as String? ?? 'citizen',
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      nationalId: map['nationalId'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
      medicalProfile: MedicalProfile.fromMap(map['medicalProfile'] as Map<String, dynamic>?),
      emergencyContactData: EmergencyContact.fromMap(map['emergencyContact'] as Map<String, dynamic>?),
      currentAmbulanceId: map['currentAmbulanceId'] as String?,
      status: map['status'] as String?,
      isAvailable: map['isAvailable'] as bool? ?? true,
      fcmToken: map['fcmToken'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
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
      'currentAmbulanceId': currentAmbulanceId,
      'status': status,
      'isAvailable': isAvailable,
      'fcmToken': fcmToken,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
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
    String? currentAmbulanceId,
    String? status,
    bool? isAvailable,
    String? fcmToken,
    double? latitude,
    double? longitude,
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
      currentAmbulanceId: currentAmbulanceId ?? this.currentAmbulanceId,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      fcmToken: fcmToken ?? this.fcmToken,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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
        currentAmbulanceId,
        status,
        isAvailable,
        fcmToken,
        latitude,
        longitude,
      ];
}




typedef AppUser = UserModel;
