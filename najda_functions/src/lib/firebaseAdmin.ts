import * as admin from 'firebase-admin';

// The ONE place admin.initializeApp() is called. Every other file imports
// `db` from here instead of calling admin.firestore() itself — when a lib
// module computed its own `const db = admin.firestore()` at module scope,
// Node's import hoisting meant that ran during index.ts's own import
// resolution, before index.ts's `admin.initializeApp()` line ever executed,
// crashing every function at load time with "the default Firebase app does
// not exist". Requiring this module (directly or transitively) is what
// guarantees initialization happens first, exactly once, regardless of
// which file in the dependency graph is required first.
if (admin.apps.length === 0) {
  admin.initializeApp();
}

export { admin };
export const db = admin.firestore();
