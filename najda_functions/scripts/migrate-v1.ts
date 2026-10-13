/**
 * One-time migration of existing Firestore data to the v1 canonical schema
 * (see firebase/CONTRACT.md). DRY-RUN BY DEFAULT — prints what it would do
 * and touches nothing. Pass --apply to actually write.
 *
 *   npx tsx najda_functions/scripts/migrate-v1.ts            (dry run)
 *   npx tsx najda_functions/scripts/migrate-v1.ts --apply     (writes)
 *
 * Needs credentials for the target project, e.g.
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
 * or an `firebase login`'d gcloud ADC session with access to the project.
 *
 * What it does, per collection:
 *
 * ambulances/{id}
 *   - lat/lng, currentLocation{latitude,longitude}, heading, speed, accuracy,
 *     lastSeen/lastActiveAt  -> written into tracking/{id} (latitude,
 *     longitude, bearing, speed, accuracy, updatedAt), then removed from the
 *     ambulance doc.
 *   - availabilityStatus, ambulancesId -> removed (availabilityStatus was a
 *     dead read-only fallback; ambulancesId was a field-name mismatch with
 *     the real ambulanceId field, never actually consumed anywhere).
 *   - email, phone, fcmToken -> moved into ambulance_private/{id} (merge),
 *     then removed from the ambulance doc.
 *
 * criticals/{id}, incidents/{id}
 *   - reportedAt -> createdAt (only if createdAt is missing).
 *   - nested assignment{ambulanceId,driverName,vehicleId,assignedAt} and
 *     location{latitude,longitude} maps -> flattened to the top-level
 *     assignedAmbulanceId/assignedDriverName/assignedVehicleId/assignedAt
 *     and latitude/longitude fields (only where the flat field is missing —
 *     never overwrites a flat field that's already correctly populated).
 *   - assignedParamedicName -> assignedDriverName (only if assignedDriverName
 *     is missing).
 *   - reporterMedicalProfile.* / reporterEmergencyContact.* -> folded into
 *     the flat bloodType/chronicDiseases/allergies/currentMedications/
 *     emergencyContact fields (only where the flat field is missing).
 *   - status normalized: reported/ai_assigning -> pending,
 *     en_route -> on_mission, resolved -> completed, unassigned -> pending,
 *     reassigned -> assigned. Anything already a canonical value is left
 *     untouched.
 *   - nested maps and the old field names above are removed once folded.
 *
 * Every write is a per-document best-effort `update()` (not a single giant
 * batch), logged individually in --apply mode, so a partial failure midway
 * never corrupts a document — it just means that one wasn't migrated yet
 * and the script is safe to re-run.
 */
import * as admin from 'firebase-admin';
import {
  COLLECTIONS,
  INCIDENT_STATUS,
  type IncidentStatus,
} from '../src/contract';

const APPLY = process.argv.includes('--apply');

admin.initializeApp();
const db = admin.firestore();

const STATUS_NORMALIZATION: Record<string, IncidentStatus> = {
  reported: INCIDENT_STATUS.pending,
  ai_assigning: INCIDENT_STATUS.pending,
  unassigned: INCIDENT_STATUS.pending,
  en_route: INCIDENT_STATUS.onMission,
  resolved: INCIDENT_STATUS.completed,
  reassigned: INCIDENT_STATUS.assigned,
};

interface Counts {
  scanned: number;
  migrated: number;
  alreadyCanonical: number;
  errors: number;
}

function newCounts(): Counts {
  return { scanned: 0, migrated: 0, alreadyCanonical: 0, errors: 0 };
}

