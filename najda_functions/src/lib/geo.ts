import * as admin from 'firebase-admin';
import { COLLECTIONS, AMBULANCE_FIELDS, AMBULANCE_STATUS } from '../contract';
import { db } from './firebaseAdmin';

/** Candidates whose tracking/{id} doc is older than this are treated as stale (no live position). */
export const TRACKING_STALE_MS = 5 * 60 * 1000;

export function haversineKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export function buildDedupeKey(lat: number, lng: number, createdAt: any): string {
  const ms = createdAt instanceof admin.firestore.Timestamp ? createdAt.toMillis() : Date.now();
  // 5-minute buckets: two SOS taps from the same patient, near the same spot,
  // within the same bucket collapse to one dedupe key.
  return `${lat.toFixed(3)}_${lng.toFixed(3)}_${Math.floor(ms / 300000)}`;
}

export interface TrackingData {
  latitude: number;
  longitude: number;
  bearing?: number;
  speed?: number;
  accuracy?: number;
  updatedAt?: admin.firestore.Timestamp;
}

/**
 * The single eligibility predicate used everywhere an ambulance is checked
 * for dispatch: the automatic nearest-ambulance search, retryPending, and
 * manualAssign's "is this operator-picked ambulance actually eligible"
 * check (unless force:true + admin overrides it).
 */
export function isAmbulanceEligible(
  ambulance: FirebaseFirestore.DocumentData | undefined,
  tracking: TrackingData | null,
  now: admin.firestore.Timestamp
): boolean {
  if (!ambulance) return false;
  if (ambulance[AMBULANCE_FIELDS.isOnline] !== true) return false;
  if (ambulance[AMBULANCE_FIELDS.status] !== AMBULANCE_STATUS.available) return false;
  if (ambulance[AMBULANCE_FIELDS.currentIncidentId]) return false;
  if (!tracking) return false;
  const updatedAtMs = tracking.updatedAt?.toMillis?.() ?? 0;
  if (now.toMillis() - updatedAtMs > TRACKING_STALE_MS) return false;
  if (typeof tracking.latitude !== 'number' || typeof tracking.longitude !== 'number') return false;
  return true;
}

export interface NearestResult {
  ambulanceDoc: FirebaseFirestore.QueryDocumentSnapshot;
  tracking: TrackingData;
  distKm: number;
}

/**
 * Distance-only nearest-ambulance search (no AI). Must run inside a
 * transaction so two simultaneous SOS reports cannot both grab the same
 * ambulance — Firestore detects the conflicting read/write on the chosen
 * ambulance doc and retries the losing transaction, which then re-evaluates
 * candidates and picks the next-nearest one.
 *
 * Every read here (the ambulances query + one tracking/{id} read per
 * candidate) happens before any caller performs a write, as Firestore
 * transactions require.
 */
export async function findNearestEligibleAmbulance(
  tx: FirebaseFirestore.Transaction,
  lat: number,
  lng: number
): Promise<NearestResult | null> {
  const now = admin.firestore.Timestamp.now();

  const snap = await tx.get(
    db.collection(COLLECTIONS.ambulances)
      .where(AMBULANCE_FIELDS.isOnline, '==', true)
      .where(AMBULANCE_FIELDS.status, '==', AMBULANCE_STATUS.available)
  );

  const candidates: NearestResult[] = [];
  for (const doc of snap.docs) {
    const amb = doc.data();
    if (amb[AMBULANCE_FIELDS.currentIncidentId]) continue;

    const trackingSnap = await tx.get(db.collection(COLLECTIONS.tracking).doc(doc.id));
    const tracking = trackingSnap.exists ? (trackingSnap.data() as TrackingData) : null;

    if (!isAmbulanceEligible(amb, tracking, now)) continue;

    const distKm = haversineKm(lat, lng, tracking!.latitude, tracking!.longitude);
    candidates.push({ ambulanceDoc: doc, tracking: tracking!, distKm });
  }

  if (candidates.length === 0) return null;

  // Deterministic tie-break: distance first, then ambulance doc id.
  candidates.sort((a, b) => a.distKm - b.distKm || a.ambulanceDoc.id.localeCompare(b.ambulanceDoc.id));
  return candidates[0];
}
