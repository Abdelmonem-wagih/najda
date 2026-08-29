import '../entities/first_aid_item.dart';

abstract class FirstAidRepository {
  Future<List<FirstAidItem>> getFirstAidItems();
}
