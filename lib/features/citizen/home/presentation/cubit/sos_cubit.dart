import 'dart:async';
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
    // Re-entrancy guard: a second near-simultaneous tap (e.g. two widgets
    // reacting to one physical press) must not fire a duplicate SOS while
    // the first one is still in flight.
    if (state is SOSLoading) return;

    emit(SOSLoading());
    try {
      final pos = await _resolvePosition();
      final address = pos != null
          ? await _resolveAddress(pos.latitude, pos.longitude)
          : '';
      final shortId = 'SOS-${_generateShortId()}';

      // A signal-less device must never hang forever on this write — with
      // Firestore's offline persistence, the underlying SDK Future doesn't
      // resolve from local cache, it just waits for a server ack.
      final docId = await _repository
          .triggerSOS(
            user: user,
            latitude: pos?.latitude,
            longitude: pos?.longitude,
            accuracy: pos?.accuracy,
            address: address,
            shortId: shortId,
          )
          .timeout(const Duration(seconds: 8));

      emit(SOSSuccess(docId, pos?.latitude, pos?.longitude,
          shortId: shortId, address: address));
    } on TimeoutException {
      emit(const SOSError(
        'تعذر إرسال البلاغ — تحقق من اتصال الإنترنت وحاول مرة أخرى',
        isOffline: true,
      ));
    } catch (e) {
      emit(SOSError(_mapError(e)));
    }
  }

  /// Never lets a GPS failure block the report. Tries a fresh high-accuracy
  /// fix first; on denial, disabled location services, or a timeout, falls
  /// back to the last known position; if that's also unavailable, returns
  /// null and the SOS still gets sent with no coordinates (see
  /// SOSRemoteDataSource — latitude/longitude are nullable precisely for
  /// this case).
  Future<Position?> _resolvePosition() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return _lastKnownPositionOrNull();
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _lastKnownPositionOrNull();
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return _lastKnownPositionOrNull();
    }
  }

  Future<Position?> _lastKnownPositionOrNull() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('permission')) {
      return 'يجب السماح بالوصول للموقع لإرسال بلاغ الطوارئ';
    }
    if (e is FormatException || msg.contains('network') || msg.contains('Network')) {
      return 'تعذر الاتصال بالخادم — تحقق من الإنترنت وحاول مرة أخرى';
    }
    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
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
      ].where((s) => s != null && s.isNotEmpty).join('، ');
    } catch (_) {
      return '';
    }
  }
}
