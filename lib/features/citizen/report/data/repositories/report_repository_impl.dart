import 'dart:io';
import 'package:najda/features/auth/domain/entities/app_user.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    return await remoteDataSource.submitReport(
      user: user,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
      shortId: shortId,
      type: type,
      consciousnessLevel: consciousnessLevel,
      injuryLocation: injuryLocation,
      painLevel: painLevel,
      image: image,
    );
  }
}
