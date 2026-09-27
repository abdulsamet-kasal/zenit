class Comment {
  final String id;
  final String complaintId;
  final String anonymousUserId;
  final String anonymousUserName;
  final String text;
  final DateTime createdAt;
  final bool isOfficial;

  Comment({
    required this.id,
    required this.complaintId,
    required this.anonymousUserId,
    required this.anonymousUserName,
    required this.text,
    required this.createdAt,
    this.isOfficial = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      complaintId: (json['complaintId'] ?? json['complaint_id']) as String,
      anonymousUserId: (json['anonymousUserId'] ?? json['author_id'] ?? 'user') as String,
      anonymousUserName: (json['anonymousUserName'] ?? json['author_name'] ?? 'Misafir Vatandaş') as String,
      text: (json['text'] ?? json['content'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      isOfficial: (json['isOfficial'] ?? json['is_official'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintId': complaintId,
      'anonymousUserId': anonymousUserId,
      'anonymousUserName': anonymousUserName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isOfficial': isOfficial,
    };
  }
}
