// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Najda';

  @override
  String get appTagline => 'Instant Emergency Response';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Enter your credentials to continue';

  @override
  String get loginAsCitizen => 'Citizen';

  @override
  String get loginAsParamedic => 'Paramedic';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => 'Enter your phone with country code';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get sendOtp => 'Send Verification Code';

  @override
  String get login => 'Sign In';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutConfirm => 'Do you want to sign out?';

  @override
  String get yes => 'Yes';

  @override
  String get cancel => 'Cancel';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get otpTitle => 'Verify Number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the code sent to $phone';
  }

  @override
  String get otpCode => 'Verification Code';

  @override
  String get otpHint => 'Enter the 6-digit code';

  @override
  String get verifyOtp => 'Verify';

  @override
  String get resendOtp => 'Resend Code';

  @override
  String get registrationTitle => 'Complete Your Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get nationalId => 'National ID';

  @override
  String get emergencyContact => 'Emergency Contact (Optional)';

  @override
  String get chronicDiseases => 'Chronic Diseases';

  @override
  String get allergies => 'Allergies';

  @override
  String get currentMedications => 'Current Medications';

  @override
  String get additionalInfo => 'Additional Information';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get homeTitle => 'Home';

  @override
  String get sos => 'Emergency';

  @override
  String get sosDescription => 'Press in case of medical emergency';

  @override
  String get firstAid => 'First Aid';

  @override
  String get firstAidDescription => 'First aid guide';

  @override
  String get hospitals => 'Nearby Hospitals';

  @override
  String get hospitalsDescription => 'Find nearby hospitals';

  @override
  String get emergency => 'Emergency Numbers';

  @override
  String get emergencyDescription => 'Important emergency numbers';

  @override
  String get history => 'Reports History';

  @override
  String get historyDescription => 'Your previous reports';

  @override
  String get aiTriage => 'AI Triage';

  @override
  String get aiTriageDescription => 'AI-powered symptom assessment';

  @override
  String get aiAssistant => 'Najda Assistant';

  @override
  String get aiAssistantDescription => 'Smart medical chat';

  @override
  String get profile => 'Profile';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get reportTitle => 'Report an Incident';

  @override
  String get reportSubtitle => 'Enter incident details';

  @override
  String get accidentType => 'Incident Type';

  @override
  String get selectAccidentType => 'Select incident type';

  @override
  String get consciousnessLevel => 'Consciousness Level';

  @override
  String get injuryLocation => 'Injury Location';

  @override
  String get painLevel => 'Pain Level';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get sendReport => 'Send Report';

  @override
  String get reportSent => 'Report sent successfully';

  @override
  String get reportError => 'Failed to send report';

  @override
  String get locating => 'Detecting your location...';

  @override
  String get accidentCarAccident => 'Car Accident / Collision';

  @override
  String get accidentPedestrianHit => 'Pedestrian Hit';

  @override
  String get accidentFallFromHeight => 'Fall from Height';

  @override
  String get accidentFall => 'Regular Fall';

  @override
  String get accidentElectricShock => 'Electric Shock';

  @override
  String get accidentFireBurn => 'Fire / Burns';

  @override
  String get accidentSuffocation => 'Suffocation';

  @override
  String get accidentDrowning => 'Drowning';

  @override
  String get accidentWorkInjury => 'Work Injury';

  @override
  String get accidentPoisoning => 'Poisoning';

  @override
  String get accidentAssault => 'Assault / Violence';

  @override
  String get accidentSportInjury => 'Sports Injury';

  @override
  String get accidentGunshot => 'Gunshot';

  @override
  String get accidentStabbing => 'Stabbing / Sharp Wound';

  @override
  String get accidentMedicalEmergency => 'Medical Emergency';

  @override
  String get conscious => 'Fully conscious';

  @override
  String get semiconscious => 'Semi-conscious';

  @override
  String get unconscious => 'Unconscious';

  @override
  String get historyEmpty => 'No previous reports';

  @override
  String get reportStatus => 'Report Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get reportDate => 'Report Date';

  @override
  String get reportType => 'Report Type';

  @override
  String get emergency_report => 'Emergency Report';

  @override
  String get normal_report => 'Normal Report';

  @override
  String get paramedicDashboard => 'Paramedic Dashboard';

  @override
  String get assignedReports => 'Assigned Reports';

  @override
  String get emergencyReports => 'Emergency Reports';

  @override
  String get noAssignedReports => 'No assigned reports';

  @override
  String get noEmergencyReports => 'No emergency reports';

  @override
  String get patientName => 'Patient Name';

  @override
  String get patientPhone => 'Patient Phone';

  @override
  String get patientLocation => 'Patient Location';

  @override
  String get distance => 'Distance';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get acceptReport => 'Accept Report';

  @override
  String get viewDetails => 'View Details';

  @override
  String get reportDetails => 'Report Details';

  @override
  String get startNavigation => 'Start Navigation';

  @override
  String get openInMaps => 'Open in Google Maps';

  @override
  String get markArrived => 'Mark as Arrived';

  @override
  String get submitMedicalReport => 'Submit Medical Report';

  @override
  String get backToAvailable => 'Return to Available';

  @override
  String get paramedicOnMission => 'On Mission';

  @override
  String get paramedicArrived => 'Arrived at Patient';

  @override
  String get paramedicToHospital => 'En Route to Hospital';

  @override
  String get paramedicAvailable => 'Available';

  @override
  String get medicalReport => 'Medical Report';

  @override
  String get medicalQuestion => 'Medical Question';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get availability => 'Availability';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get toggleAvailability => 'Toggle Availability';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get newAssignment => 'New Assignment';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get paramedicHistory => 'Mission History';

  @override
  String get missionCompleted => 'Mission Completed';

  @override
  String get missionDate => 'Mission Date';

  @override
  String get missionDuration => 'Mission Duration';

  @override
  String get navigationTitle => 'Navigation';

  @override
  String navigatingTo(String destination) {
    return 'Navigating to: $destination';
  }

  @override
  String remainingDistance(String distance) {
    return 'Remaining: $distance';
  }

  @override
  String remainingTime(String time) {
    return 'ETA: $time';
  }

  @override
  String get firstAidTitle => 'First Aid Guide';

  @override
  String get firstAidSearch => 'Search first aid...';

  @override
  String get hospitalsTitle => 'Nearby Hospitals';

  @override
  String get hospitalsSearching => 'Searching for nearby hospitals...';

  @override
  String get callHospital => 'Call';

  @override
  String get getDirections => 'Directions';

  @override
  String get emergencyNumbersTitle => 'Emergency Numbers';

  @override
  String get call => 'Call';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordTooShort => 'Password is too short';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get phoneStartsWithPlus => 'Number must start with +';

  @override
  String get phoneTooShort => 'Phone number is too short';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get changeLanguage => 'Change Language';
}
