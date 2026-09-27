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
    return Complaint(
      id: json['id'] as String,
      anonymousUserId: json['anonymousUserId'] as String,
      anonymousUserName:
          json['anonymousUserName'] as String? ?? 'Misafir Vatandaş',
      title: json['title'] as String?,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      municipalityId: json['municipalityId'] as String,
      status: ComplaintStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      confirmCount: json['confirmCount'] as int? ?? 0,
      slaDeadline: DateTime.parse(json['slaDeadline'] as String),
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
      isConfirmedByMe: json['isConfirmedByMe'] as bool? ?? false,
      resolvedPhotoUrl: json['resolvedPhotoUrl'] as String?,
      municipalityResponseNote: json['municipalityResponseNote'] as String?,
      municipalityResponseDate: json['municipalityResponseDate'] != null
          ? DateTime.parse(json['municipalityResponseDate'] as String)
          : null,
      myRating: json['myRating'] as int?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
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
