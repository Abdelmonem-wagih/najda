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
exports.db = exports.admin = void 0;
const admin = __importStar(require("firebase-admin"));
exports.admin = admin;
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
exports.db = admin.firestore();
//# sourceMappingURL=firebaseAdmin.js.map