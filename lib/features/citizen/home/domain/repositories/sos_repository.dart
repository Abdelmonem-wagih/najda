import '../../../../auth/domain/entities/app_user.dart';

abstract class SOSRepository {
  Future<String> triggerSOS({
    required UserModel user,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String address,
    required String shortId,
  });
}
