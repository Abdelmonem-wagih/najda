# Implementation Plan - Ambulance Assignment Schema & Firestore Indexes

Standardize the ambulance operational schema, fix the auto-assignment query, and update Firestore indexes to ensure consistency across the project (Cloud Functions, Flutter App, and Firestore).

## User Review Required

> [!IMPORTANT]
> - **Schema Migration**: We are moving from `availabilityStatus`/`isAvailable` to a canonical `status` field for operational state. `isOnline` will strictly represent the connection/shift state.
> - **Initial State**: Newly created ambulance accounts will start with `isOnline: false`.
> - **Identifier Consistency**: We will ensure that the ambulance document ID (e.g., `AMB-001`) and the `uid` field (Firebase Auth UID) are used correctly throughout the flow.

## Proposed Changes

### [Cloud Functions] (najda_functions/src/index.ts)

#### [MODIFY] [index.ts](file:///C:/Users/Qara-User/StudioProjects/najda/najda_functions/src/index.ts)
- Update `getAvailableAmbulances` to query `.where('status', '==', 'available')`.
- Remove all usages of `availabilityStatus` and `isAvailable`.
- Update `applyAssignment` to set `status: 'assigned'`, `currentIncidentId`, and `currentIncidentType`.
- Update `manualAssign`, `releaseAmbulance`, and `createAmbulancesAccount` to use the new schema.
- Fix `createAmbulancesAccount` to initialize `isOnline: false`.

### [Firestore Configuration]

#### [MODIFY] [firestore.indexes.json](file:///C:/Users/Qara-User/StudioProjects/najda/firestore.indexes.json)
- Add composite index for `ambulances` collection: `isOnline (ASC)`, `status (ASC)`.

### [Flutter App - Models & Logic]

#### [MODIFY] [app_user.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/domain/entities/app_user.dart)
- Rename `availabilityStatus` to `status` in `UserModel`.
- Update `fromMap` to prefer `status` but fallback to `availabilityStatus` for backward compatibility during transition.
- Update `toMap` to use `status`.

#### [MODIFY] [auth_repository_impl.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/data/repositories/auth_repository_impl.dart)
- Update `signInWithEmail` to call `remoteDataSource.updateAmbulanceOnlineStatus(user.id, true)` and ensure it sets `status: 'available'` (this might require modifying the data source method or adding a status update).
- Update `signOut` to set `isOnline: false` and `status: 'available'`.

#### [MODIFY] [auth_remote_datasource.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/data/datasources/auth_remote_datasource.dart)
- Update `updateAmbulanceOnlineStatus` to optionally accept and update the `status` field.

#### [MODIFY] [paramedic_home_page.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/home/paramedic_home_page.dart)
- Update `_toggleOnline` to use `status` instead of `availabilityStatus`.
- Update UI labels and colors to use `status`.

#### [MODIFY] [report_details_remote_datasource.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/paramedic/reports/data/datasources/report_details_remote_datasource.dart)
- Ensure `updateAmbulanceStatus` only updates the `status` field.

## Verification Plan

### Automated Tests
- I will verify the TypeScript compilation for Cloud Functions.
- I will check the Flutter models with `analyze_file`.

### Manual Verification
- **Cloud Functions**: The user should deploy functions and check logs for "Available ambulances: X".
- **Firestore**: Verify the new index is active.
- **Login Flow**: Log in as an ambulance and verify `isOnline` becomes `true` and `status` becomes `available`.
- **Assignment**: Trigger a `critical` near the ambulance and verify `pending` -> `assigned` transition on both incident and ambulance documents.
