import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/repositories/sos_repository.dart';
import '../../../../auth/domain/entities/app_user.dart';

part 'sos_state.dart';

class SOSCubit extends Cubit<SOSState> {
  final SOSRepository _repository;

  SOSCubit({required SOSRepository repository})
      : _repository = repository,
        super(SOSInitial());

  Future<void> triggerSOS(UserModel user) async {
    emit(SOSLoading());
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final address = await _resolveAddress(pos.latitude, pos.longitude);
      final shortId = 'SOS-${_generateShortId()}';

      final docId = await _repository.triggerSOS(
        user: user,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        address: address,
        shortId: shortId,
      );

      emit(SOSSuccess(docId, pos.latitude, pos.longitude, shortId: shortId, address: address));
    } catch (e) {
      emit(SOSError(e.toString()));
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
      return [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((s) => s != null && s!.isNotEmpty).join('، ');
    } catch (_) {
      return '';
    }
  }
}
