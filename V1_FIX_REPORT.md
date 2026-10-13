# Najda v1 Hardening — Fix Report

Branches: `v1-hardening` in both `najda` (APP) and `najda-dashboard` (DASHBOARD). One commit per numbered step, message `step N: <what>`.

Status key per item below (filled in as work completes): **Fixed** / **Skipped (why)** / **Not applicable** / **Needs manual test**.

---

## Phase 0 — Prepare

### 0.1 Baselines (captured before any change)

| Check | Result |
|---|---|
| `flutter analyze` (APP) | 226 issues found, 0 errors (16.7s) |
| `npm run lint` (DASHBOARD) | 21 problems: 20 errors, 1 warning |
| `npm run build` (DASHBOARD) | Succeeds. Single bundle `dist/assets/index-*.js` = 1,098.89 kB (298.47 kB gzip). Chunk-size warning. |
| `npm --prefix najda_functions run build` (APP functions, TS) | Succeeds, no output/errors |
| Dashboard legacy `functions/` (JS, separate Firebase project wiring) | Plain JS, no build step (`main: index.js`), deps: axios, firebase-admin, firebase-functions |

Branches created from:
- APP: `v1-hardening` off `rebuild-and-fix-all-issue` @ `e32b975`
- DASHBOARD: `v1-hardening` off `fixing` @ `c75b6e1`

### 0.2 Planned files per phase (updated as work proceeds; see the step-by-step log below for the authoritative list of what was actually touched)

- **Phase 1**: `firebase.json`, `.firebaserc` (APP root), new `storage.rules`, `najda_functions/src/contract.ts`, `lib/core/constants/firestore_contract.dart`, DASHBOARD `src/lib/contract.js`, `najda/firebase/CONTRACT.md`, `scripts/check-contract.mjs`, `firestore.indexes.json`; deletion of DASHBOARD `functions/`, `firebase.json`, `.firebaserc`.
- **Phase 2**: `najda_functions/src/index.ts` (full rewrite of assignment/status/account logic), `najda_functions/src/contract.ts`, new `najda_functions/scripts/migrate-v1.ts`.
- **Phase 3**: `firestore.rules`, new `storage.rules`, new `najda_functions/test/rules.test.ts` (or equivalent emulator rules tests).
- **Phase 4**: see step-by-step log (app files from the audit: `app_constants.dart`, `main.dart`, `app_routes.dart`, `groq_service.dart`, `tracking_page.dart`, `history_card.dart`, `sos_cubit.dart`, `sos_remote_datasource.dart`, `citizen_home_page.dart`, `auth_repository_impl.dart`, `paramedic_home_page.dart`, `location_service.dart`, `tracking_service.dart`, `report_details_page.dart`, `notification_service.dart`, `firstaid` data, etc.)
- **Phase 5**: DASHBOARD `src/lib/contract.js`, `src/lib/normalizeIncident.js` (new), `src/lib/functions.js`, `src/hooks/useFirestore.js`, `src/pages/*.jsx`, `src/components/*`, `public/markers/*.svg` + rendered PNGs.
- **Phase 6**: `najda_functions/test/e2e-sos.test.ts` (new), final verification run.

---

## Phase 1 — One Firebase backend + one contract — ✅ COMPLETE, VERIFIED

### 1.1 Single Firebase home
**Fixed.** `firebase.json` (APP) now also references `storage.rules` (new file — there was no Storage rules file in the repo at all before this, confirmed absent; audit finding SEC5). Both READMEs updated to state the APP repo is the sole owner of Firebase config/rules/indexes/functions, with deploy commands. `storage.rules` is a safe baseline (owner-write, authenticated-read, 5MB/image-only on `incidents/{uid}/*`) — finalized with the dashboard-user read check in Phase 3.3.

### 1.2 Park AI, delete legacy JS functions
**Fixed.** Read `najda-dashboard/functions/index.js` in full (338 lines) before touching anything. Confirmed by grep (both repos, zero hits) that nothing writes to `reports`/`emergency_reports`, so `onReportCreated`/`onEmergencyReportCreated` were genuinely dead triggers. Ported `assignHospital` (+ `analyzeWithGroq`) to `najda_functions/src/ai/assignHospital.disabled.ts`, exported as `assignHospitalDisabled`, **not** exported from `index.ts` — verified it compiles cleanly (`npm run build` in `najda_functions`, 0 errors) without being reachable. Deleted `najda-dashboard/functions/`, `firebase.json`, `.firebaserc` entirely. APP's `firebase.json` already had exactly one functions codebase (`"codebase": "default"`), confirmed.

