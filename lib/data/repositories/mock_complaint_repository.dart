import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
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
      final prefs = await SharedPreferences.getInstance();

      // 1. Load base mock complaints from assets
      final jsonString =
          await rootBundle.loadString('assets/mock/complaints.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final baseComplaints = jsonList
          .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
          .toList();

      // 2. Load custom user complaints from SharedPreferences
      final customListJson =
          prefs.getStringList(AppConstants.keyCustomComplaints) ?? [];
      final customComplaints = customListJson
          .map((e) =>
              Complaint.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();

      // Combine: custom complaints first
      final all = [...customComplaints, ...baseComplaints];

      // 3. Apply persistent likes and confirms
      final likedIds =
          prefs.getStringList(AppConstants.keyLikedComplaints) ?? [];
      final confirmedIds =
          prefs.getStringList(AppConstants.keyConfirmedComplaints) ?? [];

      // 4. Apply persistent ratings
      final ratingsRaw =
          prefs.getString(AppConstants.keyComplaintRatings);
      Map<String, dynamic> ratingsMap = {};
      if (ratingsRaw != null) {
        try {
          ratingsMap = jsonDecode(ratingsRaw) as Map<String, dynamic>;
        } catch (_) {}
      }

      _cachedComplaints = all.map((c) {
        final isLiked = likedIds.contains(c.id);
        final isConfirmed = confirmedIds.contains(c.id);
        final userRating = ratingsMap[c.id] as int?;

        var updated = c;
        if (isLiked != c.isLikedByMe) {
          updated = updated.copyWith(
            isLikedByMe: isLiked,
            likeCount: isLiked ? c.likeCount + 1 : c.likeCount,
          );
        }
        if (isConfirmed != c.isConfirmedByMe) {
          updated = updated.copyWith(
            isConfirmedByMe: isConfirmed,
            confirmCount: isConfirmed ? c.confirmCount + 1 : c.confirmCount,
          );
        }
        if (userRating != null) {
          final count = updated.ratingCount > 0 ? updated.ratingCount : 1;
          final avg = updated.averageRating > 0
              ? (updated.averageRating * count + userRating) / (count + 1)
              : userRating.toDouble();
          updated = updated.copyWith(
            myRating: userRating,
            ratingCount: count,
            averageRating: avg,
          );
        }
        return updated;
      }).toList();

      // 5. Load default mock comments
      _commentsByComplaintId['c-001'] = [
        Comment(
          id: 'comm-1',
          complaintId: 'c-001',
          anonymousUserId: 'u-55',
          anonymousUserName: 'Misafir Vatandaş #2109',
          text:
              'Dün akşam geçerken neredeyse ayağım takılıp düşüyordum, acilen tamir edilmeli.',
          createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        Comment(
          id: 'comm-2',
          complaintId: 'c-001',
          anonymousUserId: 'u-88',
          anonymousUserName: 'Misafir Vatandaş #6543',
          text:
              'Fen İşleri ekiplerine telefonla da bildirdik, umarım en kısa sürede gelirler.',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];

      // Load custom saved comments from SharedPreferences
      final savedCommentsJson = prefs.getStringList('seffaf_custom_comments') ?? [];
      for (final raw in savedCommentsJson) {
        try {
          final comm = Comment.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          final list = _commentsByComplaintId.putIfAbsent(comm.complaintId, () => []);
          if (!list.any((c) => c.id == comm.id)) {
            list.insert(0, comm);
          }
        } catch (_) {}
      }
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
    String? sortBy,
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

    // Sort by requested criteria
    final sortedList = filtered.toList();
    if (sortBy == 'most_supported') {
      sortedList.sort((a, b) =>
          (b.likeCount + b.confirmCount).compareTo(a.likeCount + a.confirmCount));
    } else if (sortBy == 'sla_urgent') {
      // Unresolved first, closest to deadline first
      sortedList.sort((a, b) {
        if (a.status == ComplaintStatus.resolved &&
            b.status != ComplaintStatus.resolved) {
          return 1;
        }
        if (b.status == ComplaintStatus.resolved &&
            a.status != ComplaintStatus.resolved) {
          return -1;
        }
        return a.slaDeadline.compareTo(b.slaDeadline);
      });
    } else {
      // Default: newest first
      sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }


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

    // Save to SharedPreferences for persistence across restarts
    try {
      final prefs = await SharedPreferences.getInstance();
      final customListJson =
          prefs.getStringList(AppConstants.keyCustomComplaints) ?? [];
      customListJson.insert(0, jsonEncode(complaint.toJson()));
      await prefs.setStringList(
          AppConstants.keyCustomComplaints, customListJson);
    } catch (_) {}

    return complaint;
  }

  @override
  Future<Complaint> toggleLike(String complaintId, String userId) async {
    await _ensureLoaded();
    final index = _cachedComplaints!.indexWhere((c) => c.id == complaintId);
    if (index == -1) {
      final prefs = await SharedPreferences.getInstance();
      final liked = prefs.getStringList(AppConstants.keyLikedComplaints) ?? [];
      final isLiked = !liked.contains(complaintId);
      if (isLiked) {
        liked.add(complaintId);
      } else {
        liked.remove(complaintId);
      }
      await prefs.setStringList(AppConstants.keyLikedComplaints, liked);

      return Complaint(
        id: complaintId,
        anonymousUserId: userId,
        anonymousUserName: 'Vatandaş',
        description: '',
        categoryId: 'other',
        status: ComplaintStatus.pending,
        createdAt: DateTime.now(),
        slaDeadline: DateTime.now().add(const Duration(days: 3)),
        municipalityId: 'unknown',
        latitude: 0,
        longitude: 0,
        address: '',
        photoUrls: const [],
        isLikedByMe: isLiked,
        likeCount: isLiked ? 1 : 0,
      );
    }

    final existing = _cachedComplaints![index];
    final isLiked = !existing.isLikedByMe;
    final updated = existing.copyWith(
      isLikedByMe: isLiked,
      likeCount: isLiked ? existing.likeCount + 1 : (existing.likeCount > 0 ? existing.likeCount - 1 : 0),
    );

    _cachedComplaints![index] = updated;

    // Persist likes
    try {
      final prefs = await SharedPreferences.getInstance();
      final liked = prefs.getStringList(AppConstants.keyLikedComplaints) ?? [];
      if (isLiked) {
        if (!liked.contains(complaintId)) liked.add(complaintId);
      } else {
        liked.remove(complaintId);
      }
      await prefs.setStringList(AppConstants.keyLikedComplaints, liked);
    } catch (_) {}

    return updated;
  }

  @override
  Future<Complaint> toggleConfirm(String complaintId, String userId) async {
    await _ensureLoaded();
    final index = _cachedComplaints!.indexWhere((c) => c.id == complaintId);
    if (index == -1) {
      final prefs = await SharedPreferences.getInstance();
      final confirmed =
          prefs.getStringList(AppConstants.keyConfirmedComplaints) ?? [];
      final isConfirmed = !confirmed.contains(complaintId);
      if (isConfirmed) {
        confirmed.add(complaintId);
      } else {
        confirmed.remove(complaintId);
      }
      await prefs.setStringList(
          AppConstants.keyConfirmedComplaints, confirmed);

      return Complaint(
        id: complaintId,
        anonymousUserId: userId,
        anonymousUserName: 'Vatandaş',
        description: '',
        categoryId: 'other',
        status: ComplaintStatus.pending,
        createdAt: DateTime.now(),
        slaDeadline: DateTime.now().add(const Duration(days: 3)),
        municipalityId: 'unknown',
        latitude: 0,
        longitude: 0,
        address: '',
        photoUrls: const [],
        isConfirmedByMe: isConfirmed,
        confirmCount: isConfirmed ? 1 : 0,
      );
    }

    final existing = _cachedComplaints![index];
    final isConfirmed = !existing.isConfirmedByMe;
    final updated = existing.copyWith(
      isConfirmedByMe: isConfirmed,
      confirmCount:
          isConfirmed ? existing.confirmCount + 1 : (existing.confirmCount > 0 ? existing.confirmCount - 1 : 0),
    );

    _cachedComplaints![index] = updated;

    // Persist confirms
    try {
      final prefs = await SharedPreferences.getInstance();
      final confirmed =
          prefs.getStringList(AppConstants.keyConfirmedComplaints) ?? [];
      if (isConfirmed) {
        if (!confirmed.contains(complaintId)) confirmed.add(complaintId);
      } else {
        confirmed.remove(complaintId);
      }
      await prefs.setStringList(
          AppConstants.keyConfirmedComplaints, confirmed);
    } catch (_) {}

    return updated;
  }

  @override
  Future<Complaint> rateComplaint(
      String complaintId, String userId, int rating) async {
    await _ensureLoaded();
    final index = _cachedComplaints!.indexWhere((c) => c.id == complaintId);
    if (index == -1) {
      return Complaint(
        id: complaintId,
        anonymousUserId: userId,
        anonymousUserName: 'Vatandaş',
        description: '',
        categoryId: 'other',
        status: ComplaintStatus.resolved,
        createdAt: DateTime.now(),
        slaDeadline: DateTime.now().add(const Duration(days: 3)),
        municipalityId: 'unknown',
        latitude: 0,
        longitude: 0,
        address: '',
        photoUrls: const [],
        myRating: rating,
      );
    }

    final existing = _cachedComplaints![index];
    final previousRating = existing.myRating;
    final newCount = previousRating == null
        ? existing.ratingCount + 1
        : existing.ratingCount;
    final totalRatingSum = (existing.averageRating * existing.ratingCount) -
        (previousRating ?? 0) +
        rating;
    final newAvg = newCount > 0 ? (totalRatingSum / newCount) : rating.toDouble();

    final updated = existing.copyWith(
      myRating: rating,
      ratingCount: newCount,
      averageRating: double.parse(newAvg.toStringAsFixed(1)),
    );

    _cachedComplaints![index] = updated;

    // Persist rating
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsRaw =
          prefs.getString(AppConstants.keyComplaintRatings);
      Map<String, dynamic> ratingsMap = {};
      if (ratingsRaw != null) {
        try {
          ratingsMap = jsonDecode(ratingsRaw) as Map<String, dynamic>;
        } catch (_) {}
      }
      ratingsMap[complaintId] = rating;
      await prefs.setString(
          AppConstants.keyComplaintRatings, jsonEncode(ratingsMap));
    } catch (_) {}

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
    final list =
        _commentsByComplaintId.putIfAbsent(comment.complaintId, () => []);
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

    // Persist comment
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCommentsJson =
          prefs.getStringList('seffaf_custom_comments') ?? [];
      savedCommentsJson.insert(0, jsonEncode(comment.toJson()));
      await prefs.setStringList(
          'seffaf_custom_comments', savedCommentsJson);
    } catch (_) {}

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

  @override
  Future<void> deleteComplaint(String complaintId, String userId) async {
    await _ensureLoaded();
    _cachedComplaints?.removeWhere((c) => c.id == complaintId);

    // Yerel depodan ve kullanıcının şikayet listesinden temizle
    try {
      final prefs = await SharedPreferences.getInstance();
      final customListJson =
          prefs.getStringList(AppConstants.keyCustomComplaints) ?? [];
      customListJson.removeWhere((item) {
        try {
          final map = jsonDecode(item) as Map<String, dynamic>;
          return map['id'] == complaintId;
        } catch (_) {
          return false;
        }
      });
      await prefs.setStringList(
          AppConstants.keyCustomComplaints, customListJson);

      final createdIds =
          prefs.getStringList('seffaf_created_complaints') ?? [];
      createdIds.remove(complaintId);
      await prefs.setStringList('seffaf_created_complaints', createdIds);
    } catch (_) {}
  }
}

