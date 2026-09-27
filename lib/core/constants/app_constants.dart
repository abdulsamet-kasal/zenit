class AppConstants {
  static const String appName = 'Şeffaf';
  static const String appTagline = 'Belediye Şeffaflık ve Sorun Takip Platformu';

  // Harita Yapılandırması (OSM Tile Server - Üretimde değiştirilebilir config)
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'tr.gov.seffaf.app/1.0';

  // Varsayılan Merkez Konum (Edirne Merkez)
  static const double defaultLatitude = 41.6771;
  static const double defaultLongitude = 26.5557;
  static const double defaultZoom = 13.5;

  // Rate Limiting ve Validasyon Kuralları
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;
  static const int maxPhotosCount = 3;
  static const int maxComplaintsPerDay = 5;

  // Puanlama Algoritması Parametreleri
  static const double baseMunicipalityScore = 70.0;
  static const int recencyDaysWindow = 90;
  static const double recencyMultiplier = 1.5;

  // Local Storage Keys
  static const String keyGuestUserId = 'seffaf_guest_user_id';
  static const String keyGuestUserName = 'seffaf_guest_user_name';
  static const String keyOnboardingCompleted = 'seffaf_onboarding_completed';
  static const String keyThemeMode = 'seffaf_theme_mode';
  static const String keyDraftComplaints = 'seffaf_draft_complaints';
  static const String keyLikedComplaints = 'seffaf_liked_complaints';
  static const String keyConfirmedComplaints = 'seffaf_confirmed_complaints';
  static const String keyCustomComplaints = 'seffaf_custom_complaints';
  static const String keyUserVerified = 'seffaf_user_verified';
  static const String keyUserPhone = 'seffaf_user_phone';
  static const String keyFollowedMunicipalities = 'seffaf_followed_municipalities';
  static const String keyComplaintRatings = 'seffaf_complaint_ratings';
}