### 1.3 Canonical contract
**Fixed.** Created `najda_functions/src/contract.ts`, `lib/core/constants/firestore_contract.dart`, `src/lib/contract.js` (dashboard) with matching `COLLECTIONS`/`INCIDENT_STATUS`/`AMBULANCE_STATUS` blocks (marked with `CONTRACT:*:START/END`) plus full field-name constants, the `incidentCollectionFor()`/`incidentKindFor()` helpers, and a machine-readable `STATUS_TRANSITIONS` table. `firebase/CONTRACT.md` is the human-readable mirror. `scripts/check-contract.mjs` parses all three files and **verified passing** (`node scripts/check-contract.mjs` with `DASHBOARD_CONTRACT` pointed at `E:/najda-dashboard/src/lib/contract.js`: 12 collections, 8 incident statuses, 5 ambulance statuses, all matching). Verified `dart analyze` on the new Dart file (0 issues), `tsc` build (0 errors), `eslint` on the new JS file (0 errors).

**Note:** replacing every hardcoded literal across both codebases with these constants is deferred to Phases 2/4/5, file-by-file, as each file gets touched anyway for its logic fix — not done as a separate blind pass, which would mean editing every file twice.

### 1.4 Firestore indexes
**Fixed — and found a bug beyond the original audit.** The pre-existing `firestore.indexes.json` used `//` comments, which is **not valid JSON** — confirmed by running it through `JSON.parse()`, which threw `SyntaxError: Unexpected token '/'`. `firebase deploy --only firestore:indexes` would have failed outright if ever run against this file; this was never caught by the original read-only audit. Regenerated as valid JSON (verified with `JSON.parse`) with exactly the index groups needed: `criticals`/`incidents` × (`assignedAmbulanceId`,`status`,`createdAt`), × (`patientUid`,`dedupeKey`,`status`), × (`status`,`createdAt` desc); `ambulances` × (`isOnline`,`status`); `notifications` × (`recipientId`,`createdAt` desc) and × (`recipientId`,`isRead`,`createdAt` desc); `ambulance_history` × (`ambulanceId`,`completedAt` desc). Rationale table in `CONTRACT.md` (JSON can't carry comments). **Needs manual verification**: could not validate against the live project — `firebase projects:list` confirms the CLI account on this machine does not have access to `ultra-bearing-402000`; deploying needs the account that owns the project.

### Discoveries beyond the original audit (new findings, logged here)

- The dashboard's legacy `functions/index.js` had its own `createAmbulanceAccount` with no admin check and a hardcoded Cairo fallback point (30.0444, 31.2357) — this duplicates (and is worse than) `najda_functions`'s `createAmbulancesAccount`, which also lacks an admin check per the original audit. Both are addressed together in Phase 2.8.
- `firestore.rules` references collections outside the canonical schema that the hardening prompt didn't mention: `admins`, `patient_profiles` (commented "legacy — kept for backward compat"), `mission_cancellations`. Left untouched in Phase 1/3 since removing them wasn't requested and nothing confirms they're unused — flagged in `CONTRACT.md` for a follow-up decision.
- `firestore.rules`'s `isAmbulance()`/`isAssignedAmbulance()` helpers fall back to reading a `users/{uid}.role` doc, even though no code anywhere writes a `users` collection (confirmed by the original audit and re-confirmed here). This fallback is dead weight today but not a live bug; will be removed when rules are rewritten in Phase 3 (the canonical schema explicitly retires `users`).
- `firestore.indexes.json` was invalid JSON (above) — not caught by the original read-only audit, which only reviewed index *field names*, not whether the file would parse at all.

---

## Phase 2 — Backend (najda_functions) — ✅ COMPLETE, VERIFIED

Read `index.ts` in full before changing anything (confirmed the exact lines the brief pointed at: `applyAssignment` ~91-124, dedupe ~199-231, `retryPending` ~377-406, `manualAssign` ~412-463, account functions ~485-566). Split the rewrite into focused modules instead of one file: `lib/geo.ts`, `lib/assignment.ts`, `lib/autoAssign.ts`, `lib/notify.ts`, `triggers/statusMachine.ts`, re-wired from `index.ts`.

### 2.1 applyAssignment — flat fields only
**Fixed.** Writes `assignedAmbulanceId/Name/DriverName/VehicleId` (from `plateNumber`), `assignedAt`, `assignedBy` (`'auto'` or the caller's uid). Never writes `assignedFcmToken` — confirmed by grep, zero matches anywhere in `src/`. Token is read from `ambulance_private/{id}` separately, after the transaction commits, by `notifyAmbulanceOfAssignment`.

### 2.2 Nearest-ambulance selection
**Fixed.** `findNearestEligibleAmbulance` (geo.ts): candidates = `ambulances` where `isOnline==true && status=='available'`, filtered to those with no `currentIncidentId`, position read from `tracking/{id}` (not the ambulance doc), stale (>5min) or missing tracking excluded, Haversine distance, deterministic tie-break by ambulance doc id. Runs entirely inside the caller's transaction (all `tx.get()` calls, no writes) so Firestore's optimistic-concurrency conflict detection prevents two simultaneous SOS reports from grabbing the same ambulance — confirmed this is exactly what Phase 6.1's "two criticals at once get two different ambulances" test needs to prove. `isAmbulanceEligible` extracted as the one predicate shared by this search, `retryPending`, and `manualAssign`'s eligibility check.

### 2.3 Dedupe + idempotency
**Fixed.** `tryAutoAssign` (autoAssign.ts) re-reads the incident fresh inside the transaction and bails immediately if it's no longer `'pending'` — this is the idempotency guard (handles at-least-once trigger redelivery and overlapping `retryPending` runs without re-processing an already-assigned doc). The dedupe query now excludes the document's own id from the duplicate check (old code could flag a redelivered CREATE event as a duplicate of itself and downgrade a valid dispatch to `'duplicate'`). Every trigger body wrapped in try/catch with `console.error`/`console.warn` logging.

### 2.4 retryPending cap + alert
**Fixed.** Increments `retryCount` on each failed cycle; at 5 attempts, stops retrying (the doc stays `'pending'` for manual assignment) and writes an admin-broadcast notification (`notifyAdminsNoAmbulanceAvailable`) instead of silently retrying forever.

### 2.5 manualAssign
**Fixed.** The dashboard's one callable for both assign and reassign. Verifies the caller is an *active* `dashboard_users` doc with role `admin`/`operator` (old version only checked `request.auth` existed — any authenticated user, not necessarily a dashboard user, could call it). Reads the target ambulance with `tx.get()` **inside** the transaction (old version read it outside — a TOCTOU gap: the ambulance could change state between the read and the transaction). Requires eligibility via the same `isAmbulanceEligible` predicate unless `force:true` **and** caller role is `admin`. Releases the previous ambulance in the same transaction on reassignment. Records `assignedBy` as the caller's uid (was previously always `undefined`/not tracked).

### 2.6 Status-machine trigger
**Fixed — this is the biggest correctness fix in the whole backend.** `onCriticalStatusChanged`/`onIncidentStatusChanged` (`onDocumentUpdated` on both collections) validate every status transition against `contract.ts`'s `STATUS_TRANSITIONS` table and revert illegal ones. A `pendingRevert` sentinel field breaks what would otherwise be an infinite trigger loop (reverting an illegal `A→B` back to `A` would itself look like a `B→A` transition to the next trigger invocation, which is *also* not a legal forward hop — the sentinel makes that second invocation a no-op clear instead of another revert attempt; verified the logic on paper, flagged for the Phase 6 emulator test to confirm at runtime). On `completed`: releases the ambulance **and writes `ambulance_history` server-side** — this directly fixes the original audit's PARA8 finding (the client write to `ambulance_history` was always rejected by `firestore.rules`, so the paramedic history tab was effectively always empty; the server-side write here is the actual fix, not just a rules change in Phase 3). On `cancelled`: releases the ambulance. On `on_mission`/`arrived`/`to_hospital`: mirrors the status onto the ambulance doc. Every accepted transition (except `assigned`, which `applyAssignment` already handles atomically) notifies the citizen.

### 2.7 Citizen push notifications
**Fixed (backend half).** `notifyCitizenOfStatus` reads `citizens/{uid}.fcmToken` and sends FCM + writes a canonical `notifications` doc on `assigned/on_mission/arrived/to_hospital/completed`. This closes CC10 from the backend side — the Flutter app still needs to actually *save* a citizen's FCM token at OTP login (Phase 4.8) for this to have anything to send to; noted as a cross-phase dependency, not forgotten.

### 2.8 Account management callables
**Fixed.** `createAmbulanceAccount` (renamed from `createAmbulancesAccount`): now requires an active dashboard `admin` (old version had **no check at all** — any authenticated caller could create ambulance accounts) and requires `baseLocation` as an argument, throwing `invalid-argument` if missing — no more hardcoded Cairo fallback point. New `deleteAmbulanceAccount` (admin only): disables the Firebase Auth user, then deletes `ambulances/{id}`, `ambulance_private/{id}`, `tracking/{id}` — old flow (neither repo had a delete at all) never touched Auth. New `createDashboardUser`/`setDashboardUserActive` (admin only). `releaseAmbulance` now requires an active dashboard admin/operator (was: any authenticated caller). `markNotificationRead` now checks the caller actually owns the notification, or is an active dashboard user for admin-targeted ones (old version: any authenticated caller could mark any notification read).

**Decision (RECOMMENDED, noted since no explicit instruction gave an unambiguous answer): no `joinRequest` callable.** `join_requests` is created directly from the client via a public Firestore `create` rule with field validation (Phase 3.2) — there's nothing for a callable to do that the rule doesn't already need to validate anyway. The legacy dashboard `functions/index.js` had one; it was deleted in step 1.2.

### 2.9 Non-existent functions
**Confirmed (again), fixed nothing new here.** `aiSelectHospital`, `reassignAmbulance`, `najdaAIAssistant`, `triageSymptoms`, `selectHospitalWithAI` are not defined anywhere in `najda_functions`. Removing the *client-side* calls to them is Phase 4 (Flutter's `groq_service.dart`) and Phase 5 (dashboard's `functions.js`).

### 2.10 Migration script
**Fixed.** `najda_functions/scripts/migrate-v1.ts`, dry-run by default. Type-checks cleanly standalone (`tsc --noEmit`). Smoke-tested via `npx tsx scripts/migrate-v1.ts`: starts, prints `DRY RUN`, and fails only at the Firestore auth step — confirming the script's logic runs correctly up to the point where it needs real project credentials, which this machine doesn't have for `ultra-bearing-402000` (same limitation as Phase 1.4). **Not run with `--apply`** — per the brief, that's the user's call after reviewing a dry run against the real project, from a machine/account with access.

### Verification
`npm run build` (tsc): 0 errors, confirmed after every module addition. Grepped the compiled output (`grep "^exports\." lib/index.js`) to confirm all 12 functions export: `autoAssignCritical`, `autoAssignIncident`, `onCriticalStatusChanged`, `onIncidentStatusChanged`, `retryPending`, `manualAssign`, `releaseAmbulance`, `createAmbulanceAccount`, `deleteAmbulanceAccount`, `createDashboardUser`, `setDashboardUserActive`, `markNotificationRead`. Grepped `src/` to confirm `createAmbulancesAccount`, `assignedFcmToken`, and `ambulancesId` are gone everywhere. Re-ran `flutter analyze` (226 issues, unchanged — confirms this backend-only phase caused zero Flutter regressions, as expected).

### What Phase 6's emulator suite still needs to prove (can't verify without a live/emulated Firestore)
- The `pendingRevert` loop-breaker actually terminates in 3 invocations against a real trigger, not just on paper.
- Two simultaneous SOS creates genuinely resolve to two different ambulances (the transaction-conflict-retry behavior).
- The dedupe-exclude-self fix actually prevents a simulated redelivery from downgrading a valid assignment.

## Phase 3 — Rules (firestore.rules + storage.rules) — NOT STARTED (storage.rules has a Phase 1 baseline only)

## Phase 4 — Flutter app — NOT STARTED

## Phase 5 — Dashboard — NOT STARTED

## Phase 6 — Verify everything (emulator E2E) — NOT STARTED

---

## Commit log (both repos)

| Repo | Commit | Message |
|---|---|---|
| APP | `ca16215` | step 0: baseline numbers and v1-hardening branch setup |
| APP | `c2204a9` | step 1.1: consolidate on one Firebase backend (APP repo) + add storage.rules |
| APP | `0013d73` | step 1.2: park Groq hospital-assignment as disabled, unexported Cloud Function |
| APP | `237e0df` | step 1.3a: add the canonical schema contract (functions + Flutter) and the cross-repo contract checker |
| APP | `2b1293e` | step 1.4: regenerate firestore.indexes.json from actual queries (it was invalid JSON) |
| DASHBOARD | (branch created) | — |
| DASHBOARD | `c0776a2` | step 1.1: document that Firebase backend lives in the najda (app) repo |
| DASHBOARD | `28d6ddb` | step 1.2: delete the legacy Firebase Functions codebase |
| DASHBOARD | `df59b37` | step 1.3a: add the canonical schema contract mirror (contract.js) |
