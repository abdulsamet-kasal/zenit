import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/anonymous_user.dart';
import 'auth_repository.dart';
import 'mock_auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final MockAuthRepository _fallbackRepo = MockAuthRepository();

  @override
  Future<AnonymousUser> getCurrentUser() async {
    final client = SupabaseConfig.client;
    final prefs = await SharedPreferences.getInstance();
    final localLoggedIn = prefs.getBool('seffaf_is_logged_in') ?? false;
    final localEmail = prefs.getString('seffaf_auth_email');
    final localName = prefs.getString('seffaf_auth_name') ?? 'Vatandaş';
    final localId = prefs.getString('seffaf_auth_user_id') ?? 'usr-local';

    if (client != null) {
      try {
        final session = client.auth.currentSession;
        final user = client.auth.currentUser;

        if (session != null && user != null) {
          final meta = user.userMetadata ?? {};
          final name = (meta['full_name'] as String?) ??
              user.email?.split('@').first ??
              'Vatandaş';
          final phone = (meta['phone'] as String?) ?? user.phone;

          await prefs.setBool('seffaf_is_logged_in', true);
          await prefs.setString('seffaf_auth_user_id', user.id);
          if (user.email != null) {
            await prefs.setString('seffaf_auth_email', user.email!);
          }
          await prefs.setString('seffaf_auth_name', name);

          return AnonymousUser(
            id: user.id,
            displayName: name,
            email: user.email,
            phoneNumber: phone,
            isGuest: false,
            isVerified: true,
            createdComplaintIds: const [],
            followedMunicipalityIds: const [],
          );
        }
      } catch (e) {
        debugPrint('⚠️ Supabase getCurrentUser hatası: $e');
      }
    }

    // Soğuk açılışta veya ağ gecikmesinde SharedPreferences kalıcılığı
    if (localLoggedIn && localEmail != null) {
      return AnonymousUser(
        id: localId,
        displayName: localName,
        email: localEmail,
        isGuest: false,
        isVerified: true,
        createdComplaintIds: const [],
        followedMunicipalityIds: const [],
      );
    }

    return _fallbackRepo.getCurrentUser();
  }

  @override
  Future<AnonymousUser> signInWithEmail(String email, String password) async {
    final client = SupabaseConfig.client;
    final prefs = await SharedPreferences.getInstance();

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

        await prefs.setBool('seffaf_is_logged_in', true);
        await prefs.setString('seffaf_auth_user_id', user.id);
        await prefs.setString('seffaf_auth_email', email);
        await prefs.setString('seffaf_auth_name', name);

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
      debugPrint('⚠️ Supabase signInWithEmail hatası: $e');
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
    final prefs = await SharedPreferences.getInstance();

    if (client == null) {
      return _fallbackRepo.signUpWithEmail(email, password, fullName, phone: phone);
    }

    try {
      final res = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'is_verified': true,
        },
      );

      // Oturumun anında diske yazılması için signIn
      if (res.session == null) {
        try {
          await client.auth.signInWithPassword(email: email, password: password);
        } catch (_) {}
      }

      final user = res.user ?? client.auth.currentUser;
      final userId = user?.id ?? 'usr-${email.hashCode.abs()}';

      // citizen_profiles tablosuna profil oluştur
      try {
        await client.from('citizen_profiles').upsert({
          'user_id': userId,
          'phone_number': phone,
          'is_verified': true,
          'verified_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {}

      await prefs.setBool('seffaf_is_logged_in', true);
      await prefs.setString('seffaf_auth_user_id', userId);
      await prefs.setString('seffaf_auth_email', email);
      await prefs.setString('seffaf_auth_name', fullName);

      final appUser = AnonymousUser(
        id: userId,
        displayName: fullName,
        email: email,
        phoneNumber: phone,
        isGuest: false,
        isVerified: true,
        createdComplaintIds: const [],
      );
      await _fallbackRepo.saveUser(appUser);
      return appUser;
    } catch (e) {
      debugPrint('⚠️ Supabase signUpWithEmail hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    final client = SupabaseConfig.client;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seffaf_is_logged_in', false);
    await prefs.remove('seffaf_auth_user_id');
    await prefs.remove('seffaf_auth_email');
    await prefs.remove('seffaf_auth_name');

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
        await client.auth.resetPasswordForEmail(
          email,
          redirectTo:
              'https://abdulsamet-kasal.github.io/zenit/reset-password.html',
        );
        return;
      } catch (e) {
        debugPrint('⚠️ Supabase resetPassword hatası: $e');
        rethrow;
      }
    }
    await _fallbackRepo.resetPassword(email);
  }

  @override
  Future<void> verifyOtpAndResetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        // 6 haneli OTP kurtarma kodunu doğrula
        await client.auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.recovery,
        );

        // Yeni şifreyi güncelle
        await client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        return;
      } catch (e) {
        debugPrint('⚠️ Supabase verifyOtpAndResetPassword hatası: $e');
        rethrow;
      }
    }
    await _fallbackRepo.verifyOtpAndResetPassword(email, token, newPassword);
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
