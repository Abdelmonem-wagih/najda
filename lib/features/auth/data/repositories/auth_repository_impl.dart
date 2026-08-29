import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AppUser?> checkAuthStatus() async {
    final firebaseUser = await remoteDataSource.currentUser;
    if (firebaseUser == null) return null;

    final role = await localDataSource.getUserRole();

    if (role == AppConstants.roleParamedic) {
      return remoteDataSource.fetchParamedic(firebaseUser.uid);
    } else {
      return remoteDataSource.fetchCitizen(firebaseUser.uid);
    }
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await remoteDataSource.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<AppUser> verifyOtp(String smsCode, String verificationId) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final uc = await remoteDataSource.signInWithCredential(credential);
    final uid = uc.user!.uid;

    await localDataSource.saveUserRole(AppConstants.roleCitizen);
    await localDataSource.saveUserId(uid);

    final user = await remoteDataSource.fetchCitizen(uid);
    if (user == null) {
      return AppUser(
        id: uid,
        role: AppConstants.roleCitizen,
        phoneNumber: uc.user!.phoneNumber,
        medicalProfile: const MedicalProfile(),
        emergencyContactData: const EmergencyContact(name: '', phone: ''),
      );
    }

    return user;
  }

  @override
  Future<AppUser> completeRegistration({
    required String uid,
    required String phone,
    required String fullName,
    required String nationalId,
    String? password,
    String? emergencyContact,
    List<String> chronicDiseases = const [],
    List<String> allergies = const [],
    List<String> currentMedications = const [],
    String? additionalInfo,
  }) async {
    if (password != null && password.trim().length >= 6) {
      await remoteDataSource.updatePassword(password.trim());
    }

    // Split fullName into firstName and lastName
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final medicalProfile = MedicalProfile(
      chronicDiseases: chronicDiseases,
      allergies: allergies,
      currentMeds: currentMedications,
      notes: additionalInfo,
    );

    final contact = EmergencyContact(
      name: 'Emergency Contact', // Should ideally be passed separately
      phone: emergencyContact ?? '',
    );

    final data = {
      'role': AppConstants.roleCitizen,
      'phoneNumber': phone,
      'firstName': firstName,
      'lastName': lastName,
      'medicalProfile': medicalProfile.toMap(),
      'emergencyContact': contact.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await remoteDataSource.saveCitizenProfile(uid, data);

    return AppUser(
      id: uid,
      role: AppConstants.roleCitizen,
      phoneNumber: phone,
      firstName: firstName,
      lastName: lastName,
      medicalProfile: medicalProfile,
      emergencyContactData: contact,
    );
  }


  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final uc = await remoteDataSource.signInWithEmailAndPassword(email.trim(), password);
    final uid = uc.user!.uid;

    final user = await remoteDataSource.fetchParamedic(uid);
    if (user == null) {
      await remoteDataSource.signOut();
      throw FirebaseAuthException(code: 'user-not-found', message: 'NOT_A_PARAMEDIC');
    }

    await localDataSource.saveUserRole(AppConstants.roleParamedic);
    await localDataSource.saveUserId(uid);
    await localDataSource.saveUserEmail(email);

    return user;
  }

  @override
  Future<void> signOut() async {
    final uid = await localDataSource.getUserId();
    final role = await localDataSource.getUserRole();
    if (role == AppConstants.roleParamedic && uid != null) {
      await remoteDataSource.updateParamedicFcmToken(uid, null);
    }

    await remoteDataSource.signOut();
    await localDataSource.clearAuthData();
  }

  @override
  Future<void> updateParamedicFcmToken(String paramedicId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await remoteDataSource.updateParamedicFcmToken(paramedicId, token);
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          remoteDataSource.updateParamedicFcmToken(paramedicId, newToken);
        });
      }
    } catch (_) {}
  }

  @override
  Future<AppUser> signInWithCredential(AuthCredential credential) async {
    final uc = await remoteDataSource.signInWithCredential(credential);
    final uid = uc.user!.uid;

    await localDataSource.saveUserRole(AppConstants.roleCitizen);
    await localDataSource.saveUserId(uid);

    final user = await remoteDataSource.fetchCitizen(uid);
    if (user == null) {
      return AppUser(
        id: uid,
        role: AppConstants.roleCitizen,
        phoneNumber: uc.user!.phoneNumber,
        medicalProfile: const MedicalProfile(),
        emergencyContactData: const EmergencyContact(name: '', phone: ''),
      );
    }

    return user;
  }

  @override
  Future<AppUser> updateProfile({
    required String uid,
    String? fullName,
    String? emergencyContact,
    List<String> chronicDiseases = const [],
    List<String> allergies = const [],
    List<String> currentMedications = const [],
    String? additionalInfo,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (fullName != null) {
      final parts = fullName.trim().split(' ');
      data['firstName'] = parts.first;
      data['lastName'] = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    
    if (emergencyContact != null) {
      data['emergencyContact.phone'] = emergencyContact;
    }
    
    data['medicalProfile.chronicDiseases'] = chronicDiseases;
    data['medicalProfile.allergies'] = allergies;
    data['medicalProfile.currentMeds'] = currentMedications;
    
    if (additionalInfo != null) {
      data['medicalProfile.notes'] = additionalInfo;
    }

    await remoteDataSource.updateCitizenProfile(uid, data);

    final updatedUser = await remoteDataSource.fetchCitizen(uid);
    if (updatedUser == null) throw Exception('USER_NOT_FOUND');
    return updatedUser;
  }

}
