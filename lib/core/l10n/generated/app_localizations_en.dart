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
  String get phoneHint => '+20 1XX XXXX XXXX';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get login => 'Sign In';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get logoutAction => 'Logout';

  @override
  String get noInfo => 'None';

  @override
  String get personalData => 'Personal Data';

  @override
  String get medicalData => 'Medical Data';

  @override
  String get identityNumber => 'National ID';

  @override
  String get emergencyContactPerson => 'Emergency Contact';

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
  String get paramedicInfo =>
      'Paramedic accounts are created by system admin only';

  @override
  String get newUserPrompt => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get sendOtpPrompt =>
      'To register: Enter your number and press \"Send OTP\"';

  @override
  String get enterPhoneFirst =>
      'Enter your phone first then press \"Send OTP\"';

  @override
  String get otpTitle => 'Verify Number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get otpCode => 'Verification Code';

  @override
  String get otpHint => 'Enter the 6-digit code';

  @override
  String get verifyOtp => 'Verify Now';

  @override
  String get resendOtp => 'Resend Code';

  @override
  String resendAfter(int seconds) {
    return 'You can resend after $seconds seconds';
  }

  @override
  String get verifiedNumber => 'Verified Number';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get medicalInfo => 'Medical Information';

  @override
  String get medicalInfoSubtitle =>
      'Sent to paramedics during reports to aid quick diagnosis';

  @override
  String get passwordLabel => 'Account Password';

  @override
  String get optional => '(Optional)';

  @override
  String get passwordHint => 'Enter password to protect your account';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get chronicDiseasesHint =>
      'Diabetes, Hypertension... (Separate with comma)';

  @override
  String get allergiesHint => 'Penicillin, Peanuts...';

  @override
  String get medicationsHint => 'Metformin, Aspirin...';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get identityError => 'Identity verification error. Try again.';

  @override
  String get fullNameLabel => 'Full Name *';

  @override
  String get nationalIdLabel => 'National ID *';

  @override
  String get emergencyContactLabel => 'Emergency Contact Number';

  @override
  String get chronicDiseasesLabel => 'Chronic Diseases';

  @override
  String get allergiesLabel => 'Allergies';

  @override
  String get medicationsLabel => 'Current Medications';

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
  String get aiThinking => 'Thinking...';

  @override
  String get aiConnected => 'Online';

  @override
  String get aiReplying => 'Replying...';

  @override
  String get typeMessageHint => 'Type your question here...';

  @override
  String get paramedicWelcome =>
      'Hello Paramedic! 🏥\n\nI am your field medical assistant. I can help with protocols, dosages, and drug interactions.\n\nAsk me any medical question.';

  @override
  String get citizenWelcome =>
      'Hello! I am Najda\'s smart assistant 🤖\n\nI can help you with symptom assessment and first aid instructions.\n\n⚠️ In emergencies, call 123 immediately!';

  @override
  String get permissionError =>
      'Permission error. Make sure you are logged in.';

  @override
  String get serviceUnavailable =>
      'Service currently unavailable. Make sure Firebase Functions are deployed.';

  @override
  String get serverError => 'AI server error. Check GROQ_API_KEY in Firebase.';

  @override
  String get timeoutError => 'Connection timeout. Try again.';

  @override
  String get networkError => 'Check your internet connection.';

  @override
  String get profile => 'Profile';

  @override
  String greeting(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get homeSubtitle => 'How can we help you today?';

  @override
  String get sosButtonTitle => 'Instant SOS Request';

  @override
  String get sosButtonSubtitle =>
      'Sends your location and medical data immediately';

  @override
  String get reportIncidentTitle => 'Report an Incident';

  @override
  String get reportIncidentSubtitle =>
      'Saw an accident? Report it to help others';

  @override
  String get sosSentTitle => 'Emergency report sent!';

  @override
  String reportNumber(String code) {
    return 'Report ID: R-$code';
  }

  @override
  String get sosSentSubtitle =>
      'Ambulance is on its way. Stay where you are and stay calm.';

  @override
  String get ok => 'OK';

  @override
  String get medicalTip =>
      'Keep your medical data updated to ensure the best care in emergencies.';

  @override
  String sosEmergencyAlert(
      String name, double lat, double lng, String code, String time) {
    return '🚨 *Najda Emergency Alert*\n\n$name sent an emergency report!\n📍 Location: https://maps.google.com/?q=$lat,$lng\n🏥 Report ID: $code\n⏰ Time: $time\n\nAmbulance has been sent automatically.';
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
  String get accidentTypeSubtitle =>
      'Select the classification closest to the case to help with response';

  @override
  String get injuryDetailsTitle => 'Injury Details';

  @override
  String get injuryDetailsSubtitle =>
      'Describing the patient\'s condition helps the paramedic prepare';

  @override
  String get head => 'Head';

  @override
  String get neck => 'Neck';

  @override
  String get chest => 'Chest';

  @override
  String get abdomen => 'Abdomen';

  @override
  String get arm => 'Arm';

  @override
  String get leg => 'Leg';

  @override
  String get backBody => 'Back';

  @override
  String get multiple => 'Multiple';

  @override
  String get unspecified => 'Unspecified';

  @override
  String get mild => 'Mild';

  @override
  String get moderate => 'Moderate';

  @override
  String get severe => 'Severe';

  @override
  String get unbearable => 'Unbearable';

  @override
  String get nextAddPhoto => 'Next — Add Photo';

  @override
  String get addPhotoSubtitle =>
      'Optional: Taking a photo of the incident helps the ambulance team understand the nature of the injury';

  @override
  String get tapToCapture => 'Tap here to capture a photo';

  @override
  String get sendWithoutPhoto => 'Send without photo';

  @override
  String get reportSentSuccess => 'Report Sent!';

  @override
  String get ambulanceOnWay => 'Ambulance is on the way. Stay calm.';

  @override
  String get backToHome => 'Back to Home';

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
  String get statusDuplicate => 'Duplicate';

  @override
  String get reportDate => 'Report Date';

  @override
  String get reportType => 'Report Type';

  @override
  String get emergency_report => 'Emergency Report';

  @override
  String get normal_report => 'Normal Report';

  @override
  String paramedicGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get availableForReports => 'Available for reports';

  @override
  String get notAvailable => 'Not available currently';

  @override
  String get reports => 'Reports';

  @override
  String get noAssignedEmergencyReports => 'No emergency reports';

  @override
  String get noAssignedReportsSubtitle =>
      'Any report assigned to you will appear here';

  @override
  String get details => 'Details';

  @override
  String get navigation => 'Navigation';

  @override
  String get locationNotSpecified => 'Location not specified';

  @override
  String updateFailed(String error) {
    return 'Update failed: $error';
  }

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
  String get statusLabel => 'Status:';

  @override
  String get accidentTypeLabel => 'Incident Type';

  @override
  String get navigationToLocation => 'Navigate to Location';

  @override
  String get confirmArrival => 'Confirm Arrival at Scene';

  @override
  String get fillMedicalReport => 'Fill Medical Report';

  @override
  String get endMission => 'End Mission / Handover Patient';

  @override
  String get fieldMedicalReport => 'Field Medical Report';

  @override
  String get additionalNotesHint => 'Write any additional notes here...';

  @override
  String get submitReportAction => 'Submit Report';

  @override
  String get statusUpdateSuccess => 'Status updated successfully';

  @override
  String get reportNotFound => 'Report not found';

  @override
  String get loadingDetails => 'Loading details...';

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
  String get noMissionHistory => 'No mission history';

  @override
  String get missionHistorySubtitle => 'Your mission history will appear here';

  @override
  String get notificationsSubtitle =>
      'You will receive notifications for new reports here';

  @override
  String get noNotificationsTitle => 'No notifications currently';

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
  String get searchFirstAidHint => 'Search for an emergency case...';

  @override
  String get noResults => 'No results found';

  @override
  String get tryDifferentSearch => 'Try searching with different words';

  @override
  String get criticalUrgency => 'Critical';

  @override
  String get highUrgency => 'High';

  @override
  String get normalUrgency => 'Normal';

  @override
  String get firstAidSteps => 'First Aid Steps';

  @override
  String get emergencyInstruction =>
      'Critical emergency — start first aid and call 123 immediately';

  @override
  String get standardInstruction =>
      'Follow steps carefully and call ambulance if needed';

  @override
  String get firstAidDisclaimer =>
      'Note: This information is for guidance purposes only. Najda disclaims any responsibility for misuse of this information.';

  @override
  String get imageCopyright => '© Photos: Wikimedia Commons — CC-BY-SA 4.0';

  @override
  String get hospitalsSearching => 'Searching for nearby hospitals...';

  @override
  String get noHospitalsFound => 'No hospitals found';

  @override
  String get checkLocationOrRetry =>
      'Make sure location is enabled or try again later';

  @override
  String foundHospitalsNearYou(int count) {
    return 'Found $count hospitals near you';
  }

  @override
  String get openNow => 'Open Now';

  @override
  String get closed => 'Closed';

  @override
  String km(String dist) {
    return '$dist km';
  }

  @override
  String get directions => 'Directions';

  @override
  String get locationAccessError => 'Location access error';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Enable it in settings.';

  @override
  String get callHospital => 'Call';

  @override
  String get getDirections => 'Directions';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get police => 'Police';

  @override
  String get fire => 'Fire Department';

  @override
  String get rescue => 'Rescue';

  @override
  String get airAmbulance => 'Air Ambulance';

  @override
  String get childRescue => 'Child Rescue';

  @override
  String get ambulanceSubtitle =>
      'For accidents, injuries, and medical emergencies';

  @override
  String get policeSubtitle => 'For crimes, security reports, and traffic';

  @override
  String get fireSubtitle => 'For fires, road accidents, and rescue';

  @override
  String get rescueSubtitle => 'For natural disasters and civil rescue';

  @override
  String get airAmbulanceSubtitle => 'For critical cases in remote areas';

  @override
  String get childRescueSubtitle =>
      'To protect children from violence and neglect';

  @override
  String get otherEmergencyNumbers => 'Other Emergency Numbers';

  @override
  String get emergencyNumbersTip =>
      'Tap any number to call, or long press to copy.';

  @override
  String get call => 'Call';

  @override
  String get hospitalsTitle => 'Hospitals Title';

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
  String get reportDetails => 'Report Details';

  @override
  String get ambulanceAssigned => 'Ambulance Assigned';

  @override
  String get paramedicName => 'Paramedic Name';

  @override
  String get plateNumberLabel => 'Plate Number';

  @override
  String get settings => 'Settings';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutUs => 'About Us';

  @override
  String get rateApp => 'Rate App';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get appVersion => 'App Version';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profileUpdateError => 'Failed to update profile, try again';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get confirmDiscard => 'Do you want to discard unsaved changes?';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get shareApp => 'Share App';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get shareMessage => 'Download the Najda emergency app:';

  @override
  String get smsMessage => 'Use the Najda emergency response app:';

  @override
  String get otherWays => 'Share via other ways';

  @override
  String get roleCitizen => 'Citizen';

  @override
  String get roleParamedic => 'Paramedic';

  @override
  String get defaultUserName => 'Najda User';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsSupportInfo => 'Support & Info';

  @override
  String get settingsShareFeedback => 'Share Feedback';

  @override
  String get settingsAccount => 'Account';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get chatWithSupport => 'Contact Support';

  @override
  String get available247 => 'Available 24/7';

  @override
  String get emergencyLine => 'Emergency Line';

  @override
  String get faqs => 'FAQs';

  @override
  String get faq1Q => 'How do I send an emergency report?';

  @override
  String get faq1A =>
      'Simply press the large SOS button on the home page or use the AI assistant to report the incident type.';

  @override
  String get faq2Q => 'Can I track the ambulance?';

  @override
  String get faq2A =>
      'Yes, once an ambulance is assigned to your report, a live tracking screen will appear showing the vehicle\'s location and ETA.';

  @override
  String get faq3Q => 'What is the AI system in Najda?';

  @override
  String get faq3A =>
      'Najda uses AI to analyze reports, classify their severity, dispatch the nearest ambulance, and select the most suitable hospital.';

  @override
  String get privacyDataCollection => 'Data Collection';

  @override
  String get privacyDataCollectionDesc =>
      '• GPS: Collected only when sending an emergency report to determine your location accurately.\\n• Medical Profile: Info you enter (blood type, allergies, chronic diseases) to assist paramedics.\\n• Phone Number: For identity verification and contacting you when necessary.';

  @override
  String get privacyDataUsage => 'Data Usage';

  @override
  String get privacyDataUsageDesc =>
      '• Assigning the nearest ambulance to the incident.\\n• Selecting the most suitable hospital based on health status.\\n• Automatically alerting your emergency contact when necessary.';

  @override
  String get privacyDataSharing => 'Data Sharing';

  @override
  String get privacyDataSharingDesc =>
      '• We do not sell your data to third parties.\\n• Your medical data and location are shared only with the ambulance crew and the hospital involved.';

  @override
  String get privacyDataDeletion => 'Data Deletion';

  @override
  String get privacyDataDeletionDesc =>
      '• You can request complete deletion of your account and data by contacting technical support within the app.';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get termsAcceptance => 'Acceptance of Terms';

  @override
  String get termsAcceptanceDesc =>
      'By using the Najda app, you agree to these terms and conditions. If you disagree with any part, please stop using the app.';

  @override
  String get termsServiceUsage => 'Service Usage';

  @override
  String get termsServiceUsageDesc =>
      '• The app is for real emergencies only.\\n• False reports are strictly prohibited and may lead to legal liability.\\n• Users must be 18+ or use it under guardian supervision.';

  @override
  String get termsLiability => 'Limitation of Liability';

  @override
  String get termsLiabilityDesc =>
      'Najda is a mediator to facilitate ambulance services; we strive for accuracy but do not guarantee immediate response in all circumstances beyond our control.';

  @override
  String get termsTermination => 'Termination of Service';

  @override
  String get termsTerminationDesc =>
      'We reserve the right to suspend or terminate your access for violating terms or misusing the emergency system.';

  @override
  String get aboutSubtitle => 'Intelligent Emergency Response System';

  @override
  String get aboutInfrastructure => 'Infrastructure';

  @override
  String get aboutRegion => 'Region';

  @override
  String get egypt => 'Arab Republic of Egypt';

  @override
  String get aboutDescription =>
      'Najda is an integrated system aiming to reduce response time in medical emergencies using AI and directly connecting citizens with ambulance crews and hospitals.';

  @override
  String get rateTitle => 'Your opinion matters';

  @override
  String get rateSubtitle => 'Help us improve Najda by rating your experience';

  @override
  String get rateSubmit => 'Submit Rating';

  @override
  String get shareTitle => 'Share via';

  @override
  String get appLink => 'App Link';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get changeLanguage => 'Change Language';
}
