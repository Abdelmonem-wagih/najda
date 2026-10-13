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
exports.handleIncidentStatusChange = handleIncidentStatusChange;
const admin = __importStar(require("firebase-admin"));
const contract_1 = require("../contract");
const notify_1 = require("../lib/notify");
const db = admin.firestore();
const AMBULANCE_STATUS_FOR = {
    [contract_1.INCIDENT_STATUS.onMission]: contract_1.AMBULANCE_STATUS.onMission,
    [contract_1.INCIDENT_STATUS.arrived]: contract_1.AMBULANCE_STATUS.arrived,
    [contract_1.INCIDENT_STATUS.toHospital]: contract_1.AMBULANCE_STATUS.toHospital,
};
/**
 * Validates every status transition on an incident/critical doc and reverts
 * illegal ones. This is a structural backstop on top of Firestore rules
 * (which restrict *who* may write which transition) — this trigger only
 * checks that the sequence itself is a legal forward hop, regardless of who
 * made the write.
 *
 * On an accepted transition it syncs the ambulance's status, releases the
 * ambulance and writes ambulance_history on completion/cancellation, and
 * notifies the citizen.
 */
async function handleIncidentStatusChange(beforeData, afterData, incidentRef, incidentId, incidentCollection) {
    // Loop-breaker: a revert write (below) sets pendingRevert=true so the
    // *next* trigger invocation it causes doesn't re-validate (which would
    // ping-pong forever — an illegal A→B being reverted to B→A isn't a legal
    // forward transition either). That next invocation just clears the flag
    // and returns; the write clearing it causes a third invocation where
    // before.status === after.status, a true no-op that returns immediately
    // at the check below. Three invocations total per illegal attempt, then it stops.
    if (afterData.pendingRevert === true) {
        await incidentRef.update({ pendingRevert: admin.firestore.FieldValue.delete() });
        return;
    }
    const fromStatus = beforeData.status;
    const toStatus = afterData.status;
    if (!toStatus || fromStatus === toStatus)
        return;
    const legalTargets = new Set((contract_1.STATUS_TRANSITIONS[fromStatus] ?? []).map(t => t.to));
    if (!fromStatus || !legalTargets.has(toStatus)) {
        console.warn(`[status-machine] illegal transition on ${incidentCollection}/${incidentId}: ${fromStatus} -> ${toStatus}; reverting`);
        await incidentRef.update({
            status: fromStatus ?? contract_1.INCIDENT_STATUS.pending,
            pendingRevert: true,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
    }
    // 'pending' -> 'assigned' is applyAssignment's job — it already syncs the
    // ambulance atomically in the same transaction. Nothing further to do.
    if (toStatus === contract_1.INCIDENT_STATUS.assigned)
        return;
    const ambulanceId = afterData.assignedAmbulanceId;
    if (toStatus === contract_1.INCIDENT_STATUS.cancelled) {
        if (ambulanceId) {
            await db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId).update({
                status: contract_1.AMBULANCE_STATUS.available,
                currentIncidentId: null,
                currentIncidentType: null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        return;
    }
    if (toStatus === contract_1.INCIDENT_STATUS.completed) {
        if (ambulanceId) {
            await db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId).update({
                status: contract_1.AMBULANCE_STATUS.available,
                currentIncidentId: null,
                currentIncidentType: null,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            await db.collection(contract_1.COLLECTIONS.ambulanceHistory).add({
                ambulanceId,
                incidentId,
                incidentCollection,
                patientName: afterData.patientName ?? 'مريض',
                address: afterData.address ?? '',
                status: contract_1.INCIDENT_STATUS.completed,
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        await (0, notify_1.notifyCitizenOfStatus)(incidentId, incidentCollection, afterData, toStatus);
        return;
    }
    // on_mission / arrived / to_hospital: ambulance status mirrors the incident, not released yet.
    const ambStatus = AMBULANCE_STATUS_FOR[toStatus];
    if (ambulanceId && ambStatus) {
        await db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId).update({
            status: ambStatus,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    await (0, notify_1.notifyCitizenOfStatus)(incidentId, incidentCollection, afterData, toStatus);
}
//# sourceMappingURL=statusMachine.js.map