import 'dart:io';
import 'package:najda/features/auth/domain/entities/app_user.dart';

abstract class ReportRepository {
  Future<void> submitReport({
    required AppUser user,
    required double latitude,
    required double longitude,
    required String type,
    String? consciousnessLevel,
    String? injuryLocation,
    String? painLevel,
    File? image,
  });
}
