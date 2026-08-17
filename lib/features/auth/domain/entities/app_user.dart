import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Universal user entity.
/// For citizens:   role = "citizen",  email may be null, phone is set.
/// For paramedics: role = "paramedic", phone and email are both set.
class AppUser extends Equatable {
  final String id;
  final String role;           // AppConstants.roleCitizen | roleParamedic
  final String? phone;
  final String? email;

  // Citizen-specific (nullable for paramedics)
  final String? fullName;
  final String? nationalId;
  final String? emergencyContact;
  final List<String> chronicDiseases;
  final List<String> allergies;
  final List<String> currentMedications;
  final String? additionalInfo;

  // Paramedic-specific (nullable for citizens)
  final String? firstName;
  final String? lastName;
  final String? licenseNumber;
  final String? ambulanceId;
  final String? status;
  final bool isActive;
  final bool isAvailable;
  final String? assignedReportId;
  final String? assignedReportType;
  final String? fcmToken;
  final double? latitude;
  final double? longitude;

  const AppUser({
    required this.id,
    required this.role,
    this.phone,
    this.email,
    // citizen
    this.fullName,
    this.nationalId,
    this.emergencyContact,
    this.chronicDiseases = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.additionalInfo,
    // paramedic
    this.firstName,
    this.lastName,
    this.licenseNumber,
    this.ambulanceId,
    this.status,
    this.isActive = true,
    this.isAvailable = true,
    this.assignedReportId,
    this.assignedReportType,
    this.fcmToken,
    this.latitude,
    this.longitude,
  });

  bool get isCitizen   => role == AppConstants.roleCitizen;
  bool get isParamedic => role == AppConstants.roleParamedic;

  // Paramedic helpers
  String get paramedicFullName => '$firstName $lastName';
  bool get hasLocation => latitude != null && longitude != null;
  bool get isAvailableForAssignment =>
      isAvailable && isActive && status == AppConstants.paramedicAvailable;
  bool get isOnMission        => status == AppConstants.paramedicOnMission;
  bool get hasArrived         => status == AppConstants.paramedicArrived;
  bool get isOnWayToHospital  => status == AppConstants.paramedicOnWayToHospital;

  AppUser copyWith({
    String? id,
    String? role,
    String? phone,
    String? email,
    String? fullName,
    String? nationalId,
    String? emergencyContact,
    List<String>? chronicDiseases,
    List<String>? allergies,
    List<String>? currentMedications,
    String? additionalInfo,
    String? firstName,
    String? lastName,
    String? licenseNumber,
    String? ambulanceId,
    String? status,
    bool? isActive,
    bool? isAvailable,
    String? assignedReportId,
    String? assignedReportType,
    String? fcmToken,
    double? latitude,
    double? longitude,
  }) {
    return AppUser(
      id: id ?? this.id,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      assignedReportId: assignedReportId ?? this.assignedReportId,
      assignedReportType: assignedReportType ?? this.assignedReportType,
      fcmToken: fcmToken ?? this.fcmToken,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id, role, phone, email,
        fullName, nationalId, emergencyContact,
        firstName, lastName, licenseNumber, ambulanceId,
        status, isActive, isAvailable,
        assignedReportId, assignedReportType, fcmToken,
        latitude, longitude,
      ];
}
