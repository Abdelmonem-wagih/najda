import '../../../../auth/domain/entities/app_user.dart';
import '../../../../citizen/report/data/models/incident_model.dart';
import '../../domain/repositories/report_details_repository.dart';
import '../datasources/report_details_remote_datasource.dart';

class ReportDetailsRepositoryImpl implements ReportDetailsRepository {
  final ReportDetailsRemoteDataSource remoteDataSource;

  ReportDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<IncidentModel> getReportDetails(String reportId, String reportType) {
    return remoteDataSource.getReportDetails(reportId, reportType);
  }

  @override
  Future<void> updateIncidentStatus(String reportId, String reportType, String status) {
    return remoteDataSource.updateIncidentStatus(reportId, reportType, status);
  }

  @override
  Future<void> updateParamedicStatus(String paramedicId, String status) {
    return remoteDataSource.updateParamedicStatus(paramedicId, status);
  }

  @override
  Future<void> submitMedicalReport({
    required String reportId,
    required String reportType,
    required AppUser paramedic,
    required Map<String, String> answers,
    required String notes,
  }) {
    return remoteDataSource.submitMedicalReport(
      reportId: reportId,
      reportType: reportType,
      paramedic: paramedic,
      answers: answers,
      notes: notes,
    );
  }
}
