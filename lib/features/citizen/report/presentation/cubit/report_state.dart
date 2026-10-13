import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/accident_type.dart';

enum ReportStatus { initial, loading, success, error }

class ReportState extends Equatable {
  final int step;
  final AccidentType? type;
  final String? consciousness;
  final String? injuryLocation;
  final String? painLevel;
  final File? image;
  final ReportStatus status;
  final String? errorMessage;
  final String? shortId;

  const ReportState({
    this.step = 0,
    this.type,
    this.consciousness,
    this.injuryLocation,
    this.painLevel,
    this.image,
    this.status = ReportStatus.initial,
    this.errorMessage,
    this.shortId,
  });

  ReportState copyWith({
    int? step,
    AccidentType? type,
    String? consciousness,
    String? injuryLocation,
    String? painLevel,
    File? image,
    ReportStatus? status,
    String? errorMessage,
    String? shortId,
  }) {
    return ReportState(
      step: step ?? this.step,
      type: type ?? this.type,
      consciousness: consciousness ?? this.consciousness,
      injuryLocation: injuryLocation ?? this.injuryLocation,
      painLevel: painLevel ?? this.painLevel,
      image: image ?? this.image,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      shortId: shortId ?? this.shortId,
    );
  }

  @override
  List<Object?> get props => [
        step,
        type,
        consciousness,
        injuryLocation,
        painLevel,
        image,
        status,
        errorMessage,
        shortId,
      ];
}
