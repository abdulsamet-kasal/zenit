import '../models/comment.dart';
import '../models/complaint.dart';

abstract class ComplaintRepository {
  Future<List<Complaint>> getFeed({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? municipalityId,
    String? status,
    String? searchQuery,
    String? sortBy,
  });


  Future<Complaint?> getComplaintById(String id);

  Future<Complaint> createComplaint(Complaint complaint);

  Future<Complaint> toggleLike(String complaintId, String userId);

  Future<Complaint> toggleConfirm(String complaintId, String userId);

  Future<List<Comment>> getComments(String complaintId);

  Future<Comment> addComment(Comment comment);

  Future<List<Complaint>> getComplaintsByMunicipality(String municipalityId);

  Future<List<Complaint>> getComplaintsByUser(String userId);

  Future<void> submitDispute(String complaintId, String userId, String reason);

  Future<Complaint> rateComplaint(String complaintId, String userId, int rating);

  Future<void> deleteComplaint(String complaintId, String userId);
}

