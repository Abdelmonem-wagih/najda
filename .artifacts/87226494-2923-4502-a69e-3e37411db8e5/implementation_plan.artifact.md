# Najda Unified Architecture Implementation Plan

This plan outlines the steps to align the Najda Flutter app with the unified architecture blueprint.

## User Review Required

> [!IMPORTANT]
> This update involves significant changes to the Firestore data structure (moving individual fields into nested maps like `assignment`, `assignedHospital`, and `timeline`). Existing documents in Firestore might need migration, or the code must handle both formats during a transition period. For this task, we will update the models to match the new schema exactly.

## Proposed Changes

### 1. Data Model Alignment

#### [MODIFY] [incident_model.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/report/data/models/incident_model.dart)
- Group assignment-related fields into an `Assignment` class/map.
- Group hospital-related fields into an `AssignedHospital` class/map.
- Replace individual timeline timestamps with a `List<TimelineEvent>`.
- Add `reporterMedicalProfile` and `reporterEmergencyContact` snapshots.
- Add `geohash` to the location logic.

#### [MODIFY] [ambulance_model.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/report/data/models/ambulance_model.dart)
- Ensure `geohash`, `baseLocation`, and `lastActiveAt` are present and correctly mapped.

#### [MODIFY] [app_user.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/domain/entities/app_user.dart)
- Align `MedicalProfile` and `EmergencyContact` with the schema (e.g., `currentMeds` vs `currentMedications`).
- Ensure `UserModel` fields match the `users/{userId}` schema.

### 2. SOS Flow Update

#### [MODIFY] [draggable_ai_button.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/home/draggable_ai_button.dart) (or relevant SOS trigger file)
- Update Firestore write logic to include medical/emergency contact snapshots.
- Add `geohash` calculation.
- Add `launchUrl(Uri.parse('tel:$emergencyPhone'))` after the write.
- Transition to the tracking/confirmation screen.

### 3. Paramedic Tracking Service

#### [NEW] [tracking_service.dart](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/services/tracking_service.dart)
- Implement `TrackingService` using `Geolocator`.
- Write frequent updates to `tracking/{ambulanceId}`.
- Manage breadcrumb `path` array.

### 4. Incident Status Listeners

#### [MODIFY] [citizen_tracking_screen.dart] (Find exact file)
- Listen to `incidents/{incidentId}` for real-time status, ETA, and hospital info.

#### [MODIFY] [paramedic_active_incident_screen.dart] (Find exact file)
- Listen to `incidents/{incidentId}` for status, hospital, and timeline events.

## Verification Plan

### Automated Tests
- Unit tests for Model `fromFirestore` and `toFirestore` to ensure schema compliance.
- Mock Firestore tests for SOS flow and TrackingService.

### Manual Verification
- Trigger SOS: Verify Firestore doc creation (check snapshots, geohash). Verify phone call dialer opens.
- Paramedic side: Accept incident, verify `tracking/` collection updates and `path` breadcrumbs.
- Observe real-time UI updates on both citizen and paramedic apps when incident status changes in Firestore.
