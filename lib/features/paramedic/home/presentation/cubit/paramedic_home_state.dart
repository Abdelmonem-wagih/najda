import 'package:equatable/equatable.dart';

import '../../../../citizen/report/data/models/incident_model.dart';

class ParamedicHomeState extends Equatable {
  final List<IncidentModel> assignedReports;
  final List<IncidentModel> emergencyReports;
  final bool isLoading;
  final String? errorMessage;

  const ParamedicHomeState({
    this.assignedReports = const [],
    this.emergencyReports = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ParamedicHomeState copyWith({
    List<IncidentModel>? assignedReports,
    List<IncidentModel>? emergencyReports,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ParamedicHomeState(
      assignedReports: assignedReports ?? this.assignedReports,
      emergencyReports: emergencyReports ?? this.emergencyReports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [assignedReports, emergencyReports, isLoading, errorMessage];
}
