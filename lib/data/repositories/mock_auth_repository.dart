import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/anonymous_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<AnonymousUser> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(AppConstants.keyGuestUserId);
    String? name = prefs.getString(AppConstants.keyGuestUserName);

    if (id == null) {
      id = const Uuid().v4();
      final randomNum = 1000 + (id.hashCode.abs() % 9000);
      name = 'Misafir Vatandaş #$randomNum';

      await prefs.setString(AppConstants.keyGuestUserId, id);
      await prefs.setString(AppConstants.keyGuestUserName, name);
    }

    final createdIds = prefs.getStringList('seffaf_created_complaints') ?? [];

    return AnonymousUser(
      id: id,
      displayName: name ?? 'Misafir Vatandaş',
      createdComplaintIds: createdIds,
    );
  }

  @override
  Future<void> saveUser(AnonymousUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyGuestUserId, user.id);
    await prefs.setString(AppConstants.keyGuestUserName, user.displayName);
    await prefs.setStringList('seffaf_created_complaints', user.createdComplaintIds);
  }

  @override
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyGuestUserId);
    await prefs.remove(AppConstants.keyGuestUserName);
    await prefs.remove('seffaf_created_complaints');
  }
}
