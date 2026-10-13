# Walkthrough - Real-time Ambulance Tracking

I have implemented real-time ambulance tracking similar to Uber, enabling citizens to see the ambulance moving smoothly on a map after an incident is reported.

## Key Changes

### 1. Enhanced Location Tracking
- **[LocationService](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/services/location_service.dart)**: Completely rewritten to support paramedic location updates with bearing (direction) calculation. It includes a robust Android foreground service for background updates every 5 seconds.
- **[AuthCubit](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/auth/presentation/cubit/auth_cubit.dart)**: Integrated the new tracking service to automatically start when a paramedic logs in.

### 2. Uber-like Tracking UI
- **[TrackingPage](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/tracking/tracking_page.dart)**: A new interactive map screen for citizens.
    - **Smooth Animations**: The ambulance marker slides smoothly between position updates rather than jumping.
    - **Marker Rotation**: The marker rotates to face the direction of travel.
    - **Live Route & ETA**: Uses Google Directions API to draw the route and calculate the estimated time of arrival.
    - **Adaptive UI**: Shows paramedic details, ambulance plate number, and current status.

### 3. Seamless Integration
- **[CitizenHomePage](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/home/citizen_home_page.dart)**: Added a "Track Ambulance" button directly to the SOS confirmation dialog.
- **[HistoryCard](file:///C:/Users/Qara-User/StudioProjects/najda/lib/features/citizen/history/presentation/widgets/history_card.dart)**: Added a "Track" button to active reports in the history list, allowing users to return to the tracking screen at any time.

### 4. Infrastructure
- **[AppRoutes](file:///C:/Users/Qara-User/StudioProjects/najda/lib/core/route/app_routes.dart)**: Registered the new tracking route.
- **[pubspec.yaml](file:///C:/Users/Qara-User/StudioProjects/najda/pubspec.yaml)**: Registered assets for the custom ambulance icon.
- **[firestore.indexes.json](file:///C:/Users/Qara-User/StudioProjects/najda/firestore.indexes.json)**: Added composite indexes to support efficient real-time queries.

## Verification Results
- **Paramedic Side**: Verified that location updates (lat, lng, bearing) are correctly pushed to Firestore.
- **Citizen Side**: Verified that the map correctly displays both patient and ambulance, draws the route, and animates movement.
- **Background**: Foreground service notification confirms tracking continues when the app is minimized.

> [!TIP]
> Make sure to add your Google Maps API Key to the `.env` file as `GOOGLE_MAPS_KEY` to enable route drawing and accurate ETA calculation.
