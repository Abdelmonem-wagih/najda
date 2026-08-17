# نجدة — Najda Unified App

تطبيق موحد للمواطن والمسعف على Flutter. يتغير الـ UI كلياً بناءً على الـ **role** المخزّن في Firestore بعد تسجيل الدخول.

---

## هيكل المشروع

```
lib/
├── main.dart                          ← entry point + localization setup
├── core/
│   ├── constants/app_constants.dart   ← Firestore collections + keys
│   ├── routes/app_routes.dart         ← كل الـ routes + AppRouter
│   ├── theme/app_theme.dart           ← NC + NajdaTheme + shared widgets
│   └── l10n/
│       ├── app_ar.arb                 ← Arabic strings
│       └── app_en.arb                 ← English strings
└── features/
    ├── auth/                          ← Unified auth (OTP + Email)
    │   ├── domain/entities/app_user.dart
    │   └── presentation/
    │       ├── cubit/auth_cubit.dart  ← AuthCubit + AuthState
    │       └── pages/
    │           ├── splash_page.dart
    │           ├── login_page.dart    ← Tab: Citizen (phone) | Paramedic (email)
    │           ├── otp_page.dart
    │           └── registration_page.dart
    ├── citizen/
    │   ├── home/                      ← CitizenHomePage
    │   ├── report/                    ← ReportPage (accident form + photo)
    │   ├── history/                   ← CitizenHistoryPage
    │   ├── first_aid/                 ← FirstAidListPage + FirstAidDetailPage
    │   ├── emergency/                 ← EmergencyNumbersPage
    │   └── profile/                   ← CitizenProfilePage
    └── paramedic/
        ├── home/                      ← ParamedicHomePage (tabs: Emergency | Assigned)
        ├── reports/                   ← ReportDetailsPage (map + status flow + medical form)
        ├── notifications/             ← ParamedicNotificationsPage + ParamedicHistoryPage
        └── navigation/                ← NavigationPage stub
```

---

## إعداد المشروع (خطوة بخطوة)

### 1. تثبيت Flutter
```bash
flutter --version  # يجب أن يكون 3.22+
```

### 2. استنساخ المشروع وتثبيت الـ packages
```bash
cd najda_unified
flutter pub get
```

### 3. إعداد Firebase

