# Najda — Unified System Architecture Blueprint

> **One shared architecture → One source of truth → AI-assisted decisions → Dashboard control → Firebase fallback → Real-time synchronization.**

---

## Table of Contents

1. [Unified Data Models](#1-unified-data-models)
2. [Firebase Architecture](#2-firebase-architecture)
3. [Cloud Functions Map](#3-cloud-functions-map)
4. [AI Layer + Fallback Strategy](#4-ai-layer--fallback-strategy)
5. [Real-Time Live Tracking](#5-real-time-live-tracking)
6. [Critical / SOS Flow](#6-critical--sos-flow)
7. [Security Rules](#7-security-rules)
8. [Firestore Indexes](#8-firestore-indexes)
9. [Implementation Checklist](#9-implementation-checklist)

---

## 1. Unified Data Models

> These are the **canonical schemas** stored in Firestore. Both Flutter and React read/write these exact shapes. Fields used only by one side are still present — they are simply `null` until populated.

---

### 1.1 `users` collection

```
users/{userId}
├── uid                   String   (= Firebase Auth uid)
├── firstName             String
├── lastName              String
├── phoneNumber           String   (E.164, e.g. +201001234567)
├── email                 String?
├── role                  String   "citizen" | "paramedic" | "admin"
├── profileImageUrl       String?
├── createdAt             Timestamp
├── updatedAt             Timestamp
│
├── medicalProfile        Map
│   ├── bloodType         String?  "A+" | "B-" | …
│   ├── chronicDiseases   List<String>
│   ├── currentMeds       List<String>
│   ├── allergies         List<String>
│   └── notes             String?
│
└── emergencyContact      Map
    ├── name              String
    ├── phone             String   (E.164)
    └── relation          String?
```

---

### 1.2 `incidents` collection

```
incidents/{incidentId}
├── id                    String   (= doc id)
├── type                  String   "sos" | "accident" | "medical" | "fire" | "other"
├── severity              String   "critical" | "high" | "medium" | "low"
├── status                String   → see Status FSM below
│
├── reportedBy            String   userId | "anonymous"
├── reporterPhone         String?
├── reportedAt            Timestamp
├── updatedAt             Timestamp
│
├── location              Map
│   ├── latitude          Number
│   ├── longitude         Number
│   ├── address           String?
│   └── geohash           String   (for geo-queries)
│
├── description           String?
├── victimCount           Number   (default 1)
│
├── reporterMedicalProfile  Map?   (snapshot of users.medicalProfile at report time)
├── reporterEmergencyContact Map?  (snapshot of users.emergencyContact at report time)
│
├── assignment            Map?
│   ├── ambulanceId       String?
│   ├── ambulancePlate    String?
│   ├── paramedicId       String?
│   ├── paramedicName     String?
│   ├── assignedAt        Timestamp?
│   ├── assignedBy        String   "ai" | "admin" | "system"
│   ├── aiConfidenceScore Number?  (0–1)
│   └── aiRationale       String?
│
├── assignedHospital      Map?
│   ├── placeId           String?
│   ├── name              String?
│   ├── address           String?
│   ├── latitude          Number?
│   ├── longitude         Number?
│   ├── selectedBy        String   "ai" | "admin"
│   └── selectedAt        Timestamp?
│
├── timeline              List<Map>
│   └── each entry:
│       ├── event         String   (e.g. "assigned", "en_route", "arrived", "resolved")
│       ├── timestamp     Timestamp
│       └── actor         String   "system" | "admin" | userId
│
└── resolvedAt            Timestamp?
```

**Incident Status FSM:**
```
reported → ai_assigning → assigned → en_route → arrived → resolved
                                   ↘ reassigned (admin override)
                    ↘ unassigned (AI failed, no ambulance found)
```

---

### 1.3 `ambulances` collection

```
ambulances/{ambulanceId}
├── id                    String
├── plateNumber           String
├── vehicleType           String   "basic" | "advanced" | "icu"
├── status                String   → see Status FSM below
│
├── currentLocation       Map?
│   ├── latitude          Number
│   ├── longitude         Number
│   ├── heading           Number?   (degrees 0–360)
│   ├── speed             Number?   (km/h)
│   └── updatedAt         Timestamp
│
├── assignedIncidentId    String?
├── assignedHospitalId    String?  (place_id when en route to hospital)
│
├── paramedicId           String?   (currently assigned paramedic)
├── paramedicName         String?
│
├── baseStationId         String?
├── baseLocation          Map?
│   ├── latitude          Number
│   └── longitude         Number
│
├── geohash               String?   (for proximity queries)
│
└── lastActiveAt          Timestamp
```

**Ambulance Status FSM:**
```
available → dispatched → en_route_to_incident → on_scene → en_route_to_hospital → at_hospital → available
          ↘ offline
          ↘ maintenance
```

---

### 1.4 `paramedics` collection

```
paramedics/{paramedicId}
├── id                    String   (= Firebase Auth uid)
├── firstName             String
├── lastName              String
├── email                 String
├── phoneNumber           String
├── profileImageUrl       String?
├── status                String   "active" | "inactive" | "on_duty" | "off_duty"
├── currentAmbulanceId    String?
├── role                  String   "paramedic" | "driver" | "supervisor"
├── certificationLevel    String?
├── joinedAt              Timestamp
└── updatedAt             Timestamp
```

---

### 1.5 `tracking` collection (real-time sub-path)

```
tracking/{ambulanceId}
├── ambulanceId           String
├── incidentId            String?
├── latitude              Number
├── longitude             Number
├── heading               Number?
├── speed                 Number?
├── accuracy              Number?
├── updatedAt             Timestamp
└── path                  List<Map>?   (recent breadcrumb trail, last 50 points)
    └── each: { lat, lng, timestamp }
```

> `tracking` is a **separate top-level collection** from `ambulances`. It is written frequently (every 3–5 seconds) by the mobile app. `ambulances.currentLocation` is updated less frequently (every 30 s) by a Cloud Function aggregating from `tracking`. Dashboard listens to `tracking/{id}` for live movement; it listens to `ambulances/{id}` for status changes.

---

### 1.6 `hospitals` collection (cache)

```
hospitals/{placeId}
├── placeId               String   (Google Places ID)
├── name                  String
├── address               String
├── latitude              Number
├── longitude             Number
├── phoneNumber           String?
├── emergencyCapacity     String?  "high" | "medium" | "low" | "unknown"
├── specialties           List<String>
├── lastVerified          Timestamp
└── source                String   "google_places" | "manual"
```

---

### 1.7 `assignments` collection (audit log)

```
assignments/{assignmentId}
├── id                    String
├── incidentId            String
├── ambulanceId           String
├── paramedicId           String?
├── assignedBy            String   "ai" | "admin" | "system"
├── assignedAt            Timestamp
├── status                String   "active" | "cancelled" | "completed" | "reassigned"
├── cancelledBy           String?
├── cancelledAt           Timestamp?
├── replacedByAssignmentId String?
└── aiPayload             Map?
    ├── model             String
    ├── confidenceScore   Number
    └── rationale         String
```

---

### 1.8 `notifications` collection

```
notifications/{notificationId}
├── id                    String
├── targetType            String   "ambulance" | "paramedic" | "admin" | "citizen"
├── targetId              String
├── type                  String   "incident_assigned" | "sos" | "status_update" | "hospital_selected" | …
├── title                 String
├── body                  String
├── data                  Map      (arbitrary payload for deep-linking)
├── read                  Boolean
├── createdAt             Timestamp
└── expiresAt             Timestamp?
```

---

### 1.9 `join_requests` collection

```
join_requests/{requestId}
├── id                    String
├── applicantName         String
├── email                 String
├── phoneNumber           String
├── requestedRole         String   "paramedic" | "driver"
├── status                String   "pending" | "approved" | "rejected"
├── submittedAt           Timestamp
├── reviewedAt            Timestamp?
└── reviewedBy            String?   (admin uid)
```

---

## 2. Firebase Architecture

### 2.1 Collection Map

```
Firestore Root
├── users/
├── incidents/
├── ambulances/
├── paramedics/
├── tracking/
├── hospitals/
├── assignments/
├── notifications/
└── join_requests/
```

### 2.2 Design Principles

| Principle | Rule |
|-----------|------|
| **Single source of truth** | One canonical collection per entity. No shadow copies. |
| **Snapshots over joins** | Embed user name/phone at write time so reads are cheap. |
| **Audit trail** | Every status change appends to `incident.timeline[]`. |
| **Tracking separation** | High-frequency GPS writes go to `tracking/`, not `ambulances/`. |
| **Geohash everywhere** | Store geohash alongside lat/lng to enable efficient geo-queries. |

---

## 3. Cloud Functions Map

All functions live in `functions/src/`. Each file is a single responsibility.

```
functions/src/
├── incidents/
│   ├── onIncidentCreated.js       — triggers AI assignment on new incident
│   ├── onIncidentUpdated.js       — status change notifications
│   └── retryUnassigned.js         — scheduled: retry unassigned incidents every 2 min
│
├── assignment/
│   ├── assignAmbulance.js         — SHARED: find nearest available ambulance (Haversine)
│   ├── aiAssignAmbulance.js       — wraps assignAmbulance + Groq reasoning
│   └── reassignAmbulance.js       — admin-triggered override (calls assignAmbulance)
│
├── hospital/
│   ├── selectHospital.js          — SHARED: deterministic nearest hospital
│   └── aiSelectHospital.js        — wraps selectHospital + Groq reasoning
│
├── tracking/
│   ├── onTrackingUpdated.js       — aggregates to ambulances.currentLocation every 30s
│   └── cleanTrackingPath.js       — keeps path[] trimmed to last 50 points
│
├── notifications/
│   ├── sendFCM.js                 — shared FCM sender (all targets)
│   └── sendWhatsApp.js            — WhatsApp via Twilio/WhatsApp Business
│
├── sos/
│   └── onSOSCreated.js            — full SOS flow (dispatch + report + WhatsApp + call)
│
├── paramedics/
│   ├── onStatusChange.js          — paramedic status machine
│   └── onJoinRequest.js           — join request → admin notification
│
└── ambulances/
    └── onAmbulanceCreated.js      — mirror to paramedics if needed
```

### 3.1 Shared Assignment Logic

The core `assignAmbulance(incidentId, options)` function:

```javascript
// assignment/assignAmbulance.js
async function assignAmbulance(incidentId, { preferredAmbulanceId = null, triggeredBy = 'system' }) {
  const incident = await db.collection('incidents').doc(incidentId).get();
  const { latitude, longitude } = incident.data().location;

  // 1. Query available ambulances
  const snapshot = await db.collection('ambulances')
    .where('status', '==', 'available')
    .get();

  if (snapshot.empty) {
    await markUnassigned(incidentId, 'No available ambulances');
    return null;
  }

  // 2. Sort by Haversine distance
  const sorted = snapshot.docs
    .map(doc => ({ ...doc.data(), distance: haversine(latitude, longitude, doc.data()) }))
    .sort((a, b) => a.distance - b.distance);

  const chosen = preferredAmbulanceId
    ? sorted.find(a => a.id === preferredAmbulanceId) ?? sorted[0]
    : sorted[0];

  // 3. Write assignment atomically
  const batch = db.batch();
  const assignmentRef = db.collection('assignments').doc();
  batch.set(assignmentRef, {
    id: assignmentRef.id, incidentId, ambulanceId: chosen.id,
    paramedicId: chosen.paramedicId ?? null,
    assignedBy: triggeredBy, assignedAt: FieldValue.serverTimestamp(),
    status: 'active',
  });
  batch.update(db.collection('incidents').doc(incidentId), {
    status: 'assigned',
    'assignment.ambulanceId': chosen.id,
    'assignment.ambulancePlate': chosen.plateNumber,
    'assignment.paramedicId': chosen.paramedicId ?? null,
    'assignment.assignedAt': FieldValue.serverTimestamp(),
    'assignment.assignedBy': triggeredBy,
    timeline: FieldValue.arrayUnion({ event: 'assigned', timestamp: new Date(), actor: triggeredBy }),
  });
  batch.update(db.collection('ambulances').doc(chosen.id), {
    status: 'dispatched',
    assignedIncidentId: incidentId,
  });
  await batch.commit();

  return { assignmentId: assignmentRef.id, ambulance: chosen };
}
```

Both `aiAssignAmbulance` and `reassignAmbulance` call this same function — they only differ in how `triggeredBy` and `preferredAmbulanceId` are set.

---

## 4. AI Layer + Fallback Strategy

### 4.1 Architecture

```
Dashboard / Mobile App
        │
        ▼
  Cloud Function (callable)
        │
        ├──► AI Layer (Groq)
        │         │ success → return recommendation + rationale
        │         │ timeout/error ↓
        └──► Deterministic Fallback (pure Firestore logic)
                  │
                  └──► Write result to Firestore (status = assigned/hospital_selected)
                              │
                              ▼
                      Dashboard shows result
                      Admin approves / overrides
```

### 4.2 AI Functions Pattern

```javascript
// hospital/aiSelectHospital.js
exports.aiSelectHospitalCallable = onCall(async (request) => {
  const { incidentId } = request.data;

  // 1. Always run deterministic logic first as baseline
  const deterministicResult = await selectNearestHospital(incidentId);

  // 2. Try AI enhancement
  try {
    const aiResult = await callGroqWithFallback(buildHospitalPrompt(incidentId));
    return { ...aiResult, fallback: false, baseline: deterministicResult };
  } catch (err) {
    console.warn('AI hospital selection failed, using deterministic fallback:', err.message);
    return { ...deterministicResult, fallback: true };
  }
});
```

### 4.3 Groq Model Fallback Chain

```javascript
const GROQ_MODELS = [
  'llama-3.3-70b-versatile',
  'llama-3.1-8b-instant',
  'gemma2-9b-it',
  'mixtral-8x7b-32768',
];

async function callGroqWithFallback(messages, systemPrompt) {
  for (const model of GROQ_MODELS) {
    try {
      const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: { Authorization: `Bearer ${process.env.GROQ_API_KEY}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ model, messages: [{ role: 'system', content: systemPrompt }, ...messages], max_tokens: 512 }),
      });
      if (!res.ok) continue;
      return await res.json();
    } catch { continue; }
  }
  throw new Error('All Groq models failed');
}
```

### 4.4 Dashboard AI Approval UX

Every AI decision is written to Firestore with `assignedBy: "ai"` and shown in the Dashboard with:

- ✅ **Accept** — no action needed (it's already written)
- ✏️ **Override** — opens manual picker; calls `reassignAmbulance` or `adminSelectHospital`
- ℹ️ **Rationale** — expandable AI explanation card

---

## 5. Real-Time Live Tracking

### 5.1 Flutter Side (Mobile App)

```dart
// services/tracking_service.dart

class TrackingService {
  static const _interval = Duration(seconds: 4);
  StreamSubscription? _positionSub;

  void startTracking(String ambulanceId, String? incidentId) {
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((pos) => _pushLocation(ambulanceId, incidentId, pos));
  }

  Future<void> _pushLocation(String ambulanceId, String? incidentId, Position pos) async {
    final data = {
      'ambulanceId': ambulanceId,
      'incidentId': incidentId,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'heading': pos.heading,
      'speed': pos.speed * 3.6, // m/s → km/h
      'accuracy': pos.accuracy,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // High-frequency write to tracking/
    await FirebaseFirestore.instance
        .collection('tracking')
        .doc(ambulanceId)
        .set(data, SetOptions(merge: true));

    // Append breadcrumb (Cloud Function will trim to 50)
    await FirebaseFirestore.instance
        .collection('tracking')
        .doc(ambulanceId)
        .update({
      'path': FieldValue.arrayUnion([{ 'lat': pos.latitude, 'lng': pos.longitude, 'ts': DateTime.now().toIso8601String() }]),
    });
  }

  void stopTracking() => _positionSub?.cancel();
}
```

### 5.2 Dashboard Side (React)

```javascript
// hooks/useAmbulanceTracking.js
import { useEffect, useState } from 'react';
import { doc, onSnapshot } from 'firebase/firestore';
import { db } from '../firebase';

export function useAmbulanceTracking(ambulanceId) {
  const [tracking, setTracking] = useState(null);

  useEffect(() => {
    if (!ambulanceId) return;
    const unsub = onSnapshot(
      doc(db, 'tracking', ambulanceId),
      (snap) => snap.exists() && setTracking(snap.data())
    );
    return unsub;
  }, [ambulanceId]);

  return tracking;
}
```

```javascript
// components/LiveMap.jsx — smooth marker movement
useEffect(() => {
  if (!tracking || !markerRef.current) return;
  markerRef.current.setPosition({ lat: tracking.latitude, lng: tracking.longitude });

  // Smooth heading rotation
  if (tracking.heading != null) {
    const icon = markerRef.current.getIcon();
    markerRef.current.setIcon({ ...icon, rotation: tracking.heading });
  }
}, [tracking]);
```

### 5.3 Cloud Function: Aggregator

```javascript
// tracking/onTrackingUpdated.js
exports.aggregateTracking = onDocumentUpdated('tracking/{ambulanceId}', async (event) => {
  const data = event.data.after.data();
  // Throttle: only sync to ambulances/ every 30 s
  const lastSync = data._lastSynced?.toDate();
  if (lastSync && Date.now() - lastSync < 30_000) return;

  await db.collection('ambulances').doc(event.params.ambulanceId).update({
    'currentLocation.latitude': data.latitude,
    'currentLocation.longitude': data.longitude,
    'currentLocation.heading': data.heading,
    'currentLocation.speed': data.speed,
    'currentLocation.updatedAt': FieldValue.serverTimestamp(),
    geohash: geohashForLocation([data.latitude, data.longitude]),
  });

  await event.data.after.ref.update({ _lastSynced: FieldValue.serverTimestamp() });
});
```

---

## 6. Critical / SOS Flow

### 6.1 Flutter Trigger

```dart
// When user presses SOS button
Future<void> triggerSOS(BuildContext context) async {
  final user = context.read<AuthCubit>().currentUser;
  final position = await Geolocator.getCurrentPosition();

  // Write incident to Firestore — Cloud Function takes over from here
  await FirebaseFirestore.instance.collection('incidents').add({
    'type': 'sos',
    'severity': 'critical',
    'status': 'reported',
    'reportedBy': user.uid,
    'reporterPhone': user.phoneNumber,
    'reportedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'location': {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'geohash': Geoflutterfire().point(latitude: position.latitude, longitude: position.longitude).hash,
    },
    'reporterMedicalProfile': user.medicalProfile.toMap(),
    'reporterEmergencyContact': user.emergencyContact.toMap(),
  });

  // D. Emergency phone call (client-side, immediate)
  final phone = user.emergencyContact.phone;
  await launchUrl(Uri.parse('tel:$phone'));
}
```

### 6.2 Cloud Function: `onSOSCreated`

```javascript
// sos/onSOSCreated.js
exports.onSOSCreated = onDocumentCreated('incidents/{incidentId}', async (event) => {
  const data = event.data.data();
  if (data.type !== 'sos') return;

  const incidentId = event.params.incidentId;

  // A. Dispatch nearest ambulance
  await assignAmbulance(incidentId, { triggeredBy: 'system' });

  // B. Dashboard alert notification
  await db.collection('notifications').add({
    targetType: 'admin',
    targetId: 'all',
    type: 'sos',
    title: '🚨 SOS Emergency',
    body: `Critical SOS from ${data.reporterPhone ?? 'unknown'} — ambulance dispatching now.`,
    data: { incidentId, screen: 'critical' },
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  // C. WhatsApp to emergency contact
  const contact = data.reporterEmergencyContact;
  const medical = data.reporterMedicalProfile;
  const disease = medical?.chronicDiseases?.[0] ?? 'a medical emergency';
  if (contact?.phone) {
    await sendWhatsApp(contact.phone, `🚨 نجدة! ${contact.name}، يحتاج أحد أفراد عائلتك المساعدة العاجلة بسبب ${disease}. الرجاء الاتصال به فوراً.`);
  }
});
```

### 6.3 Complete SOS Sequence Diagram

```
User presses SOS
      │
      ├──► Flutter writes incident (type=sos) to Firestore
      │
      ├──► Flutter calls tel: URI → Emergency phone call (immediate, client-side)
      │
      └──► Cloud Function onSOSCreated fires
                │
                ├──[A]► assignAmbulance() → nearest ambulance dispatched
                │           └──► ambulance status: available → dispatched
                │           └──► incident status: reported → assigned
                │           └──► FCM push to paramedic device
                │
                ├──[B]► notifications/ doc created → Dashboard shows SOS alert
                │           └──► Dashboard rings alarm, highlights Critical tab
                │
                └──[C]► sendWhatsApp() → emergency contact receives message
```

---

## 7. Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() { return request.auth != null; }
    function uid() { return request.auth.uid; }
    function role() { return get(/databases/$(database)/documents/users/$(uid())).data.role; }
    function isAdmin() { return role() == 'admin'; }
    function isParamedic() { return role() == 'paramedic'; }
    function isCitizen() { return role() == 'citizen'; }

    // Users — own profile read/write; admins read all
    match /users/{userId} {
      allow read: if isSignedIn() && (uid() == userId || isAdmin());
      allow write: if isSignedIn() && uid() == userId;
    }

    // Incidents — citizens create; paramedics + admins read/update
    match /incidents/{incidentId} {
      allow create: if isSignedIn() && isCitizen();
      allow read: if isSignedIn() && (isParamedic() || isAdmin());
      allow update: if isSignedIn() && (isParamedic() || isAdmin());
      allow delete: if isAdmin();
    }

    // Ambulances — paramedics update own; admins full access
    match /ambulances/{ambulanceId} {
      allow read: if isSignedIn() && (isParamedic() || isAdmin());
      allow update: if isSignedIn() && (
        isAdmin() ||
        (isParamedic() && resource.data.paramedicId == uid())
      );
      allow create, delete: if isAdmin();
    }

    // Tracking — paramedics write own; admins read all
    match /tracking/{ambulanceId} {
      allow write: if isSignedIn() && isParamedic();
      allow read: if isSignedIn() && (isParamedic() || isAdmin());
    }

    // Paramedics — own read/write; admins full
    match /paramedics/{paramedicId} {
      allow read: if isSignedIn() && (uid() == paramedicId || isAdmin());
      allow write: if isSignedIn() && (uid() == paramedicId || isAdmin());
    }

    // Hospitals — all authenticated read; admins write
    match /hospitals/{hospitalId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }

    // Assignments — admins full; paramedics read own
    match /assignments/{assignmentId} {
      allow read: if isSignedIn() && (
        isAdmin() ||
        (isParamedic() && resource.data.paramedicId == uid())
      );
      allow write: if isAdmin();
    }

    // Notifications — own read/write
    match /notifications/{notificationId} {
      allow read: if isSignedIn() && (
        resource.data.targetId == uid() ||
        resource.data.targetId == 'all' && (isAdmin() || isParamedic())
      );
      allow update: if isSignedIn() && resource.data.targetId == uid();
      allow create: if false; // Cloud Functions only
    }

    // Join requests — anyone create; admins manage
    match /join_requests/{requestId} {
      allow create: if true; // public form
      allow read, update: if isAdmin();
    }
  }
}
```

---

## 8. Firestore Indexes

```json
{
  "indexes": [
    {
      "collectionGroup": "incidents",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "reportedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "incidents",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "type", "order": "ASCENDING" },
        { "fieldPath": "severity", "order": "ASCENDING" },
        { "fieldPath": "reportedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "ambulances",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "geohash", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "assignments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "incidentId", "order": "ASCENDING" },
        { "fieldPath": "assignedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "assignments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ambulanceId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "targetId", "order": "ASCENDING" },
        { "fieldPath": "read", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## 9. Implementation Checklist

### Phase 1 — Data Model Alignment (Week 1)

- [ ] Audit existing Flutter models vs this schema; update Dart classes
- [ ] Audit existing React types/hooks vs this schema; update JS models
- [ ] Migrate any existing Firestore documents to unified schema
- [ ] Add `geohash` field to existing `ambulances` + `incidents` documents

### Phase 2 — Firebase Backend Unification (Week 1–2)

- [ ] Refactor Cloud Functions into the directory structure above
- [ ] Implement shared `assignAmbulance()` called by all assignment paths
- [ ] Implement `onSOSCreated` function with all 4 sub-flows
- [ ] Implement `onTrackingUpdated` aggregator
- [ ] Deploy unified security rules
- [ ] Deploy composite indexes via `firebase.json`

### Phase 3 — Real-Time Tracking (Week 2)

- [ ] Implement `TrackingService` in Flutter (paramedic app side)
- [ ] Implement `useAmbulanceTracking` hook in React dashboard
- [ ] Smooth marker animation on Dashboard LiveMap
- [ ] Breadcrumb path visualization on map

### Phase 4 — AI Layer (Week 2–3)

- [ ] Wrap `assignAmbulance` with Groq AI reasoning layer
- [ ] Wrap `selectHospital` with Groq AI reasoning layer
- [ ] Dashboard: AI decision card with Accept / Override / Rationale UI
- [ ] Verify Groq model availability and fallback chain

### Phase 5 — SOS Full Flow (Week 3)

- [ ] Flutter SOS button writes full incident with medical snapshot
- [ ] Flutter immediately launches `tel:` for emergency call
- [ ] `onSOSCreated` Cloud Function wires all 4 actions (A/B/C + FCM)
- [ ] WhatsApp integration (Twilio or WhatsApp Business API)
- [ ] Dashboard Critical tab highlights SOS in real time
- [ ] End-to-end test: SOS → ambulance dispatch → dashboard alert → WhatsApp

### Phase 6 — QA & Hardening

- [ ] Test AI timeout → fallback path
- [ ] Test no-ambulance-available path
- [ ] Test reassignment flow from Dashboard
- [ ] Load test tracking writes (simulate 10 concurrent ambulances)
- [ ] Security rules audit

---

*Document version: 1.0 — Generated for Najda unified architecture review.*
