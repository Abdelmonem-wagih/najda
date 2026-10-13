# Najda — Canonical Firestore Contract

Single human-readable reference for the schema shared by the Flutter app, `najda_functions`, and the dashboard. If code and this document disagree, the code constant files are authoritative for values; this file should be updated to match and `npm run check:contract` should be run.

Mirrored in:
- `najda_functions/src/contract.ts`
- `lib/core/constants/firestore_contract.dart`
- `src/lib/contract.js` (dashboard repo)

## Collections

| Collection | Purpose |
|---|---|
| `criticals` | SOS-button reports |
| `incidents` | Accident-wizard reports |
| `ambulances` | Ambulance fleet state (public-ish fields; no FCM token, no credentials) |
| `ambulance_private` | Per-ambulance secrets: `fcmToken`, `email`, `phone` |
| `tracking` | One doc per ambulance, latest GPS point only |
| `citizens` | Citizen profiles |
| `notifications` | Push/in-app notification records |
| `ambulance_history` | Completed-mission history, server-written only |
| `hospitals` | Hospital directory for manual hospital selection |
| `join_requests` | Public "join our fleet" form submissions |
| `dashboard_users` | Dashboard operator/admin accounts |
| `_counters` | Internal server-only counters |

Collections explicitly **removed** from code and docs as of v1 hardening: `reports`, `emergency_reports`, `paramedics`, `users` (as a real collection — a `users/{uid}` doc is still referenced by legacy Firestore *rules* fallbacks pre-hardening; removed in Phase 3), `assignments`, `medical_reports` (was write-only dead data).

Pre-existing collections found in `firestore.rules` that are **outside** this canonical list and were *not* covered by the v1 hardening prompt: `admins` (mobile-app admin collection), `patient_profiles` (explicitly commented "legacy — kept for backward compat"), `mission_cancellations`. These were left alone during this pass — not deleted, not migrated — because removing them wasn't in scope and nothing confirmed they're unused. Flagged here for a follow-up decision.

## `criticals` / `incidents` (same shape)

`criticals` = SOS button. `incidents` = accident wizard. ALL FLAT — no nested `assignment`/`location` maps.

| Field | Type | Notes |
|---|---|---|
| `shortId` | string | short display id |
| `incidentType` | string | `'emergency'` for criticals, `'report'` for incidents (kept as-is, pre-existing values) |
| `accidentType` | string? | incidents only |
| `source` | string | e.g. `'sos_button'` |
| `patientUid` | string | |
| `patientName` | string | |
| `nationalId` | string | |
| `phoneNumber` | string | |
| `emergencyContact` | string | E.164 phone, flat (not a map — matches the live write path) |
| `emergencyContactName` | string? | new in v1 |
| `bloodType`, `chronicDiseases`, `allergies`, `currentMedications`, `additionalInfo` | — | flat, not nested |
| `consciousnessLevel`, `injuryLocation`, `painLevel`, `imageUrl` | — | incidents only |
| `latitude`, `longitude` | number \| null | a report must never be blocked by missing GPS |
| `address` | string | |
| `accuracy` | number | |
| `status` | enum | `pending \| assigned \| on_mission \| arrived \| to_hospital \| completed \| cancelled \| duplicate` |
| `assignedAmbulanceId`, `assignedAmbulanceName`, `assignedDriverName`, `assignedVehicleId` | string? | flat, `assignedVehicleId` = plate number |
| `assignedAt` | Timestamp? | |
| `assignedBy` | `'auto' \| <adminUid>` | |
| `retryCount` | number | server-owned |
| `dedupeKey` | string | server-owned |
| `suggestedHospitalName`, `hospitalId` | string? | set by dashboard operator in v1 (manual, not AI) |
| `medicalReportSubmitted` | bool | |
| `enRouteAt`, `arrivedAt`, `toHospitalAt`, `completedAt` | Timestamp? | |
| `createdAt`, `updatedAt` | Timestamp | `createdAt` is the ONLY creation timestamp name (retiring `reportedAt`) |

**Never** store an FCM token on these docs — that was the old `assignedFcmToken` field; the token lives in `ambulance_private/{id}.fcmToken` and is read server-side only.

## `ambulances/{ambulanceId}`

| Field | Type | Writable by |
|---|---|---|
| `uid` | string | server (account creation) |
| `ambulanceId` | string? | server |
| `plateNumber`, `driverName`, `name`, `area`, `baseLocation` | — | admin (dashboard), server |
| `isOnline` | bool | **owner** (client) |
| `status` | enum `available \| assigned \| on_mission \| arrived \| to_hospital` | **server only** |
| `currentIncidentId`, `currentIncidentType` (`'criticals' \| 'incidents' \| null`) | — | **server only** |
| `lastActiveAt`, `createdAt`, `updatedAt` | Timestamp | server, owner (`lastActiveAt`) |

Removed duplicate/legacy keys: `lat`/`lng`, `currentLocation`, `heading`, `availabilityStatus`, `ambulancesId`, `lastSeen`, `speed`, `accuracy` — all position data now lives only in `tracking/{ambulanceId}`.

## `ambulance_private/{ambulanceId}`

`fcmToken`, `email`, `phone`. Owner may read/write `fcmToken` only; dashboard can read; Functions have full access.

## `tracking/{ambulanceId}`

ONE doc per ambulance, latest point only — no growing path array.

| Field | Type |
|---|---|
| `latitude`, `longitude` | number |
| `bearing`, `speed`, `accuracy` | number |
| `updatedAt` | Timestamp (serverTimestamp) |

Readable by any authenticated user; writable only by the owning ambulance user.

## `citizens/{uid}`

`role: 'citizen'`, `phoneNumber`, `firstName`, `lastName`, `nationalId`, `medicalProfile {bloodType, chronicDiseases, currentMeds, allergies, notes}`, `emergencyContact {name, phone, relation}`, `fcmToken?`, `createdAt`. Owner-only read/write.

## `notifications/{id}`

`recipientId` (ambulanceId or citizen uid), `recipientRole` (`'ambulance' | 'citizen' | 'admin'`), `type`, `title`, `body`, `incidentId`, `incidentCollection` (`'criticals' | 'incidents'`), `isRead`, `readAt?`, `createdAt`.

## `ambulance_history/{id}`

Server-written only: `ambulanceId`, `incidentId`, `incidentCollection`, `patientName`, `address`, `status`, `completedAt`.

## `hospitals/{id}`, `join_requests/{id}`, `dashboard_users/{uid}`

Existing shapes kept. `dashboard_users/{uid}`: `{role: 'admin' | 'operator', name, email, active, createdAt}`.

## Ownership-of-writes rule (ends the races)

- `status` of an incident: the **assigned ambulance** may move it only along legal transitions (`pending→assigned` is server-only; `assigned→on_mission→arrived→to_hospital→completed` by the ambulance; any status `→cancelled` by the owning citizen while `pending`/`assigned`, or by an admin). A Cloud Function trigger validates every transition and reverts illegal ones.
- `status`, `currentIncidentId`, `currentIncidentType` of an **ambulance**: server only, synced by the incident-status trigger.
- The app **never** writes ambulance `status`. Login/logout/online-toggle write `isOnline` only.

See `najda_functions/src/contract.ts` → `STATUS_TRANSITIONS` for the machine-readable version of the transition table.
