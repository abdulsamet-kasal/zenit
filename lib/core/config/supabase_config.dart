import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String projectRef = 'txhpstratzihirwlpixu';
  static const String supabaseUrl = 'https://txhpstratzihirwlpixu.supabase.co';
  
  // Anon Public Key: Supabase Dashboard -> Project Settings -> API sayfasından alınır.
  // Varsayılan geçici değer veya çevre değişkeni:
  static const String defaultAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '***REMOVED***',
  );

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Supabase istemcisini başlatır. Geçersiz anahtar veya ağ yoksa çökmez,
  /// çevrimdışı / yerel depolama modunda devam eder.
  static Future<void> initialize({String? anonKey}) async {
    final keyToUse = anonKey ?? defaultAnonKey;
    if (keyToUse.isEmpty || keyToUse.contains('placeholder')) {
      debugPrint('ℹ️ Supabase anon key henüz girilmedi, offline-first / yerel modda çalışılıyor.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: keyToUse,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _isInitialized = true;
      debugPrint('🚀 Supabase başarıyla bağlandı: $supabaseUrl');
    } catch (e) {
      debugPrint('⚠️ Supabase başlatılırken hata oluştu: $e. Çevrimdışı modda devam ediliyor.');
      _isInitialized = false;
    }
  }
}
