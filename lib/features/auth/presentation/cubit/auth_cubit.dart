import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/entities/app_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;

  AuthCubit() : super(AuthInitial());

  // ─── Splash: determine where to go ──────────────────────────────────────

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(AppConstants.keyUserRole);

      if (role == AppConstants.roleParamedic) {
        final user = await _fetchParamedic(firebaseUser.uid);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        // Citizen — check if profile is complete
        final doc = await _firestore
            .collection(AppConstants.citizensCollection)
            .doc(firebaseUser.uid)
            .get();

        if (!doc.exists) {
          // Authenticated but profile not yet created
          emit(AuthNeedsRegistration(
            uid: firebaseUser.uid,
            phone: firebaseUser.phoneNumber ?? '',
          ));
        } else {
          final user = _citizenFromDoc(firebaseUser.uid, doc.data()!);
          emit(AuthAuthenticated(user));
        }
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // ─── Citizen: Phone + OTP ────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber) async {
    emit(AuthLoading());
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await checkAuthStatus();
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(e.message ?? 'فشل التحقق من الرقم'));
        },
        codeSent: (String verificationId, int? _) {
          _verificationId = verificationId;
          emit(OtpSent(verificationId, phoneNumber));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String smsCode, String verificationId) async {
    emit(AuthLoading());
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final uc = await _auth.signInWithCredential(credential);
      final uid = uc.user!.uid; // ← real uid from Firebase Auth

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserRole, AppConstants.roleCitizen);
      await prefs.setString(AppConstants.keyUserId, uid);

      final doc = await _firestore
          .collection(AppConstants.citizensCollection)
          .doc(uid) // ← never empty here
          .get();

      if (!doc.exists) {
        emit(AuthNeedsRegistration(
          uid: uid, // ← real uid passed to registration
          phone: uc.user!.phoneNumber ?? '',
        ));
      } else {
        final user = _citizenFromDoc(uid, doc.data()!);
        emit(AuthAuthenticated(user));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'رمز التحقق غير صحيح'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> completeRegistration({
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
    emit(AuthLoading());
    try {
      // Validate uid is not empty before writing to Firestore
      if (uid.isEmpty) {
        emit(const AuthError('خطأ: لم يتم التحقق من الهوية. أعد تسجيل الدخول.'));
        return;
      }

      // Update password if provided
      if (password != null && password.trim().length >= 6) {
        await _auth.currentUser?.updatePassword(password.trim());
      }

      final data = {
        'role': AppConstants.roleCitizen,
        'phone': phone,
        'fullName': fullName,
        'nationalId': nationalId,
        'emergencyContact': emergencyContact,
        'chronicDiseases': chronicDiseases,
        'allergies': allergies,
        'currentMedications': currentMedications,
        'additionalInfo': additionalInfo,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(AppConstants.citizensCollection)
          .doc(uid) // uid guaranteed non-empty
          .set(data);

      final user = AppUser(
        id: uid,
        role: AppConstants.roleCitizen,
        phone: phone,
        fullName: fullName,
        nationalId: nationalId,
        emergencyContact: emergencyContact,
        chronicDiseases: chronicDiseases,
        allergies: allergies,
        currentMedications: currentMedications,
        additionalInfo: additionalInfo,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─── Paramedic: Email + Password ─────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final uc = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = uc.user!.uid;

      final user = await _fetchParamedic(uid);
      if (user == null) {
        await _auth.signOut();
        emit(const AuthError('لم يتم العثور على حساب مسعف بهذا البريد الإلكتروني'));
        return;
      }

      // Save role
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserRole, AppConstants.roleParamedic);
      await prefs.setString(AppConstants.keyUserId, uid);
      await prefs.setString(AppConstants.keyUserEmail, email);

      // Update FCM token
      _updateFcmToken(uid);

      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      // Remove FCM token from Firestore if paramedic
      final state = this.state;
      if (state is AuthAuthenticated && state.user.isParamedic) {
        await _firestore
            .collection(AppConstants.paramedicCollection)
            .doc(state.user.id)
            .update({'fcmToken': FieldValue.delete()});
      }

      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserRole);
      await prefs.remove(AppConstants.keyUserId);
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  // Searches 'paramedics' (app-created) AND 'ambulances' (dashboard-created)
  Future<AppUser?> _fetchParamedic(String uid) async {
    // 1. Try paramedics collection first
    var doc = await _firestore
        .collection(AppConstants.paramedicCollection)
        .doc(uid)
        .get();
    if (doc.exists) return _paramedicFromDoc(uid, doc.data()!);

    // 2. Try ambulances collection (created by dashboard)
    doc = await _firestore
        .collection(AppConstants.ambulancesCollection)
        .doc(uid)
        .get();
    if (doc.exists) {
      final data = Map<String, dynamic>.from(doc.data()!);
      data['role'] = AppConstants.roleParamedic;
      // Mirror to paramedics so future lookups are fast
      await _firestore
          .collection(AppConstants.paramedicCollection)
          .doc(uid)
          .set(data, SetOptions(merge: true));
      return _paramedicFromDoc(uid, data);
    }

    // 3. Query ambulances by email (in case doc ID != uid)
    final email = _auth.currentUser?.email ?? '';
    if (email.isNotEmpty) {
      final q = await _firestore
          .collection(AppConstants.ambulancesCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final data = Map<String, dynamic>.from(q.docs.first.data());
        data['role'] = AppConstants.roleParamedic;
        await _firestore
            .collection(AppConstants.paramedicCollection)
            .doc(uid)
            .set(data, SetOptions(merge: true));
        return _paramedicFromDoc(uid, data);
      }
    }

    return null;
  }


  AppUser _paramedicFromDoc(String uid, Map<String, dynamic> d) {
    // Normalize: dashboard may use different field names than the app
    String? firstName = d['firstName'] as String?;
    String? lastName  = d['lastName']  as String?;

    // Dashboard might store 'name' or 'driverName' as full name
    if ((firstName == null || firstName.isEmpty)) {
      final fullName = (d['name'] ?? d['driverName'] ?? '') as String;
      if (fullName.isNotEmpty) {
        final parts = fullName.split(' ');
        firstName = parts.first;
        lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    // Phone: 'phoneNumber' | 'phone' | 'driverPhone'
    final phone = (d['phoneNumber'] ?? d['phone'] ?? d['driverPhone'] ?? '') as String;

    // Ambulance ID: 'ambulanceId' | 'vehicleId' | 'plateNumber'
    final ambulanceId =
    (d['ambulanceId'] ?? d['vehicleId'] ?? d['plateNumber'] ?? '') as String;

    // License
    final license = (d['licenseNumber'] ?? d['license'] ?? '') as String;
    return AppUser(
        id: uid,
        role: AppConstants.roleParamedic,
        email: (d['email'] ?? '') as String,
        phone: phone,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        licenseNumber: license,
        ambulanceId: ambulanceId,
        status: (d['status'] ?? AppConstants.paramedicAvailable) as String,
        isActive: (d['isActive'] ?? d['active'] ?? true) as bool,
        isAvailable: (d['isAvailable'] ?? d['available'] ?? true) as bool,
        assignedReportId: d['assignedReportId'] as String?,
        assignedReportType: d['assignedReportType'] as String?,
        fcmToken: d['fcmToken'] as String?,
        latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
    );
  }

  AppUser _citizenFromDoc(String uid, Map<String, dynamic> d) {
    return AppUser(
      id: uid,
      role: AppConstants.roleCitizen,
      phone: d['phone'],
      fullName: d['fullName'],
      nationalId: d['nationalId'],
      emergencyContact: d['emergencyContact'],
      chronicDiseases: List<String>.from(d['chronicDiseases'] ?? []),
      allergies: List<String>.from(d['allergies'] ?? []),
      currentMedications: List<String>.from(d['currentMedications'] ?? []),
      additionalInfo: d['additionalInfo'],
    );
  }

  void _updateFcmToken(String paramedicId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore
            .collection(AppConstants.paramedicCollection)
            .doc(paramedicId)
            .update({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          _firestore
              .collection(AppConstants.paramedicCollection)
              .doc(paramedicId)
              .update({'fcmToken': newToken});
        });
      }
    } catch (_) {}
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':      return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':      return 'كلمة المرور غير صحيحة';
      case 'invalid-email':       return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':       return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':   return 'محاولات كثيرة، حاول لاحقاً';
      case 'network-request-failed': return 'تحقق من اتصالك بالإنترنت';
      default:                    return 'فشل تسجيل الدخول';
    }
  }
}
