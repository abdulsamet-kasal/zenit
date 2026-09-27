import 'dart:math';

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);
}

class DistrictBoundary {
  final String municipalityId;
  final String districtName;
  final String provinceName;
  final List<GeoPoint> polygon;
  final double? centerLat;
  final double? centerLon;

  const DistrictBoundary({
    required this.municipalityId,
    required this.districtName,
    required this.provinceName,
    required this.polygon,
    this.centerLat,
    this.centerLon,
  });
}

class GeoUtils {
  // Ray-Casting Algoritması: Bir noktanın poligon içinde olup olmadığını test eder
  static bool isPointInPolygon(GeoPoint point, List<GeoPoint> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final pi = polygon[i];
      final pj = polygon[j];

      if ((pi.longitude > point.longitude) != (pj.longitude > point.longitude) &&
          (point.latitude <
              (pj.latitude - pi.latitude) *
                      (point.longitude - pi.longitude) /
                      (pj.longitude - pi.longitude) +
                  pi.latitude)) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  // Haversine Formülü ile iki koordinat arası mesafe hesabı (metre cinsinden)
  static double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // Metre
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // Dinamik olarak kayıtlı tüm Türkiye ilçe sınırları
  static List<DistrictBoundary> _allDistricts = [];

  static void setMunicipalities(List<dynamic> municipalities) {
    _allDistricts = municipalities.map((m) {
      final id = m.id as String;
      final province = m.province as String;
      final district = m.district as String;
      final lat = (m.latitude as num).toDouble();
      final lon = (m.longitude as num).toDouble();

      List<GeoPoint> poly = [];
      if (m.boundaryPolygon != null && m.boundaryPolygon is List) {
        for (final p in m.boundaryPolygon) {
          if (p is List && p.length >= 2) {
            poly.add(GeoPoint((p[0] as num).toDouble(), (p[1] as num).toDouble()));
          }
        }
      }

      if (poly.isEmpty) {
        // 0.05 derecelik (~5.5 km) varsayılan bir sınır kutusu oluştur
        poly = [
          GeoPoint(lat + 0.05, lon - 0.05),
          GeoPoint(lat + 0.05, lon + 0.05),
          GeoPoint(lat - 0.05, lon + 0.05),
          GeoPoint(lat - 0.05, lon - 0.05),
        ];
      }

      return DistrictBoundary(
        municipalityId: id,
        districtName: district,
        provinceName: province,
        polygon: poly,
        centerLat: lat,
        centerLon: lon,
      );
    }).toList();
  }

  // Trakya & Edirne Başlangıç Sınırları (Fallback)
  static final List<DistrictBoundary> knownBoundaries = [
    // Edirne Merkez Sınır Poligonu
    const DistrictBoundary(
      municipalityId: 'muni_edirne_merkez',
      districtName: 'Merkez',
      provinceName: 'Edirne',
      centerLat: 41.6750,
      centerLon: 26.5600,
      polygon: [
        GeoPoint(41.7200, 26.5000),
        GeoPoint(41.7200, 26.6200),
        GeoPoint(41.6300, 26.6200),
        GeoPoint(41.6300, 26.5000),
      ],
    ),
    // Keşan Sınır Poligonu
    const DistrictBoundary(
      municipalityId: 'muni_edirne_kesan',
      districtName: 'Keşan',
      provinceName: 'Edirne',
      centerLat: 40.8550,
      centerLon: 26.6400,
      polygon: [
        GeoPoint(40.9100, 26.5800),
        GeoPoint(40.9100, 26.7000),
        GeoPoint(40.8000, 26.7000),
        GeoPoint(40.8000, 26.5800),
      ],
    ),
    // Uzunköprü Sınır Poligonu
    const DistrictBoundary(
      municipalityId: 'muni_edirne_uzunkopru',
      districtName: 'Uzunköprü',
      provinceName: 'Edirne',
      centerLat: 41.2700,
      centerLon: 26.6900,
      polygon: [
        GeoPoint(41.3200, 26.6300),
        GeoPoint(41.3200, 26.7500),
        GeoPoint(41.2200, 26.7500),
        GeoPoint(41.2200, 26.6300),
      ],
    ),
    // Çorlu Sınır Poligonu (Tekirdağ)
    const DistrictBoundary(
      municipalityId: 'muni_tekirdag_corlu',
      districtName: 'Çorlu',
      provinceName: 'Tekirdağ',
      centerLat: 41.1700,
      centerLon: 27.8150,
      polygon: [
        GeoPoint(41.2200, 27.7500),
        GeoPoint(41.2200, 27.8800),
        GeoPoint(41.1200, 27.8800),
        GeoPoint(41.1200, 27.7500),
      ],
    ),
    // Lüleburgaz Sınır Poligonu (Kırklareli)
    const DistrictBoundary(
      municipalityId: 'muni_kirklareli_luleburgaz',
      districtName: 'Lüleburgaz',
      provinceName: 'Kırklareli',
      centerLat: 41.4000,
      centerLon: 27.3600,
      polygon: [
        GeoPoint(41.4500, 27.3000),
        GeoPoint(41.4500, 27.4200),
        GeoPoint(41.3500, 27.4200),
        GeoPoint(41.3500, 27.3000),
      ],
    ),
  ];

  /// Verilen GPS koordinatından belediyeyi tespit eder.
  /// Önce tüm kayıtlı ilçelerde hassas ray-casting poligon kontrolü yapar.
  /// Poligon dışına düşerse en yakın belediyeyi centroid mesafesine göre belirler.
  static DistrictBoundary detectMunicipality(double lat, double lon) {
    final searchList = _allDistricts.isNotEmpty ? _allDistricts : knownBoundaries;
    final point = GeoPoint(lat, lon);

    // 1. Hassas Ray-Casting Poligon Kontrolü
    for (final boundary in searchList) {
      if (isPointInPolygon(point, boundary.polygon)) {
        return boundary;
      }
    }

    // 2. Poligon içine düşmezse en yakın ilçe merkezini (Haversine) bul
    DistrictBoundary nearest = searchList.first;
    double minDistance = double.infinity;

    for (final boundary in searchList) {
      double cLat = boundary.centerLat ?? 0;
      double cLon = boundary.centerLon ?? 0;

      if (cLat == 0 && boundary.polygon.isNotEmpty) {
        double sumLat = 0;
        double sumLon = 0;
        for (final p in boundary.polygon) {
          sumLat += p.latitude;
          sumLon += p.longitude;
        }
        cLat = sumLat / boundary.polygon.length;
        cLon = sumLon / boundary.polygon.length;
      }

      final dist = calculateDistanceInMeters(lat, lon, cLat, cLon);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = boundary;
      }
    }

    return nearest;
  }
}
