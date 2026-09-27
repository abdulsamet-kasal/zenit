import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/core/utils/scoring_calculator.dart';
import 'package:seffaf/data/models/complaint.dart';
import 'package:seffaf/data/models/complaint_status.dart';

void main() {
  group('ScoringCalculator Tests', () {
    test('Zamanında çözülen şikayet pozitif puan etkisi üretmeli', () {
      final now = DateTime.now();
      // Waste cleaning SLA is 3 days
      final complaint = Complaint(
        id: 'test-1',
        anonymousUserId: 'u1',
        anonymousUserName: 'Misafir',
        description: 'Çöp yığılmış',
        categoryId: 'waste_cleaning',
        photoUrls: [],
        latitude: 41.67,
        longitude: 26.55,
        address: 'Edirne',
        municipalityId: 'muni_edirne_merkez',
        status: ComplaintStatus.resolved,
        createdAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)), // 1 günde çözüldü (3 gün SLA)
        slaDeadline: now.add(const Duration(days: 1)),
      );

      final impact = ScoringCalculator.calculateComplaintImpact(complaint, referenceDate: now);
      expect(impact, greaterThan(0));
    });

    test('SLA aşıldığında çözülemeyen şikayet negatif ceza üretmeli', () {
      final now = DateTime.now();
      final complaint = Complaint(
        id: 'test-2',
        anonymousUserId: 'u2',
        anonymousUserName: 'Misafir',
        description: 'Çöp yığılmış',
        categoryId: 'waste_cleaning',
        photoUrls: [],
        latitude: 41.67,
        longitude: 26.55,
        address: 'Edirne',
        municipalityId: 'muni_edirne_merkez',
        status: ComplaintStatus.pending,
        createdAt: now.subtract(const Duration(days: 10)),
        slaDeadline: now.subtract(const Duration(days: 7)), // 7 gün gecikmiş
      );

      final impact = ScoringCalculator.calculateComplaintImpact(complaint, referenceDate: now);
      expect(impact, lessThan(0));
    });

    test('Belediye toplam skoru 0-100 aralığında sınırlanmalı', () {
      final now = DateTime.now();
      final complaints = List.generate(
        15,
        (i) => Complaint(
          id: 't-$i',
          anonymousUserId: 'u',
          anonymousUserName: 'M',
          description: 'D',
          categoryId: 'waste_cleaning',
          photoUrls: [],
          latitude: 41.67,
          longitude: 26.55,
          address: 'E',
          municipalityId: 'muni_edirne_merkez',
          status: ComplaintStatus.resolved,
          createdAt: now.subtract(const Duration(days: 5)),
          resolvedAt: now.subtract(const Duration(days: 4)),
          slaDeadline: now.subtract(const Duration(days: 2)),
        ),
      );

      final score = ScoringCalculator.calculateMunicipalityScore(complaints, referenceDate: now);
      expect(score, inInclusiveRange(0.0, 100.0));
      expect(score, greaterThan(70.0));
    });
  });
}
