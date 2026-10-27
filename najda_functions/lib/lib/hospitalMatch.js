"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.pickNearestHospital = pickNearestHospital;
const geo_1 = require("./geo");
/**
 * Deterministic nearest-hospital pick: hospitals without an ER are excluded,
 * the rest are sorted by distance, ties broken by more beds available.
 *
 * Deliberately not AI/LLM-based (see the deleted ai/assignHospital.disabled.ts)
 * — a dispatch-critical decision should be fast, free, and reproducible.
 * This only ever SUGGESTS a value; the dashboard's manual hospital picker
 * (setIncidentHospital) always remains available to override it.
 */
function pickNearestHospital(lat, lng, hospitals) {
    const candidates = hospitals
        .filter(h => h.hasER === true && typeof h.latitude === 'number' && typeof h.longitude === 'number')
        .map(h => ({ ...h, distKm: (0, geo_1.haversineKm)(lat, lng, h.latitude, h.longitude) }));
    if (candidates.length === 0)
        return null;
    candidates.sort((a, b) => a.distKm - b.distKm ||
        (b.bedsAvailable ?? 0) - (a.bedsAvailable ?? 0) ||
        a.id.localeCompare(b.id));
    const best = candidates[0];
    return { hospitalId: best.id, hospitalName: best.name ?? best.id };
}
//# sourceMappingURL=hospitalMatch.js.map