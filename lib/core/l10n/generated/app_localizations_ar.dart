// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نجدة';

  @override
  String get appTagline => 'استجابة الطوارئ الفورية';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'أدخل بيانات حسابك للمتابعة';

  @override
  String get loginAsCitizen => 'مواطن';

  @override
  String get loginAsAmbulance => 'الإسعاف';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => '+20 1XX XXXX XXXX';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logoutConfirmMessage =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟';

  @override
  String get logoutAction => 'خروج';

  @override
  String get noInfo => 'لا يوجد';

  @override
  String get personalData => 'البيانات الشخصية';

  @override
  String get medicalData => 'البيانات الطبية';

  @override
  String get identityNumber => 'الرقم القومي';

  @override
  String get emergencyContactPerson => 'جهة اتصال الطوارئ';

  @override
  String get yes => 'نعم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get save => 'حفظ';

  @override
  String get submit => 'إرسال';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get ambulanceInfo => 'حسابات الإسعاف يُنشئها مشرف النظام فقط';

  @override
  String get newUserPrompt => 'ليس لديك حساب؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get sendOtpPrompt =>
      'لتسجيل حساب جديد: أدخل رقمك واضغط \"إرسال رمز التحقق\"';

  @override
  String get enterPhoneFirst =>
      'أدخل رقم هاتفك أولاً ثم اضغط \"إرسال رمز التحقق\"';

  @override
  String get otpTitle => 'التحقق من الرقم';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $phone';
  }

  @override
  String get otpCode => 'كود التحقق';

  @override
  String get otpHint => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get verifyOtp => 'تحقق الآن';

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String resendAfter(int seconds) {
    return 'يمكنك إعادة الإرسال بعد $seconds ثانية';
  }

  @override
  String get verifiedNumber => 'رقم تم التحقق منه';

  @override
  String get personalInfo => 'البيانات الشخصية';

  @override
  String get medicalInfo => 'البيانات الطبية';

  @override
  String get medicalInfoSubtitle =>
      'تُرسل لطاقم الإسعاف عند البلاغات للمساعدة في التشخيص السريع';

  @override
  String get passwordLabel => 'كلمة مرور للحساب';

  @override
  String get optional => '(اختياري)';

  @override
  String get passwordHint => 'أدخل كلمة مرور لحماية حسابك';

  @override
  String get passwordLengthError => 'كلمة المرور 6 أحرف على الأقل';

  @override
  String get chronicDiseasesHint => 'سكري، ضغط، قلب... (افصل بفاصلة)';

  @override
  String get allergiesHint => 'بنسيلين، فول سوداني...';

  @override
  String get medicationsHint => 'ميتفورمين، أسبرين...';

  @override
  String get createAccountButton => 'إنشاء الحساب';

  @override
  String get identityError => 'خطأ في التحقق من الهوية. أعد المحاولة.';

  @override
  String get fullNameLabel => 'الاسم الكامل *';

  @override
  String get nationalIdLabel => 'الرقم القومي *';

  @override
  String get emergencyContactNameLabel => 'اسم جهة الاتصال الطارئة';

  @override
  String get emergencyContactLabel => 'رقم جهة الاتصال الطارئة';

  @override
  String get invalidEgyptianPhone => 'رقم هاتف مصري غير صحيح';

  @override
  String get chronicDiseasesLabel => 'أمراض مزمنة';

  @override
  String get allergiesLabel => 'حساسية من أدوية أو مواد';

  @override
  String get medicationsLabel => 'أدوية حالية';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get sos => 'طوارئ';

  @override
  String get sosDescription => 'اضغط في حالة الطوارئ الطبية';

  @override
  String get firstAid => 'إسعافات أولية';

  @override
  String get firstAidDescription => 'دليل الإسعافات الأولية';

  @override
  String get hospitals => 'مستشفيات قريبة';

  @override
  String get hospitalsDescription => 'ابحث عن مستشفيات قريبة';

  @override
  String get emergency => 'أرقام الطوارئ';

  @override
  String get emergencyDescription => 'أرقام الطوارئ الهامة';

  @override
  String get history => 'سجل البلاغات';

  @override
  String get historyDescription => 'بلاغاتك السابقة';

  @override
  String get aiTriage => 'تقييم الأعراض';

  @override
  String get aiTriageDescription => 'ذكاء اصطناعي للتشخيص';

  @override
  String get aiThinking => 'جارٍ التفكير...';

  @override
  String get aiConnected => 'متصل الآن';

  @override
  String get aiReplying => 'جارٍ الرد...';

  @override
  String get typeMessageHint => 'اكتب سؤالك هنا...';

  @override
  String get ambulanceWelcome =>
      'مرحباً بك في نظام نجدة! 🏥\n\nأنا مساعدك الطبي الميداني. يمكنني مساعدتك في البروتوكولات والجرعات والتفاعلات الدوائية.\n\nاسألني أي سؤال طبي.';

  @override
  String get citizenWelcome =>
      'مرحباً! أنا مساعد نجدة الذكي 🤖\n\nيمكنني مساعدتك في تقييم الأعراض وإرشادات الإسعافات الأولية.\n\n⚠️ في الطوارئ اتصل بـ 123 فوراً!';

  @override
  String get permissionError => 'خطأ في الصلاحيات. تأكد من تسجيل الدخول.';

  @override
  String get serviceUnavailable =>
      'الخدمة غير متاحة حالياً. تأكد من نشر Firebase Functions.';

  @override
  String get serverError =>
      'خطأ في خادم الذكاء الاصطناعي. تحقق من إعداد GROQ_API_KEY في Firebase.';

  @override
  String get timeoutError => 'انتهت مهلة الاتصال. حاول مرة أخرى.';

  @override
  String get networkError => 'تحقق من اتصالك بالإنترنت.';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String greeting(String name) {
    return 'مرحباً، $name 👋';
  }

  @override
  String get homeSubtitle => 'كيف يمكننا مساعدتك اليوم؟';

  @override
  String get sosButtonTitle => 'طلب نجدة فورية';

  @override
  String get sosButtonSubtitle => 'يُرسل موقعك وبياناتك الطبية فوراً';

  @override
  String get reportIncidentTitle => 'إبلاغ عن حادث';

  @override
  String get reportIncidentSubtitle => 'شاهدت حادثاً؟ أبلغ عنه لمساعدة الآخرين';

  @override
  String get sosSentTitle => 'تم إرسال بلاغ الطوارئ!';

  @override
  String reportNumber(String code) {
    return 'رقم البلاغ: R-$code';
  }

  @override
  String get sosSentSubtitle =>
      'الإسعاف في الطريق إليك. ابقَ في مكانك وحافظ على هدوئك.';

  @override
  String get ok => 'حسناً';

  @override
  String get medicalTip =>
      'حافظ على تحديث بياناتك الطبية لضمان حصولك على أفضل رعاية في حالات الطوارئ.';

  @override
  String sosEmergencyAlert(
      String name, double lat, double lng, String code, String time) {
    return '🚨 *تنبيه طوارئ نجدة*\n\n$name أرسل بلاغ طوارئ!\n📍 الموقع: https://maps.google.com/?q=$lat,$lng\n🏥 رقم البلاغ: $code\n⏰ الوقت: $time\n\nتم إرسال الإسعاف تلقائياً.';
  }

  @override
  String get reportTitle => 'إبلاغ عن حادث';

  @override
  String get reportSubtitle => 'أدخل تفاصيل الحادث';

  @override
  String get accidentType => 'نوع الحادث';

  @override
  String get selectAccidentType => 'اختر نوع الحادث';

  @override
  String get consciousnessLevel => 'مستوى الوعي';

  @override
  String get injuryLocation => 'موضع الإصابة';

  @override
  String get painLevel => 'مستوى الألم';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get removePhoto => 'حذف الصورة';

  @override
  String get sendReport => 'إرسال البلاغ';

  @override
  String get reportSent => 'تم إرسال البلاغ بنجاح';

  @override
  String get reportError => 'فشل إرسال البلاغ';

  @override
  String get accidentTypeSubtitle =>
      'اختر التصنيف الأقرب للحالة للمساعدة في الاستجابة';

  @override
  String get injuryDetailsTitle => 'إصابات الحالة';

  @override
  String get injuryDetailsSubtitle =>
      'وصف حالة المصاب يساعد طاقم الإسعاف على الاستعداد';

  @override
  String get head => 'الرأس';

  @override
  String get neck => 'الرقبة';

  @override
  String get chest => 'الصدر';

  @override
  String get abdomen => 'البطن';

  @override
  String get arm => 'الذراع';

  @override
  String get leg => 'الساق';

  @override
  String get backBody => 'الظهر';

  @override
  String get multiple => 'متعدد';

  @override
  String get unspecified => 'غير محدد';

  @override
  String get mild => 'خفيف';

  @override
  String get moderate => 'متوسط';

  @override
  String get severe => 'شديد';

  @override
  String get unbearable => 'لا يطاق';

  @override
  String get nextAddPhoto => 'التالي — إضافة صورة';

  @override
  String get addPhotoSubtitle =>
      'اختياري: التقاط صورة للحادث يساعد فريق الإسعاف على فهم طبيعة الإصابة';

  @override
  String get tapToCapture => 'اضغط هنا لالتقاط صورة';

  @override
  String get sendWithoutPhoto => 'إرسال بدون صورة';

  @override
  String get reportSentSuccess => 'تم إرسال البلاغ!';

  @override
  String get ambulanceOnWay => 'الإسعاف في الطريق. ابقَ هادئاً.';

  @override
  String get backToHome => 'عودة للرئيسية';

  @override
  String get locating => 'جارٍ تحديد موقعك...';

  @override
  String get accidentCarAccident => 'حادث سيارة / تصادم';

  @override
  String get accidentPedestrianHit => 'دهس مشاة';

  @override
  String get accidentFallFromHeight => 'سقوط من ارتفاع';

  @override
  String get accidentFall => 'سقوط عادي';

  @override
  String get accidentElectricShock => 'صدمة كهربائية';

  @override
  String get accidentFireBurn => 'حريق / حروق';

  @override
  String get accidentSuffocation => 'اختناق';

  @override
  String get accidentDrowning => 'غرق';

  @override
  String get accidentWorkInjury => 'إصابة عمل';

  @override
  String get accidentPoisoning => 'تسمم';

  @override
  String get accidentAssault => 'اعتداء / إصابة بعنف';

  @override
  String get accidentSportInjury => 'إصابة رياضية';

  @override
  String get accidentGunshot => 'طلق ناري';

  @override
  String get accidentStabbing => 'طعن / جرح بآلة حادة';

  @override
  String get accidentMedicalEmergency => 'حالة مرضية طارئة';

  @override
  String get conscious => 'واعٍ تماماً';

  @override
  String get semiconscious => 'شبه واعٍ';

  @override
  String get unconscious => 'فاقد الوعي';

  @override
  String get historyEmpty => 'لا يوجد بلاغات سابقة';

  @override
  String get reportStatus => 'حالة البلاغ';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAssigned => 'تم التعيين';

  @override
  String get statusInProgress => 'جارٍ التنفيذ';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusDuplicate => 'مكرر';

  @override
  String get reportDate => 'تاريخ البلاغ';

  @override
  String get reportType => 'نوع البلاغ';

  @override
  String get emergency_report => 'بلاغ طوارئ';

  @override
  String get normal_report => 'بلاغ عادي';

  @override
  String ambulanceGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get availableForReports => 'متاح لاستقبال البلاغات';

  @override
  String get notAvailable => 'غير متاح حالياً';

  @override
  String get reports => 'بلاغات';

  @override
  String get noAssignedEmergencyReports => 'لا توجد بلاغات طوارئ';

  @override
  String get noAssignedReportsSubtitle => 'سيظهر هنا أي بلاغ يتم تكليفك به';

  @override
  String get details => 'التفاصيل';

  @override
  String get navigation => 'ملاحة';

  @override
  String get locationNotSpecified => 'الموقع غير محدد';

  @override
  String updateFailed(String error) {
    return 'فشل التحديث: $error';
  }

  @override
  String get assignedReports => 'البلاغات المُعيَّنة';

  @override
  String get emergencyReports => 'بلاغات الطوارئ';

  @override
  String get noAssignedReports => 'لا توجد بلاغات مُعيَّنة';

  @override
  String get noEmergencyReports => 'لا توجد بلاغات طوارئ';

  @override
  String get patientName => 'اسم المريض';

  @override
  String get patientPhone => 'هاتف المريض';

  @override
  String get patientLocation => 'موقع المريض';

  @override
  String get distance => 'المسافة';

  @override
  String get estimatedTime => 'الوقت المتوقع';

  @override
  String get acceptReport => 'قبول البلاغ';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get statusLabel => 'الحالة:';

  @override
  String get accidentTypeLabel => 'نوع الحادث';

  @override
  String get navigationToLocation => 'الملاحة إلى الموقع';

  @override
  String get confirmArrival => 'تأكيد الوصول للموقع';

  @override
  String get fillMedicalReport => 'تعبئة التقرير الطبي';

  @override
  String get endMission => 'إنهاء المهمة / تسليم المريض';

  @override
  String get fieldMedicalReport => 'التقرير الطبي الميداني';

  @override
  String get additionalNotesHint => 'اكتب أي ملاحظات أخرى هنا...';

  @override
  String get submitReportAction => 'إرسال التقرير';

  @override
  String get statusUpdateSuccess => 'تم تحديث الحالة بنجاح';

  @override
  String get reportNotFound => 'البلاغ غير موجود';

  @override
  String get loadingDetails => 'تحميل التفاصيل...';

  @override
  String get startNavigation => 'بدء الملاحة';

  @override
  String get openInMaps => 'فتح في خرائط جوجل';

  @override
  String get markArrived => 'تحديد الوصول';

  @override
  String get submitMedicalReport => 'إرسال التقرير الطبي';

  @override
  String get backToAvailable => 'العودة للحالة المتاحة';

  @override
  String get ambulanceOnMission => 'في مهمة';

  @override
  String get ambulanceArrived => 'وصل للمريض';

  @override
  String get ambulanceToHospital => 'في طريقه للمستشفى';

  @override
  String get ambulanceAvailable => 'متاح';

  @override
  String get medicalReport => 'التقرير الطبي';

  @override
  String get medicalQuestion => 'سؤال طبي';

  @override
  String get additionalNotes => 'ملاحظات إضافية';

  @override
  String get submitReport => 'إرسال التقرير';

  @override
  String get availability => 'حالة التوفر';

  @override
  String get available => 'متاح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get toggleAvailability => 'تغيير حالة التوفر';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get noMissionHistory => 'لا يوجد سجل للمهام';

  @override
  String get missionHistorySubtitle =>
      'سيظهر هنا تاريخ المهام التي قمت بإنجازها';

  @override
  String get notificationsSubtitle =>
      'ستصلك هنا إشعارات بالبلاغات الجديدة الموجهة إليك';

  @override
  String get noNotificationsTitle => 'لا توجد إشعارات حالياً';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get ambulanceHistory => 'سجل المهام';

  @override
  String get missionCompleted => 'مهمة مكتملة';

  @override
  String get missionDate => 'تاريخ المهمة';

  @override
  String get missionDuration => 'مدة المهمة';

  @override
  String get navigationTitle => 'الملاحة';

  @override
  String navigatingTo(String destination) {
    return 'التوجه إلى: $destination';
  }

  @override
  String remainingDistance(String distance) {
    return 'المسافة المتبقية: $distance';
  }

  @override
  String remainingTime(String time) {
    return 'الوقت المتبقي: $time';
  }

  @override
  String get searchFirstAidHint => 'ابحث عن حالة إسعافية...';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get tryDifferentSearch => 'حاول البحث بكلمات أخرى';

  @override
  String get criticalUrgency => 'حرج';

  @override
  String get highUrgency => 'عاجل';

  @override
  String get normalUrgency => 'عادي';

  @override
  String get firstAidSteps => 'خطوات الإسعاف';

  @override
  String get emergencyInstruction =>
      'حالة طارئة جداً — ابدأ الإسعافات واتصل بـ 123 فوراً';

  @override
  String get standardInstruction =>
      'اتبع الخطوات بدقة واتصل بالإسعاف إذا لزم الأمر';

  @override
  String get firstAidDisclaimer =>
      'تنبيه: هذه المعلومات للأغراض الإرشادية فقط. نجدة تخلي مسؤوليتها عن سوء استخدام هذه المعلومات.';

  @override
  String get imageCopyright => '© الصور: Wikimedia Commons — CC-BY-SA 4.0';

  @override
  String get hospitalsSearching => 'جارٍ البحث عن أقرب المستشفيات...';

  @override
  String get noHospitalsFound => 'لم يتم العثور على مستشفيات';

  @override
  String get checkLocationOrRetry => 'تأكد من تفعيل الموقع أو جرب لاحقاً';

  @override
  String foundHospitalsNearYou(int count) {
    return 'تم العثور على $count مستشفيات بالقرب منك';
  }

  @override
  String get openNow => 'مفتوح الآن';

  @override
  String get closed => 'مغلق';

  @override
  String km(String dist) {
    return '$dist كم';
  }

  @override
  String get directions => 'الاتجاهات';

  @override
  String get locationAccessError => 'تعذر الوصول للموقع';

  @override
  String get locationPermissionDenied =>
      'صلاحية الموقع مرفوضة. فعّلها من الإعدادات.';

  @override
  String get callHospital => 'اتصال';

  @override
  String get getDirections => 'الاتجاهات';

  @override
  String get ambulance => 'الإسعاف';

  @override
  String get police => 'الشرطة';

  @override
  String get fire => 'المطافي';

  @override
  String get rescue => 'النجدة';

  @override
  String get airAmbulance => 'الإسعاف الطائر';

  @override
  String get childRescue => 'نجدة الطفل';

  @override
  String get ambulanceSubtitle =>
      'للحوادث والإصابات والتبليغ عن حالات طبية طارئة';

  @override
  String get policeSubtitle => 'للجرائم والبلاغات الأمنية والمرور';

  @override
  String get fireSubtitle => 'للحرائق وحوادث الطرق والإنقاذ';

  @override
  String get rescueSubtitle => 'للكوارث الطبيعية والإنقاذ المدني';

  @override
  String get airAmbulanceSubtitle => 'للحالات الحرجة في المناطق البعيدة';

  @override
  String get childRescueSubtitle => 'لحماية الطفل من العنف والإهمال';

  @override
  String get otherEmergencyNumbers => 'أرقام الطوارئ الأخرى';

  @override
  String get emergencyNumbersTip =>
      'اضغط على أي رقم للاتصال المباشر، أو اضغط مطولاً لنسخ الرقم.';

  @override
  String get call => 'اتصال';

  @override
  String get hospitalsTitle => 'عنوان المستشفيات';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get invalidPhone => 'رقم الهاتف غير صحيح';

  @override
  String get invalidEmail => 'البريد الإلكتروني غير صحيح';

  @override
  String get passwordTooShort => 'كلمة المرور قصيرة جداً';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get phoneStartsWithPlus => 'يجب أن يبدأ الرقم بـ +';

  @override
  String get phoneTooShort => 'رقم الهاتف قصير جداً';

  @override
  String get reportDetails => 'تفاصيل البلاغ';

  @override
  String get ambulanceAssigned => 'تم تعيين سيارة إسعاف';

  @override
  String get ambulanceName => 'معرف الإسعاف';

  @override
  String get plateNumberLabel => 'رقم اللوحة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutUs => 'عن التطبيق';

  @override
  String get rateApp => 'تقييم التطبيق';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get updateProfile => 'تحديث البيانات';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get profileUpdateError => 'فشل تحديث البيانات، حاول مرة أخرى';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get discardChanges => 'تجاهل التغييرات';

  @override
  String get confirmDiscard => 'هل تريد تجاهل التغييرات غير المحفوظة؟';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get locationSharingActive => 'تتبع الموقع نشط';

  @override
  String get critical => 'حالة حرجة';

  @override
  String get incident => 'حادث';

  @override
  String get emergencyFeed => 'خلاصة الطوارئ';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get historyTab => 'السجل';

  @override
  String get notificationsTab => 'الإشعارات';

  @override
  String get profileTab => 'الملف';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get linkCopied => 'تم نسخ الرابط';

  @override
  String get shareMessage => 'حمل تطبيق نجدة للطوارئ:';

  @override
  String get smsMessage => 'استخدم تطبيق نجدة للاستجابة الطارئة:';

  @override
  String get otherWays => 'مشاركة بطرق أخرى';

  @override
  String get roleCitizen => 'مواطن';

  @override
  String get roleAmbulances => 'الإسعاف';

  @override
  String get defaultUserName => 'مستخدم نجدة';

  @override
  String get settingsPreferences => 'التفضيلات';

  @override
  String get settingsSupportInfo => 'الدعم والمعلومات';

  @override
  String get settingsShareFeedback => 'شاركنا رأيك';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get chatWithSupport => 'تواصل مع الدعم';

  @override
  String get available247 => 'متاح 24/7';

  @override
  String get emergencyLine => 'خط الطوارئ';

  @override
  String get faqs => 'الأسئلة الشائعة';

  @override
  String get faq1Q => 'كيف أرسل بلاغ طارئ؟';

  @override
  String get faq1A =>
      'ببساطة اضغط على زر SOS الكبير في الصفحة الرئيسية أو استخدم المساعد الذكي للإبلاغ عن نوع الحادث.';

  @override
  String get faq2Q => 'هل يمكنني تتبع سيارة الإسعاف؟';

  @override
  String get faq2A =>
      'نعم، بمجرد تعيين سيارة إسعاف لبلاغك، ستظهر لك شاشة تتبع مباشرة توضح موقع السيارة والوقت المتوقع للوصول.';

  @override
  String get faq3Q => 'ما هو نظام الذكاء الاصطناعي في نجدة؟';

  @override
  String get faq3A =>
      'يستخدم نجدة تقنيات الذكاء الاصطناعي لتحليل البلاغات وتصنيف خطورتها وتوجيه أقرب سيارة إسعاف واختيار المستشفى الأنسب للحالة.';

  @override
  String get privacyDataCollection => 'جمع البيانات';

  @override
  String get privacyDataCollectionDesc =>
      '• الموقع الجغرافي (GPS): يتم جمعه فقط عند إرسال بلاغ طوارئ لتحديد موقعك بدقة.\\n• الملف الطبي: المعلومات التي تدخلها (فصيلة الدم، الحساسية، الأمراض المزمنة) لمساعدة طاقم الإسعاف.\\n• رقم الهاتف: للتحقق من الهوية والتواصل معك عند الضرورة.';

  @override
  String get privacyDataUsage => 'استخدام البيانات';

  @override
  String get privacyDataUsageDesc =>
      '• تعيين أقرب سيارة إسعاف لموقع البلاغ.\\n• اختيار المستشفى الأنسب بناءً على الحالة الصحية.\\n• تنبيه جهة اتصال الطوارئ الخاصة بك تلقائياً عند الضرورة.';

  @override
  String get privacyDataSharing => 'مشاركة البيانات';

  @override
  String get privacyDataSharingDesc =>
      '• نحن لا نبيع بياناتك لأي جهات خارجية.\\n• يتم مشاركة بياناتك الطبية وموقعك فقط مع طاقم الإسعاف والمستشفى المعني بالبلاغ.';

  @override
  String get privacyDataDeletion => 'حذف البيانات';

  @override
  String get privacyDataDeletionDesc =>
      '• يمكنك طلب حذف حسابك وبياناتك بالكامل عبر التواصل مع الدعم الفني من داخل التطبيق.';

  @override
  String lastUpdated(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get termsAcceptance => 'القبول بالشروط';

  @override
  String get termsAcceptanceDesc =>
      'باستخدامك لتطبيق نجدة، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء منها، يرجى التوقف عن استخدام التطبيق.';

  @override
  String get termsServiceUsage => 'استخدام الخدمة';

  @override
  String get termsServiceUsageDesc =>
      '• التطبيق مخصص للحالات الطارئة الحقيقية فقط.\\n• يُحظر تماماً إرسال بلاغات وهمية، مما قد يعرضك للمساءلة القانونية.\\n• يجب أن يكون عمر المستخدم 18 عاماً فأكثر، أو استخدامه تحت إشراف ولي الأمر.';

  @override
  String get termsLiability => 'حدود المسؤولية';

  @override
  String get termsLiabilityDesc =>
      'تطبيق نجدة هو وسيط لتسهيل وصول خدمات الإسعاف، ونحن نبذل قصارى جهدنا لضمان دقة النظام ولكننا لا نضمن الاستجابة الفورية في جميع الظروف الخارجة عن إرادتنا.';

  @override
  String get termsTermination => 'إنهاء الخدمة';

  @override
  String get termsTerminationDesc =>
      'نحتفظ بالحق في تعليق أو إنهاء وصولك إلى الخدمة في حالة مخالفة شروط الاستخدام أو إساءة استخدام نظام الطوارئ.';

  @override
  String get aboutSubtitle => 'نظام الاستجابة الطارئة الذكي';

  @override
  String get aboutInfrastructure => 'البنية التحتية';

  @override
  String get aboutRegion => 'المنطقة';

  @override
  String get egypt => 'جمهورية مصر العربية';

  @override
  String get aboutDescription =>
      'نجدة هو نظام متكامل يهدف إلى تقليل وقت الاستجابة في حالات الطوارئ الطبية باستخدام الذكاء الاصطناعي وربط المواطنين مباشرة بأطقم الإسعاف والمستشفيات.';

  @override
  String get rateTitle => 'رأيك يهمنا';

  @override
  String get rateSubtitle => 'ساعدنا في تحسين نجدة من خلال تقييم تجربتك';

  @override
  String get rateSubmit => 'إرسال التقييم';

  @override
  String get shareTitle => 'شارك عبر';

  @override
  String get appLink => 'رابط التطبيق';

  @override
  String get copyLink => 'نسخ رابط';

  @override
  String get changeLanguage => 'تغيير اللغة';
}
