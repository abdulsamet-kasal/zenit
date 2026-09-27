class AnonymousUser {
  final String id;
  final String displayName;
  final List<String> createdComplaintIds;
  final bool isVerified;
  final String? phoneNumber;
  final List<String> followedMunicipalityIds;

  AnonymousUser({
    required this.id,
    required this.displayName,
    required this.createdComplaintIds,
    this.isVerified = false,
    this.phoneNumber,
    this.followedMunicipalityIds = const [],
  });

  factory AnonymousUser.fromJson(Map<String, dynamic> json) {
    return AnonymousUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      createdComplaintIds: (json['createdComplaintIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isVerified: json['isVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      followedMunicipalityIds: (json['followedMunicipalityIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'createdComplaintIds': createdComplaintIds,
      'isVerified': isVerified,
      'phoneNumber': phoneNumber,
      'followedMunicipalityIds': followedMunicipalityIds,
    };
  }

  AnonymousUser copyWith({
    String? id,
    String? displayName,
    List<String>? createdComplaintIds,
    bool? isVerified,
    String? phoneNumber,
    List<String>? followedMunicipalityIds,
  }) {
    return AnonymousUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdComplaintIds: createdComplaintIds ?? this.createdComplaintIds,
      isVerified: isVerified ?? this.isVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      followedMunicipalityIds:
          followedMunicipalityIds ?? this.followedMunicipalityIds,
    );
  }
}

