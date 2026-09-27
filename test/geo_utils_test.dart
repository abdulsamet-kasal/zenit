import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/core/utils/geo_utils.dart';

void main() {
  group('GeoUtils Tests', () {
    test('Edirne Merkez koordinatları Edirne Merkez belediyesi olarak tespit edilmeli', () {
      final boundary = GeoUtils.detectMunicipality(41.6771, 26.5557);
      expect(boundary.municipalityId, 'muni_edirne_merkez');
      expect(boundary.provinceName, 'Edirne');
    });

    test('Keşan koordinatları Keşan belediyesi olarak tespit edilmeli', () {
      final boundary = GeoUtils.detectMunicipality(40.8550, 26.6350);
      expect(boundary.municipalityId, 'muni_edirne_kesan');
      expect(boundary.districtName, 'Keşan');
    });

    test('Çorlu koordinatları Çorlu belediyesi olarak tespit edilmeli', () {
      final boundary = GeoUtils.detectMunicipality(41.1600, 27.8000);
      expect(boundary.municipalityId, 'muni_tekirdag_corlu');
      expect(boundary.provinceName, 'Tekirdağ');
    });

    test('Lüleburgaz koordinatları Lüleburgaz belediyesi olarak tespit edilmeli', () {
      final boundary = GeoUtils.detectMunicipality(41.4000, 27.3500);
      expect(boundary.municipalityId, 'muni_kirklareli_luleburgaz');
      expect(boundary.provinceName, 'Kırklareli');
    });

    test('Poligon dışındaki yakın koordinat en yakın belediyeyi tespit etmeli', () {
      // Çorlu'ya çok yakın ama sınırın hemen dışındaki bir koordinat
      final boundary = GeoUtils.detectMunicipality(41.1000, 27.7800);
      expect(boundary.municipalityId, 'muni_tekirdag_corlu');
    });

    test('Mesafe hesaplama metre ve kilometre formatı doğru dönmeli', () {
      expect(GeoUtils.formatDistance(450), '450 m');
      expect(GeoUtils.formatDistance(2400), '2.4 km');
    });
  });
}
