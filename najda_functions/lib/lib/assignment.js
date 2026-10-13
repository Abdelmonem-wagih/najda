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
exports.applyAssignment = applyAssignment;
exports.releaseAmbulanceInTx = releaseAmbulanceInTx;
const admin = __importStar(require("firebase-admin"));
const contract_1 = require("../contract");
const firebaseAdmin_1 = require("./firebaseAdmin");
/**
 * Writes the FLAT canonical assignment fields to the incident and syncs the
 * ambulance in the same transaction. Never writes an FCM token onto the
 * incident doc — the token lives in ambulance_private/{id} and is read
 * separately, after the transaction commits, by the notify helpers.
 *
 * `assignedBy` is 'auto' for the automatic nearest-ambulance path, or the
 * calling dashboard user's uid for a manual assign/reassign.
 */
function applyAssignment(tx, incidentRef, incidentId, incidentCollection, ambulanceDoc, assignedBy) {
    const amb = ambulanceDoc.data();
    const ambulanceId = ambulanceDoc.id;
    const ambulanceName = amb.plateNumber ?? amb.ambulanceId ?? ambulanceId;
    const driverName = amb.driverName ?? amb.name ?? '';
    tx.update(incidentRef, {
        status: contract_1.INCIDENT_STATUS.assigned,
        assignedAmbulanceId: ambulanceId,
        assignedAmbulanceName: ambulanceName,
        assignedDriverName: driverName,
        assignedVehicleId: amb.plateNumber ?? null,
        assignedAt: admin.firestore.FieldValue.serverTimestamp(),
        assignedBy,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.update(firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId), {
        status: contract_1.AMBULANCE_STATUS.assigned,
        currentIncidentId: incidentId,
        currentIncidentType: incidentCollection,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { ambulanceId, ambulanceName, driverName };
}
/** Frees an ambulance back to the pool — used on reassignment, cancellation, completion, and the releaseAmbulance callable. */
function releaseAmbulanceInTx(tx, ambulanceId) {
    tx.update(firebaseAdmin_1.db.collection(contract_1.COLLECTIONS.ambulances).doc(ambulanceId), {
        status: contract_1.AMBULANCE_STATUS.available,
        currentIncidentId: null,
        currentIncidentType: null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
//# sourceMappingURL=assignment.js.map