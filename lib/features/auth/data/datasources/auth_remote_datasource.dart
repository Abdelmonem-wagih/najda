import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Future<User?> get currentUser;
  Future<AppUser?> fetchAmbulanceData(String uid);
  Future<AppUser?> fetchCitizen(String uid);
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  });
  Future<UserCredential> signInWithCredential(AuthCredential credential);
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> updatePassword(String password);
  Future<void> saveCitizenProfile(String uid, Map<String, dynamic> data);
  Future<void> updateCitizenProfile(String uid, Map<String, dynamic> data);
  Future<void> updateAmbulanceFcmToken(String ambulanceId, String? token);
  Future<void> updateAmbulanceOnlineStatus(String ambulanceId, bool isOnline, {String? status});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> get currentUser async => _auth.currentUser;

  @override
  Future<AppUser?> fetchAmbulanceData(String uid) async {
    // According to ambulances schema, we query the 'ambulances' collection where uid matches
    final query = await _firestore
        .collection(AppConstants.ambulancesCollection)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    
    final doc = query.docs.first;
    return UserModel.fromMap(doc.data(), doc.id);
  }

  @override
  Future<AppUser?> fetchCitizen(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.citizensCollection)
        .doc(uid)
        .get();
    
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> updatePassword(String password) async {
    await _auth.currentUser?.updatePassword(password);
  }

  @override
  Future<void> saveCitizenProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.citizensCollection)
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<void> updateCitizenProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.citizensCollection)
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<void> updateAmbulanceFcmToken(String ambulanceId, String? token) async {
    final update = token == null 
        ? {'fcmToken': FieldValue.delete()} 
        : {'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()};
        
    await _firestore
        .collection(AppConstants.ambulancesCollection)
        .doc(ambulanceId)
        .set(update, SetOptions(merge: true));
  }

  @override
  Future<void> updateAmbulanceOnlineStatus(String ambulanceId, bool isOnline, {String? status}) async {
    final Map<String, dynamic> update = {
      'isOnline': isOnline,
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
    if (status != null) {
      update['status'] = status;
    }
    await _firestore
        .collection(AppConstants.ambulancesCollection)
        .doc(ambulanceId)
        .update(update);
  }
}
