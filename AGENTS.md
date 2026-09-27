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
   - **Giriş Yap Ekranı (`LoginScreen`):** E-posta ve şifre ile giriş, form validasyonu, şifre sıfırlama talebi ve "Kayıt Ol" geçişi.
   - **Kayıt Ol Ekranı (`RegisterScreen`):** Ad Soyad, E-posta, Telefon (opsiyonel), Şifre ve Şifre Tekrar alanları, hata yönetimi ve doğrudan oturum başlatma.
   - **Supabase Auth Entegrasyonu (`SupabaseAuthRepository`):** Canlı Supabase `client.auth` üzerinden oturum açma, kayıt oluşturma, şifre sıfırlama ve profil senkronizasyonu; ağ yokken yerel fallback desteği.
   - **Profil Ekranı Güncellemesi:** Giriş yapmış vatandaşlar için e-posta, aktif rozet ve "Hesaptan Çıkış Yap" butonu.
   - **Widget Testleri:** `test/auth_screens_test.dart` ile form doğrulama ve render testleri (%100 başarı).

---

12. **Faz 12 (Zorunlu Kayıt & Giriş, Hesaptan Çıkış Akışı, Supabase Storage & SeffafImage, Dark Mode Kontrastı):**
   - **Misafir Kullanıcı Tamamen Kaldırıldı:** Kayıt ve giriş işlemi zorunlu kılındı. `main.dart` açılışında oturum açılmamışsa doğrudan `LoginScreen(isModal: false)`'a yönlendirilir; `OnboardingScreen` ve `LoginScreen` içerisindeki tüm misafir mod seçenekleri arındırıldı.
   - **Hesaptan Çıkış (Sign Out) Akışı:** `ProfileScreen` AppBar'ına ve ayarlar listesine belirgin "Hesaptan Çıkış Yap" eklendi; onay sonrası `authRepository.signOut()` çağrılarak oturum sıfırlanıp login ekranına temiz yönlendirme sağlandı.
   - **Fotoğraf Yükleme & Görüntüleme Düzeltmesi (Supabase Storage):**
     - Supabase canlı veritabanında `complaint-photos` storage bucket'ı oluşturuldu ve RLS politikaları uygulandı (`20260927000001_create_storage_and_auth_cleanup.sql`).
     - `SupabaseComplaintRepository`: Şikayet oluştururken yerel fotoğraflar `client.storage.from('complaint-photos').uploadBinary(...)` ile Supabase Storage'a yüklenip public URL'leri veritabanına kaydedilir hale getirildi.
     - `SeffafImage` (`lib/shared/widgets/seffaf_image.dart`): Hem internet URL'leri (`CachedNetworkImage`), hem yerel dosya yolları (`Image.file`), hem de yerel asset'leri (`Image.asset`) dark-mode uyumlu placeholder ve fallback ile sorunsuz render eden evrensel bileşen geliştirildi ve akış (`ComplaintCard`), detay (`ComplaintDetailScreen`), tam ekran görüntüleyici (`FullScreenImageViewer`), harita önizlemesi (`MapScreen`) ve şikayet sihirbazı Step 4 özetine entegre edildi.
   - **Dark Mode Kontrast ve Tipografi İyileştirmeleri:**
     - `AppTheme`: Hem `lightTheme` hem `darkTheme` için tam kapsamlı `textTheme` ve `chipTheme` tanımları eklendi.
     - `FeedScreen`, `LeaderboardScreen`, `MapScreen`, `ReportCreationScreen`, `ComplaintDetailScreen`, `LoginScreen` ve `RegisterScreen` ekranlarındaki siyah kalan tüm metinler, filtre çipleri ve kenarlıklar dark mode uyumlu dinamik renklere dönüştürüldü.
   - **Tam Test Kapsamı:** Tüm 20 birim, widget ve mimari testi %100 başarıyla geçti.

---

