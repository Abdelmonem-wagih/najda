import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/services/tracking_service.dart';
import '../../../../auth/domain/entities/app_user.dart';
import '../../domain/repositories/report_details_repository.dart';
import 'report_details_state.dart';

class ReportDetailsCubit extends Cubit<ReportDetailsState> {
  final ReportDetailsRepository _repository;
  StreamSubscription? _posStream;

  ReportDetailsCubit({required ReportDetailsRepository repository})
      : _repository = repository,
        super(ReportDetailsInitial());

  Future<void> loadReport(String reportId, String reportType) async {
    emit(ReportDetailsLoading());
    try {
      final report = await _repository.getReportDetails(reportId, reportType);
      emit(ReportDetailsLoaded(report: report));
      _startLocation();
      
      // If report is already assigned to this ambulance and en_route, ensure tracking is on
      if (report.status == AppConstants.statusEnRoute || report.status == AppConstants.statusArrived) {
        final ambulance = report.assignment?.ambulanceId;
        if (ambulance != null) {
          TrackingService().startTracking(report.assignment?.vehicleId ?? 'unknown', report.id);
        }
      }
    } catch (e) {
      emit(ReportDetailsError(e.toString()));
    }
  }

  void _startLocation() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) await Geolocator.requestPermission();
    
    _posStream?.cancel();
    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15),
    ).listen((p) {
      if (state is ReportDetailsLoaded) {
        emit((state as ReportDetailsLoaded).copyWith(myPosition: p));
      }
    });
  }

  Future<void> updateStatus(String reportId, String reportType, String ambulanceId, String newStatus) async {
    if (state is! ReportDetailsLoaded) return;
    final currentState = state as ReportDetailsLoaded;
    
    emit(currentState.copyWith(isSubmitting: true));
    try {
      await _repository.updateIncidentStatus(reportId, reportType, newStatus);
      await _repository.updateAmbulanceStatus(ambulanceId, newStatus);
      
      final updatedReport = await _repository.getReportDetails(reportId, reportType);
      
      // Handle Tracking Service lifecycle
      if (newStatus == AppConstants.statusEnRoute) {
        TrackingService().startTracking(updatedReport.assignment?.vehicleId ?? 'unknown', reportId);
      } else if (newStatus == AppConstants.statusResolved) {
        TrackingService().stopTracking();
      }

      emit(currentState.copyWith(report: updatedReport, isSubmitting: false));
    } catch (e) {
      emit(currentState.copyWith(isSubmitting: false));
    }
  }


  void toggleMedicalForm(bool show) {
    if (state is ReportDetailsLoaded) {
      emit((state as ReportDetailsLoaded).copyWith(showMedicalForm: show));
    }
  }

  Future<void> submitMedicalReport({
    required String reportId,
    required String reportType,
    required AppUser ambulance,
    required Map<String, String> answers,
    required String notes,
  }) async {
    if (state is! ReportDetailsLoaded) return;
    final currentState = state as ReportDetailsLoaded;

    emit(currentState.copyWith(isSubmitting: true));
    try {
      await _repository.submitMedicalReport(
        reportId: reportId,
        reportType: reportType,
        ambulance: ambulance,
        answers: answers,
        notes: notes,
      );
      
      await updateStatus(reportId, reportType, ambulance.id, AppConstants.statusResolved);
      emit(currentState.copyWith(isSubmitting: false, showMedicalForm: false));
    } catch (e) {
      emit(currentState.copyWith(isSubmitting: false));
    }
  }


  @override
  Future<void> close() {
    _posStream?.cancel();
    return super.close();
  }
}
