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

  /// No description provided for @loginAsAmbulance.
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف'**
  String get loginAsAmbulance;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'+20 1XX XXXX XXXX'**
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

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutAction.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get logoutAction;

  /// No description provided for @noInfo.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد'**
  String get noInfo;

  /// No description provided for @personalData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الشخصية'**
  String get personalData;

  /// No description provided for @medicalData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الطبية'**
  String get medicalData;

  /// No description provided for @identityNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي'**
  String get identityNumber;

  /// No description provided for @emergencyContactPerson.
  ///
  /// In ar, this message translates to:
  /// **'جهة اتصال الطوارئ'**
  String get emergencyContactPerson;

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

  /// No description provided for @ambulanceInfo.
  ///
  /// In ar, this message translates to:
  /// **'حسابات الإسعاف يُنشئها مشرف النظام فقط'**
  String get ambulanceInfo;

  /// No description provided for @newUserPrompt.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get newUserPrompt;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// No description provided for @sendOtpPrompt.
  ///
  /// In ar, this message translates to:
  /// **'لتسجيل حساب جديد: أدخل رقمك واضغط \"إرسال رمز التحقق\"'**
  String get sendOtpPrompt;

  /// No description provided for @enterPhoneFirst.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك أولاً ثم اضغط \"إرسال رمز التحقق\"'**
  String get enterPhoneFirst;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الرقم'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكون من 6 أرقام المرسل إلى {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpCode.
  ///
  /// In ar, this message translates to:
  /// **'كود التحقق'**
  String get otpCode;

  /// No description provided for @otpHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكون من 6 أرقام'**
  String get otpHint;

  /// No description provided for @verifyOtp.
  ///
  /// In ar, this message translates to:
  /// **'تحقق الآن'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendOtp;

  /// No description provided for @resendAfter.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إعادة الإرسال بعد {seconds} ثانية'**
  String resendAfter(int seconds);

  /// No description provided for @verifiedNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم تم التحقق منه'**
  String get verifiedNumber;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الشخصية'**
  String get personalInfo;

  /// No description provided for @medicalInfo.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الطبية'**
  String get medicalInfo;

  /// No description provided for @medicalInfoSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تُرسل لطاقم الإسعاف عند البلاغات للمساعدة في التشخيص السريع'**
  String get medicalInfoSubtitle;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة مرور للحساب'**
  String get passwordLabel;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'(اختياري)'**
  String get optional;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة مرور لحماية حسابك'**
  String get passwordHint;

  /// No description provided for @passwordLengthError.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور 6 أحرف على الأقل'**
  String get passwordLengthError;

  /// No description provided for @chronicDiseasesHint.
  ///
  /// In ar, this message translates to:
  /// **'سكري، ضغط، قلب... (افصل بفاصلة)'**
  String get chronicDiseasesHint;

  /// No description provided for @allergiesHint.
  ///
  /// In ar, this message translates to:
  /// **'بنسيلين، فول سوداني...'**
  String get allergiesHint;

  /// No description provided for @medicationsHint.
  ///
  /// In ar, this message translates to:
  /// **'ميتفورمين، أسبرين...'**
  String get medicationsHint;

  /// No description provided for @createAccountButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccountButton;

  /// No description provided for @identityError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في التحقق من الهوية. أعد المحاولة.'**
  String get identityError;

  /// No description provided for @fullNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل *'**
  String get fullNameLabel;

  /// No description provided for @nationalIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي *'**
  String get nationalIdLabel;

  /// No description provided for @emergencyContactLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم جهة الاتصال الطارئة'**
  String get emergencyContactLabel;

  /// No description provided for @chronicDiseasesLabel.
  ///
  /// In ar, this message translates to:
  /// **'أمراض مزمنة'**
  String get chronicDiseasesLabel;

  /// No description provided for @allergiesLabel.
  ///
  /// In ar, this message translates to:
  /// **'حساسية من أدوية أو مواد'**
  String get allergiesLabel;

  /// No description provided for @medicationsLabel.
  ///
  /// In ar, this message translates to:
  /// **'أدوية حالية'**
  String get medicationsLabel;

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

  /// No description provided for @aiThinking.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التفكير...'**
  String get aiThinking;

  /// No description provided for @aiConnected.
  ///
  /// In ar, this message translates to:
  /// **'متصل الآن'**
  String get aiConnected;

  /// No description provided for @aiReplying.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الرد...'**
  String get aiReplying;

  /// No description provided for @typeMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سؤالك هنا...'**
  String get typeMessageHint;

  /// No description provided for @ambulanceWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في نظام نجدة! 🏥\n\nأنا مساعدك الطبي الميداني. يمكنني مساعدتك في البروتوكولات والجرعات والتفاعلات الدوائية.\n\nاسألني أي سؤال طبي.'**
  String get ambulanceWelcome;

  /// No description provided for @citizenWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً! أنا مساعد نجدة الذكي 🤖\n\nيمكنني مساعدتك في تقييم الأعراض وإرشادات الإسعافات الأولية.\n\n⚠️ في الطوارئ اتصل بـ 123 فوراً!'**
  String get citizenWelcome;

  /// No description provided for @permissionError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الصلاحيات. تأكد من تسجيل الدخول.'**
  String get permissionError;

  /// No description provided for @serviceUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة غير متاحة حالياً. تأكد من نشر Firebase Functions.'**
  String get serviceUnavailable;

  /// No description provided for @serverError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في خادم الذكاء الاصطناعي. تحقق من إعداد GROQ_API_KEY في Firebase.'**
  String get serverError;

  /// No description provided for @timeoutError.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال. حاول مرة أخرى.'**
  String get timeoutError;

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالإنترنت.'**
  String get networkError;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name} 👋'**
  String greeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكننا مساعدتك اليوم؟'**
  String get homeSubtitle;

  /// No description provided for @sosButtonTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب نجدة فورية'**
  String get sosButtonTitle;

  /// No description provided for @sosButtonSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يُرسل موقعك وبياناتك الطبية فوراً'**
  String get sosButtonSubtitle;

  /// No description provided for @reportIncidentTitle.
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ عن حادث'**
  String get reportIncidentTitle;

  /// No description provided for @reportIncidentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شاهدت حادثاً؟ أبلغ عنه لمساعدة الآخرين'**
  String get reportIncidentSubtitle;

  /// No description provided for @sosSentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال بلاغ الطوارئ!'**
  String get sosSentTitle;

  /// No description provided for @reportNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم البلاغ: R-{code}'**
  String reportNumber(String code);

  /// No description provided for @sosSentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف في الطريق إليك. ابقَ في مكانك وحافظ على هدوئك.'**
  String get sosSentSubtitle;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @medicalTip.
  ///
  /// In ar, this message translates to:
  /// **'حافظ على تحديث بياناتك الطبية لضمان حصولك على أفضل رعاية في حالات الطوارئ.'**
  String get medicalTip;

  /// No description provided for @sosEmergencyAlert.
  ///
  /// In ar, this message translates to:
  /// **'🚨 *تنبيه طوارئ نجدة*\n\n{name} أرسل بلاغ طوارئ!\n📍 الموقع: https://maps.google.com/?q={lat},{lng}\n🏥 رقم البلاغ: {code}\n⏰ الوقت: {time}\n\nتم إرسال الإسعاف تلقائياً.'**
  String sosEmergencyAlert(
      String name, double lat, double lng, String code, String time);

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

  /// No description provided for @accidentTypeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيف الأقرب للحالة للمساعدة في الاستجابة'**
  String get accidentTypeSubtitle;

  /// No description provided for @injuryDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إصابات الحالة'**
  String get injuryDetailsTitle;

  /// No description provided for @injuryDetailsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'وصف حالة المصاب يساعد طاقم الإسعاف على الاستعداد'**
  String get injuryDetailsSubtitle;

  /// No description provided for @head.
  ///
  /// In ar, this message translates to:
  /// **'الرأس'**
  String get head;

  /// No description provided for @neck.
  ///
  /// In ar, this message translates to:
  /// **'الرقبة'**
  String get neck;

  /// No description provided for @chest.
  ///
  /// In ar, this message translates to:
  /// **'الصدر'**
  String get chest;

  /// No description provided for @abdomen.
  ///
  /// In ar, this message translates to:
  /// **'البطن'**
  String get abdomen;

  /// No description provided for @arm.
  ///
  /// In ar, this message translates to:
  /// **'الذراع'**
  String get arm;

  /// No description provided for @leg.
  ///
  /// In ar, this message translates to:
  /// **'الساق'**
  String get leg;

  /// No description provided for @backBody.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get backBody;

  /// No description provided for @multiple.
  ///
  /// In ar, this message translates to:
  /// **'متعدد'**
  String get multiple;

  /// No description provided for @unspecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get unspecified;

  /// No description provided for @mild.
  ///
  /// In ar, this message translates to:
  /// **'خفيف'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get moderate;

  /// No description provided for @severe.
  ///
  /// In ar, this message translates to:
  /// **'شديد'**
  String get severe;

  /// No description provided for @unbearable.
  ///
  /// In ar, this message translates to:
  /// **'لا يطاق'**
  String get unbearable;

  /// No description provided for @nextAddPhoto.
  ///
  /// In ar, this message translates to:
  /// **'التالي — إضافة صورة'**
  String get nextAddPhoto;

  /// No description provided for @addPhotoSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختياري: التقاط صورة للحادث يساعد فريق الإسعاف على فهم طبيعة الإصابة'**
  String get addPhotoSubtitle;

  /// No description provided for @tapToCapture.
  ///
  /// In ar, this message translates to:
  /// **'اضغط هنا لالتقاط صورة'**
  String get tapToCapture;

  /// No description provided for @sendWithoutPhoto.
  ///
  /// In ar, this message translates to:
  /// **'إرسال بدون صورة'**
  String get sendWithoutPhoto;

  /// No description provided for @reportSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال البلاغ!'**
  String get reportSentSuccess;

  /// No description provided for @ambulanceOnWay.
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف في الطريق. ابقَ هادئاً.'**
  String get ambulanceOnWay;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'عودة للرئيسية'**
  String get backToHome;

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

  /// No description provided for @statusDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'مكرر'**
  String get statusDuplicate;

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

  /// No description provided for @ambulanceGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String ambulanceGreeting(String name);

  /// No description provided for @availableForReports.
  ///
  /// In ar, this message translates to:
  /// **'متاح لاستقبال البلاغات'**
  String get availableForReports;

  /// No description provided for @notAvailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح حالياً'**
  String get notAvailable;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'بلاغات'**
  String get reports;

  /// No description provided for @noAssignedEmergencyReports.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات طوارئ'**
  String get noAssignedEmergencyReports;

  /// No description provided for @noAssignedReportsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر هنا أي بلاغ يتم تكليفك به'**
  String get noAssignedReportsSubtitle;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @navigation.
  ///
  /// In ar, this message translates to:
  /// **'ملاحة'**
  String get navigation;

  /// No description provided for @locationNotSpecified.
  ///
  /// In ar, this message translates to:
  /// **'الموقع غير محدد'**
  String get locationNotSpecified;

  /// No description provided for @updateFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحديث: {error}'**
  String updateFailed(String error);

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

  /// No description provided for @statusLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة:'**
  String get statusLabel;

  /// No description provided for @accidentTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحادث'**
  String get accidentTypeLabel;

  /// No description provided for @navigationToLocation.
  ///
  /// In ar, this message translates to:
  /// **'الملاحة إلى الموقع'**
  String get navigationToLocation;

  /// No description provided for @confirmArrival.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الوصول للموقع'**
  String get confirmArrival;

  /// No description provided for @fillMedicalReport.
  ///
  /// In ar, this message translates to:
  /// **'تعبئة التقرير الطبي'**
  String get fillMedicalReport;

  /// No description provided for @endMission.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء المهمة / تسليم المريض'**
  String get endMission;

  /// No description provided for @fieldMedicalReport.
  ///
  /// In ar, this message translates to:
  /// **'التقرير الطبي الميداني'**
  String get fieldMedicalReport;

  /// No description provided for @additionalNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب أي ملاحظات أخرى هنا...'**
  String get additionalNotesHint;

  /// No description provided for @submitReportAction.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقرير'**
  String get submitReportAction;

  /// No description provided for @statusUpdateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الحالة بنجاح'**
  String get statusUpdateSuccess;

  /// No description provided for @reportNotFound.
  ///
  /// In ar, this message translates to:
  /// **'البلاغ غير موجود'**
  String get reportNotFound;

  /// No description provided for @loadingDetails.
  ///
  /// In ar, this message translates to:
  /// **'تحميل التفاصيل...'**
  String get loadingDetails;

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

  /// No description provided for @ambulanceOnMission.
  ///
  /// In ar, this message translates to:
  /// **'في مهمة'**
  String get ambulanceOnMission;

  /// No description provided for @ambulanceArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصل للمريض'**
  String get ambulanceArrived;

  /// No description provided for @ambulanceToHospital.
  ///
  /// In ar, this message translates to:
  /// **'في طريقه للمستشفى'**
  String get ambulanceToHospital;

  /// No description provided for @ambulanceAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get ambulanceAvailable;

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

  /// No description provided for @noMissionHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل للمهام'**
  String get noMissionHistory;

  /// No description provided for @missionHistorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر هنا تاريخ المهام التي قمت بإنجازها'**
  String get missionHistorySubtitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ستصلك هنا إشعارات بالبلاغات الجديدة الموجهة إليك'**
  String get notificationsSubtitle;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات حالياً'**
  String get noNotificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @ambulanceHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المهام'**
  String get ambulanceHistory;

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

  /// No description provided for @searchFirstAidHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن حالة إسعافية...'**
  String get searchFirstAidHint;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In ar, this message translates to:
  /// **'حاول البحث بكلمات أخرى'**
  String get tryDifferentSearch;

  /// No description provided for @criticalUrgency.
  ///
  /// In ar, this message translates to:
  /// **'حرج'**
  String get criticalUrgency;

  /// No description provided for @highUrgency.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get highUrgency;

  /// No description provided for @normalUrgency.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get normalUrgency;

  /// No description provided for @firstAidSteps.
  ///
  /// In ar, this message translates to:
  /// **'خطوات الإسعاف'**
  String get firstAidSteps;

  /// No description provided for @emergencyInstruction.
  ///
  /// In ar, this message translates to:
  /// **'حالة طارئة جداً — ابدأ الإسعافات واتصل بـ 123 فوراً'**
  String get emergencyInstruction;

  /// No description provided for @standardInstruction.
  ///
  /// In ar, this message translates to:
  /// **'اتبع الخطوات بدقة واتصل بالإسعاف إذا لزم الأمر'**
  String get standardInstruction;

  /// No description provided for @firstAidDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: هذه المعلومات للأغراض الإرشادية فقط. نجدة تخلي مسؤوليتها عن سوء استخدام هذه المعلومات.'**
  String get firstAidDisclaimer;

  /// No description provided for @imageCopyright.
  ///
  /// In ar, this message translates to:
  /// **'© الصور: Wikimedia Commons — CC-BY-SA 4.0'**
  String get imageCopyright;

  /// No description provided for @hospitalsSearching.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث عن أقرب المستشفيات...'**
  String get hospitalsSearching;

  /// No description provided for @noHospitalsFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على مستشفيات'**
  String get noHospitalsFound;

  /// No description provided for @checkLocationOrRetry.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من تفعيل الموقع أو جرب لاحقاً'**
  String get checkLocationOrRetry;

  /// No description provided for @foundHospitalsNearYou.
  ///
  /// In ar, this message translates to:
  /// **'تم العثور على {count} مستشفيات بالقرب منك'**
  String foundHospitalsNearYou(int count);

  /// No description provided for @openNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح الآن'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get closed;

  /// No description provided for @km.
  ///
  /// In ar, this message translates to:
  /// **'{dist} كم'**
  String km(String dist);

  /// No description provided for @directions.
  ///
  /// In ar, this message translates to:
  /// **'الاتجاهات'**
  String get directions;

  /// No description provided for @locationAccessError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الوصول للموقع'**
  String get locationAccessError;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية الموقع مرفوضة. فعّلها من الإعدادات.'**
  String get locationPermissionDenied;

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

  /// No description provided for @ambulance.
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف'**
  String get ambulance;

  /// No description provided for @police.
  ///
  /// In ar, this message translates to:
  /// **'الشرطة'**
  String get police;

  /// No description provided for @fire.
  ///
  /// In ar, this message translates to:
  /// **'المطافي'**
  String get fire;

  /// No description provided for @rescue.
  ///
  /// In ar, this message translates to:
  /// **'النجدة'**
  String get rescue;

  /// No description provided for @airAmbulance.
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف الطائر'**
  String get airAmbulance;

  /// No description provided for @childRescue.
  ///
  /// In ar, this message translates to:
  /// **'نجدة الطفل'**
  String get childRescue;

  /// No description provided for @ambulanceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'للحوادث والإصابات والتبليغ عن حالات طبية طارئة'**
  String get ambulanceSubtitle;

  /// No description provided for @policeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'للجرائم والبلاغات الأمنية والمرور'**
  String get policeSubtitle;

  /// No description provided for @fireSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'للحرائق وحوادث الطرق والإنقاذ'**
  String get fireSubtitle;

  /// No description provided for @rescueSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'للكوارث الطبيعية والإنقاذ المدني'**
  String get rescueSubtitle;

  /// No description provided for @airAmbulanceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'للحالات الحرجة في المناطق البعيدة'**
  String get airAmbulanceSubtitle;

  /// No description provided for @childRescueSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لحماية الطفل من العنف والإهمال'**
  String get childRescueSubtitle;

  /// No description provided for @otherEmergencyNumbers.
  ///
  /// In ar, this message translates to:
  /// **'أرقام الطوارئ الأخرى'**
  String get otherEmergencyNumbers;

  /// No description provided for @emergencyNumbersTip.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على أي رقم للاتصال المباشر، أو اضغط مطولاً لنسخ الرقم.'**
  String get emergencyNumbersTip;

  /// No description provided for @call.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get call;

  /// No description provided for @hospitalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المستشفيات'**
  String get hospitalsTitle;

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

  /// No description provided for @reportDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل البلاغ'**
  String get reportDetails;

  /// No description provided for @ambulanceAssigned.
  ///
  /// In ar, this message translates to:
  /// **'تم تعيين سيارة إسعاف'**
  String get ambulanceAssigned;

  /// No description provided for @ambulanceName.
  ///
  /// In ar, this message translates to:
  /// **'معرف الإسعاف'**
  String get ambulanceName;

  /// No description provided for @plateNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get plateNumberLabel;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutUs;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rateApp;

  /// No description provided for @helpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpSupport;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @updateProfile.
  ///
  /// In ar, this message translates to:
  /// **'تحديث البيانات'**
  String get updateProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get profileUpdated;

  /// No description provided for @profileUpdateError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحديث البيانات، حاول مرة أخرى'**
  String get profileUpdateError;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @discardChanges.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات'**
  String get discardChanges;

  /// No description provided for @confirmDiscard.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تجاهل التغييرات غير المحفوظة؟'**
  String get confirmDiscard;

  /// No description provided for @termsOfService.
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get termsOfService;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get shareApp;

  /// No description provided for @locationSharingActive.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الموقع نشط'**
  String get locationSharingActive;

  /// No description provided for @critical.
  ///
  /// In ar, this message translates to:
  /// **'حالة حرجة'**
  String get critical;

  /// No description provided for @incident.
  ///
  /// In ar, this message translates to:
  /// **'حادث'**
  String get incident;

  /// No description provided for @emergencyFeed.
  ///
  /// In ar, this message translates to:
  /// **'خلاصة الطوارئ'**
  String get emergencyFeed;

  /// No description provided for @homeTab.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeTab;

  /// No description provided for @historyTab.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get historyTab;

  /// No description provided for @notificationsTab.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTab;

  /// No description provided for @profileTab.
  ///
  /// In ar, this message translates to:
  /// **'الملف'**
  String get profileTab;

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

  /// No description provided for @linkCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرابط'**
  String get linkCopied;

  /// No description provided for @shareMessage.
  ///
  /// In ar, this message translates to:
  /// **'حمل تطبيق نجدة للطوارئ:'**
  String get shareMessage;

  /// No description provided for @smsMessage.
  ///
  /// In ar, this message translates to:
  /// **'استخدم تطبيق نجدة للاستجابة الطارئة:'**
  String get smsMessage;

  /// No description provided for @otherWays.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة بطرق أخرى'**
  String get otherWays;

  /// No description provided for @roleCitizen.
  ///
  /// In ar, this message translates to:
  /// **'مواطن'**
  String get roleCitizen;

  /// No description provided for @roleAmbulances.
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف'**
  String get roleAmbulances;

  /// No description provided for @defaultUserName.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم نجدة'**
  String get defaultUserName;

  /// No description provided for @settingsPreferences.
  ///
  /// In ar, this message translates to:
  /// **'التفضيلات'**
  String get settingsPreferences;

  /// No description provided for @settingsSupportInfo.
  ///
  /// In ar, this message translates to:
  /// **'الدعم والمعلومات'**
  String get settingsSupportInfo;

  /// No description provided for @settingsShareFeedback.
  ///
  /// In ar, this message translates to:
  /// **'شاركنا رأيك'**
  String get settingsShareFeedback;

  /// No description provided for @settingsAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get settingsAccount;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @chatWithSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get chatWithSupport;

  /// No description provided for @available247.
  ///
  /// In ar, this message translates to:
  /// **'متاح 24/7'**
  String get available247;

  /// No description provided for @emergencyLine.
  ///
  /// In ar, this message translates to:
  /// **'خط الطوارئ'**
  String get emergencyLine;

  /// No description provided for @faqs.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get faqs;

  /// No description provided for @faq1Q.
  ///
  /// In ar, this message translates to:
  /// **'كيف أرسل بلاغ طارئ؟'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In ar, this message translates to:
  /// **'ببساطة اضغط على زر SOS الكبير في الصفحة الرئيسية أو استخدم المساعد الذكي للإبلاغ عن نوع الحادث.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In ar, this message translates to:
  /// **'هل يمكنني تتبع سيارة الإسعاف؟'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In ar, this message translates to:
  /// **'نعم، بمجرد تعيين سيارة إسعاف لبلاغك، ستظهر لك شاشة تتبع مباشرة توضح موقع السيارة والوقت المتوقع للوصول.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In ar, this message translates to:
  /// **'ما هو نظام الذكاء الاصطناعي في نجدة؟'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In ar, this message translates to:
  /// **'يستخدم نجدة تقنيات الذكاء الاصطناعي لتحليل البلاغات وتصنيف خطورتها وتوجيه أقرب سيارة إسعاف واختيار المستشفى الأنسب للحالة.'**
  String get faq3A;

  /// No description provided for @privacyDataCollection.
  ///
  /// In ar, this message translates to:
  /// **'جمع البيانات'**
  String get privacyDataCollection;

  /// No description provided for @privacyDataCollectionDesc.
  ///
  /// In ar, this message translates to:
  /// **'• الموقع الجغرافي (GPS): يتم جمعه فقط عند إرسال بلاغ طوارئ لتحديد موقعك بدقة.\\n• الملف الطبي: المعلومات التي تدخلها (فصيلة الدم، الحساسية، الأمراض المزمنة) لمساعدة طاقم الإسعاف.\\n• رقم الهاتف: للتحقق من الهوية والتواصل معك عند الضرورة.'**
  String get privacyDataCollectionDesc;

  /// No description provided for @privacyDataUsage.
  ///
  /// In ar, this message translates to:
  /// **'استخدام البيانات'**
  String get privacyDataUsage;

  /// No description provided for @privacyDataUsageDesc.
  ///
  /// In ar, this message translates to:
  /// **'• تعيين أقرب سيارة إسعاف لموقع البلاغ.\\n• اختيار المستشفى الأنسب بناءً على الحالة الصحية.\\n• تنبيه جهة اتصال الطوارئ الخاصة بك تلقائياً عند الضرورة.'**
  String get privacyDataUsageDesc;

  /// No description provided for @privacyDataSharing.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة البيانات'**
  String get privacyDataSharing;

  /// No description provided for @privacyDataSharingDesc.
  ///
  /// In ar, this message translates to:
  /// **'• نحن لا نبيع بياناتك لأي جهات خارجية.\\n• يتم مشاركة بياناتك الطبية وموقعك فقط مع طاقم الإسعاف والمستشفى المعني بالبلاغ.'**
  String get privacyDataSharingDesc;

  /// No description provided for @privacyDataDeletion.
  ///
  /// In ar, this message translates to:
  /// **'حذف البيانات'**
  String get privacyDataDeletion;

  /// No description provided for @privacyDataDeletionDesc.
  ///
  /// In ar, this message translates to:
  /// **'• يمكنك طلب حذف حسابك وبياناتك بالكامل عبر التواصل مع الدعم الفني من داخل التطبيق.'**
  String get privacyDataDeletionDesc;

  /// No description provided for @lastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: {date}'**
  String lastUpdated(String date);

  /// No description provided for @termsAcceptance.
  ///
  /// In ar, this message translates to:
  /// **'القبول بالشروط'**
  String get termsAcceptance;

  /// No description provided for @termsAcceptanceDesc.
  ///
  /// In ar, this message translates to:
  /// **'باستخدامك لتطبيق نجدة، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء منها، يرجى التوقف عن استخدام التطبيق.'**
  String get termsAcceptanceDesc;

  /// No description provided for @termsServiceUsage.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الخدمة'**
  String get termsServiceUsage;

  /// No description provided for @termsServiceUsageDesc.
  ///
  /// In ar, this message translates to:
  /// **'• التطبيق مخصص للحالات الطارئة الحقيقية فقط.\\n• يُحظر تماماً إرسال بلاغات وهمية، مما قد يعرضك للمساءلة القانونية.\\n• يجب أن يكون عمر المستخدم 18 عاماً فأكثر، أو استخدامه تحت إشراف ولي الأمر.'**
  String get termsServiceUsageDesc;

  /// No description provided for @termsLiability.
  ///
  /// In ar, this message translates to:
  /// **'حدود المسؤولية'**
  String get termsLiability;

  /// No description provided for @termsLiabilityDesc.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق نجدة هو وسيط لتسهيل وصول خدمات الإسعاف، ونحن نبذل قصارى جهدنا لضمان دقة النظام ولكننا لا نضمن الاستجابة الفورية في جميع الظروف الخارجة عن إرادتنا.'**
  String get termsLiabilityDesc;

  /// No description provided for @termsTermination.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الخدمة'**
  String get termsTermination;

  /// No description provided for @termsTerminationDesc.
  ///
  /// In ar, this message translates to:
  /// **'نحتفظ بالحق في تعليق أو إنهاء وصولك إلى الخدمة في حالة مخالفة شروط الاستخدام أو إساءة استخدام نظام الطوارئ.'**
  String get termsTerminationDesc;

  /// No description provided for @aboutSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام الاستجابة الطارئة الذكي'**
  String get aboutSubtitle;

  /// No description provided for @aboutInfrastructure.
  ///
  /// In ar, this message translates to:
  /// **'البنية التحتية'**
  String get aboutInfrastructure;

  /// No description provided for @aboutRegion.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة'**
  String get aboutRegion;

  /// No description provided for @egypt.
  ///
  /// In ar, this message translates to:
  /// **'جمهورية مصر العربية'**
  String get egypt;

  /// No description provided for @aboutDescription.
  ///
  /// In ar, this message translates to:
  /// **'نجدة هو نظام متكامل يهدف إلى تقليل وقت الاستجابة في حالات الطوارئ الطبية باستخدام الذكاء الاصطناعي وربط المواطنين مباشرة بأطقم الإسعاف والمستشفيات.'**
  String get aboutDescription;

  /// No description provided for @rateTitle.
  ///
  /// In ar, this message translates to:
  /// **'رأيك يهمنا'**
  String get rateTitle;

  /// No description provided for @rateSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ساعدنا في تحسين نجدة من خلال تقييم تجربتك'**
  String get rateSubtitle;

  /// No description provided for @rateSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get rateSubmit;

  /// No description provided for @shareTitle.
  ///
  /// In ar, this message translates to:
  /// **'شارك عبر'**
  String get shareTitle;

  /// No description provided for @appLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط التطبيق'**
  String get appLink;

  /// No description provided for @copyLink.
  ///
  /// In ar, this message translates to:
  /// **'نسخ رابط'**
  String get copyLink;

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
