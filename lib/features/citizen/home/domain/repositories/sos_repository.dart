import '../../../../auth/domain/entities/app_user.dart';

abstract class SOSRepository {
  Future<String> triggerSOS({
    required AppUser user,
    required double latitude,
    required double longitude,
  });
}
