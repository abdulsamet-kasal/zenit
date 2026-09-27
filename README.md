# 🏛️ ŞEFFAF — Belediye Şeffaflık Uygulaması

> **Vatandaş bildirimleri ve belediye performans karnesi mobil uygulaması.**  
> *Hangi belediyenin gerçekten çalıştığını somut verilerle ortaya koyan şeffaf platform.*

---

## 📱 Proje Hakkında

**Şeffaf**, vatandaşların yaşadıkları bölgedeki belediye sorumluluğundaki aksaklıkları (yol çukurları, arızalı sokak lambaları, çöp/temizlik, park bakım vb.) fotoğraf ve konum ile anında bildirebildiği; bu bildirimlerin kamuya açık bir akışta paylaşılarak belediyelerin çözüm hızına göre otomatik puanlandığı açık kaynaklı bir Flutter mobil uygulamasıdır.

---

## ✨ Temel Özellikler

### 1. 📢 Şikayet Akışı (Feed)
- Instagram tarzı dikey kart görünümü
- Çoklu fotoğraf desteği ve sayfa göstergesi
- Kategoriye göre renkli rozetler ve dinamik durum etiketleri (🟡 Bekliyor, 🔵 İnceleniyor, 🟢 Çözüldü, 🔴 Reddedildi)
- Mahalle ve ilçe konum etiketleri (tıklanınca haritada odaklanır)
- Beğeni, yorum ve "Ben de gördüm" onay mekanizması
- Pull-to-refresh ve akıllı filtreleme (Kategori & Durum)

### 2. 🗺️ İnteraktif Harita (OpenStreetMap)
- Google Maps yerine tamamen açık kaynaklı **OpenStreetMap (OSM)** altyapısı
- Performanslı pin kümeleme (**flutter_map_marker_cluster**)
- Kategori renk kodlu özel pinler
- Seçilen şikayet için kaydırılabilir alt sayfa (Bottom Sheet) önizlemesi
- GPS ile anlık "Konumuma Git" butonu

### 3. 📝 Çok Adımlı Bildirim Sihirbazı (Report Creation)
- **1. Adım:** Kamera veya galeriden 1-3 adet fotoğraf seçimi
- **2. Adım:** GPS tabanlı konum algılama ve harita üzerinde pin düzeltme
- **3. Adım:** 8 farklı kategori seçimi (SLA süreleri tanımlı) ve karakter sayaçlı açıklama alanı
- **Otomatik İlçe Tespiti:** Koordinatlardan ilgili belediyeyi anında tespit etme (Ray-casting / Coğrafi sınır tespiti)
- **4. Adım:** Önizleme ve tek tuşla gönderim
- **Offline Desteği:** İnternet kesintilerinde taslak olarak yerel depolamada saklama ve bağlantı kurulunca otomatik gönderme sırası

### 4. 📊 Belediye Karnesi ve Şeffaflık Puanlama Algoritması
- 0-100 arası dinamik şeffaflık skoru hesaplama motoru:
  - **%40 Çözüm Oranı**
  - **%30 SLA Uyumu** (Beklenen çözüm süresine sadakat)
  - **%20 Vatandaş Memnuniyeti**
  - **%10 Çözüm Hızı**
- 90 günlük puan trend grafiği (**fl_chart** LineChart)
- Kategori bazlı çözüm başarı çubukları
- İlgili belediyeye ait filtrelenebilir şikayet listesi

### 5. 🏆 Belediyeler Sıralaması (Leaderboard)
- Tüm belediyelerin şeffaflık puanına göre sıralandığı lig tablosu
- Madalya göstergeleri (🥇 Altın, 🥈 Gümüş, 🥉 Bronz)
- İl ve ilçe bazlı anlık arama ve filtreleme
- Trend yön okları (↑ / ↓ / -)

### 6. 👤 Misafir Profil & Sistem
- Giriş/Kayıt zorunluluğu olmadan misafir UUID modeli
- Kullanıcının kendi oluşturduğu şikayetlerin takibi
- Material 3 Açık / Koyu tema geçişi
- Bildirim tercihleri, KVKK gizlilik politikası ve yerel verileri sıfırlama

---

## 🛠️ Teknoloji Yığını

| Katman | Teknoloji / Kütüphane | Amaç |
|---|---|---|
| **Framework** | Flutter 3.47+ (Dart 3.13+) | Cross-platform mobil uygulama |
| **State Management** | `flutter_riverpod` (v3 Notifier) | Reaktif, test edilebilir ve granüler state yönetimi |
| **Harita** | `flutter_map` + `latlong2` | Açık kaynak OpenStreetMap tile katmanı |
| **Marker Kümeleme** | `flutter_map_marker_cluster` | Harita pin performans optimizasyonu |
| **Konum & GPS** | `geolocator` | Anlık konum ve mesafe hesabı |
| **Grafik Motoru** | `fl_chart` | 90 günlük puan geçmişi çizgi grafiği |
| **Yerel Depolama** | `shared_preferences` | Misafir kimliği ve tema/çevrimdışı ayarlar |
| **Tarih & Format** | `intl` | Türkçe yerelleştirilmiş tarih formatları |
| **Tasarım** | Material 3 (M3) | Modern ve erişilebilir arayüz |

---

## 📂 Proje Mimarisi

```
lib/
├── core/
│   ├── constants/         # Renkler, sabitler, kategori ve SLA tanımları
│   ├── network/           # Offline kuyruk ve bağlantı yöneticisi
│   ├── theme/             # Material 3 Açık/Koyu tema tanımları
│   └── utils/             # Puanlama algoritması, geo utils, tarih formatlayıcı
├── data/
│   ├── models/            # Complaint, Municipality, Comment, AnonymousUser
│   └── repositories/      # Repository interface'leri ve Mock/API implementasyonları
├── features/
│   ├── onboarding/        # Tanıtım ekranları ve misafir kimlik üretimi
│   ├── main_navigation/   # 5 sekmeli ana yönlendirme barı
│   ├── feed/              # Şikayet akışı ve kart bileşenleri
│   ├── map/               # Tam ekran OSM haritası ve pin kümeleme
│   ├── report_creation/   # 4 adımlı şikayet oluşturma akışı
│   ├── complaint_detail/  # Şikayet detay, yorumlar ve SLA zaman çizelgesi
│   ├── municipality/      # Belediye karne profili ve trend grafikleri
│   ├── leaderboard/       # Sıralama ve arama ekranı
│   └── profile/           # Misafir profil ekranı ve ayarlar
└── shared/
    └── widgets/           # Ortak rozetler, shimmer ve hata bileşenleri
```

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK (>= 3.47.0)
- Android SDK veya iOS Xcode (macOS için)

### Adımlar

1. Depoyu klonlayın:
```bash
git clone https://github.com/abdulsamet-kasal/zenit.git
cd zenit
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Testleri çalıştırın:
```bash
flutter test
```

4. Uygulamayı başlatın:
```bash
flutter run
```

---

## 📜 Lisans

Bu proje açık kaynak kodlu olup MIT lisansı altındadır.
