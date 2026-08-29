import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../citizen/report/data/models/incident_model.dart';

abstract class ReportDetailsState extends Equatable {
  const ReportDetailsState();

  @override
  List<Object?> get props => [];
}

class ReportDetailsInitial extends ReportDetailsState {}

class ReportDetailsLoading extends ReportDetailsState {}

class ReportDetailsLoaded extends ReportDetailsState {
  final IncidentModel report;
  final Position? myPosition;
  final bool isSubmitting;
  final bool showMedicalForm;

  const ReportDetailsLoaded({
    required this.report,
    this.myPosition,
    this.isSubmitting = false,
    this.showMedicalForm = false,
  });

  ReportDetailsLoaded copyWith({
    IncidentModel? report,
    Position? myPosition,
    bool? isSubmitting,
    bool? showMedicalForm,
  }) {
    return ReportDetailsLoaded(
      report: report ?? this.report,
      myPosition: myPosition ?? this.myPosition,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showMedicalForm: showMedicalForm ?? this.showMedicalForm,
    );
  }

  @override
  List<Object?> get props => [report, myPosition, isSubmitting, showMedicalForm];
}

class ReportDetailsError extends ReportDetailsState {
  final String message;

  const ReportDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
