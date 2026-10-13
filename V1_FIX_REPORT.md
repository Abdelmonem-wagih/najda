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

## Phase 1 — One Firebase backend + one contract

_(log fills in below as executed)_

---

## Commit log (both repos)

| Repo | Commit | Message |
|---|---|---|
| APP | (branch created) | — |
| DASHBOARD | (branch created) | — |
