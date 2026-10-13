import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/firestore_contract.dart';

/// Saves the current device's FCM token to citizens/{uid}.fcmToken.
///
/// Citizens previously never had an FCM token saved anywhere (only the
/// ambulance/paramedic login path called updateAmbulanceFcmToken) — the
/// backend's Phase 2 citizen-targeted notifications had nothing to send a
/// push to. Call this right after a citizen authenticates (OTP verify,
/// credential sign-in, registration) — mirrors the ambulance equivalent.
Future<void> saveCitizenFcmToken(String uid) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.citizens)
        .doc(uid)
        .set({CitizenFields.fcmToken: token}, SetOptions(merge: true));
  } catch (_) {
    // Best-effort — a failed token save shouldn't block sign-in.
  }
}

/// Called once at app startup, before any widget tree/AuthCubit exists, to
/// cover a citizen who was already signed in from a previous session (so a
/// token refresh while the app was closed still gets picked up on next
/// launch). No-ops if nobody is signed in, or the signed-in account isn't a
/// citizen (no citizens/{uid} doc).
Future<void> maybeSaveCitizenFcmToken() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  try {
    final doc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.citizens)
        .doc(uid)
        .get();
    if (!doc.exists) return;
    await saveCitizenFcmToken(uid);
  } catch (_) {}
}
