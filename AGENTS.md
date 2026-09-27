# 🧠 AGENTS.md — Proje Hafızası ve Geliştirici Kılavuzu

Bu dosya, gelecekteki yapay zeka asistanlarının (Antigravity, Cursor, Claude Code vb.) ve geliştiricilerin bu projenin geçmişini, mimarisini ve sistem kısıtlarını anında hatırlaması için hazırlanmıştır.

---

## 📌 Proje Özeti
- **Proje Adı:** ŞEFFAF (Zenit)
- **Açıklama:** Vatandaşların belediye aksaklıklarını fotoğraf ve GPS ile bildirdiği, belediyelerin çözüm hızına göre 0-100 arası otomatik puanlandığı açık kaynaklı Flutter mobil uygulaması.
- **GitHub Deposu:** [https://github.com/abdulsamet-kasal/zenit](https://github.com/abdulsamet-kasal/zenit)
- **Geliştirici:** Abdulsamet Kasal (<abdulskasal@gmail.com>)

---

## 💻 Sistem ve Donanım Kısıtları (ÖNEMLİ)
- **İşletim Sistemi:** CachyOS Linux (Arch tabanlı)
- **İşlemci:** AMD Ryzen 3 5300U (4C/8T)
- **RAM:** 8 GB (Kullanılabilir: ~3.5 - 4 GB)
- **Kritik Gradle Kuralı:** Sistemde OOM (Out Of Memory) çökmesini engellemek için `android/gradle.properties` içinde JVM sınırı kesinlikle **maksimum 1.5 GB** (`-Xmx1536M -XX:MaxMetaspaceSize=384M -XX:ReservedCodeCacheSize=256m -XX:+UseG1GC`) tutulmalıdır.
- **Hazır Test Emülatörü:**
  - AVD Adı: `Seffaf_Pixel_Fast` (API 30, 720x1280, 1536M RAM, KVM GPU host hızlandırmalı, snapshot destekli).
  - Başlatma komutu: `$HOME/Android/Sdk/emulator/emulator -avd Seffaf_Pixel_Fast`
  - Flutter çalıştırma: `flutter run -d emulator-5554`

---

## 🏗️ Mimari ve Teknoloji Yığını
- **Flutter:** 3.47.5 / Dart 3.13.4
- **State Management:** `flutter_riverpod` (v3 `Notifier` ve `NotifierProvider` kullanılır; deprecated `StateNotifier` kullanılmaz).
- **Harita:** Google Maps yerine `flutter_map` (OpenStreetMap) + `flutter_map_marker_cluster`.
- **Grafik:** `fl_chart` (90 günlük puan trend çizgisi).
- **Puanlama Algoritması:** `lib/core/utils/scoring_calculator.dart` (%40 Çözüm Oranı, %30 SLA Uyumu, %20 Memnuniyet, %10 Hız).
- **Yerel Depolama:** `shared_preferences` (Misafir UUID, tema ve çevrimdışı taslaklar).

---

## 🚦 Tamamlanan Aşamalar (Faz 1 - Faz 10)
1. **Faz 1:** Temiz Mimari (`core/`, `data/`, `features/`, `shared/`), veri modelleri, SLA ve puanlama motoru.
2. **Faz 2:** Mock veri setleri (Edirne, Keşan, Uzunköprü, Çorlu, Lüleburgaz) ve repository katmanı.
3. **Faz 3:** Onboarding ve Misafir Kullanıcı kimliği (UUID).
4. **Faz 4:** 5 sekmeli ana navigasyon ve Instagram tarzı Şikayet Akışı (Feed).
5. **Faz 5:** OpenStreetMap haritası, kümeleme (clustering) ve pin bottom sheet önizlemesi.
6. **Faz 6:** 4 adımlı Şikayet Oluşturma Sihirbazı, ray-casting ile otomatik belediye tespiti ve offline kuyruk.
7. **Faz 7:** Şikayet Detay ekranı, çoklu görsel galerisi, SLA zaman çizelgesi, itiraz ve yorum akışı.
8. **Faz 8:** Belediye Karnesi profili (0-100 puan göstergesi, fl_chart trendi) ve Sıralama (Leaderboard) ekranı.
9. **Faz 9 (Kalıcılık, Çözüm Kanıtı, Doğrulama & UX İleri Geliştirmeler):**
   - **Kalıcı Yerel Depolama:** SharedPreferences kalıcılığı.
   - **Otomatik Çevrimdışı Eşitleme (Offline Sync Engine):** `connectivity_plus` dinleyicisi.
   - **Çözüm Kanıtı (Önce / Sonra):** Vatandaş bildirimi ve belediye çözüm fotoğrafı karşılaştırması.
   - **Resmi Belediye Yanıtı & Vatandaş Memnuniyet Anketi:** 1-5 yıldız oylama.
   - **Tam Ekran Görsel Görüntüleyici:** Pinch-to-zoom tam ekran modu.
   - **SMS OTP Vatandaş Doğrulaması:** 6 haneli SMS akışı ve rozet.
10. **Faz 10 (Tüm Türkiye Verisi & Supabase Bulut Backend Entegrasyonu):**
   - **Türkiye Geneli 81 İl ve 972 İlçe:** `assets/data/turkey_provinces.json` ve `assets/data/turkey_municipalities.json` veri setleri oluşturuldu. Tüm ilçe merkez koordinatları, şeffaflık puanları, kategori performansları ve sınır poligonları hazırlandı.
   - **Ülke Geneli GPS Belediye Tespiti:** `GeoUtils` 972 ilçenin tamamını dinamik olarak yükleyerek Ray-Casting poligon ve Haversine centroid mesafe formülüyle Türkiye'nin her noktasından anında ilçe belediyesi tespit edebilir hale getirildi.
   - **Dinamik Liderlik Sıralaması:** `LeaderboardScreen` hardcoded iller yerine 81 ilin tamamını dinamik filtreleme ve anlık arama desteğiyle sunar hale getirildi.
   - **Supabase Entegrasyonu (Proje Ref: `txhpstratzihirwlpixu`):**
     - `supabase_flutter: ^2.8.0` bağımlılığı eklendi.
     - `supabase/config.toml` proje referansı `txhpstratzihirwlpixu` olarak güncellendi.
     - `supabase/migrations/20260927000000_create_seffaf_schema.sql`: `municipalities`, `complaints`, `complaint_likes`, `complaint_confirmations`, `complaint_comments`, `complaint_disputes`, `citizen_profiles` tabloları, RLS politikaları ve trigger fonksiyonları hazırlandı.
     - `supabase/seed.sql`: 972 belediye ve başlangıç şikayetlerinin SQL aktarımı oluşturuldu.
     - `SupabaseConfig`: Güvenli başlatma (`publishableKey`), ağ veya anahtar yokluğunda çökmeden yerel moda geçiş.
     - `SupabaseComplaintRepository` & `SupabaseMunicipalityRepository`: Canlı Supabase veri akışı ve kesintisiz Offline-First / SharedPreferences fallback mimarisi.
     - MCP Supabase konfigürasyonu (`~/.gemini/antigravity/mcp_config.json`) ve `supabase/agent-skills` entegre edildi.

---

11. **Faz 11 (Kullanıcı Giriş & Kayıt Mimarisi, Supabase Auth ve E-Devlet Kaldırımı):**
   - **E-Devlet Kaldırımı:** E-Devlet bağımlılığı, referansları veya gereksinimleri tamamen ortadan kaldırıldı; platform tamamen bağımsız vatandaş odaklı kimlik modeline kavuşturuldu.
   - **Giriş Yap Ekranı (`LoginScreen`):** E-posta ve şifre ile giriş, form validasyonu, şifre sıfırlama talebi, "Misafir Olarak Devam Et" seçeneği ve "Kayıt Ol" geçişi.
   - **Kayıt Ol Ekranı (`RegisterScreen`):** Ad Soyad, E-posta, Telefon (opsiyonel), Şifre ve Şifre Tekrar alanları, hata yönetimi ve doğrudan oturum başlatma.
   - **Supabase Auth Entegrasyonu (`SupabaseAuthRepository`):** Canlı Supabase `client.auth` üzerinden oturum açma, kayıt oluşturma, şifre sıfırlama ve profil senkronizasyonu; ağ yokken yerel fallback desteği.
   - **Profil Ekranı Güncellemesi:** Giriş yapmış vatandaşlar için e-posta, aktif rozet ve "Hesaptan Çıkış Yap" butonu; misafirler için "Giriş / Kayıt" davet kartı.
   - **Onboarding Son Ekranı:** "Giriş Yap / Kayıt Ol" ve "Misafir Olarak Keşfet" ikili yönlendirmesi.
   - **Widget Testleri:** `test/auth_screens_test.dart` ile form doğrulama ve render testleri (%100 başarı).

---

## 🎯 Gelecek Faz (Faz 12 - Canlı Dağıtım ve Yayın Öncesi)
- Supabase Storage Bucket'a fotoğraf yükleme (`complaint-photos` bucket).
- Canlı SMS sağlayıcısı (Netgsm / Twilio) ile harici SMS gönderimi.

