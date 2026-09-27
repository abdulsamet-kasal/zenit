import '../models/anonymous_user.dart';

abstract class AuthRepository {
  Future<AnonymousUser> getCurrentUser();

  Future<void> saveUser(AnonymousUser user);

  Future<void> clearUserData();

  Future<void> toggleFollowMunicipality(String municipalityId);

  Future<void> verifyUser(String phoneNumber);

  Future<void> addCreatedComplaintId(String complaintId);

  Future<AnonymousUser> signInWithEmail(String email, String password);

  Future<AnonymousUser> signUpWithEmail(
    String email,
    String password,
    String fullName, {
    String? phone,
  });

  Future<void> signOut();

  Future<void> resetPassword(String email);
}

