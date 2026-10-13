/**
 * PAUSED FOR v1 — AI is cancelled for v1, not deleted.
 *
 * This is the Groq-based hospital assignment callable, ported over from the
 * dashboard repo's legacy `functions/index.js` (`assignHospital` +
 * `analyzeWithGroq`) as part of the v1 hardening pass. It is intentionally
 * NOT exported from `src/index.ts`, so it is never deployed and never
 * reachable from any client. v1's hospital selection is manual: a dashboard
 * operator picks from the `hospitals` collection directly in the incident
 * drawer (writes `hospitalId` + `suggestedHospitalName`).
 *
 * To re-enable post-v1: export `assignHospital` from `index.ts`, set
 * `GROQ_API_KEY` as a Functions param/secret, and wire the dashboard's
 * "AI Selection" button back to call it.
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineString } from 'firebase-functions/params';
import * as admin from 'firebase-admin';
import axios from 'axios';

const GROQ_API_KEY = defineString('GROQ_API_KEY');

function distanceKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * Math.PI / 180) *
    Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

interface HospitalCandidate {
  id: string;
  name?: string;
  lat: number;
  lng: number;
  bedsAvailable?: number;
  specialties?: string[];
  distanceKm: number;
}

interface CaseData {
  type?: string;
  conscious?: boolean;
  chronicDiseases?: string[];
  allergies?: string[];
  paramedicNotes?: string;
  injuryLocation?: string;
}

async function analyzeWithGroq(caseData: CaseData, hospitals: HospitalCandidate[]): Promise<string | null> {
  const groqKey = GROQ_API_KEY.value();
  if (!groqKey) return hospitals[0]?.id ?? null;

  const prompt = `
You are an emergency medical dispatcher AI for Najda Emergency Response System in Egypt.

Patient case:
- Type: ${caseData.type}
- Conscious: ${caseData.conscious ? 'Yes' : 'No'}
- Chronic diseases: ${(caseData.chronicDiseases ?? []).join(', ') || 'None'}
- Allergies: ${(caseData.allergies ?? []).join(', ') || 'None'}
- Paramedic notes: ${caseData.paramedicNotes ?? 'Not available'}
- Injury location: ${caseData.injuryLocation ?? 'Unknown'}

Available hospitals (sorted by distance):
${hospitals.map((h, i) => `${i + 1}. ID:${h.id} | ${h.name} | ${h.distanceKm.toFixed(1)}km | ${h.bedsAvailable} beds | Specialties: ${(h.specialties ?? []).join(', ') || 'General'}`).join('\n')}

Choose the BEST hospital ID for this patient. Reply with ONLY the hospital ID, nothing else.
Valid IDs: ${hospitals.map(h => h.id).join(', ')}
`;

  try {
    const res = await axios.post(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        model: 'llama3-8b-8192',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 20,
        temperature: 0.1,
      },
      { headers: { Authorization: `Bearer ${groqKey}`, 'Content-Type': 'application/json' } }
    );
    const answer = res.data.choices[0].message.content.trim();
    const match = hospitals.find(h => answer.includes(h.id));
    return match?.id ?? hospitals[0]?.id ?? null;
  } catch (err: any) {
    console.error('Groq error:', err.message);
    return hospitals[0]?.id ?? null;
  }
}

const db = admin.firestore();

export const assignHospitalDisabled = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Login required');

  const { incidentId, incidentCollection, paramedicLat, paramedicLng, paramedicNotes, injuryLocation } =
    request.data as {
      incidentId: string;
      incidentCollection: 'criticals' | 'incidents';
      paramedicLat?: number;
      paramedicLng?: number;
      paramedicNotes?: string;
      injuryLocation?: string;
    };

  try {
    const incidentRef = db.collection(incidentCollection).doc(incidentId);
    const incidentSnap = await incidentRef.get();
    if (!incidentSnap.exists) throw new HttpsError('not-found', 'Incident not found');
    const incident = incidentSnap.data()!;

    // TODO(post-v1): switch to COLLECTIONS.hospitals from ../contract once re-enabled.
    const hospitalsSnap = await db.collection('hospitals').get();
    const hospitals: HospitalCandidate[] = hospitalsSnap.docs
      .map(d => ({ id: d.id, ...d.data() } as any))
      .filter((h: any) => h.bedsAvailable > 0)
      .map((h: any) => ({
        ...h,
        distanceKm: distanceKm(
          paramedicLat ?? incident.latitude ?? 30.0444,
          paramedicLng ?? incident.longitude ?? 31.2357,
          h.lat, h.lng
        ),
      }))
      .sort((a: HospitalCandidate, b: HospitalCandidate) => a.distanceKm - b.distanceKm)
      .slice(0, 5);

    if (hospitals.length === 0) throw new HttpsError('not-found', 'No hospitals available');

    const caseData: CaseData = {
      type: incident.accidentType,
      conscious: incident.consciousnessLevel !== 'unconscious',
      chronicDiseases: incident.chronicDiseases ?? [],
      allergies: incident.allergies ?? [],
      paramedicNotes,
      injuryLocation,
    };

    const bestHospitalId = await analyzeWithGroq(caseData, hospitals);
    const bestHospital = hospitals.find(h => h.id === bestHospitalId) ?? hospitals[0];

    await incidentRef.update({
      hospitalId: bestHospital.id,
      suggestedHospitalName: bestHospital.name,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      hospitalId: bestHospital.id,
      hospitalName: bestHospital.name,
      distanceKm: bestHospital.distanceKm.toFixed(1),
    };
  } catch (err: any) {
    console.error('assignHospitalDisabled error:', err);
    throw new HttpsError('internal', err.message);
  }
});
