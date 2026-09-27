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

  const DistrictBoundary({
    required this.municipalityId,
    required this.districtName,
    required this.provinceName,
    required this.polygon,
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

  // Trakya & Edirne İlçe Sınırları (Mock Polygon Verileri)
  static final List<DistrictBoundary> knownBoundaries = [
    // Edirne Merkez Sınır Poligonu
    const DistrictBoundary(
      municipalityId: 'muni_edirne_merkez',
      districtName: 'Merkez',
      provinceName: 'Edirne',
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
      polygon: [
        GeoPoint(41.3200, 26.6300),
        GeoPoint(41.3200, 26.7500),
        GeoPoint(41.2200, 26.7500),
        GeoPoint(41.2200, 26.6300),
      ],
    ),
  ];

  /// Verilen GPS koordinatından belediyeyi tespit eder
  static DistrictBoundary detectMunicipality(double lat, double lon) {
    final point = GeoPoint(lat, lon);
    for (final boundary in knownBoundaries) {
      if (isPointInPolygon(point, boundary.polygon)) {
        return boundary;
      }
    }
    // Eşleşmezse varsayılan olarak Edirne Merkez döner
    return knownBoundaries.first;
  }
}
