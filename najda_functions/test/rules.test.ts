/**
 * Firestore + Storage rules tests against the local emulator. Requires the
 * Firestore and Storage emulators running (run via `npm run test:rules`,
 * which wraps this in `firebase emulators:exec`).
 *
 * NOTE: could not be executed in this environment — the Firestore emulator
 * in this firebase-tools version requires Java 21+, and this machine has
 * Java 17 (confirmed via `firebase emulators:exec`, which refused to start
 * with "firebase-tools no longer supports Java version before 21"). This
 * file type-checks cleanly (`tsc --noEmit`) and was carefully hand-reviewed
 * against firestore.rules/storage.rules line by line, but running it for
 * real against the emulator is a manual step — see V1_FIX_REPORT.md.
 */
import * as fs from 'node:fs';
import * as path from 'node:path';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { test, runTests } from './testHarness';

const REPO_ROOT = path.join(__dirname, '..', '..');

let testEnv: RulesTestEnvironment;

async function setup(): Promise<void> {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-najda-test',
    firestore: {
      rules: fs.readFileSync(path.join(REPO_ROOT, 'firestore.rules'), 'utf8'),
    },
  });

  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const now = new Date();

    await db.collection('dashboard_users').doc('operator1').set({ role: 'operator', name: 'Op', email: 'op@x.com', active: true, createdAt: now });
    await db.collection('dashboard_users').doc('admin1').set({ role: 'admin', name: 'Admin', email: 'admin@x.com', active: true, createdAt: now });
    await db.collection('dashboard_users').doc('inactive1').set({ role: 'operator', name: 'Gone', email: 'gone@x.com', active: false, createdAt: now });

    await db.collection('ambulances').doc('amb1').set({
      uid: 'amb1', ambulanceId: 'amb1', driverName: 'Driver One', plateNumber: 'ABC-1',
      area: 'Giza', isOnline: true, status: 'available', currentIncidentId: null, currentIncidentType: null,
      createdAt: now, updatedAt: now,
    });
    await db.collection('ambulances').doc('amb2').set({
      uid: 'amb2', ambulanceId: 'amb2', driverName: 'Driver Two', plateNumber: 'ABC-2',
      area: 'Cairo', isOnline: true, status: 'available', currentIncidentId: null, currentIncidentType: null,
      createdAt: now, updatedAt: now,
    });

    await db.collection('ambulance_private').doc('amb1').set({ email: 'amb1@x.com', phone: '01000000000', fcmToken: null });

    await db.collection('tracking').doc('amb1').set({ latitude: 30.0, longitude: 31.0, bearing: 0, speed: 0, accuracy: 5, updatedAt: now });

    await db.collection('criticals').doc('crit1').set({
      patientUid: 'citizen1', status: 'assigned', assignedAmbulanceId: 'amb1', assignedAmbulanceName: 'ABC-1',
      assignedDriverName: 'Driver One', patientName: 'Test Patient', phoneNumber: '01011111111',
      emergencyContact: '01022222222', latitude: 30.01, longitude: 31.01, address: 'Test St', createdAt: now, updatedAt: now,
    });
    await db.collection('criticals').doc('critPending').set({
      patientUid: 'citizen1', status: 'pending', assignedAmbulanceId: null, patientName: 'Pending Patient',
      latitude: 30.01, longitude: 31.01, address: 'Test St', createdAt: now, updatedAt: now,
    });

    await db.collection('notifications').doc('notifCitizen').set({ recipientId: 'citizen1', recipientRole: 'citizen', type: 'assigned', title: 't', body: 'b', incidentId: 'crit1', incidentCollection: 'criticals', isRead: false, createdAt: now });
    await db.collection('notifications').doc('notifAmbulance').set({ recipientId: 'amb1', recipientRole: 'ambulance', type: 'critical_assigned', title: 't', body: 'b', incidentId: 'crit1', incidentCollection: 'criticals', isRead: false, createdAt: now });
    await db.collection('notifications').doc('notifAdmin').set({ recipientId: 'admin-broadcast', recipientRole: 'admin', type: 'no_ambulance_available', title: 't', body: 'b', incidentId: 'crit1', incidentCollection: 'criticals', isRead: false, createdAt: now });

    await db.collection('ambulance_history').doc('hist1').set({ ambulanceId: 'amb1', incidentId: 'crit1', incidentCollection: 'criticals', patientName: 'Test Patient', address: 'Test St', status: 'completed', completedAt: now });

    await db.collection('hospitals').doc('hosp1').set({ name: 'Test Hospital', lat: 30.0, lng: 31.0, bedsAvailable: 5 });

    await db.collection('citizens').doc('citizen1').set({ role: 'citizen', phoneNumber: '01011111111', firstName: 'A', lastName: 'B', createdAt: now });

    await db.collection('_counters').doc('counter1').set({ value: 1 });
  });
}

