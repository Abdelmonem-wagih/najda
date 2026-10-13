import 'dart:io';
import 'package:najda/features/auth/domain/entities/app_user.dart';

abstract class ReportRepository {
  Future<String> submitReport({
    required UserModel user,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String address,
    required String shortId,
    required String type,
    String? consciousnessLevel,
    String? injuryLocation,
    String? painLevel,
    File? image,
  });
}
