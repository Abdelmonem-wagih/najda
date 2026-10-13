"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.TRACKING_STALE_MS = void 0;
exports.haversineKm = haversineKm;
exports.buildDedupeKey = buildDedupeKey;
exports.isAmbulanceEligible = isAmbulanceEligible;
exports.findNearestEligibleAmbulance = findNearestEligibleAmbulance;
const admin = __importStar(require("firebase-admin"));
const contract_1 = require("../contract");
const firebaseAdmin_1 = require("./firebaseAdmin");
/** Candidates whose tracking/{id} doc is older than this are treated as stale (no live position). */
exports.TRACKING_STALE_MS = 5 * 60 * 1000;
function haversineKm(lat1, lng1, lat2, lng2) {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
function buildDedupeKey(lat, lng, createdAt) {
    const ms = createdAt instanceof admin.firestore.Timestamp ? createdAt.toMillis() : Date.now();
    // 5-minute buckets: two SOS taps from the same patient, near the same spot,
    // within the same bucket collapse to one dedupe key.
    return `${lat.toFixed(3)}_${lng.toFixed(3)}_${Math.floor(ms / 300000)}`;
}
/**
 * The single eligibility predicate used everywhere an ambulance is checked
 * for dispatch: the automatic nearest-ambulance search, retryPending, and
 * manualAssign's "is this operator-picked ambulance actually eligible"
 * check (unless force:true + admin overrides it).
 */
function isAmbulanceEligible(ambulance, tracking, now) {
    if (!ambulance)
        return false;
    if (ambulance[contract_1.AMBULANCE_FIELDS.isOnline] !== true)
        return false;
    if (ambulance[contract_1.AMBULANCE_FIELDS.status] !== contract_1.AMBULANCE_STATUS.available)
        return false;
    if (ambulance[contract_1.AMBULANCE_FIELDS.currentIncidentId])
        return false;
    if (!tracking)
        return false;
    const updatedAtMs = tracking.updatedAt?.toMillis?.() ?? 0;
    if (now.toMillis() - updatedAtMs > exports.TRACKING_STALE_MS)
        return false;
    if (typeof tracking.latitude !== 'number' || typeof tracking.longitude !== 'number')
        return false;
    return true;
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
async function findNearestEligibleAmbulance(tx, lat, lng) {
    const now = admin.firestore.Timestamp.now();
    const snap = await tx.get(firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.ambulances)
        .where(contract_1.AMBULANCE_FIELDS.isOnline, '==', true)
        .where(contract_1.AMBULANCE_FIELDS.status, '==', contract_1.AMBULANCE_STATUS.available));
    const candidates = [];
    for (const doc of snap.docs) {
        const amb = doc.data();
        if (amb[contract_1.AMBULANCE_FIELDS.currentIncidentId])
            continue;
        const trackingSnap = await tx.get(firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.tracking).doc(doc.id));
        const tracking = trackingSnap.exists ? trackingSnap.data() : null;
        if (!isAmbulanceEligible(amb, tracking, now))
            continue;
        const distKm = haversineKm(lat, lng, tracking.latitude, tracking.longitude);
        candidates.push({ ambulanceDoc: doc, tracking: tracking, distKm });
    }
    if (candidates.length === 0)
        return null;
    // Deterministic tie-break: distance first, then ambulance doc id.
    candidates.sort((a, b) => a.distKm - b.distKm || a.ambulanceDoc.id.localeCompare(b.ambulanceDoc.id));
    return candidates[0];
}
//# sourceMappingURL=geo.js.map