import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import '../models/anonymous_user.dart';
import 'auth_repository.dart';
import 'mock_auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final MockAuthRepository _fallbackRepo = MockAuthRepository();

  @override
  Future<AnonymousUser> getCurrentUser() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getCurrentUser();
    }

    try {
      final session = client.auth.currentSession;
      final user = client.auth.currentUser;

      if (session != null && user != null) {
        final meta = user.userMetadata ?? {};
        final name = (meta['full_name'] as String?) ??
            user.email?.split('@').first ??
            'Vatandaş';
        final phone = (meta['phone'] as String?) ?? user.phone;

        return AnonymousUser(
          id: user.id,
          displayName: name,
          email: user.email,
          phoneNumber: phone,
          isGuest: false,
          isVerified: user.phone != null || (meta['is_verified'] == true),
          createdComplaintIds: const [],
          followedMunicipalityIds: const [],
        );
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getCurrentUser hatası: $e');
    }

    return _fallbackRepo.getCurrentUser();
  }

  @override
  Future<AnonymousUser> signInWithEmail(String email, String password) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.signInWithEmail(email, password);
    }

    try {
      final res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        final meta = user.userMetadata ?? {};
        final name = (meta['full_name'] as String?) ??
            user.email?.split('@').first ??
            'Vatandaş';

        final appUser = AnonymousUser(
          id: user.id,
          displayName: name,
          email: user.email,
          phoneNumber: (meta['phone'] as String?) ?? user.phone,
          isGuest: false,
          isVerified: true,
          createdComplaintIds: const [],
        );
        await _fallbackRepo.saveUser(appUser);
        return appUser;
      }
    } catch (e) {
      debugPrint('⚠️ Supabase signInWithEmail hatası: $e. Mock auth deneniyor.');
      rethrow;
    }

    return _fallbackRepo.signInWithEmail(email, password);
  }

  @override
  Future<AnonymousUser> signUpWithEmail(
    String email,
    String password,
    String fullName, {
    String? phone,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.signUpWithEmail(email, password, fullName, phone: phone);
    }

    try {
      final res = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': ?phone,
          'is_verified': true,
        },
      );

      final user = res.user;
      if (user != null) {
        // citizen_profiles tablosuna profil oluştur
        try {
          await client.from('citizen_profiles').upsert({
            'user_id': user.id,
            'phone_number': phone,
            'is_verified': true,
            'verified_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (_) {}

        final appUser = AnonymousUser(
          id: user.id,
          displayName: fullName,
          email: email,
          phoneNumber: phone,
          isGuest: false,
          isVerified: true,
          createdComplaintIds: const [],
        );
        await _fallbackRepo.saveUser(appUser);
        return appUser;
      }
    } catch (e) {
      debugPrint('⚠️ Supabase signUpWithEmail hatası: $e');
      rethrow;
    }

    return _fallbackRepo.signUpWithEmail(email, password, fullName, phone: phone);
  }

  @override
  Future<void> signOut() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('⚠️ Supabase signOut hatası: $e');
      }
    }
    await _fallbackRepo.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.resetPasswordForEmail(email);
        return;
      } catch (e) {
        debugPrint('⚠️ Supabase resetPassword hatası: $e');
        rethrow;
      }
    }
    await _fallbackRepo.resetPassword(email);
  }

  @override
  Future<void> saveUser(AnonymousUser user) async {
    await _fallbackRepo.saveUser(user);
  }

  @override
  Future<void> clearUserData() async {
    await _fallbackRepo.clearUserData();
  }

  @override
  Future<void> toggleFollowMunicipality(String municipalityId) async {
    await _fallbackRepo.toggleFollowMunicipality(municipalityId);
  }

  @override
  Future<void> verifyUser(String phoneNumber) async {
    await _fallbackRepo.verifyUser(phoneNumber);
  }

  @override
  Future<void> addCreatedComplaintId(String complaintId) async {
    await _fallbackRepo.addCreatedComplaintId(complaintId);
  }
}
