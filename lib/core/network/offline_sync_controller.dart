import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/providers.dart';
import '../../features/feed/application/feed_controller.dart';
import 'offline_manager.dart';

class OfflineSyncState {
  final int pendingDraftCount;
  final bool isSyncing;
  final bool isOnline;
  final String? lastSyncMessage;

  const OfflineSyncState({
    this.pendingDraftCount = 0,
    this.isSyncing = false,
    this.isOnline = true,
    this.lastSyncMessage,
  });

  OfflineSyncState copyWith({
    int? pendingDraftCount,
    bool? isSyncing,
    bool? isOnline,
    String? lastSyncMessage,
  }) {
    return OfflineSyncState(
      pendingDraftCount: pendingDraftCount ?? this.pendingDraftCount,
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      lastSyncMessage: lastSyncMessage,
    );
  }
}

final offlineSyncProvider =
    NotifierProvider<OfflineSyncNotifier, OfflineSyncState>(
  OfflineSyncNotifier.new,
);

class OfflineSyncNotifier extends Notifier<OfflineSyncState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  OfflineSyncState build() {
    _init();
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const OfflineSyncState();
  }

  Future<void> _init() async {
    final drafts = await OfflineManager.getDraftComplaints();
    final isOnline = await OfflineManager.isConnected();
    state = state.copyWith(
      pendingDraftCount: drafts.length,
      isOnline: isOnline,
    );

    _subscription = Connectivity().onConnectivityChanged.listen((results) async {
      final online = !results.contains(ConnectivityResult.none);
      state = state.copyWith(isOnline: online);
      if (online && state.pendingDraftCount > 0 && !state.isSyncing) {
        await syncNow();
      }
    });

    if (isOnline && drafts.isNotEmpty) {
      await syncNow();
    }
  }

  Future<void> refreshDraftCount() async {
    final drafts = await OfflineManager.getDraftComplaints();
    state = state.copyWith(pendingDraftCount: drafts.length);
  }

  Future<int> syncNow() async {
    if (state.isSyncing) return 0;
    state = state.copyWith(isSyncing: true);

    try {
      final repo = ref.read(complaintRepositoryProvider);
      final syncedCount = await OfflineManager.syncPendingDrafts(repo);

      final remaining = await OfflineManager.getDraftComplaints();
      state = state.copyWith(
        isSyncing: false,
        pendingDraftCount: remaining.length,
        lastSyncMessage: syncedCount > 0
            ? '$syncedCount adet çevrimdışı bildirim başarıyla iletildi.'
            : null,
      );

      if (syncedCount > 0) {
        ref.read(feedControllerProvider.notifier).loadInitial();
      }
      return syncedCount;
    } catch (_) {
      state = state.copyWith(isSyncing: false);
      return 0;
    }
  }
}