async function migrateAmbulances(): Promise<Counts> {
  const counts = newCounts();
  const snap = await db.collection(COLLECTIONS.ambulances).get();
  counts.scanned = snap.size;

  for (const doc of snap.docs) {
    const data = doc.data();
    const legacyLat = data.lat ?? data.currentLocation?.latitude;
    const legacyLng = data.lng ?? data.currentLocation?.longitude;
    const hasLegacyPosition = legacyLat != null && legacyLng != null;
    const hasLegacyKeys =
      hasLegacyPosition ||
      data.heading !== undefined ||
      data.speed !== undefined ||
      data.accuracy !== undefined ||
      data.lastSeen !== undefined ||
      data.availabilityStatus !== undefined ||
      data.ambulancesId !== undefined ||
      data.email !== undefined ||
      data.phone !== undefined ||
      data.fcmToken !== undefined ||
      data.currentLocation !== undefined;

    if (!hasLegacyKeys) {
      counts.alreadyCanonical++;
      continue;
    }

    const trackingPatch: Record<string, unknown> = {};
    if (hasLegacyPosition) {
      trackingPatch.latitude = legacyLat;
      trackingPatch.longitude = legacyLng;
    }
    if (data.heading !== undefined) trackingPatch.bearing = data.heading;
    if (data.speed !== undefined) trackingPatch.speed = data.speed;
    if (data.accuracy !== undefined) trackingPatch.accuracy = data.accuracy;
    trackingPatch.updatedAt = data.lastSeen ?? data.lastActiveAt ?? admin.firestore.FieldValue.serverTimestamp();

    const privatePatch: Record<string, unknown> = {};
    if (data.email !== undefined) privatePatch.email = data.email;
    if (data.phone !== undefined) privatePatch.phone = data.phone;
    if (data.fcmToken !== undefined) privatePatch.fcmToken = data.fcmToken;

    const ambulanceCleanup: Record<string, unknown> = {};
    for (const key of ['lat', 'lng', 'currentLocation', 'heading', 'speed', 'accuracy', 'lastSeen', 'availabilityStatus', 'ambulancesId', 'email', 'phone', 'fcmToken']) {
      if (data[key] !== undefined) ambulanceCleanup[key] = admin.firestore.FieldValue.delete();
    }

    console.log(`[ambulances/${doc.id}] would move to tracking:`, trackingPatch, Object.keys(privatePatch).length ? `; to ambulance_private: ${Object.keys(privatePatch)}` : '', `; remove from ambulance: ${Object.keys(ambulanceCleanup)}`);

    if (APPLY) {
      try {
        if (Object.keys(trackingPatch).length > 0) {
          await db.collection(COLLECTIONS.tracking).doc(doc.id).set(trackingPatch, { merge: true });
        }
        if (Object.keys(privatePatch).length > 0) {
          await db.collection(COLLECTIONS.ambulancePrivate).doc(doc.id).set(privatePatch, { merge: true });
        }
        if (Object.keys(ambulanceCleanup).length > 0) {
          await doc.ref.update(ambulanceCleanup);
        }
        counts.migrated++;
      } catch (err) {
        console.error(`[ambulances/${doc.id}] migration FAILED:`, err);
        counts.errors++;
      }
    } else {
      counts.migrated++; // "would migrate" count in dry-run
    }
  }

  return counts;
}

