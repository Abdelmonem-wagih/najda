part of 'sos_cubit.dart';

abstract class SOSState extends Equatable {
  const SOSState();

  @override
  List<Object?> get props => [];
}

class SOSInitial extends SOSState {}

class SOSLoading extends SOSState {}

class SOSSuccess extends SOSState {
  final String reportId;
  final double latitude;
  final double longitude;
  const SOSSuccess(this.reportId, this.latitude, this.longitude);

  @override
  List<Object?> get props => [reportId, latitude, longitude];
}

class SOSError extends SOSState {
  final String message;
  const SOSError(this.message);

  @override
  List<Object?> get props => [message];
}
