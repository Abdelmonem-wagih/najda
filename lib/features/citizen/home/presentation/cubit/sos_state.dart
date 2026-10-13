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
  // Nullable — the report was still created even if GPS failed; see
  // SOSCubit._resolvePosition. The UI must handle a null location (e.g. hide
  // "track on map" rather than opening a map centered on nothing).
  final double? latitude;
  final double? longitude;
  final String shortId;
  final String address;

  const SOSSuccess(this.reportId, this.latitude, this.longitude,
      {required this.shortId, required this.address});

  bool get hasLocation => latitude != null && longitude != null;

  @override
  List<Object?> get props => [reportId, latitude, longitude, shortId, address];
}

class SOSError extends SOSState {
  final String message;
  final bool isOffline;
  const SOSError(this.message, {this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}
