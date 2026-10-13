# Implementation Plan: Ambulance Login & Firebase Synchronization

This plan addresses the requirement to complete the ambulance login flow and ensure continuous Firebase synchronization (location, online status) while preserving Dashboard-created data and operational status.

## User Review Required

> [!IMPORTANT]
> **Schema Alignment**: I will be updating the `UserModel` and Firestore update logic to use the following field names to match the Dashboard and your requirements:
> - `lat`, `lng` (instead of `latitude`, `longitude` where possible, or keeping both for compatibility)
> - `area` (formatted as "lat, lng")
> - `lastActiveAt` (replacing or supplementing `lastSeen`)
> - `isOnline` (driver connection state)
> - `status` (operational state, mapped to `availabilityStatus` in the model)

> [!WARNING]
> **Location Service Changes**: The `LocationService` will be updated to perform partial updates on the ambulance document. This ensures that Dashboard-set fields like `driverName`, `email`, and `phone` are never overwritten during location heartbeats.

## Proposed Changes

### Core & Domain

#### [MODIFY] [UserModel](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/domain/entities/app_user.dart)
- Add `area` (String) and `lastActiveAt` (Timestamp) fields.
- Update `fromMap` to handle `lat`, `lng`, `status`, `area`, and `lastActiveAt` robustly.
- Update `toMap` and `copyWith` accordingly.

---

### Data Layer

#### [MODIFY] [AuthRemoteDataSource](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/data/datasources/auth_remote_datasource.dart)
- Add `updateAmbulanceOnlineStatus(String ambulanceId, bool isOnline)` method.
- Refine `fetchAmbulanceData` to ensure it always queries by `uid`.

#### [MODIFY] [AuthRepository](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/data/repositories/auth_repository_impl.dart)
- Update `signInWithEmail` to call `updateAmbulanceOnlineStatus(true)` upon success.
- Update `signOut` to call `updateAmbulanceOnlineStatus(false)` and stop tracking.
- Ensure `checkAuthStatus` correctly identifies ambulance role and starts tracking if already logged in.

---

### Services

#### [MODIFY] [LocationService](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/services/location_service.dart)
- Update field names in `_sendToFirestore` to `lat`, `lng`, `area`, and `lastActiveAt`.
- Ensure `area` is computed as `"lat, lng"`.
- Use `update()` instead of `set(..., merge: true)` to be safe, or stick to `update` as currently used.

---

### Security

#### [MODIFY] [firestore.rules](file:///C:/Users/Qara-User/StudioProjects/najda/firestore.rules)
- Refine `match /ambulances/{docId}` to:
  ```
  allow update: if isOwner(resource.data.uid) || isAdmin();
  ```
  This ensures an ambulance can only update its own record based on the `uid` field.

## Verification Plan

### Automated Tests
- N/A (Manual verification on device/emulator is preferred for GPS and Auth flows).

### Manual Verification
1. **Login Flow**:
   - Create an ambulance in Dashboard with a specific ID (e.g., `AMB-11`).
   - Log in via mobile app using the assigned email.
   - Verify that `ambulances/{AMB-11}` is updated with the authenticated `uid` and `isOnline: true`.
   - Verify `driverName`, `phone`, etc., are preserved.
2. **Location Sync**:
   - Observe Firestore while the app is running.
   - Verify `lat`, `lng`, `area`, and `lastActiveAt` update every 3-5 seconds.
3. **Operational Status**:
   - Manually change `status` in Firestore to `assigned`.
   - Verify the mobile app reflects this (if UI allows) and that subsequent location updates do NOT reset it to `available`.
4. **Logout/Offline**:
   - Log out from the app.
   - Verify `isOnline` becomes `false` and location updates stop.
   - Force close the app and verify the `lastActiveAt` timestamp helps identify the last heartbeat.
