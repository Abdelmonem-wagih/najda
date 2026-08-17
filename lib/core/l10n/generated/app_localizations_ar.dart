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
  String get loginAsParamedic => 'مسعف';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => 'أدخل رقم هاتفك مع مفتاح الدولة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل تريد تسجيل الخروج؟';

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
  String get otpTitle => 'التحقق من الرقم';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المرسل إلى $phone';
  }

  @override
  String get otpCode => 'رمز التحقق';

  @override
  String get otpHint => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get verifyOtp => 'تحقق';

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String get registrationTitle => 'استكمال بيانات الملف';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nationalId => 'الرقم القومي';

  @override
  String get emergencyContact => 'رقم الطوارئ (اختياري)';

  @override
  String get chronicDiseases => 'الأمراض المزمنة';

  @override
  String get allergies => 'الحساسية';

  @override
  String get currentMedications => 'الأدوية الحالية';

  @override
  String get additionalInfo => 'معلومات إضافية';

  @override
  String get completeProfile => 'إكمال الملف الشخصي';

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
  String get aiAssistant => 'مساعد نجدة';

  @override
  String get aiAssistantDescription => 'دردشة طبية ذكية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String greeting(String name) {
    return 'مرحباً، $name';
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
  String get reportDate => 'تاريخ البلاغ';

  @override
  String get reportType => 'نوع البلاغ';

  @override
  String get emergency_report => 'بلاغ طوارئ';

  @override
  String get normal_report => 'بلاغ عادي';

  @override
  String get paramedicDashboard => 'لوحة المسعف';

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
  String get reportDetails => 'تفاصيل البلاغ';

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
  String get paramedicOnMission => 'في مهمة';

  @override
  String get paramedicArrived => 'وصل للمريض';

  @override
  String get paramedicToHospital => 'في طريقه للمستشفى';

  @override
  String get paramedicAvailable => 'متاح';

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
  String get newAssignment => 'تعيين جديد';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get paramedicHistory => 'سجل المهام';

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
  String get firstAidTitle => 'دليل الإسعافات الأولية';

  @override
  String get firstAidSearch => 'ابحث عن إسعافات أولية...';

  @override
  String get hospitalsTitle => 'مستشفيات قريبة';

  @override
  String get hospitalsSearching => 'جارٍ البحث عن مستشفيات قريبة...';

  @override
  String get callHospital => 'اتصال';

  @override
  String get getDirections => 'الاتجاهات';

  @override
  String get emergencyNumbersTitle => 'أرقام الطوارئ';

  @override
  String get call => 'اتصال';

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
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get changeLanguage => 'تغيير اللغة';
}
