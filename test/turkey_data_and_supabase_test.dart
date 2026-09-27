import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/core/utils/geo_utils.dart';
import 'package:seffaf/data/models/complaint.dart';
import 'package:seffaf/data/models/complaint_status.dart';
import 'package:seffaf/data/repositories/mock_municipality_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Türkiye İl & İlçe ve Supabase Veri Testleri', () {
    final repo = MockMunicipalityRepository();

    test('81 il eksiksiz yüklenmeli ve "Tümü" ile birlikte 82 eleman dönmeli', () async {
      final provinces = await repo.getProvinces();
      expect(provinces.length, greaterThanOrEqualTo(81));
      expect(provinces.contains('Tümü'), isTrue);
      expect(provinces.contains('İstanbul'), isTrue);
      expect(provinces.contains('Ankara'), isTrue);
      expect(provinces.contains('İzmir'), isTrue);
      expect(provinces.contains('Edirne'), isTrue);
      expect(provinces.contains('Düzce'), isTrue);
    });

    test('972 ilçe belediyesi eksiksiz yüklenmeli', () async {
      final munis = await repo.getMunicipalities();
      expect(munis.length, greaterThanOrEqualTo(970));

      final kadikoy = munis.firstWhere((m) => m.district == 'Kadıköy' && m.province == 'İstanbul');
      expect(kadikoy.name, contains('Kadıköy Belediyesi'));
      expect(kadikoy.transparencyScore, inInclusiveRange(0, 100));

      final cankaya = munis.firstWhere((m) => m.district == 'Çankaya' && m.province == 'Ankara');
      expect(cankaya.name, contains('Çankaya Belediyesi'));
    });

    test('GeoUtils Türkiye genelinde GPS koordinatından doğru ilçeyi tespit etmeli', () async {
      // 972 ilçeyi GeoUtils'e yükle
      final munis = await repo.getMunicipalities();
      GeoUtils.setMunicipalities(munis);

      // Edirne Merkez koordinatları (~41.67, 26.55)
      final edirneMuni = GeoUtils.detectMunicipality(41.6775, 26.5552);
      expect(edirneMuni.districtName, equals('Merkez'));
      expect(edirneMuni.provinceName, equals('Edirne'));

      // Ankara Kızılay/Çankaya koordinatları (~39.92, 32.85)
      final ankaraMuni = GeoUtils.detectMunicipality(39.9208, 32.8541);
      expect(ankaraMuni.provinceName, equals('Ankara'));

      // İzmir Konak koordinatları (~38.41, 27.12)
      final izmirMuni = GeoUtils.detectMunicipality(38.4192, 27.1287);
      expect(izmirMuni.provinceName, equals('İzmir'));
    });

    test('Complaint toSupabaseMap ve fromJson dönüşümleri veri kaybetmemeli', () {
      final complaint = Complaint(
        id: 'test-supabase-01',
        anonymousUserId: 'usr-999',
        anonymousUserName: 'Denetçi Vatandaş',
        title: 'Bozuk Sokak Lambası',
        description: 'Lambalar gece yanmıyor tehlike arz ediyor.',
        categoryId: 'lighting',
        photoUrls: ['https://example.com/p1.jpg'],
        latitude: 41.0082,
        longitude: 28.9784,
        address: 'Fatih, İstanbul',
        municipalityId: 'muni_istanbul_fatih',
        status: ComplaintStatus.inReview,
        createdAt: DateTime.parse('2026-09-27T10:00:00Z'),
        slaDeadline: DateTime.parse('2026-10-04T10:00:00Z'),
        likeCount: 5,
        confirmCount: 2,
        resolvedPhotoUrl: 'https://example.com/p2.jpg',
        municipalityResponseNote: 'Ekipler sevk edildi.',
        myRating: 4,
      );

      final supabaseMap = complaint.toSupabaseMap();
      expect(supabaseMap['id'], equals('test-supabase-01'));
      expect(supabaseMap['author_id'], equals('usr-999'));
      expect(supabaseMap['category_id'], equals('lighting'));
      expect(supabaseMap['citizen_satisfaction_rating'], equals(4));

      final restored = Complaint.fromJson(supabaseMap);
      expect(restored.id, equals(complaint.id));
      expect(restored.anonymousUserId, equals(complaint.anonymousUserId));
      expect(restored.categoryId, equals(complaint.categoryId));
      expect(restored.likeCount, equals(5));
      expect(restored.resolvedPhotoUrl, equals('https://example.com/p2.jpg'));
    });
  });
}
