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

## 🚦 Tamamlanan Aşamalar (Faz 1 - Faz 9)
1. **Faz 1:** Temiz Mimari (`core/`, `data/`, `features/`, `shared/`), veri modelleri, SLA ve puanlama motoru.
2. **Faz 2:** Mock veri setleri (Edirne, Keşan, Uzunköprü, Çorlu, Lüleburgaz) ve repository katmanı.
3. **Faz 3:** Onboarding ve Misafir Kullanıcı kimliği (UUID).
4. **Faz 4:** 5 sekmeli ana navigasyon ve Instagram tarzı Şikayet Akışı (Feed).
5. **Faz 5:** OpenStreetMap haritası, kümeleme (clustering) ve pin bottom sheet önizlemesi.
6. **Faz 6:** 4 adımlı Şikayet Oluşturma Sihirbazı, ray-casting ile otomatik belediye tespiti ve offline kuyruk.
7. **Faz 7:** Şikayet Detay ekranı, çoklu görsel galerisi, SLA zaman çizelgesi, itiraz ve yorum akışı.
8. **Faz 8:** Belediye Karnesi profili (0-100 puan göstergesi, fl_chart trendi) ve Sıralama (Leaderboard) ekranı.
9. **Faz 9 (Kalıcılık, Çözüm Kanıtı, Doğrulama & UX İleri Geliştirmeler):**
   - **Kalıcı Yerel Depolama:** Kullanıcının açtığı şikayetler, beğenileri, onayları, yorumları ve oyları SharedPreferences ile cihazda kalıcı hale getirildi.
   - **Otomatik Çevrimdışı Eşitleme (Offline Sync Engine):** `connectivity_plus` dinleyicisi ile internet geldiğinde arka plandaki taslakların otomatik aktarılması ve kullanıcıya durum gösterimi.
   - **Çözüm Kanıtı (Önce / Sonra):** Çözülmüş şikayetlerde vatandaş bildirimi ile belediyenin çözüm fotoğrafının yan yana karşılaştırılması.
   - **Resmi Belediye Yanıtı & Vatandaş Memnuniyet Anketi:** Belediyenin resmi açıklama notu, vatandaşın 1-5 yıldız vermesi ve bunun şeffaflık puanına doğrudan etki etmesi.
   - **Tam Ekran Görsel Görüntüleyici:** Detaydaki tüm görsellere dokunulduğunda pinch-to-zoom (`InteractiveViewer`) tam ekran modu.
   - **SMS OTP Vatandaş Doğrulaması:** 6 haneli SMS onay akışı, profilde "🛡️ Doğrulanmış Vatandaş" rozeti ve takip edilen belediyeler listesi.
   - **Genişletilmiş Coğrafi Kapsam:** Çorlu ve Lüleburgaz poligonları ve poligon dışı alanlar için en yakın centroid mesafesi yedek tespit algoritması.
   - **Gelişmiş Sıralama Ölçütleri:** Akışta En Yeni / En Çok Desteklenen / SLA Acil Olanlar; Sıralamada Şeffaflık Puanı / Çözüm Oranı / En Hızlı Çözenler.

---

## 🎯 Gelecek Faz (Faz 10 - Sıradaki Yol Haritası)
- **Harici Bulut Backend:** Supabase / Firebase veya REST API servislerinin bağlanması.
- **Harici Coğrafi Veri:** Türkiye geneli 922 ilçe sınır poligonlarının GeoJSON olarak yüklenmesi.

