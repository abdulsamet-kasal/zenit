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
    final isVerified = prefs.getBool(AppConstants.keyUserVerified) ?? false;
    final phone = prefs.getString(AppConstants.keyUserPhone);
    final followed =
        prefs.getStringList(AppConstants.keyFollowedMunicipalities) ?? [];

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
      isVerified: isVerified,
      phoneNumber: phone,
      followedMunicipalityIds: followed,
    );
  }

  @override
  Future<void> saveUser(AnonymousUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyGuestUserId, user.id);
    await prefs.setString(AppConstants.keyGuestUserName, user.displayName);
    await prefs.setStringList('seffaf_created_complaints', user.createdComplaintIds);
    await prefs.setBool(AppConstants.keyUserVerified, user.isVerified);
    if (user.phoneNumber != null) {
      await prefs.setString(AppConstants.keyUserPhone, user.phoneNumber!);
    } else {
      await prefs.remove(AppConstants.keyUserPhone);
    }
    await prefs.setStringList(
        AppConstants.keyFollowedMunicipalities, user.followedMunicipalityIds);
  }

  @override
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyGuestUserId);
    await prefs.remove(AppConstants.keyGuestUserName);
    await prefs.remove('seffaf_created_complaints');
    await prefs.remove(AppConstants.keyUserVerified);
    await prefs.remove(AppConstants.keyUserPhone);
    await prefs.remove(AppConstants.keyFollowedMunicipalities);
    await prefs.remove(AppConstants.keyCustomComplaints);
    await prefs.remove(AppConstants.keyLikedComplaints);
    await prefs.remove(AppConstants.keyConfirmedComplaints);
    await prefs.remove(AppConstants.keyComplaintRatings);
  }

  @override
  Future<void> toggleFollowMunicipality(String municipalityId) async {
    final prefs = await SharedPreferences.getInstance();
    final followed =
        prefs.getStringList(AppConstants.keyFollowedMunicipalities) ?? [];
    if (followed.contains(municipalityId)) {
      followed.remove(municipalityId);
    } else {
      followed.add(municipalityId);
    }
    await prefs.setStringList(
        AppConstants.keyFollowedMunicipalities, followed);
  }

  @override
  Future<void> verifyUser(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyUserVerified, true);
    await prefs.setString(AppConstants.keyUserPhone, phoneNumber);
    final currentName = prefs.getString(AppConstants.keyGuestUserName) ?? 'Vatandaş';
    if (!currentName.contains('Doğrulanmış')) {
      final updatedName = currentName.replaceFirst('Misafir', 'Doğrulanmış');
      await prefs.setString(AppConstants.keyGuestUserName, updatedName);
    }
  }

  @override
  Future<void> addCreatedComplaintId(String complaintId) async {
    final prefs = await SharedPreferences.getInstance();
    final createdIds = prefs.getStringList('seffaf_created_complaints') ?? [];
    if (!createdIds.contains(complaintId)) {
      createdIds.insert(0, complaintId);
      await prefs.setStringList('seffaf_created_complaints', createdIds);
    }
  }
}

