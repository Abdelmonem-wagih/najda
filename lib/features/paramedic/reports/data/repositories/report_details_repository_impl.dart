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
  Future<void> updateAmbulanceStatus(String ambulanceId, String status) {
    return remoteDataSource.updateAmbulanceStatus(ambulanceId, status);
  }

  @override
  Future<void> submitMedicalReport({
    required String reportId,
    required String reportType,
    required AppUser ambulance,
    required Map<String, String> answers,
    required String notes,
  }) {
    return remoteDataSource.submitMedicalReport(
      reportId: reportId,
      reportType: reportType,
      ambulance: ambulance,
      answers: answers,
      notes: notes,
    );
  }
}