13. **Faz 13 (Oturum Kalıcılığı, Supabase Auto-Confirm, Çift Geri Tuşu, Uygulama İçi OTP Şifre Sıfırlama & RAM Optimizasyonu):**
   - **Otomatik E-posta Onay Trigger'ı (Supabase Auto-Confirm):** Supabase'de e-posta onay zorunluluğundan kaynaklanan ve şifre doğru olsa dahi "Invalid login credentials" hatasına yol açan engel kökten çözüldü (`20260928000000_auto_confirm_users.sql`). Canlı veritabanındaki tüm kullanıcılar onaylandı ve yeni kayıt olan her kullanıcı için anında onaylama trigger'ı kuruldu.
   - **Oturum Kalıcılığı (Session Persistence):** `SupabaseAuthRepository` oturum açma ve kayıt işlemlerinde bilgileri güvenli SharedPreferences alanlarına (`seffaf_is_logged_in`, `seffaf_auth_email`, `seffaf_auth_user_id`) kaydeder. Uygulama soğuk açılışında (cold start) veya internet gecikmelerinde kullanıcı asla oturumdan düşürülmez.
   - **Gelişmiş Geri Tuşu Yönetimi (Double Back to Exit & Anasayfaya Dönüş):** `MainNavScreen`'e modern `PopScope` entegre edildi. Kullanıcı Harita, Belediyeler veya Profil sekmesindeyken geri tuşuna basarsa anında Akış (Anasayfa) sekmesine döner; Anasayfadayken 2 saniye içinde iki kez geri tuşuna basarsa uygulama güvenle kapanır, ilk basışta bilgilendirici SnackBar uyarısı verilir.
   - **Uygulama İçi 6 Haneli OTP ile Şifre Sıfırlama (`localhost:3000` Çözümü):** Supabase'in varsayılan e-posta linkindeki `localhost:3000` yönlendirme sorunu yerine kullanıcıya tarayıcı açtırmayan 2 adımlı uygulama içi diyalog geliştirildi. Kullanıcı e-postasına gelen 6 haneli doğrulama kodunu ve yeni şifresini doğrudan uygulama içinde girerek `verifyOTP(..., type: OtpType.recovery)` + `updateUser` ile şifresini sıfırlar.
   - **Görsel & Bellek Optimizasyonları:** `SeffafImage` içine `memCacheWidth`, `maxWidthDiskCache`, `maxHeightDiskCache` ve `Image.file` için bellek sınırlamaları eklendi; RAM şişmesi ve düşük bellekli cihazlarda OOM riski önlendi.
   - **Sürüm Güncellemesi:** Uygulama sürümü `1.2.0+3` olarak güncellendi.
   - **Test & Analiz:** `flutter analyze` 0 hata ile tamamlandı, 20 testin 20'si de başarıyla geçti.

---

14. **Faz 14 (Detay Görsel Düzeltmesi, Kullanıcı Şikayet Silme & 429 Rate Limit Yönetimi):**
   - **Şikayet Detayı Görsel Yüklenmeme Hatası Kökten Çözüldü:** `ComplaintDetailScreen` içinde görsel genişliği `double.infinity` verildiğinde `SeffafImage` içerisindeki bellek boyutlandırmasında `double.infinity.toInt()` çağrısının `UnsupportedError` fırlatması ve görselin render edilememesi engellendi; `width.isFinite` denetimi getirilerek hem detayda hem akışta fotoğrafların kusursuz görüntülenmesi sağlandı.
   - **Kullanıcı Şikayet Silme Özelliği:** Şikayeti paylaşan kullanıcının kendi şikayetini silebilmesi için Supabase üzerinde `public delete access for complaints` RLS politikası oluşturulup canlıya pushlandı (`20260928000001_add_complaint_delete_policy.sql`). `ComplaintDetailScreen` AppBar'ına silme aksiyonu, çift onay diyaloğu eklendi; Storage üzerindeki görseller ve bağlı yorumlar/beğeniler temizlenerek Riverpod akışından anında kaldırılması sağlandı.
   - **AuthApiException 429 (Rate Limit) Yönetimi:** Supabase e-posta gönderim limitine ulaşıldığında kullanıcıya net ve anlaşılır rehberlik sunuldu; ayrıca 60 saniye beklemek istemeyen veya daha önceden e-posta almış kullanıcılar için Step 1'e *"Daha önce kod aldım, şifre belirleyeceğim"* doğrudan geçiş butonu eklendi.
   - **Sürüm Güncellemesi:** Uygulama sürümü `1.2.1+4` olarak güncellendi.
   - **Test & Analiz:** `flutter analyze` 0 hata ile tamamlandı, 20 testin 20'si de başarıyla geçti.

---

## 🎯 Gelecek Faz (Faz 15 - Canlı Dağıtım ve Yayın Öncesi)
- Canlı SMS sağlayıcısı (Netgsm / Twilio) ile harici SMS gönderimi.


