# Najda — Fix Prompt: Ambulance Model + Auto-Assign + Live Tracking

This plan outlines the steps to fix the ambulance auto-assignment and live tracking by synchronizing field and collection names between the Flutter app, Firestore rules, and Firebase Functions.

## User Review Required

> [!IMPORTANT]
> - **Collection Names**: The project will standardize on `criticals` (for SOS) and `incidents` (for accidents).
> - **Ambulance Document**: The `ambulances` collection will now track `isOnline` (driver-controlled) and `availabilityStatus` (system-controlled).
> - **Backward Compatibility**: Fields like `isAvailable` and `status` will be maintained in the `ambulances` collection for legacy support.

## Proposed Changes

### 1. Flutter Data Models

Update the `AppUser` entity and its mapping to support the new ambulance status fields.

#### [MODIFY] [app_user.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/domain/entities/app_user.dart)
- Update `UserModel` class to include `isOnline`, `availabilityStatus`, `currentIncidentId`, `currentIncidentType`, `plateNumber`, `bearing`.
- Update `fromMap`, `toMap`, and `copyWith` to handle these fields.

#### [MODIFY] [auth_cubit.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/presentation/cubit/auth_cubit.dart)
- Add the `_paramedicFromDoc` helper method to handle paramedic-specific mapping logic as requested.

---

### 2. Paramedic UI

Update the home page and report details to use the new status fields and collection names.

#### [MODIFY] [paramedic_home_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/home/paramedic_home_page.dart)
- Update `_toggleAvailability` to `_toggleOnline` with the new logic.
- Update the header UI to show both Online/Offline status and Availability badge.
- Update Firestore queries to use the correct fields.

#### [MODIFY] [report_details_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/reports/report_details_page.dart)
- Update status constants for incidents (`_IS`) and ambulances (`_AS`).
- Update `_updateStatus` to synchronize incident and ambulance states.
- Correct the `_collection` getter to use `criticals` and `incidents`.

---

### 3. Citizen UI & Tracking

Ensure the citizen app writes to the correct collections and the tracking page reads from them.

#### [MODIFY] [citizen_home_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/home/citizen_home_page.dart)
- Update the `reportType` passed to the tracking page.

#### [MODIFY] [report_remote_datasource.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/report/data/datasources/report_remote_datasource.dart)
- Ensure it writes to the correct collections if any discrepancies exist.

#### [MODIFY] [tracking_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/tracking/tracking_page.dart)
- Update collection names and `reportType` logic.
- Update paramedic location listener to use `paramedics` collection (or `ambulances` as per tracking logic).

---

### 4. Notifications

#### [MODIFY] [notifications_history_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/notifications/notifications_history_page.dart)
- Change `paramedicId` query field to `ambulanceId`.

---

### 5. Backend (Firebase)

#### [MODIFY] [index.ts](file:///C:/Users/Qara-User/StudioProjects/najda/najda_functions/src/index.ts)
- Replace entire content with the fixed logic provided by the user, ensuring it listens to `criticals` and `incidents` and queries `isOnline`/`availabilityStatus`.

#### [MODIFY] [firestore.rules](file:///C:/Users/Qara-User/StudioProjects/najda/firestore.rules)
- Update rules to allow necessary reads/writes for the new collections and fields.

---

## Verification Plan

### Automated Tests
- Run `cd najda_functions && npm run build` to verify Cloud Functions compile.
- Run `firebase deploy --only functions,firestore:rules` (dry run if possible, or actual deploy if permitted).

### Manual Verification
1. **Paramedic Online/Offline**: Toggle the online switch in the paramedic app and verify `isOnline` and `availabilityStatus` change in Firestore.
2. **Auto-Assignment**:
   - Ensure an ambulance is "Online" and "Available".
   - Trigger SOS from the citizen app.
   - Verify the function logs show `Available ambulances: X` (X > 0).
   - Verify the incident is assigned and the paramedic receives a notification.
3. **Live Tracking**:
   - As a paramedic, accept the mission.
   - As a citizen, open the tracking page and verify the ambulance position updates.
4. **Status Transitions**:
   - Paramedic clicks "Arrived", "Submit Medical Form", and "Complete".
   - Verify both incident and ambulance statuses update correctly in Firestore at each step.
