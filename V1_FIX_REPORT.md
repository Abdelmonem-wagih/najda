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

## Phase 2 — Backend (najda_functions) — NOT STARTED

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
