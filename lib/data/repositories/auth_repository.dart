import '../models/anonymous_user.dart';

abstract class AuthRepository {
  Future<AnonymousUser> getCurrentUser();

  Future<void> saveUser(AnonymousUser user);

  Future<void> clearUserData();
}
