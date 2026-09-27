class Comment {
  final String id;
  final String complaintId;
  final String anonymousUserId;
  final String anonymousUserName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.complaintId,
    required this.anonymousUserId,
    required this.anonymousUserName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      complaintId: json['complaintId'] as String,
      anonymousUserId: json['anonymousUserId'] as String,
      anonymousUserName: json['anonymousUserName'] as String? ?? 'Misafir Vatandaş',
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
    };
  }
}
