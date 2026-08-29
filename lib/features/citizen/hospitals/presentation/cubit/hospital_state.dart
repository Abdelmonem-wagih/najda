import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/hospital.dart';

abstract class HospitalState extends Equatable {
  const HospitalState();

  @override
  List<Object?> get props => [];
}

class HospitalInitial extends HospitalState {}

class HospitalLoading extends HospitalState {}

class HospitalLoaded extends HospitalState {
  final List<Hospital> hospitals;
  final Position position;

  const HospitalLoaded({required this.hospitals, required this.position});

  @override
  List<Object?> get props => [hospitals, position];
}

class HospitalError extends HospitalState {
  final String message;

  const HospitalError(this.message);

  @override
  List<Object?> get props => [message];
}
