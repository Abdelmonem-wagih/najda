import 'package:najda/features/auth/domain/entities/app_user.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/repositories/report_repository.dart';
import '../../domain/entities/accident_type.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository repository;

  ReportCubit({required this.repository}) : super(const ReportState());

  void setType(AccidentType type) {
    emit(state.copyWith(type: type, step: 1));
  }

  void setConsciousness(String? value) {
    emit(state.copyWith(consciousness: value));
  }

  void setInjuryLocation(String? value) {
    emit(state.copyWith(injuryLocation: value));
  }

  void setPainLevel(String? value) {
    emit(state.copyWith(painLevel: value));
  }

  void nextStep() {
    emit(state.copyWith(step: state.step + 1));
  }

  void previousStep() {
    if (state.step > 0) {
      emit(state.copyWith(step: state.step - 1));
    }
  }

  Future<void> pickImage() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (picked != null) {
      emit(state.copyWith(image: File(picked.path)));
    }
  }

  void removeImage() {
    emit(state.copyWith(image: null));
  }

  Future<void> submitReport({
    required AppUser user,
  }) async {
    if (state.type == null) return;

    emit(state.copyWith(status: ReportStatus.loading));

    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await repository.submitReport(
        user: user,
        latitude: pos.latitude,
        longitude: pos.longitude,
        type: state.type!.name,
        consciousnessLevel: state.consciousness,
        injuryLocation: state.injuryLocation,
        painLevel: state.painLevel,
        image: state.image,
      );

      emit(state.copyWith(status: ReportStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: 'فشل إرسال البلاغ',
      ));
    }
  }
}
