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
exports.tryAutoAssign = tryAutoAssign;
const admin = __importStar(require("firebase-admin"));
const contract_1 = require("../contract");
const firebaseAdmin_1 = require("./firebaseAdmin");
const geo_1 = require("./geo");
const assignment_1 = require("./assignment");
const hospitalMatch_1 = require("./hospitalMatch");
/**
 * Finds the nearest eligible ambulance and assigns it, distance only, no AI.
 * Used by both onDocumentCreated triggers (first attempt) and retryPending
 * (subsequent attempts for incidents still stuck 'pending').
 *
 * Idempotent: re-reads the incident fresh inside the transaction and bails
 * out if it's no longer 'pending' — this makes at-least-once trigger
 * redelivery (and overlapping retryPending runs) safe to call twice on the
 * same doc without corrupting a valid dispatch.
 *
 * Returns the assigned ambulance id, or null if the incident is still
 * pending (no eligible ambulance) or was found to be a duplicate.
 */
async function tryAutoAssign(incidentId, incidentCollection) {
    let assignedAmbulanceId = null;
    const incidentRef = firebaseAdmin_1.db.collection(incidentCollection).doc(incidentId);
    await firebaseAdmin_1.db.runTransaction(async (tx) => {
        const freshSnap = await tx.get(incidentRef);
        if (!freshSnap.exists)
            return;
        const data = freshSnap.data();
        if (data[contract_1.INCIDENT_FIELDS.status] !== contract_1.INCIDENT_STATUS.pending)
            return; // already handled by an earlier invocation
        const lat = data[contract_1.INCIDENT_FIELDS.latitude];
        const lng = data[contract_1.INCIDENT_FIELDS.longitude];
        if (lat == null || lng == null)
            return; // no location yet — nothing to assign against
        const dedupeKey = (0, geo_1.buildDedupeKey)(lat, lng, data[contract_1.INCIDENT_FIELDS.createdAt]);
        const dupSnap = await tx.get(firebaseAdmin_1.db.collection(incidentCollection)
            .where(contract_1.INCIDENT_FIELDS.patientUid, '==', data[contract_1.INCIDENT_FIELDS.patientUid])
            .where(contract_1.INCIDENT_FIELDS.dedupeKey, '==', dedupeKey)
            .where(contract_1.INCIDENT_FIELDS.status, 'in', [
            contract_1.INCIDENT_STATUS.assigned,
            contract_1.INCIDENT_STATUS.onMission,
            contract_1.INCIDENT_STATUS.arrived,
            contract_1.INCIDENT_STATUS.toHospital,
        ]));
        // Exclude this doc's own id so an at-least-once redelivery of the
        // CREATE event (which already assigned this very doc) never flags
        // itself as a duplicate and overwrites a valid dispatch.
        const realDuplicate = dupSnap.docs.find(d => d.id !== incidentId);
        if (realDuplicate) {
            tx.update(incidentRef, {
                status: contract_1.INCIDENT_STATUS.duplicate,
                dedupeKey,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            return;
        }
        const nearest = await (0, geo_1.findNearestEligibleAmbulance)(tx, lat, lng);
        if (!nearest) {
            tx.update(incidentRef, { dedupeKey, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
            return; // stays pending; retryPending will try again
        }
        // Read the hospital directory now, before any write in this transaction
        // (Firestore requires all transaction reads before any write) — the
        // dashboard's manual hospital picker can always override this suggestion.
        const hospitalsSnap = await tx.get(firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.hospitals));
        const hospitalCandidates = hospitalsSnap.docs.map(d => ({
            id: d.id,
            ...d.data(),
        }));
        const suggestion = (0, hospitalMatch_1.pickNearestHospital)(lat, lng, hospitalCandidates);
        (0, assignment_1.applyAssignment)(tx, incidentRef, incidentId, incidentCollection, nearest.ambulanceDoc, 'auto');
        tx.update(incidentRef, {
            dedupeKey,
            ...(suggestion && {
                [contract_1.INCIDENT_FIELDS.hospitalId]: suggestion.hospitalId,
                [contract_1.INCIDENT_FIELDS.suggestedHospitalName]: suggestion.hospitalName,
            }),
        });
        assignedAmbulanceId = nearest.ambulanceDoc.id;
    });
    return assignedAmbulanceId;
}
//# sourceMappingURL=autoAssign.js.map