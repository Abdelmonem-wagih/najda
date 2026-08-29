import '../../../../auth/domain/entities/app_user.dart';
import '../../../../citizen/report/data/models/incident_model.dart';

abstract class ReportDetailsRepository {
  Future<IncidentModel> getReportDetails(String reportId, String reportType);
  Future<void> updateIncidentStatus(String reportId, String reportType, String status);
  Future<void> updateParamedicStatus(String paramedicId, String status);
  Future<void> submitMedicalReport({
    required String reportId,
    required String reportType,
    required AppUser paramedic,
    required Map<String, String> answers,
    required String notes,
  });
}
