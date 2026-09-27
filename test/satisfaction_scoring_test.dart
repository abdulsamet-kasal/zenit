import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/core/utils/scoring_calculator.dart';
import 'package:seffaf/data/models/complaint.dart';
import 'package:seffaf/data/models/complaint_status.dart';

void main() {
  group('Satisfaction Scoring Tests', () {
    test('Yüksek vatandaş memnuniyeti (5 yıldız) puan etkisini artırmalı', () {
      final now = DateTime.now();

      final complaintWithoutRating = Complaint(
        id: 'c-test-1',
        anonymousUserId: 'u1',
        anonymousUserName: 'Vatandaş',
        description: 'Test açıklaması',
        categoryId: 'waste_cleaning',
        photoUrls: [],
        latitude: 41.67,
        longitude: 26.55,
        address: 'Edirne',
        municipalityId: 'muni_edirne_merkez',
        status: ComplaintStatus.resolved,
        createdAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)),
        slaDeadline: now.add(const Duration(days: 1)),
      );

      final complaintWithHighRating = complaintWithoutRating.copyWith(
        averageRating: 5.0,
        ratingCount: 10,
      );

      final impactBase = ScoringCalculator.calculateComplaintImpact(
        complaintWithoutRating,
        referenceDate: now,
      );
      final impactHigh = ScoringCalculator.calculateComplaintImpact(
        complaintWithHighRating,
        referenceDate: now,
      );

      expect(impactHigh, greaterThan(impactBase));
      expect(impactHigh - impactBase, closeTo(2.0, 0.01));
    });

    test('Düşük vatandaş memnuniyeti (1 yıldız) puan etkisini düşürmeli', () {
      final now = DateTime.now();

      final complaintBase = Complaint(
        id: 'c-test-2',
        anonymousUserId: 'u1',
        anonymousUserName: 'Vatandaş',
        description: 'Test açıklaması',
        categoryId: 'waste_cleaning',
        photoUrls: [],
        latitude: 41.67,
        longitude: 26.55,
        address: 'Edirne',
        municipalityId: 'muni_edirne_merkez',
        status: ComplaintStatus.resolved,
        createdAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)),
        slaDeadline: now.add(const Duration(days: 1)),
      );

      final complaintWithLowRating = complaintBase.copyWith(
        averageRating: 1.0,
        ratingCount: 5,
      );

      final impactBase = ScoringCalculator.calculateComplaintImpact(
        complaintBase,
        referenceDate: now,
      );
      final impactLow = ScoringCalculator.calculateComplaintImpact(
        complaintWithLowRating,
        referenceDate: now,
      );

      expect(impactLow, lessThan(impactBase));
      expect(impactBase - impactLow, closeTo(2.0, 0.01));
    });
  });
}
