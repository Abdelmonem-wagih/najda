# Implementation Plan - Real-time Ambulance Tracking

Implement real-time ambulance tracking similar to Uber, where citizens can see the ambulance marker moving smoothly on the map after sending an SOS or accident report.

## User Review Required

> [!IMPORTANT]
> - **Google Maps API Key:** The tracking feature requires a valid Google Maps Directions API key for route drawing and ETA calculation. Ensure it is set in `.env` as `GOOGLE_MAPS_KEY`.
> - **Location Permissions:** Paramedics will need to grant "Always Allow" location permissions for background tracking to work.
> - **Assets:** A custom ambulance icon `assets/images/ambulance_icon.png` is required. A fallback red circle is implemented if the asset is missing.

## Proposed Changes

### Core Services

#### [MODIFY] [LocationService](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/services/location_service.dart)
- Replace the existing `LocationService` with the new implementation that supports smooth tracking, bearing calculation, and background service integration.
- Update the Firestore update fields to include `latitude`, `longitude`, `bearing`, `speed`, `accuracy`, and `lastSeen`.
- The background service will update the location every 5 seconds.

### Citizen Features - Tracking

#### [NEW] [TrackingPage](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/tracking/tracking_page.dart)
- Create a new Uber-like tracking screen using `google_maps_flutter`.
- Implement smooth marker animation using `AnimationController`.
- Integrate Google Directions API for real-time ETA and route polyline drawing.
- Handle different report statuses and display paramedic/ambulance information.

### Navigation & Routing

#### [MODIFY] [AppRoutes](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/route/app_routes.dart)
- Register the new `TrackingPage` route.
- Add `trackIncident` constant to `AppRoutes`.

### UI Updates

#### [MODIFY] [CitizenHomePage](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/home/citizen_home_page.dart)
- Update `_showSOSConfirm` to include a "Track Ambulance" button that navigates to the `TrackingPage`.
- Pass patient coordinates to the confirmation dialog and then to the tracking page.

#### [MODIFY] [HistoryCard](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/history/presentation/widgets/history_card.dart)
- Add a "Track" button to active incident reports (status not completed, cancelled, or duplicate).
- Link this button to the `TrackingPage`.

### Authentication & Initialization

#### [MODIFY] [AuthCubit](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/presentation/cubit/auth_cubit.dart)
- Update `startTracking` calls to match the new signature, passing `paramedicId` and `collection`.

### Infrastructure

#### [MODIFY] [pubspec.yaml](file:///C:/Users/Qara-User/StudioProjects/najda/pubspec.yaml)
- Register `assets/images/ambulance_icon.png` in the assets section.

#### [MODIFY] [firestore.indexes.json](file:///C:/Users/Qara-User/StudioProjects/najda/firestore.indexes.json)
- Add composite indexes for `criticals` and `reports` to support querying by `assignedParamedicId`, `status`, and `createdAt`.

## Verification Plan

### Automated Tests
- N/A (UI and real-time streaming features are best verified manually).

### Manual Verification
1. **Paramedic Login:** Login as a paramedic and verify that location updates are being sent to Firestore every 5 seconds (check `paramedics` or `ambulances` collection).
2. **Background Tracking:** Move the app to the background and ensure the foreground service notification appears and location continues to update.
3. **SOS Trigger:** Send an SOS from a citizen account.
4. **Tracking Screen:** Tap "Track Ambulance" and verify:
   - The map shows both patient and ambulance markers.
   - The ambulance marker moves smoothly when Firestore updates.
   - The marker rotates based on the bearing.
   - The route polyline is drawn.
   - The ETA is calculated and displayed.
5. **History Tracking:** Open the history page and verify the "Track" button appears for active reports and correctly opens the tracking screen.
