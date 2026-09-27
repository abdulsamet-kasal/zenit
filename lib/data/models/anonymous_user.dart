class AnonymousUser {
  final String id;
  final String displayName;
  final List<String> createdComplaintIds;

  AnonymousUser({
    required this.id,
    required this.displayName,
    required this.createdComplaintIds,
  });

  factory AnonymousUser.fromJson(Map<String, dynamic> json) {
    return AnonymousUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      createdComplaintIds: (json['createdComplaintIds'] as List<dynamic>?)
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
    };
  }

  AnonymousUser copyWith({
    String? id,
    String? displayName,
    List<String>? createdComplaintIds,
  }) {
    return AnonymousUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdComplaintIds: createdComplaintIds ?? this.createdComplaintIds,
    );
  }
}
