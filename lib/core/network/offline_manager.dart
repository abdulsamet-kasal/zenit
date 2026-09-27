import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/complaint.dart';
import '../../data/repositories/complaint_repository.dart';
import '../constants/app_constants.dart';

class OfflineManager {
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (_) {
      return true; // Fallback to optimistic online
    }
  }

  static Future<void> saveDraftComplaint(Complaint complaint) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = prefs.getStringList(AppConstants.keyDraftComplaints) ?? [];
    drafts.add(jsonEncode(complaint.toJson()));
    await prefs.setStringList(AppConstants.keyDraftComplaints, drafts);
  }

  static Future<List<Complaint>> getDraftComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = prefs.getStringList(AppConstants.keyDraftComplaints) ?? [];
    return drafts
        .map((e) => Complaint.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<int> syncPendingDrafts(ComplaintRepository repository) async {
    final connected = await isConnected();
    if (!connected) return 0;

    final drafts = await getDraftComplaints();
    if (drafts.isEmpty) return 0;

    int syncedCount = 0;
    for (final draft in drafts) {
      try {
        await repository.createComplaint(draft);
        syncedCount++;
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyDraftComplaints);
    return syncedCount;
  }
}
