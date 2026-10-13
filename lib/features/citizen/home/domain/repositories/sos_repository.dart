import '../../../../auth/domain/entities/app_user.dart';

abstract class SOSRepository {
  /// [latitude]/[longitude]/[accuracy] are nullable — a report must never be
  /// blocked by GPS failing.
  Future<String> triggerSOS({
    required UserModel user,
    double? latitude,
    double? longitude,
    double? accuracy,
    required String address,
    required String shortId,
  });
}
