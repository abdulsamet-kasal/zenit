import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/comment.dart';
import '../models/complaint.dart';
import '../models/complaint_status.dart';
import 'complaint_repository.dart';
import 'mock_complaint_repository.dart';

class SupabaseComplaintRepository implements ComplaintRepository {
  final MockComplaintRepository _fallbackRepo = MockComplaintRepository();

  /// Kullanıcının beğendiği ve onayladığı (ben de gördüm) yerel şikayet ID listesini uygular
  Future<List<Complaint>> _applyLocalStateToList(List<Complaint> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final liked = prefs.getStringList(AppConstants.keyLikedComplaints) ?? [];
      final confirmed =
          prefs.getStringList(AppConstants.keyConfirmedComplaints) ?? [];

      return list.map((c) {
        final isLiked = liked.contains(c.id);
        final isConfirmed = confirmed.contains(c.id);
        return c.copyWith(
          isLikedByMe: isLiked,
          isConfirmedByMe: isConfirmed,
        );
      }).toList();
    } catch (_) {
      return list;
    }
  }

  /// Tek bir şikayet için yerel beğeni ve onay durumunu uygular
  Future<Complaint> _applyLocalStateToSingle(Complaint complaint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final liked = prefs.getStringList(AppConstants.keyLikedComplaints) ?? [];
      final confirmed =
          prefs.getStringList(AppConstants.keyConfirmedComplaints) ?? [];

      return complaint.copyWith(
        isLikedByMe: liked.contains(complaint.id),
        isConfirmedByMe: confirmed.contains(complaint.id),
      );
    } catch (_) {
      return complaint;
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
    final client = SupabaseConfig.client;
    if (client == null) {
      final fallbackList = await _fallbackRepo.getFeed(
        page: page,
        limit: limit,
        categoryId: categoryId,
        municipalityId: municipalityId,
        status: status,
        searchQuery: searchQuery,
        sortBy: sortBy,
      );
      return _applyLocalStateToList(fallbackList);
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
      if (sortBy == 'supported' || sortBy == 'most_supported') {
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
        return await _applyLocalStateToList(list);
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getFeed hatası: $e. Mock veriye geçiliyor.');
    }

    final fallbackList = await _fallbackRepo.getFeed(
      page: page,
      limit: limit,
      categoryId: categoryId,
      municipalityId: municipalityId,
      status: status,
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
    return _applyLocalStateToList(fallbackList);
  }

  @override
  Future<Complaint?> getComplaintById(String id) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final response = await client
            .from('complaints')
            .select()
            .eq('id', id)
            .maybeSingle();

        if (response != null) {
          final c = Complaint.fromJson(response);
          return await _applyLocalStateToSingle(c);
        }
      } catch (e) {
        debugPrint('⚠️ Supabase getComplaintById hatası: $e');
      }
    }

    final fallback = await _fallbackRepo.getComplaintById(id);
    if (fallback != null) {
      return _applyLocalStateToSingle(fallback);
    }
    return null;
  }

  Future<List<String>> _uploadPhotos(List<String> photoUrls) async {
    final client = SupabaseConfig.client;
    if (client == null) return photoUrls;

    final result = <String>[];
    for (final path in photoUrls) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        result.add(path);
        continue;
      }

      try {
        final cleanPath = path.replaceFirst('file://', '');
        final file = File(cleanPath);
        if (await file.exists()) {
          final ext = cleanPath.split('.').last.toLowerCase();
          final mimeType = ext == 'png'
              ? 'image/png'
              : ext == 'webp'
                  ? 'image/webp'
                  : 'image/jpeg';
          final fileName =
              'complaint_${DateTime.now().millisecondsSinceEpoch}_${cleanPath.hashCode.abs()}.$ext';
          final bytes = await file.readAsBytes();

          await client.storage.from('complaint-photos').uploadBinary(
                fileName,
                bytes,
                fileOptions: FileOptions(
                  contentType: mimeType,
                  upsert: true,
                ),
              );

          final publicUrl =
              client.storage.from('complaint-photos').getPublicUrl(fileName);
          debugPrint('📸 Fotoğraf Supabase Storage\'a başarıyla yüklendi: $publicUrl');
          result.add(publicUrl);
        } else {
          result.add(path);
        }
      } catch (e) {
        debugPrint('⚠️ Fotoğraf yükleme hatası ($path): $e');
        result.add(path);
      }
    }
    return result;
  }

  @override
  Future<Complaint> createComplaint(Complaint complaint) async {
    // 1. Önce fotoğrafları Supabase Storage'a yükle
    final uploadedPhotos = await _uploadPhotos(complaint.photoUrls);
    final complaintToSave = complaint.copyWith(photoUrls: uploadedPhotos);

    // 2. Mock / Yerel depoya kaydet
    final localResult = await _fallbackRepo.createComplaint(complaintToSave);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('complaints').upsert(complaintToSave.toSupabaseMap());
        debugPrint('✅ Şikayet Supabase veritabanına aktarıldı: ${complaintToSave.id}');
      } catch (e) {
        debugPrint('⚠️ Supabase createComplaint hatası: $e. Yerel depolamada saklandı.');
      }
    }

    return localResult;
  }

  @override
  Future<Complaint> toggleLike(String complaintId, String userId) async {
    // 1. SharedPreferences üzerindeki beğeni listesini oku ve tersine çevir
    final prefs = await SharedPreferences.getInstance();
    final likedList = prefs.getStringList(AppConstants.keyLikedComplaints) ?? [];
    final wasLiked = likedList.contains(complaintId);
    final isLiked = !wasLiked;

    if (isLiked) {
      likedList.add(complaintId);
    } else {
      likedList.remove(complaintId);
    }
    await prefs.setStringList(AppConstants.keyLikedComplaints, likedList);

    // 2. Canlı Supabase tablosunu güncelle
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        if (isLiked) {
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

    // 3. Fallback repo'yu da güvenli şekilde güncelle
    try {
      await _fallbackRepo.toggleLike(complaintId, userId);
    } catch (_) {}

    // 4. Güncel complaint nesnesini döndür
    final existing = await getComplaintById(complaintId);
    if (existing != null) {
      final currentLikes = existing.likeCount;
      final newLikes = isLiked
          ? (wasLiked ? currentLikes : currentLikes + 1)
          : (wasLiked ? (currentLikes > 0 ? currentLikes - 1 : 0) : currentLikes);

      return existing.copyWith(
        isLikedByMe: isLiked,
        likeCount: newLikes,
      );
    }

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

  @override
  Future<Complaint> toggleConfirm(String complaintId, String userId) async {
    // 1. SharedPreferences üzerindeki onay (ben de gördüm) listesini güncelle
    final prefs = await SharedPreferences.getInstance();
    final confirmedList =
        prefs.getStringList(AppConstants.keyConfirmedComplaints) ?? [];
    final wasConfirmed = confirmedList.contains(complaintId);
    final isConfirmed = !wasConfirmed;

    if (isConfirmed) {
      confirmedList.add(complaintId);
    } else {
      confirmedList.remove(complaintId);
    }
    await prefs.setStringList(
        AppConstants.keyConfirmedComplaints, confirmedList);

    // 2. Canlı Supabase tablosunu güncelle
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        if (isConfirmed) {
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

    // 3. Fallback repo'yu da güvenli şekilde güncelle
    try {
      await _fallbackRepo.toggleConfirm(complaintId, userId);
    } catch (_) {}

    // 4. Güncel complaint nesnesini döndür
    final existing = await getComplaintById(complaintId);
    if (existing != null) {
      final currentConfirms = existing.confirmCount;
      final newConfirms = isConfirmed
          ? (wasConfirmed ? currentConfirms : currentConfirms + 1)
          : (wasConfirmed
              ? (currentConfirms > 0 ? currentConfirms - 1 : 0)
              : currentConfirms);

      return existing.copyWith(
        isConfirmedByMe: isConfirmed,
        confirmCount: newConfirms,
      );
    }

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

  @override
  Future<List<Comment>> getComments(String complaintId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final response = await client
            .from('complaint_comments')
            .select()
            .eq('complaint_id', complaintId)
            .order('created_at', ascending: true);

        return (response as List<dynamic>)
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ Supabase getComments hatası: $e');
      }
    }

    return _fallbackRepo.getComments(complaintId);
  }

  @override
  Future<Comment> addComment(Comment comment) async {
    try {
      await _fallbackRepo.addComment(comment);
    } catch (_) {}

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
        debugPrint('💬 Yorum Supabase\'e başarıyla eklendi: ${comment.id}');
      } catch (e) {
        debugPrint('⚠️ Supabase addComment hatası: $e');
      }
    }

    return comment;
  }

  @override
  Future<List<Complaint>> getComplaintsByMunicipality(
      String municipalityId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final response = await client
            .from('complaints')
            .select()
            .eq('municipality_id', municipalityId)
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
            .toList();

        if (list.isNotEmpty) {
          return await _applyLocalStateToList(list);
        }
      } catch (e) {
        debugPrint('⚠️ Supabase getComplaintsByMunicipality hatası: $e');
      }
    }

    final fallback =
        await _fallbackRepo.getComplaintsByMunicipality(municipalityId);
    return _applyLocalStateToList(fallback);
  }

  @override
  Future<List<Complaint>> getComplaintsByUser(String userId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final response = await client
            .from('complaints')
            .select()
            .eq('author_id', userId)
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
            .toList();

        if (list.isNotEmpty) {
          return await _applyLocalStateToList(list);
        }
      } catch (e) {
        debugPrint('⚠️ Supabase getComplaintsByUser hatası: $e');
      }
    }

    final fallback = await _fallbackRepo.getComplaintsByUser(userId);
    return _applyLocalStateToList(fallback);
  }

  @override
  Future<void> submitDispute(
      String complaintId, String userId, String reason) async {
    try {
      await _fallbackRepo.submitDispute(complaintId, userId, reason);
    } catch (_) {}

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
    try {
      await _fallbackRepo.rateComplaint(complaintId, userId, rating);
    } catch (_) {}

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

    final updated = await getComplaintById(complaintId);
    if (updated != null) {
      return updated.copyWith(myRating: rating);
    }

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

  @override
  Future<void> deleteComplaint(String complaintId, String userId) async {
    // 1. Yerel depodan / önbellekten sil
    try {
      await _fallbackRepo.deleteComplaint(complaintId, userId);
    } catch (_) {}

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        // İlgili şikayetin fotoğraflarını storage'dan temizle
        final existing = await client
            .from('complaints')
            .select('photo_urls')
            .eq('id', complaintId)
            .maybeSingle();

        if (existing != null && existing['photo_urls'] != null) {
          final urls = (existing['photo_urls'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          final filePaths = <String>[];
          for (final url in urls) {
            if (url.contains('complaint-photos/')) {
              final path = url.split('complaint-photos/').last;
              filePaths.add(path);
            }
          }
          if (filePaths.isNotEmpty) {
            try {
              await client.storage.from('complaint-photos').remove(filePaths);
            } catch (e) {
              debugPrint('⚠️ Storage dosya silme uyarısı: $e');
            }
          }
        }

        // Veritabanından şikayeti sil (Cascade ile beğeniler, yorumlar silinir)
        await client
            .from('complaints')
            .delete()
            .eq('id', complaintId)
            .eq('author_id', userId);
      } catch (e) {
        debugPrint('⚠️ Supabase deleteComplaint hatası: $e');
        rethrow;
      }
    }
  }
}
