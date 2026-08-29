import 'dart:io';
import 'package:najda/features/auth/domain/entities/app_user.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitReport({
    required AppUser user,
    required double latitude,
    required double longitude,
    required String type,
    String? consciousnessLevel,
    String? injuryLocation,
    String? painLevel,
    File? image,
  }) async {
    return await remoteDataSource.submitReport(
      user: user,
      latitude: latitude,
      longitude: longitude,
      type: type,
      consciousnessLevel: consciousnessLevel,
      injuryLocation: injuryLocation,
      painLevel: painLevel,
      image: image,
    );
  }
}
