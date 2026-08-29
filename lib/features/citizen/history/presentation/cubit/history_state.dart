import 'package:equatable/equatable.dart';
import '../../../report/data/models/incident_model.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<IncidentModel> reports;

  const HistoryLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
