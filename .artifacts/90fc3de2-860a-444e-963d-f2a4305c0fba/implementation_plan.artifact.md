# Implementation Plan – Ambulance App Enhancements

This plan outlines the steps to implement background location tracking, a unified home screen, light theme, and improved navigation for the Paramedic/Ambulance role in the Najda application.

## User Review Required

> [!IMPORTANT]
> **Background Location Permission**: The app will require "Always Allow" location permission for the background tracking to work reliably on Android and iOS. The UI will explain this to the user.
> [!WARNING]
> **Theme Change**: The entire Paramedic UI will be switched from a Navy/Dark theme to a Light theme with medical-grade accents.
> [!NOTE]
> **Unified Home**: "Critical Cases" and "Incidents" will be merged into a single feed. Visual badges will distinguish them.

## Proposed Changes

### 1. Core Services & Architecture

#### [MODIFY] [location_service.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/services/location_service.dart)
- Rewrite to use `Geolocator.getPositionStream` inside the `flutter_background_service` entry point.
- Implement internet connectivity awareness (using `dio` or simple `try-catch` with exponential backoff if needed, though simple `try-catch` is already there).
- Handle all permission states (denied, deniedForever, disabled).
- Update field names to `latitude`, `longitude`, `updatedAt` to match requirements (currently uses `lastSeen`).

#### [NEW] [notification_service.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/services/notification_service.dart)
- Centralize FCM initialization and listeners.
- Handle foreground notifications using `flutter_local_notifications`.
- Implement tap-navigation logic to route users to specific incidents/reports.

---

### 2. UI & Theme Redesign

#### [MODIFY] [design.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/theme/design.dart)
- Add a light palette to the `NC` class (e.g., `NC.lightBase`, `NC.lightSurface`).
- Update `NajdaTheme` to provide a `light` theme that matches the requirement.
- Ensure all shared widgets (`GlassCard`, `GradientButton`, `StatusBadge`) adapt to the theme.

#### [MODIFY] [app_theme.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/theme/app_theme.dart)
- Ensure the light theme is the default and matches the new design system.

---

### 3. Paramedic Feature Enhancements

#### [NEW] [paramedic_main_scaffold.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/presentation/pages/paramedic_main_scaffold.dart)
- A new root page for paramedics with a `BottomNavigationBar`.
- Tabs: Home, History, Notifications, Profile.
- Integrates the `isAvailable` toggle in the header or a persistent location.

#### [MODIFY] [paramedic_home_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/home/paramedic_home_page.dart)
- Remove `TabBar` and `TabBarView`.
- Merge `_emergency` and `_reports` into a single `allIncidents` list.
- Sort by `createdAt` (descending) and urgency (Emergency first).
- Update cards to show clear "CRITICAL" vs "INCIDENT" badges.
- Update styling to Light Theme.

#### [MODIFY] [notifications_history_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/notifications/notifications_history_page.dart)
- Update styling to Light Theme.
- Remove `AppBar` if integrated into `MainScaffold`, or adjust for consistency.

---

### 4. Navigation & Localization

#### [MODIFY] [app_routes.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/route/app_routes.dart)
- Update `AppRoutes.paramedicHome` to point to `ParamedicMainScaffold`.

#### [MODIFY] [app_en.arb](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/l10n/app_en.arb) & [app_ar.arb](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/l10n/app_ar.arb)
- Add new keys: `critical_case`, `incident`, `location_sharing_active`, `history`, `notifications`, `profile`, `home`, etc.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no regressions in existing logic.
- (Optional) Implement a unit test for `LocationService` permission handling.

### Manual Verification
1. **Auth Flow**: Login as Paramedic, verify location tracking starts (check Firestore).
2. **Background Location**: Minimize app, lock screen, move (simulated), check Firestore for updates.
3. **Notifications**: Send a test FCM, verify foreground pop-up and tap navigation.
4. **Unified Home**: Ensure both Critical and Incident reports appear in the same list with distinct badges.
5. **Theme**: Verify the app is in Light Mode and looks clean/medical.
6. **Navigation**: Toggle between Home, History, Notifications, and Profile via Bottom Nav.
7. **Switch**: Toggle availability and verify Firestore `isAvailable` field updates.
