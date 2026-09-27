import 'complaint_status.dart';

class Complaint {
  final String id;
  final String anonymousUserId;
  final String anonymousUserName;
  final String? title;
  final String description;
  final String categoryId;
  final List<String> photoUrls;
  final double latitude;
  final double longitude;
  final String address;
  final String municipalityId;
  final ComplaintStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final int likeCount;
  final int commentCount;
  final int confirmCount;
  final DateTime slaDeadline;
  final bool isLikedByMe;
  final bool isConfirmedByMe;
  final String? resolvedPhotoUrl;
  final String? municipalityResponseNote;
  final DateTime? municipalityResponseDate;
  final int? myRating;
  final double averageRating;
  final int ratingCount;

  Complaint({
    required this.id,
    required this.anonymousUserId,
    required this.anonymousUserName,
    this.title,
    required this.description,
    required this.categoryId,
    required this.photoUrls,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.municipalityId,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.confirmCount = 0,
    required this.slaDeadline,
    this.isLikedByMe = false,
    this.isConfirmedByMe = false,
    this.resolvedPhotoUrl,
    this.municipalityResponseNote,
    this.municipalityResponseDate,
    this.myRating,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  bool get isSlaExceeded {
    if (status == ComplaintStatus.resolved && resolvedAt != null) {
      return resolvedAt!.isAfter(slaDeadline);
    }
    return DateTime.now().isAfter(slaDeadline);
  }

  int get remainingDays {
    final now = DateTime.now();
    return slaDeadline.difference(now).inDays;
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    // Fotoğraflar List veya String listesi
    List<String> photos = [];
    final rawPhotos = json['photoUrls'] ?? json['photo_urls'];
    if (rawPhotos is List) {
      photos = rawPhotos.map((e) => e.toString()).toList();
    }

    // Çözüm fotoğrafları
    String? resolvedPhoto = json['resolvedPhotoUrl'] as String? ?? json['resolved_photo_url'] as String?;
    if (resolvedPhoto == null) {
      final rawSolutionPhotos = json['solution_photo_urls'];
      if (rawSolutionPhotos is List && rawSolutionPhotos.isNotEmpty) {
        resolvedPhoto = rawSolutionPhotos.first.toString();
      }
    }

    return Complaint(
      id: json['id'] as String,
      anonymousUserId: (json['anonymousUserId'] ?? json['author_id'] ?? json['authorId'] ?? 'user-guest').toString(),
      anonymousUserName: (json['anonymousUserName'] ?? json['author_name'] ?? json['authorName'] ?? 'Misafir Vatandaş').toString(),
      title: json['title'] as String?,
      description: (json['description'] ?? '') as String,
      categoryId: (json['categoryId'] ?? json['category_id'] ?? 'other') as String,
      photoUrls: photos,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: (json['address'] ?? '') as String,
      municipalityId: (json['municipalityId'] ?? json['municipality_id'] ?? '') as String,
      status: ComplaintStatus.fromString((json['status'] ?? 'pending') as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : (json['resolved_at'] != null
              ? DateTime.parse(json['resolved_at'] as String)
              : null),
      likeCount: (json['likeCount'] ?? json['likes_count'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? json['comment_count'] ?? 0) as int,
      confirmCount: (json['confirmCount'] ?? json['confirmations_count'] ?? 0) as int,
      slaDeadline: json['slaDeadline'] != null
          ? DateTime.parse(json['slaDeadline'] as String)
          : (json['sla_deadline'] != null
              ? DateTime.parse(json['sla_deadline'] as String)
              : DateTime.now().add(const Duration(days: 14))),
      isLikedByMe: (json['isLikedByMe'] ?? false) as bool,
      isConfirmedByMe: (json['isConfirmedByMe'] ?? false) as bool,
      resolvedPhotoUrl: resolvedPhoto,
      municipalityResponseNote: (json['municipalityResponseNote'] ?? json['official_response_note']) as String?,
      municipalityResponseDate: json['municipalityResponseDate'] != null
          ? DateTime.parse(json['municipalityResponseDate'] as String)
          : (json['official_response_date'] != null
              ? DateTime.parse(json['official_response_date'] as String)
              : null),
      myRating: (json['myRating'] ?? json['citizen_satisfaction_rating']) as int?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anonymousUserId': anonymousUserId,
      'anonymousUserName': anonymousUserName,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'photoUrls': photoUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'municipalityId': municipalityId,
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'confirmCount': confirmCount,
      'slaDeadline': slaDeadline.toIso8601String(),
      'isLikedByMe': isLikedByMe,
      'isConfirmedByMe': isConfirmedByMe,
      'resolvedPhotoUrl': resolvedPhotoUrl,
      'municipalityResponseNote': municipalityResponseNote,
      'municipalityResponseDate': municipalityResponseDate?.toIso8601String(),
      'myRating': myRating,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'title': title ?? (description.length > 30 ? '${description.substring(0, 30)}...' : description),
      'description': description,
      'category_id': categoryId,
      'category_name': categoryId,
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
      'municipality_id': municipalityId,
      'municipality_name': '',
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'photo_urls': photoUrls,
      'solution_photo_urls': resolvedPhotoUrl != null ? [resolvedPhotoUrl!] : [],
      'official_response_note': municipalityResponseNote,
      'official_response_date': municipalityResponseDate?.toIso8601String(),
      'citizen_satisfaction_rating': myRating,
      'author_id': anonymousUserId,
      'author_name': anonymousUserName,
      'is_anonymous': true,
      'likes_count': likeCount,
      'confirmations_count': confirmCount,
      'sla_deadline': slaDeadline.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  Complaint copyWith({
    String? id,
    String? anonymousUserId,
    String? anonymousUserName,
    String? title,
    String? description,
    String? categoryId,
    List<String>? photoUrls,
    double? latitude,
    double? longitude,
    String? address,
    String? municipalityId,
    ComplaintStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    int? likeCount,
    int? commentCount,
    int? confirmCount,
    DateTime? slaDeadline,
    bool? isLikedByMe,
    bool? isConfirmedByMe,
    String? resolvedPhotoUrl,
    String? municipalityResponseNote,
    DateTime? municipalityResponseDate,
    int? myRating,
    double? averageRating,
    int? ratingCount,
  }) {
    return Complaint(
      id: id ?? this.id,
      anonymousUserId: anonymousUserId ?? this.anonymousUserId,
      anonymousUserName: anonymousUserName ?? this.anonymousUserName,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      photoUrls: photoUrls ?? this.photoUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      municipalityId: municipalityId ?? this.municipalityId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      confirmCount: confirmCount ?? this.confirmCount,
      slaDeadline: slaDeadline ?? this.slaDeadline,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isConfirmedByMe: isConfirmedByMe ?? this.isConfirmedByMe,
      resolvedPhotoUrl: resolvedPhotoUrl ?? this.resolvedPhotoUrl,
      municipalityResponseNote:
          municipalityResponseNote ?? this.municipalityResponseNote,
      municipalityResponseDate:
          municipalityResponseDate ?? this.municipalityResponseDate,
      myRating: myRating ?? this.myRating,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
