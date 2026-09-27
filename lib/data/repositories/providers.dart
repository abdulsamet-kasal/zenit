import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anonymous_user.dart';
import 'auth_repository.dart';
import 'complaint_repository.dart';
import 'mock_auth_repository.dart';
import 'mock_complaint_repository.dart';
import 'mock_municipality_repository.dart';
import 'municipality_repository.dart';

// Repository Providers (Dependency Injection interface üzerinden)
final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return MockComplaintRepository();
});

final municipalityRepositoryProvider = Provider<MunicipalityRepository>((ref) {
  return MockMunicipalityRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

// Güncel Misafir Kullanıcı Provider'ı
final currentUserProvider = FutureProvider<AnonymousUser>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentUser();
});
