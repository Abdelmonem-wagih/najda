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
  final String shortId;
  final String address;

  const SOSSuccess(this.reportId, this.latitude, this.longitude,
      {required this.shortId, required this.address});

  @override
  List<Object?> get props => [reportId, latitude, longitude, shortId, address];
}

class SOSError extends SOSState {
  final String message;
  const SOSError(this.message);

  @override
  List<Object?> get props => [message];
}
