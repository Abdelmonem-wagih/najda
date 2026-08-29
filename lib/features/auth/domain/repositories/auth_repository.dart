import 'package:firebase_auth/firebase_auth.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> checkAuthStatus();
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  });
  Future<AppUser> verifyOtp(String smsCode, String verificationId);
  Future<AppUser> completeRegistration({
    required String uid,
    required String phone,
    required String fullName,
    required String nationalId,
    String? password,
    String? emergencyContact,
    List<String> chronicDiseases,
    List<String> allergies,
    List<String> currentMedications,
    String? additionalInfo,
  });
  Future<AppUser> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> updateParamedicFcmToken(String paramedicId);
  Future<AppUser> signInWithCredential(AuthCredential credential);
  Future<AppUser> updateProfile({
    required String uid,
    String? fullName,
    String? emergencyContact,
    List<String> chronicDiseases = const [],
    List<String> allergies = const [],
    List<String> currentMedications = const [],
    String? additionalInfo,
  });
}
