import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/comment.dart';
import '../models/complaint.dart';
import '../models/complaint_status.dart';
import 'complaint_repository.dart';

class MockComplaintRepository implements ComplaintRepository {
  List<Complaint>? _cachedComplaints;
  final Map<String, List<Comment>> _commentsByComplaintId = {};
  final List<Map<String, dynamic>> _disputes = [];

  Future<void> _ensureLoaded() async {
    if (_cachedComplaints != null) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/mock/complaints.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedComplaints =
          jsonList.map((e) => Complaint.fromJson(e as Map<String, dynamic>)).toList();

      // Mock default comments for first few complaints
      _commentsByComplaintId['c-001'] = [
        Comment(
          id: 'comm-1',
          complaintId: 'c-001',
          anonymousUserId: 'u-55',
          anonymousUserName: 'Misafir Vatandaş #2109',
          text: 'Dün akşam geçerken neredeyse ayağım takılıp düşüyordum, acilen tamir edilmeli.',
          createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        Comment(
          id: 'comm-2',
          complaintId: 'c-001',
          anonymousUserId: 'u-88',
          anonymousUserName: 'Misafir Vatandaş #6543',
          text: 'Fen İşleri ekiplerine telefonla da bildirdik, umarım en kısa sürede gelirler.',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];
    } catch (e) {
      _cachedComplaints = [];
    }
  }

  @override
  Future<List<Complaint>> getFeed({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? municipalityId,
    String? status,
    String? searchQuery,
  }) async {
    await _ensureLoaded();

    Iterable<Complaint> filtered = _cachedComplaints!;

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      filtered = filtered.where((c) => c.categoryId == categoryId);
    }

    if (municipalityId != null && municipalityId.isNotEmpty) {
      filtered = filtered.where((c) => c.municipalityId == municipalityId);
    }

    if (status != null && status.isNotEmpty && status != 'all') {
      final targetStatus = ComplaintStatus.fromString(status);
      filtered = filtered.where((c) => c.status == targetStatus);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      filtered = filtered.where((c) =>
          c.description.toLowerCase().contains(query) ||
          c.address.toLowerCase().contains(query) ||
          (c.title != null && c.title!.toLowerCase().contains(query)));
    }

    // Sort by createdAt descending (newest first)
    final sortedList = filtered.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Pagination
    final startIndex = (page - 1) * limit;
    if (startIndex >= sortedList.length) {
      return [];
    }

    final endIndex = (startIndex + limit).clamp(0, sortedList.length);
    return sortedList.sublist(startIndex, endIndex);
  }

  @override
  Future<Complaint?> getComplaintById(String id) async {
    await _ensureLoaded();
    try {
      return _cachedComplaints!.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Complaint> createComplaint(Complaint complaint) async {
    await _ensureLoaded();
    _cachedComplaints!.insert(0, complaint);
    return complaint;
  }

  @override
  Future<Complaint> toggleLike(String complaintId, String userId) async {
    await _ensureLoaded();
    final index = _cachedComplaints!.indexWhere((c) => c.id == complaintId);
    if (index == -1) throw Exception('Şikayet bulunamadı');

    final existing = _cachedComplaints![index];
    final isLiked = !existing.isLikedByMe;
    final updated = existing.copyWith(
      isLikedByMe: isLiked,
      likeCount: isLiked ? existing.likeCount + 1 : existing.likeCount - 1,
    );

    _cachedComplaints![index] = updated;
    return updated;
  }

  @override
  Future<Complaint> toggleConfirm(String complaintId, String userId) async {
    await _ensureLoaded();
    final index = _cachedComplaints!.indexWhere((c) => c.id == complaintId);
    if (index == -1) throw Exception('Şikayet bulunamadı');

    final existing = _cachedComplaints![index];
    final isConfirmed = !existing.isConfirmedByMe;
    final updated = existing.copyWith(
      isConfirmedByMe: isConfirmed,
      confirmCount:
          isConfirmed ? existing.confirmCount + 1 : existing.confirmCount - 1,
    );

    _cachedComplaints![index] = updated;
    return updated;
  }

  @override
  Future<List<Comment>> getComments(String complaintId) async {
    await _ensureLoaded();
    return _commentsByComplaintId[complaintId] ?? [];
  }

  @override
  Future<Comment> addComment(Comment comment) async {
    await _ensureLoaded();
    final list = _commentsByComplaintId.putIfAbsent(comment.complaintId, () => []);
    list.insert(0, comment);

    // Update comment count on complaint
    final index =
        _cachedComplaints!.indexWhere((c) => c.id == comment.complaintId);
    if (index != -1) {
      final existing = _cachedComplaints![index];
      _cachedComplaints![index] = existing.copyWith(
        commentCount: existing.commentCount + 1,
      );
    }

    return comment;
  }

  @override
  Future<List<Complaint>> getComplaintsByMunicipality(
      String municipalityId) async {
    await _ensureLoaded();
    return _cachedComplaints!
        .where((c) => c.municipalityId == municipalityId)
        .toList();
  }

  @override
  Future<List<Complaint>> getComplaintsByUser(String userId) async {
    await _ensureLoaded();
    return _cachedComplaints!
        .where((c) => c.anonymousUserId == userId)
        .toList();
  }

  @override
  Future<void> submitDispute(
      String complaintId, String userId, String reason) async {
    _disputes.add({
      'complaintId': complaintId,
      'userId': userId,
      'reason': reason,
      'submittedAt': DateTime.now().toIso8601String(),
    });
  }
}
