import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'نجدة'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'استجابة الطوارئ الفورية'**
  String get appTagline;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بيانات حسابك للمتابعة'**
  String get loginSubtitle;

  /// No description provided for @loginAsCitizen.
  ///
  /// In ar, this message translates to:
  /// **'مواطن'**
  String get loginAsCitizen;

  /// No description provided for @loginAsParamedic.
  ///
  /// In ar, this message translates to:
  /// **'مسعف'**
  String get loginAsParamedic;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك مع مفتاح الدولة'**
  String get phoneHint;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @sendOtp.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز التحقق'**
  String get sendOtp;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الرقم'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المرسل إلى {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otpCode;

  /// No description provided for @otpHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكون من 6 أرقام'**
  String get otpHint;

  /// No description provided for @verifyOtp.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendOtp;

  /// No description provided for @registrationTitle.
  ///
  /// In ar, this message translates to:
  /// **'استكمال بيانات الملف'**
  String get registrationTitle;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @nationalId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي'**
  String get nationalId;

  /// No description provided for @emergencyContact.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطوارئ (اختياري)'**
  String get emergencyContact;

  /// No description provided for @chronicDiseases.
  ///
  /// In ar, this message translates to:
  /// **'الأمراض المزمنة'**
  String get chronicDiseases;

  /// No description provided for @allergies.
  ///
  /// In ar, this message translates to:
  /// **'الحساسية'**
  String get allergies;

  /// No description provided for @currentMedications.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية الحالية'**
  String get currentMedications;

  /// No description provided for @additionalInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات إضافية'**
  String get additionalInfo;

  /// No description provided for @completeProfile.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الملف الشخصي'**
  String get completeProfile;

  /// No description provided for @homeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeTitle;

  /// No description provided for @sos.
  ///
  /// In ar, this message translates to:
  /// **'طوارئ'**
  String get sos;

  /// No description provided for @sosDescription.
  ///
  /// In ar, this message translates to:
  /// **'اضغط في حالة الطوارئ الطبية'**
  String get sosDescription;

  /// No description provided for @firstAid.
  ///
  /// In ar, this message translates to:
  /// **'إسعافات أولية'**
  String get firstAid;

  /// No description provided for @firstAidDescription.
  ///
  /// In ar, this message translates to:
  /// **'دليل الإسعافات الأولية'**
  String get firstAidDescription;

  /// No description provided for @hospitals.
  ///
  /// In ar, this message translates to:
  /// **'مستشفيات قريبة'**
  String get hospitals;

  /// No description provided for @hospitalsDescription.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مستشفيات قريبة'**
  String get hospitalsDescription;

  /// No description provided for @emergency.
  ///
  /// In ar, this message translates to:
  /// **'أرقام الطوارئ'**
  String get emergency;

  /// No description provided for @emergencyDescription.
  ///
  /// In ar, this message translates to:
  /// **'أرقام الطوارئ الهامة'**
  String get emergencyDescription;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'سجل البلاغات'**
  String get history;

  /// No description provided for @historyDescription.
  ///
  /// In ar, this message translates to:
  /// **'بلاغاتك السابقة'**
  String get historyDescription;

  /// No description provided for @aiTriage.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الأعراض'**
  String get aiTriage;

  /// No description provided for @aiTriageDescription.
  ///
  /// In ar, this message translates to:
  /// **'ذكاء اصطناعي للتشخيص'**
  String get aiTriageDescription;

  /// No description provided for @aiAssistant.
  ///
  /// In ar, this message translates to:
  /// **'مساعد نجدة'**
  String get aiAssistant;

  /// No description provided for @aiAssistantDescription.
  ///
  /// In ar, this message translates to:
  /// **'دردشة طبية ذكية'**
  String get aiAssistantDescription;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String greeting(String name);

  /// No description provided for @reportTitle.
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ عن حادث'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تفاصيل الحادث'**
  String get reportSubtitle;

  /// No description provided for @accidentType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحادث'**
  String get accidentType;

  /// No description provided for @selectAccidentType.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الحادث'**
  String get selectAccidentType;

  /// No description provided for @consciousnessLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الوعي'**
  String get consciousnessLevel;

  /// No description provided for @injuryLocation.
  ///
  /// In ar, this message translates to:
  /// **'موضع الإصابة'**
  String get injuryLocation;

  /// No description provided for @painLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الألم'**
  String get painLevel;

  /// No description provided for @addPhoto.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get addPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In ar, this message translates to:
  /// **'حذف الصورة'**
  String get removePhoto;

  /// No description provided for @sendReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال البلاغ'**
  String get sendReport;

  /// No description provided for @reportSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال البلاغ بنجاح'**
  String get reportSent;

  /// No description provided for @reportError.
  ///
  /// In ar, this message translates to:
  /// **'فشل إرسال البلاغ'**
  String get reportError;

  /// No description provided for @locating.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد موقعك...'**
  String get locating;

  /// No description provided for @accidentCarAccident.
  ///
  /// In ar, this message translates to:
  /// **'حادث سيارة / تصادم'**
  String get accidentCarAccident;

  /// No description provided for @accidentPedestrianHit.
  ///
  /// In ar, this message translates to:
  /// **'دهس مشاة'**
  String get accidentPedestrianHit;

  /// No description provided for @accidentFallFromHeight.
  ///
  /// In ar, this message translates to:
  /// **'سقوط من ارتفاع'**
  String get accidentFallFromHeight;

  /// No description provided for @accidentFall.
  ///
  /// In ar, this message translates to:
  /// **'سقوط عادي'**
  String get accidentFall;

  /// No description provided for @accidentElectricShock.
  ///
  /// In ar, this message translates to:
  /// **'صدمة كهربائية'**
  String get accidentElectricShock;

  /// No description provided for @accidentFireBurn.
  ///
  /// In ar, this message translates to:
  /// **'حريق / حروق'**
  String get accidentFireBurn;

  /// No description provided for @accidentSuffocation.
  ///
  /// In ar, this message translates to:
  /// **'اختناق'**
  String get accidentSuffocation;

  /// No description provided for @accidentDrowning.
  ///
  /// In ar, this message translates to:
  /// **'غرق'**
  String get accidentDrowning;

  /// No description provided for @accidentWorkInjury.
  ///
  /// In ar, this message translates to:
  /// **'إصابة عمل'**
  String get accidentWorkInjury;

  /// No description provided for @accidentPoisoning.
  ///
  /// In ar, this message translates to:
  /// **'تسمم'**
  String get accidentPoisoning;

  /// No description provided for @accidentAssault.
  ///
  /// In ar, this message translates to:
  /// **'اعتداء / إصابة بعنف'**
  String get accidentAssault;

  /// No description provided for @accidentSportInjury.
  ///
  /// In ar, this message translates to:
  /// **'إصابة رياضية'**
  String get accidentSportInjury;

  /// No description provided for @accidentGunshot.
  ///
  /// In ar, this message translates to:
  /// **'طلق ناري'**
  String get accidentGunshot;

  /// No description provided for @accidentStabbing.
  ///
  /// In ar, this message translates to:
  /// **'طعن / جرح بآلة حادة'**
  String get accidentStabbing;

  /// No description provided for @accidentMedicalEmergency.
  ///
  /// In ar, this message translates to:
  /// **'حالة مرضية طارئة'**
  String get accidentMedicalEmergency;

  /// No description provided for @conscious.
  ///
  /// In ar, this message translates to:
  /// **'واعٍ تماماً'**
  String get conscious;

  /// No description provided for @semiconscious.
  ///
  /// In ar, this message translates to:
  /// **'شبه واعٍ'**
  String get semiconscious;

  /// No description provided for @unconscious.
  ///
  /// In ar, this message translates to:
  /// **'فاقد الوعي'**
  String get unconscious;

  /// No description provided for @historyEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد بلاغات سابقة'**
  String get historyEmpty;

  /// No description provided for @reportStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة البلاغ'**
  String get reportStatus;

  /// No description provided for @statusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get statusPending;

  /// No description provided for @statusAssigned.
  ///
  /// In ar, this message translates to:
  /// **'تم التعيين'**
  String get statusAssigned;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التنفيذ'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get statusCancelled;

  /// No description provided for @reportDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البلاغ'**
  String get reportDate;

  /// No description provided for @reportType.
  ///
  /// In ar, this message translates to:
  /// **'نوع البلاغ'**
  String get reportType;

  /// No description provided for @emergency_report.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ طوارئ'**
  String get emergency_report;

  /// No description provided for @normal_report.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ عادي'**
  String get normal_report;

  /// No description provided for @paramedicDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المسعف'**
  String get paramedicDashboard;

  /// No description provided for @assignedReports.
  ///
  /// In ar, this message translates to:
  /// **'البلاغات المُعيَّنة'**
  String get assignedReports;

  /// No description provided for @emergencyReports.
  ///
  /// In ar, this message translates to:
  /// **'بلاغات الطوارئ'**
  String get emergencyReports;

  /// No description provided for @noAssignedReports.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات مُعيَّنة'**
  String get noAssignedReports;

  /// No description provided for @noEmergencyReports.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات طوارئ'**
  String get noEmergencyReports;

  /// No description provided for @patientName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المريض'**
  String get patientName;

  /// No description provided for @patientPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف المريض'**
  String get patientPhone;

  /// No description provided for @patientLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع المريض'**
  String get patientLocation;

  /// No description provided for @distance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get distance;

  /// No description provided for @estimatedTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتوقع'**
  String get estimatedTime;

  /// No description provided for @acceptReport.
  ///
  /// In ar, this message translates to:
  /// **'قبول البلاغ'**
  String get acceptReport;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @reportDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل البلاغ'**
  String get reportDetails;

  /// No description provided for @startNavigation.
  ///
  /// In ar, this message translates to:
  /// **'بدء الملاحة'**
  String get startNavigation;

  /// No description provided for @openInMaps.
  ///
  /// In ar, this message translates to:
  /// **'فتح في خرائط جوجل'**
  String get openInMaps;

  /// No description provided for @markArrived.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الوصول'**
  String get markArrived;

  /// No description provided for @submitMedicalReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقرير الطبي'**
  String get submitMedicalReport;

  /// No description provided for @backToAvailable.
  ///
  /// In ar, this message translates to:
  /// **'العودة للحالة المتاحة'**
  String get backToAvailable;

  /// No description provided for @paramedicOnMission.
  ///
  /// In ar, this message translates to:
  /// **'في مهمة'**
  String get paramedicOnMission;

  /// No description provided for @paramedicArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصل للمريض'**
  String get paramedicArrived;

  /// No description provided for @paramedicToHospital.
  ///
  /// In ar, this message translates to:
  /// **'في طريقه للمستشفى'**
  String get paramedicToHospital;

  /// No description provided for @paramedicAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get paramedicAvailable;

  /// No description provided for @medicalReport.
  ///
  /// In ar, this message translates to:
  /// **'التقرير الطبي'**
  String get medicalReport;

  /// No description provided for @medicalQuestion.
  ///
  /// In ar, this message translates to:
  /// **'سؤال طبي'**
  String get medicalQuestion;

  /// No description provided for @additionalNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية'**
  String get additionalNotes;

  /// No description provided for @submitReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقرير'**
  String get submitReport;

  /// No description provided for @availability.
  ///
  /// In ar, this message translates to:
  /// **'حالة التوفر'**
  String get availability;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get unavailable;

  /// No description provided for @toggleAvailability.
  ///
  /// In ar, this message translates to:
  /// **'تغيير حالة التوفر'**
  String get toggleAvailability;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotifications;

  /// No description provided for @newAssignment.
  ///
  /// In ar, this message translates to:
  /// **'تعيين جديد'**
  String get newAssignment;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @paramedicHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المهام'**
  String get paramedicHistory;

  /// No description provided for @missionCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مهمة مكتملة'**
  String get missionCompleted;

  /// No description provided for @missionDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ المهمة'**
  String get missionDate;

  /// No description provided for @missionDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة المهمة'**
  String get missionDuration;

  /// No description provided for @navigationTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملاحة'**
  String get navigationTitle;

  /// No description provided for @navigatingTo.
  ///
  /// In ar, this message translates to:
  /// **'التوجه إلى: {destination}'**
  String navigatingTo(String destination);

  /// No description provided for @remainingDistance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة المتبقية: {distance}'**
  String remainingDistance(String distance);

  /// No description provided for @remainingTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي: {time}'**
  String remainingTime(String time);

  /// No description provided for @firstAidTitle.
  ///
  /// In ar, this message translates to:
  /// **'دليل الإسعافات الأولية'**
  String get firstAidTitle;

  /// No description provided for @firstAidSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن إسعافات أولية...'**
  String get firstAidSearch;

  /// No description provided for @hospitalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مستشفيات قريبة'**
  String get hospitalsTitle;

  /// No description provided for @hospitalsSearching.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث عن مستشفيات قريبة...'**
  String get hospitalsSearching;

  /// No description provided for @callHospital.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get callHospital;

  /// No description provided for @getDirections.
  ///
  /// In ar, this message translates to:
  /// **'الاتجاهات'**
  String get getDirections;

  /// No description provided for @emergencyNumbersTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرقام الطوارئ'**
  String get emergencyNumbersTitle;

  /// No description provided for @call.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get call;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صحيح'**
  String get invalidPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة جداً'**
  String get passwordTooShort;

  /// No description provided for @loginFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول'**
  String get loginFailed;

  /// No description provided for @phoneStartsWithPlus.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يبدأ الرقم بـ +'**
  String get phoneStartsWithPlus;

  /// No description provided for @phoneTooShort.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف قصير جداً'**
  String get phoneTooShort;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @changeLanguage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get changeLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