async function migrateIncidentCollection(collection: 'criticals' | 'incidents'): Promise<Counts> {
  const counts = newCounts();
  const snap = await db.collection(collection).get();
  counts.scanned = snap.size;

  for (const doc of snap.docs) {
    const data = doc.data();
    const patch: Record<string, unknown> = {};
    const cleanup: Record<string, unknown> = {};
    let needsMigration = false;

    if (data.createdAt === undefined && data.reportedAt !== undefined) {
      patch.createdAt = data.reportedAt;
      cleanup.reportedAt = admin.firestore.FieldValue.delete();
      needsMigration = true;
    }

    if (data.assignment && typeof data.assignment === 'object') {
      const a = data.assignment;
      if (data.assignedAmbulanceId === undefined && a.ambulanceId !== undefined) patch.assignedAmbulanceId = a.ambulanceId;
      if (data.assignedDriverName === undefined && a.driverName !== undefined) patch.assignedDriverName = a.driverName;
      if (data.assignedVehicleId === undefined && a.vehicleId !== undefined) patch.assignedVehicleId = a.vehicleId;
      if (data.assignedAt === undefined && a.assignedAt !== undefined) patch.assignedAt = a.assignedAt;
      cleanup.assignment = admin.firestore.FieldValue.delete();
      needsMigration = true;
    }

    if (data.location && typeof data.location === 'object') {
      const l = data.location;
      if (data.latitude === undefined && l.latitude !== undefined) patch.latitude = l.latitude;
      if (data.longitude === undefined && l.longitude !== undefined) patch.longitude = l.longitude;
      cleanup.location = admin.firestore.FieldValue.delete();
      needsMigration = true;
    }

    if (data.assignedDriverName === undefined && data.assignedParamedicName !== undefined) {
      patch.assignedDriverName = data.assignedParamedicName;
      needsMigration = true;
    }
    if (data.assignedParamedicName !== undefined) {
      cleanup.assignedParamedicName = admin.firestore.FieldValue.delete();
      needsMigration = true;
    }

    if (data.reporterMedicalProfile && typeof data.reporterMedicalProfile === 'object') {
      const m = data.reporterMedicalProfile;
      if (data.bloodType === undefined && m.bloodType !== undefined) patch.bloodType = m.bloodType;
      if (data.chronicDiseases === undefined && m.chronicDiseases !== undefined) patch.chronicDiseases = m.chronicDiseases;
      if (data.allergies === undefined && m.allergies !== undefined) patch.allergies = m.allergies;
      if (data.currentMedications === undefined && m.currentMeds !== undefined) patch.currentMedications = m.currentMeds;
      cleanup.reporterMedicalProfile = admin.firestore.FieldValue.delete();
      needsMigration = true;
    }

    if (data.reporterEmergencyContact !== undefined) {
      if (data.emergencyContact === undefined) {
        const c = data.reporterEmergencyContact;
        patch.emergencyContact = typeof c === 'string' ? c : c?.phone ?? '';
      }
      cleanup.reporterEmergencyContact = admin.firestore.FieldValue.delete();
      needsMigration = true;
    }

    const normalizedStatus = STATUS_NORMALIZATION[data.status];
    if (normalizedStatus) {
      patch.status = normalizedStatus;
      needsMigration = true;
    }

    if (!needsMigration) {
      counts.alreadyCanonical++;
      continue;
    }

    console.log(`[${collection}/${doc.id}] patch:`, patch, 'cleanup:', Object.keys(cleanup));

    if (APPLY) {
      try {
        await doc.ref.update({ ...patch, ...cleanup });
        counts.migrated++;
      } catch (err) {
        console.error(`[${collection}/${doc.id}] migration FAILED:`, err);
        counts.errors++;
      }
    } else {
      counts.migrated++;
    }
  }

  return counts;
}

async function main() {
  console.log(`=== migrate-v1.ts — ${APPLY ? 'APPLY (writing data)' : 'DRY RUN (no writes)'} ===\n`);

  const ambulanceCounts = await migrateAmbulances();
  const criticalsCounts = await migrateIncidentCollection(COLLECTIONS.criticals);
  const incidentsCounts = await migrateIncidentCollection(COLLECTIONS.incidents);

  console.log('\n=== Summary ===');
  for (const [name, c] of [
    ['ambulances', ambulanceCounts],
    ['criticals', criticalsCounts],
    ['incidents', incidentsCounts],
  ] as const) {
    console.log(
      `${name}: ${c.scanned} scanned, ${c.migrated} ${APPLY ? 'migrated' : 'would be migrated'}, ${c.alreadyCanonical} already canonical, ${c.errors} errors`
    );
  }

  if (!APPLY) {
    console.log('\nThis was a DRY RUN. Re-run with --apply to write these changes.');
  }
}

main().catch(err => {
  console.error('migrate-v1.ts fatal error:', err);
  process.exit(1);
});
