import 'dart:math';
import '../../data/models/complaint.dart';
import '../../data/models/complaint_status.dart';
import '../constants/app_constants.dart';
import '../constants/category_defaults.dart';

class ScoringCalculator {
  /// Tek bir şikayetin belediye puanına olan anlık puan etkisini hesaplar.
  static double calculateComplaintImpact(Complaint complaint, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final category = CategoryDefaults.getById(complaint.categoryId);
    final slaDays = category.slaDays;

    if (complaint.status == ComplaintStatus.resolved && complaint.resolvedAt != null) {
      final actualDays = complaint.resolvedAt!.difference(complaint.createdAt).inDays;
      final diff = slaDays - actualDays;

      double baseImpact;
      if (diff >= 0) {
        // Erken / zamanında çözüm bonusu (max ~15)
        final bonusFactor = min(1.0, (diff / slaDays) + 0.5);
        baseImpact = 10.0 * bonusFactor;
      } else {
        // Geç çözüm cezası (taban -15 ile sınırlı)
        final penaltyFactor = (diff.abs() / slaDays);
        final penalty = -5.0 * penaltyFactor;
        baseImpact = max(-15.0, penalty);
      }

      // Vatandaş memnuniyeti etkisi (%20 etki: 1 ila 5 yıldız değerlendirmesi)
      if (complaint.averageRating > 0) {
        final satisfactionFactor = (complaint.averageRating - 3.0); // -2.0 ile +2.0 arası
        baseImpact += satisfactionFactor;
      }

      return baseImpact;
    } else if (complaint.status == ComplaintStatus.pending ||
        complaint.status == ComplaintStatus.inReview) {
      if (now.isAfter(complaint.slaDeadline)) {
        // SLA aşıldı ve hala çözülmedi: Günlük artan ceza (taban -20)
        final overdueDays = now.difference(complaint.slaDeadline).inDays;
        final penalty = -0.5 * max(1, overdueDays);
        return max(-20.0, penalty);
      }
    }

    return 0.0;
  }

  /// Bir belediyenin tüm şikayetlerine göre toplam şeffaflık puanını hesaplar (0 - 100).
  static double calculateMunicipalityScore(
    List<Complaint> complaints, {
    DateTime? referenceDate,
  }) {
    if (complaints.isEmpty) return AppConstants.baseMunicipalityScore;

    final now = referenceDate ?? DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: AppConstants.recencyDaysWindow));

    double weightedImpactSum = 0.0;
    double totalWeight = 0.0;

    for (final c in complaints) {
      // Sadece son 90 günün şikayetlerini puanlamaya dahil et
      if (c.createdAt.isBefore(cutoffDate)) continue;

      final impact = calculateComplaintImpact(c, referenceDate: now);

      // Recency weighting: Son 30 gündeki olaylara 1.5x ağırlık ver
      final daysAgo = now.difference(c.createdAt).inDays;
      final weight = daysAgo <= 30 ? AppConstants.recencyMultiplier : 1.0;

      weightedImpactSum += impact * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return AppConstants.baseMunicipalityScore;

    final averageImpact = weightedImpactSum / totalWeight;
    final finalScore = AppConstants.baseMunicipalityScore + averageImpact;

    return finalScore.clamp(0.0, 100.0);
  }
}
