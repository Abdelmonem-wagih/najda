import 'package:najda/features/auth/domain/entities/app_user.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
    required UserModel user,
  }) async {
    if (state.type == null) return;

    emit(state.copyWith(status: ReportStatus.loading));

    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final address = await _resolveAddress(pos.latitude, pos.longitude);
      final shortId = 'RPT-${_generateShortId()}';

      await repository.submitReport(
        user: user,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        address: address,
        shortId: shortId,
        type: state.type!.name,
        consciousnessLevel: state.consciousness,
        injuryLocation: state.injuryLocation,
        painLevel: state.painLevel,
        image: state.image,
      );

      emit(state.copyWith(status: ReportStatus.success, shortId: shortId));
    } catch (e) {
      emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: 'فشل إرسال البلاغ',
      ));
    }
  }

  String _generateShortId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<String> _resolveAddress(double lat, double lng) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return '';
      final p = marks.first;
      return [p.street, p.subLocality, p.locality, p.administrativeArea]
          .where((s) => s != null && s!.isNotEmpty)
          .join('، ');
    } catch (_) {
      return '';
    }
  }
}
