import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import '../models/comment.dart';
import '../models/complaint.dart';
import 'complaint_repository.dart';
import 'mock_complaint_repository.dart';

class SupabaseComplaintRepository implements ComplaintRepository {
  final MockComplaintRepository _fallbackRepo = MockComplaintRepository();

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
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getFeed(
        page: page,
        limit: limit,
        categoryId: categoryId,
        municipalityId: municipalityId,
        status: status,
        searchQuery: searchQuery,
        sortBy: sortBy,
      );
    }

    try {
      dynamic filterQuery = client.from('complaints').select();

      if (categoryId != null && categoryId.isNotEmpty) {
        filterQuery = filterQuery.eq('category_id', categoryId);
      }
      if (municipalityId != null && municipalityId.isNotEmpty) {
        filterQuery = filterQuery.eq('municipality_id', municipalityId);
      }
      if (status != null && status.isNotEmpty) {
        filterQuery = filterQuery.eq('status', status);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        filterQuery = filterQuery.or('title.ilike.%$q%,description.ilike.%$q%');
      }

      // Sıralama
      dynamic transformQuery;
      if (sortBy == 'supported') {
        transformQuery = filterQuery.order('likes_count', ascending: false);
      } else if (sortBy == 'sla_urgent') {
        transformQuery = filterQuery.order('sla_deadline', ascending: true);
      } else {
        transformQuery = filterQuery.order('created_at', ascending: false);
      }

      final fromIndex = (page - 1) * limit;
      final toIndex = fromIndex + limit - 1;
      final response = await transformQuery.range(fromIndex, toIndex);

      final list = (response as List<dynamic>)
          .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) {
        return list;
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getFeed hatası: $e. Mock veriye geçiliyor.');
    }

    return _fallbackRepo.getFeed(
      page: page,
      limit: limit,
      categoryId: categoryId,
      municipalityId: municipalityId,
      status: status,
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
  }

  @override
  Future<Complaint?> getComplaintById(String id) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getComplaintById(id);
    }

    try {
      final response = await client
          .from('complaints')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return Complaint.fromJson(response);
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getComplaintById hatası: $e');
    }

    return _fallbackRepo.getComplaintById(id);
  }

  @override
  Future<Complaint> createComplaint(Complaint complaint) async {
    // Önce yerel önbelleğe ve SharedPreferences'a ekle (çevrimdışı güvenliği)
    final localResult = await _fallbackRepo.createComplaint(complaint);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('complaints').upsert(complaint.toSupabaseMap());
        debugPrint('✅ Şikayet Supabase veritabanına aktarıldı: ${complaint.id}');
      } catch (e) {
        debugPrint('⚠️ Supabase createComplaint hatası: $e. Yerel depolamada saklandı.');
      }
    }

    return localResult;
  }

  @override
  Future<Complaint> toggleLike(String complaintId, String userId) async {
    final updated = await _fallbackRepo.toggleLike(complaintId, userId);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        if (updated.isLikedByMe) {
          await client.from('complaint_likes').insert({
            'complaint_id': complaintId,
            'user_id': userId,
          });
        } else {
          await client
              .from('complaint_likes')
              .delete()
              .eq('complaint_id', complaintId)
              .eq('user_id', userId);
        }
      } catch (e) {
        debugPrint('⚠️ Supabase toggleLike hatası: $e');
      }
    }

    return updated;
  }

  @override
  Future<Complaint> toggleConfirm(String complaintId, String userId) async {
    final updated = await _fallbackRepo.toggleConfirm(complaintId, userId);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        if (updated.isConfirmedByMe) {
          await client.from('complaint_confirmations').insert({
            'complaint_id': complaintId,
            'user_id': userId,
          });
        } else {
          await client
              .from('complaint_confirmations')
              .delete()
              .eq('complaint_id', complaintId)
              .eq('user_id', userId);
        }
      } catch (e) {
        debugPrint('⚠️ Supabase toggleConfirm hatası: $e');
      }
    }

    return updated;
  }

  @override
  Future<List<Comment>> getComments(String complaintId) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getComments(complaintId);
    }

    try {
      final response = await client
          .from('complaint_comments')
          .select()
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);

      final list = (response as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('⚠️ Supabase getComments hatası: $e');
    }

    return _fallbackRepo.getComments(complaintId);
  }

  @override
  Future<Comment> addComment(Comment comment) async {
    final localComment = await _fallbackRepo.addComment(comment);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('complaint_comments').insert({
          'id': comment.id,
          'complaint_id': comment.complaintId,
          'author_id': comment.anonymousUserId,
          'author_name': comment.anonymousUserName,
          'content': comment.text,
          'created_at': comment.createdAt.toIso8601String(),
          'is_official': comment.isOfficial,
        });
      } catch (e) {
        debugPrint('⚠️ Supabase addComment hatası: $e');
      }
    }

    return localComment;
  }

  @override
  Future<List<Complaint>> getComplaintsByMunicipality(
      String municipalityId) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return _fallbackRepo.getComplaintsByMunicipality(municipalityId);
    }

    try {
      final response = await client
          .from('complaints')
          .select()
          .eq('municipality_id', municipalityId)
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('⚠️ Supabase getComplaintsByMunicipality hatası: $e');
    }

    return _fallbackRepo.getComplaintsByMunicipality(municipalityId);
  }

  @override
  Future<List<Complaint>> getComplaintsByUser(String userId) async {
    return _fallbackRepo.getComplaintsByUser(userId);
  }

  @override
  Future<void> submitDispute(
      String complaintId, String userId, String reason) async {
    await _fallbackRepo.submitDispute(complaintId, userId, reason);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('complaint_disputes').insert({
          'id': 'disp-${DateTime.now().millisecondsSinceEpoch}',
          'complaint_id': complaintId,
          'author_id': userId,
          'reason': reason,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e) {
        debugPrint('⚠️ Supabase submitDispute hatası: $e');
      }
    }
  }

  @override
  Future<Complaint> rateComplaint(
      String complaintId, String userId, int rating) async {
    final updated =
        await _fallbackRepo.rateComplaint(complaintId, userId, rating);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('complaints').update({
          'citizen_satisfaction_rating': rating,
        }).eq('id', complaintId);
      } catch (e) {
        debugPrint('⚠️ Supabase rateComplaint hatası: $e');
      }
    }

    return updated;
  }
}
