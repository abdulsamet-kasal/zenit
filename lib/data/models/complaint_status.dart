enum ComplaintStatus {
  pending('Bekliyor', '🟡'),
  inReview('İnceleniyor', '🔵'),
  resolved('Çözüldü', '🟢'),
  rejected('Reddedildi', '🔴');

  final String label;
  final String emoji;

  String get displayName => label;

  const ComplaintStatus(this.label, this.emoji);


  static ComplaintStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'in_review':
      case 'inreview':
        return ComplaintStatus.inReview;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'rejected':
        return ComplaintStatus.rejected;
      case 'pending':
      default:
        return ComplaintStatus.pending;
    }
  }

  String toJson() {
    switch (this) {
      case ComplaintStatus.inReview:
        return 'inReview';
      case ComplaintStatus.resolved:
        return 'resolved';
      case ComplaintStatus.rejected:
        return 'rejected';
      case ComplaintStatus.pending:
        return 'pending';
    }
  }
}
