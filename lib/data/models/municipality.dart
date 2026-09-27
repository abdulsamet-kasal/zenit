class ScorePoint {
  final DateTime date;
  final double score;

  const ScorePoint({
    required this.date,
    required this.score,
  });

  factory ScorePoint.fromJson(Map<String, dynamic> json) {
    return ScorePoint(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'score': score,
    };
  }
}

class CategoryPerformance {
  final String categoryId;
  final String categoryName;
  final int total;
  final int resolved;
  final double successRate;

  const CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.resolved,
    required this.successRate,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      total: json['total'] as int? ?? 0,
      resolved: json['resolved'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'total': total,
      'resolved': resolved,
      'successRate': successRate,
    };
  }
}

class Municipality {
  final String id;
  final String name;
  final String province;
  final String district;
  final String? logoUrl;
  final double latitude;
  final double longitude;
  final int? plateNumber;
  final List<dynamic>? boundaryPolygon;
  final double transparencyScore; // 0-100
  final int totalComplaints;
  final int resolvedComplaints;
  final double avgResolutionDays;
  final List<ScorePoint> scoreHistory;
  final List<CategoryPerformance> categoryPerformance;

  const Municipality({
    required this.id,
    required this.name,
    required this.province,
    required this.district,
    this.logoUrl,
    this.latitude = 39.0,
    this.longitude = 35.0,
    this.plateNumber,
    this.boundaryPolygon,
    required this.transparencyScore,
    required this.totalComplaints,
    required this.resolvedComplaints,
    required this.avgResolutionDays,
    required this.scoreHistory,
    this.categoryPerformance = const [],
  });

  double get resolutionRate {
    if (totalComplaints == 0) return 0.0;
    return (resolvedComplaints / totalComplaints) * 100;
  }

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json['id'] as String,
      name: json['name'] as String,
      province: json['province'] as String,
      district: json['district'] as String,
      logoUrl: (json['logoUrl'] ?? json['logo_url']) as String?,
      latitude: ((json['latitude'] ?? 39.0) as num).toDouble(),
      longitude: ((json['longitude'] ?? 35.0) as num).toDouble(),
      plateNumber: (json['plateNumber'] ?? json['plate_number']) as int?,
      boundaryPolygon: (json['boundaryPolygon'] ?? json['boundary_polygon']) as List<dynamic>?,
      transparencyScore: ((json['transparencyScore'] ?? json['transparency_score'] ?? 70.0) as num).toDouble(),
      totalComplaints: (json['totalComplaints'] ?? json['total_complaints'] ?? 0) as int,
      resolvedComplaints: (json['resolvedComplaints'] ?? json['resolved_complaints'] ?? 0) as int,
      avgResolutionDays: ((json['avgResolutionDays'] ?? json['avg_resolution_days'] ?? 0.0) as num).toDouble(),
      scoreHistory: ((json['scoreHistory'] ?? json['score_history']) as List<dynamic>?)
              ?.map((e) => ScorePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categoryPerformance: ((json['categoryPerformance'] ?? json['category_performance']) as List<dynamic>?)
              ?.map((e) =>
                  CategoryPerformance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'province': province,
      'district': district,
      'logoUrl': logoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'plateNumber': plateNumber,
      'boundaryPolygon': boundaryPolygon,
      'transparencyScore': transparencyScore,
      'totalComplaints': totalComplaints,
      'resolvedComplaints': resolvedComplaints,
      'avgResolutionDays': avgResolutionDays,
      'scoreHistory': scoreHistory.map((e) => e.toJson()).toList(),
      'categoryPerformance':
          categoryPerformance.map((e) => e.toJson()).toList(),
    };
  }

  Municipality copyWith({
    String? id,
    String? name,
    String? province,
    String? district,
    String? logoUrl,
    double? latitude,
    double? longitude,
    int? plateNumber,
    List<dynamic>? boundaryPolygon,
    double? transparencyScore,
    int? totalComplaints,
    int? resolvedComplaints,
    double? avgResolutionDays,
    List<ScorePoint>? scoreHistory,
    List<CategoryPerformance>? categoryPerformance,
  }) {
    return Municipality(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      district: district ?? this.district,
      logoUrl: logoUrl ?? this.logoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      plateNumber: plateNumber ?? this.plateNumber,
      boundaryPolygon: boundaryPolygon ?? this.boundaryPolygon,
      transparencyScore: transparencyScore ?? this.transparencyScore,
      totalComplaints: totalComplaints ?? this.totalComplaints,
      resolvedComplaints: resolvedComplaints ?? this.resolvedComplaints,
      avgResolutionDays: avgResolutionDays ?? this.avgResolutionDays,
      scoreHistory: scoreHistory ?? this.scoreHistory,
      categoryPerformance: categoryPerformance ?? this.categoryPerformance,
    );
  }
}
