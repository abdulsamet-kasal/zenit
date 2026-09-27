class AnonymousUser {
  final String id;
  final String displayName;
  final List<String> createdComplaintIds;
  final bool isVerified;
  final String? phoneNumber;
  final String? email;
  final bool isGuest;
  final List<String> followedMunicipalityIds;

  AnonymousUser({
    required this.id,
    required this.displayName,
    required this.createdComplaintIds,
    this.isVerified = false,
    this.phoneNumber,
    this.email,
    this.isGuest = true,
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
      email: json['email'] as String?,
      isGuest: json['isGuest'] as bool? ?? true,
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
      'email': email,
      'isGuest': isGuest,
      'followedMunicipalityIds': followedMunicipalityIds,
    };
  }

  AnonymousUser copyWith({
    String? id,
    String? displayName,
    List<String>? createdComplaintIds,
    bool? isVerified,
    String? phoneNumber,
    String? email,
    bool? isGuest,
    List<String>? followedMunicipalityIds,
  }) {
    return AnonymousUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdComplaintIds: createdComplaintIds ?? this.createdComplaintIds,
      isVerified: isVerified ?? this.isVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      followedMunicipalityIds:
          followedMunicipalityIds ?? this.followedMunicipalityIds,
    );
  }
}