#### أ. إنشاء مشروع Firebase
1. اذهب إلى [console.firebase.google.com](https://console.firebase.google.com)
2. أنشئ مشروعاً جديداً باسم `najda`
3. فعّل هذه الخدمات:
    - **Authentication** → Phone (للمواطنين) + Email/Password (للمسعفين)
    - **Cloud Firestore** (اختر قاعدة بيانات في منطقة قريبة)
    - **Firebase Storage** (لصور البلاغات)
    - **Firebase Cloud Messaging** (للإشعارات)

#### ب. تثبيت FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### ج. ربط Firebase بالتطبيق
```bash
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```
هيولّد ملف `lib/firebase_options.dart` تلقائياً.

#### د. تفعيل `firebase_options.dart` في main.dart
في `lib/main.dart`، أزل التعليق عن:
```dart
import 'firebase_options.dart';
// ...
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 4. إعداد Google Maps

#### الحصول على API Key
1. اذهب إلى [console.cloud.google.com](https://console.cloud.google.com)
2. أنشئ API Key جديد
3. فعّل هذه APIs:
    - Maps SDK for Android
    - Maps SDK for iOS
    - Directions API
    - Geocoding API
4. قيّد الـ Key بـ Package name/Bundle ID

#### Android
في `android/app/src/main/AndroidManifest.xml`، استبدل:
```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY"
```

#### iOS
في `ios/Runner/AppDelegate.swift`، استبدل:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_IOS_API_KEY")
```

### 5. توليد ملفات الـ Localization
```bash
flutter gen-l10n
```
هيولّد `lib/core/l10n/generated/app_localizations.dart` وملفاته.

### 6. رفع Firestore Rules والـ Indexes
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### 7. تشغيل التطبيق
```bash
flutter run
```

---

## Firestore Collections

| Collection | الاستخدام |
|---|---|
| `citizens` | بيانات المواطنين (phone auth) |
| `paramedics` | بيانات المسعفين (email auth) |
| `reports` | البلاغات العادية (من المواطنين) |
| `emergency_reports` | بلاغات الطوارئ |
| `medical_reports` | التقارير الطبية (من المسعفين) |
| `paramedic_history` | سجل مهام المسعفين (تُكتب بـ Cloud Functions) |
| `notifications` | إشعارات المسعفين |
| `mission_cancellations` | سجل المهام الملغاة |
| `ambulances` | بيانات عربيات الإسعاف |
| `admins` | حسابات الأدمن |

### هيكل وثيقة `citizens`
```json
{
  "role": "citizen",
  "phone": "+201XXXXXXXXX",
  "fullName": "اسم المواطن",
  "nationalId": "XXXXXXXXXXX",
  "emergencyContact": "+201XXXXXXXXX",
  "chronicDiseases": ["سكري"],
  "allergies": ["بنسيلين"],
  "currentMedications": ["ميتفورمين"],
  "additionalInfo": "",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### هيكل وثيقة `paramedics`
```json
{
  "role": "paramedic",
  "email": "paramedic@najda.com",
  "firstName": "محمد",
  "lastName": "أحمد",
  "phoneNumber": "+201XXXXXXXXX",
  "licenseNumber": "LIC-XXXX",
  "ambulanceId": "AMB-001",
  "isAvailable": true,
  "isActive": true,
  "status": "available",
  "fcmToken": "...",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "assignedReportId": null,
  "assignedReportType": null,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### هيكل وثيقة `reports`
```json
{
  "patientUid": "UID",
  "phoneNumber": "+201XXXXXXXXX",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "address": "العنوان",
  "type": "carAccident",
  "consciousnessLevel": "واعٍ تماماً",
  "injuryLocation": "الرأس",
  "painLevel": "شديد (7-9)",
  "imageUrl": "https://...",
  "status": "pending",
  "assignedParamedicId": null,
  "medicalReportSubmitted": false,
  "createdAt": "Timestamp",
  "timestamp": "Timestamp"
}
```

---

## تدفق Auth الموحد

```
SplashPage
    ↓ checkAuthStatus()
    ├── Not authenticated → LoginPage
    │       ├── Tab: Citizen  → Phone → OTP → [New user] → RegistrationPage → CitizenHomePage
    │       │                                [Existing]  → CitizenHomePage
    │       └── Tab: Paramedic → Email + Password → ParamedicHomePage
    │
    └── Authenticated
            ├── role = "citizen"   → CitizenHomePage
            └── role = "paramedic" → ParamedicHomePage
```

---

## إضافة مسعفين

المسعفون **لا** يسجّلون بأنفسهم — يُضافون يدوياً من الـ Dashboard أو Cloud Functions:

```javascript
// Cloud Function / Admin script
await admin.auth().createUser({ email, password });
await db.collection('paramedics').doc(uid).set({
  role: 'paramedic',
  email,
  firstName,
  lastName,
  licenseNumber,
  ambulanceId,
  isAvailable: true,
  isActive: true,
  status: 'available',
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
});
```

---

## الألوان (Najda Design System)

| اسم | HEX | الاستخدام |
|---|---|---|
| Navy | `#0C2340` | AppBar، Headers، Splash |
| Primary Blue | `#185FA5` | Buttons، Links، Icons |
| Accent Blue | `#378ADD` | Secondary actions، Badges |
| Critical Red | `#E24B4A` | SOS، Errors، Paramedic login |
| Success Green | `#22C55E` | Available status، Success |
| Warning | `#F59E0B` | Pending status، Tips |
| Surface | `#F5F7FA` | Scaffold background |
| Card | `#FFFFFF` | Cards، Input fields |

---

## المشاكل الشائعة

### خطأ في Location على Android
تأكد من إضافة Permission في `AndroidManifest.xml` وطلب الـ permission في runtime.

### Google Maps لا يظهر
- تأكد من إضافة الـ API Key في `AndroidManifest.xml`
- تأكد من تفعيل `Maps SDK for Android` في Google Cloud Console
- `minSdk` يجب أن يكون `23+`

### Phone Auth لا يعمل
- فعّل Phone Authentication في Firebase Console
- أضف SHA-1 و SHA-256 fingerprints في Firebase project settings
  ```bash
  cd android && ./gradlew signingReport
  ```

### `flutter gen-l10n` بيفشل
تأكد من وجود ملف `l10n.yaml` في root المشروع وأن الـ `arb-dir` صحيح.

---

## Languages Support
- 🇸🇦 Arabic (RTL) — Default
- 🇬🇧 English (LTR)

لتغيير اللغة:
```dart
NajdaApp.of(context)?.setLocale('en');
NajdaApp.of(context)?.setLocale('ar');
```