function ctxFor(uid: string | null, claims?: Record<string, unknown>) {
  return uid === null ? testEnv.unauthenticatedContext() : testEnv.authenticatedContext(uid, claims);
}

async function main() {
  await setup();

  // ── criticals / incidents ────────────────────────────────────────────
  test('criticals: owner can read their own', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('criticals').doc('crit1').get());
  });
  test('criticals: a different citizen cannot read someone else\'s critical', async () => {
    await assertFails(ctxFor('citizen2').firestore().collection('criticals').doc('crit1').get());
  });
  test('criticals: assigned ambulance can read it', async () => {
    await assertSucceeds(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('criticals').doc('crit1').get());
  });
  test('criticals: a DIFFERENT ambulance cannot read it', async () => {
    await assertFails(ctxFor('amb2', { role: 'ambulance', ambulanceId: 'amb2' }).firestore().collection('criticals').doc('crit1').get());
  });
  test('criticals: dashboard user can read it', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('criticals').doc('crit1').get());
  });
  test('criticals: citizen can create their own pending report', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('criticals').add({
      patientUid: 'citizen1', status: 'pending', patientName: 'New', latitude: 30, longitude: 31, address: '', createdAt: new Date(), updatedAt: new Date(),
    }));
  });
  test('criticals: citizen cannot create a report already marked assigned', async () => {
    await assertFails(ctxFor('citizen1').firestore().collection('criticals').add({
      patientUid: 'citizen1', status: 'assigned', assignedAmbulanceId: 'amb1', createdAt: new Date(), updatedAt: new Date(),
    }));
  });
  test('criticals: citizen cannot create a report impersonating another patientUid', async () => {
    await assertFails(ctxFor('citizen1').firestore().collection('criticals').add({
      patientUid: 'citizen2', status: 'pending', createdAt: new Date(), updatedAt: new Date(),
    }));
  });
  test('criticals: assigned ambulance can move assigned -> on_mission', async () => {
    await assertSucceeds(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('criticals').doc('crit1').update({ status: 'on_mission', updatedAt: new Date() }));
  });
  test('criticals: assigned ambulance CANNOT skip assigned -> completed', async () => {
    await assertFails(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('criticals').doc('crit1').update({ status: 'completed', updatedAt: new Date() }));
  });
  test('criticals: owner citizen can cancel while pending', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('criticals').doc('critPending').update({ status: 'cancelled', updatedAt: new Date() }));
  });
  test('criticals: a citizen cannot set someone else\'s report to cancelled', async () => {
    await assertFails(ctxFor('citizen2').firestore().collection('criticals').doc('critPending').update({ status: 'cancelled', updatedAt: new Date() }));
  });
  test('criticals: ambulance cannot touch unrelated fields like patientName', async () => {
    await assertFails(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('criticals').doc('crit1').update({ patientName: 'Hacked', updatedAt: new Date() }));
  });
  test('criticals: no client can delete', async () => {
    await assertFails(ctxFor('admin1').firestore().collection('criticals').doc('crit1').delete());
  });

  // ── ambulances ────────────────────────────────────────────────────────
  test('ambulances: owner can toggle isOnline', async () => {
    await assertSucceeds(ctxFor('amb1').firestore().collection('ambulances').doc('amb1').update({ isOnline: false, updatedAt: new Date() }));
  });
  test('ambulances: owner CANNOT write status directly', async () => {
    await assertFails(ctxFor('amb1').firestore().collection('ambulances').doc('amb1').update({ status: 'assigned', updatedAt: new Date() }));
  });
  test('ambulances: owner CANNOT write currentIncidentId directly', async () => {
    await assertFails(ctxFor('amb1').firestore().collection('ambulances').doc('amb1').update({ currentIncidentId: 'crit1' }));
  });
  test('ambulances: another ambulance cannot update amb1', async () => {
    await assertFails(ctxFor('amb2').firestore().collection('ambulances').doc('amb1').update({ isOnline: false }));
  });
  test('ambulances: dashboard user can read the fleet', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('ambulances').doc('amb1').get());
  });
  test('ambulances: no client can create an ambulance doc', async () => {
    await assertFails(ctxFor('admin1').firestore().collection('ambulances').doc('amb3').set({ uid: 'amb3', isOnline: false, status: 'available' }));
  });
  test('ambulances: dashboard user can edit non-operational fleet details', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('ambulances').doc('amb1').update({ driverName: 'New Driver', updatedAt: new Date() }));
  });
  test('ambulances: dashboard user editing fleet details CANNOT also sneak in a status change', async () => {
    await assertFails(ctxFor('operator1').firestore().collection('ambulances').doc('amb1').update({ driverName: 'New Driver', status: 'assigned', updatedAt: new Date() }));
  });

  // ── ambulance_private ─────────────────────────────────────────────────
  test('ambulance_private: owner can update own fcmToken', async () => {
    await assertSucceeds(ctxFor('amb1').firestore().collection('ambulance_private').doc('amb1').update({ fcmToken: 'tok123' }));
  });
  test('ambulance_private: owner cannot update email', async () => {
    await assertFails(ctxFor('amb1').firestore().collection('ambulance_private').doc('amb1').update({ email: 'new@x.com' }));
  });
  test('ambulance_private: a citizen cannot read it', async () => {
    await assertFails(ctxFor('citizen1').firestore().collection('ambulance_private').doc('amb1').get());
  });
  test('ambulance_private: dashboard user can read it', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('ambulance_private').doc('amb1').get());
  });

  // ── tracking ──────────────────────────────────────────────────────────
  test('tracking: any signed-in user can read', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('tracking').doc('amb1').get());
  });
  test('tracking: owning ambulance can write its position', async () => {
    await assertSucceeds(ctxFor('amb1').firestore().collection('tracking').doc('amb1').set({ latitude: 30.02, longitude: 31.02, bearing: 90, speed: 10, accuracy: 5, updatedAt: new Date() }));
  });
  test('tracking: a DIFFERENT ambulance cannot write amb1\'s position', async () => {
    await assertFails(ctxFor('amb2').firestore().collection('tracking').doc('amb1').set({ latitude: 0, longitude: 0, bearing: 0, speed: 0, accuracy: 1, updatedAt: new Date() }));
  });
  test('tracking: cannot write extra fields outside the whitelist', async () => {
    await assertFails(ctxFor('amb1').firestore().collection('tracking').doc('amb1').set({ latitude: 30, longitude: 31, bearing: 0, speed: 0, accuracy: 1, updatedAt: new Date(), extra: 'nope' }));
  });

  // ── notifications ─────────────────────────────────────────────────────
  test('notifications: citizen can read their own', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('notifications').doc('notifCitizen').get());
  });
  test('notifications: a different citizen cannot read it', async () => {
    await assertFails(ctxFor('citizen2').firestore().collection('notifications').doc('notifCitizen').get());
  });
  test('notifications: assigned ambulance can read its own', async () => {
    await assertSucceeds(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('notifications').doc('notifAmbulance').get());
  });
  test('notifications: dashboard user can read an admin-broadcast one', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('notifications').doc('notifAdmin').get());
  });
  test('notifications: a citizen cannot read an admin-broadcast one', async () => {
    await assertFails(ctxFor('citizen1').firestore().collection('notifications').doc('notifAdmin').get());
  });
  test('notifications: recipient can mark their own isRead', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('notifications').doc('notifCitizen').update({ isRead: true, readAt: new Date() }));
  });
  test('notifications: no client can create one directly', async () => {
    await assertFails(ctxFor('admin1').firestore().collection('notifications').add({ recipientId: 'citizen1', recipientRole: 'citizen', isRead: false, createdAt: new Date() }));
  });

  // ── ambulance_history ─────────────────────────────────────────────────
  test('ambulance_history: the ambulance it\'s about can read it', async () => {
    await assertSucceeds(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('ambulance_history').doc('hist1').get());
  });
  test('ambulance_history: dashboard user can read it', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('ambulance_history').doc('hist1').get());
  });
  test('ambulance_history: ambulance CANNOT write it directly (server-only)', async () => {
    await assertFails(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('ambulance_history').add({ ambulanceId: 'amb1', incidentId: 'crit1', incidentCollection: 'criticals', status: 'completed', completedAt: new Date() }));
  });

  // ── citizens ──────────────────────────────────────────────────────────
  test('citizens: owner can read/write their own profile', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('citizens').doc('citizen1').update({ firstName: 'Updated' }));
  });
  test('citizens: a different citizen cannot write someone else\'s profile', async () => {
    await assertFails(ctxFor('citizen2').firestore().collection('citizens').doc('citizen1').update({ firstName: 'Hacked' }));
  });
  test('citizens: ambulance crew can read for incident context', async () => {
    await assertSucceeds(ctxFor('amb1', { role: 'ambulance', ambulanceId: 'amb1' }).firestore().collection('citizens').doc('citizen1').get());
  });

  // ── hospitals ─────────────────────────────────────────────────────────
  test('hospitals: any signed-in user can read', async () => {
    await assertSucceeds(ctxFor('citizen1').firestore().collection('hospitals').doc('hosp1').get());
  });
  test('hospitals: a non-admin cannot write', async () => {
    await assertFails(ctxFor('operator1').firestore().collection('hospitals').doc('hosp1').update({ bedsAvailable: 0 }));
  });
  test('hospitals: dashboard admin can write', async () => {
    await assertSucceeds(ctxFor('admin1').firestore().collection('hospitals').doc('hosp1').update({ bedsAvailable: 4 }));
  });

  // ── join_requests ─────────────────────────────────────────────────────
  test('join_requests: a well-formed public submission succeeds, even unauthenticated', async () => {
    await assertSucceeds(ctxFor(null).firestore().collection('join_requests').add({ name: 'Volunteer', phone: '01099999999', status: 'pending', createdAt: new Date() }));
  });
  test('join_requests: a submission missing a name is rejected', async () => {
    await assertFails(ctxFor(null).firestore().collection('join_requests').add({ phone: '01099999999', status: 'pending', createdAt: new Date() }));
  });
  test('join_requests: a submission with an unexpected field is rejected', async () => {
    await assertFails(ctxFor(null).firestore().collection('join_requests').add({ name: 'X', phone: '01099999999', status: 'pending', createdAt: new Date(), isAdmin: true }));
  });
  test('join_requests: a random citizen cannot read submissions', async () => {
    await assertFails(ctxFor('citizen1').firestore().collection('join_requests').doc('whatever').get());
  });

  // ── dashboard_users ───────────────────────────────────────────────────
  test('dashboard_users: a dashboard user can read their own doc', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('dashboard_users').doc('operator1').get());
  });
  test('dashboard_users: an operator cannot create another dashboard user', async () => {
    await assertFails(ctxFor('operator1').firestore().collection('dashboard_users').doc('newuser').set({ role: 'operator', name: 'New', email: 'n@x.com', active: true, createdAt: new Date() }));
  });
  test('dashboard_users: an operator can update their own name/prefs', async () => {
    await assertSucceeds(ctxFor('operator1').firestore().collection('dashboard_users').doc('operator1').update({ name: 'Renamed' }));
  });
  test('dashboard_users: an operator CANNOT self-promote to admin', async () => {
    await assertFails(ctxFor('operator1').firestore().collection('dashboard_users').doc('operator1').update({ role: 'admin' }));
  });
  test('dashboard_users: a deactivated dashboard user has no dashboard access', async () => {
    await assertFails(ctxFor('inactive1').firestore().collection('ambulances').doc('amb1').get());
  });

  // ── _counters ─────────────────────────────────────────────────────────
  test('_counters: no client (not even admin) can read', async () => {
    await assertFails(ctxFor('admin1').firestore().collection('_counters').doc('counter1').get());
  });
  test('_counters: no client can write', async () => {
    await assertFails(ctxFor('admin1').firestore().collection('_counters').doc('counter1').set({ value: 2 }));
  });

  await runTests();
  await testEnv.cleanup();
}

main().catch(err => {
  console.error('rules.test.ts fatal error:', err);
  process.exit(1);
});
