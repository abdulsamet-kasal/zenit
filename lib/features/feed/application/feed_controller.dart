import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/complaint.dart';
import '../../../data/repositories/providers.dart';

class FeedState {
  final List<Complaint> complaints;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? selectedCategory;
  final String? selectedStatus;
  final String? searchQuery;
  final String sortBy;
  final String? errorMessage;

  const FeedState({
    this.complaints = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.selectedCategory,
    this.selectedStatus,
    this.searchQuery,
    this.sortBy = 'newest',
    this.errorMessage,
  });

  FeedState copyWith({
    List<Complaint>? complaints,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? selectedCategory,
    String? selectedStatus,
    String? searchQuery,
    String? sortBy,
    String? errorMessage,
  }) {
    return FeedState(
      complaints: complaints ?? this.complaints,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      errorMessage: errorMessage,
    );
  }
}

class FeedController extends Notifier<FeedState> {
  @override
  FeedState build() {
    // Initial fetch on creation
    Future.microtask(() => loadInitial());
    return const FeedState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, page: 1, errorMessage: null);

    try {
      final repo = ref.read(complaintRepositoryProvider);
      final results = await repo.getFeed(
        page: 1,
        limit: 10,
        categoryId: state.selectedCategory,
        status: state.selectedStatus,
        searchQuery: state.searchQuery,
        sortBy: state.sortBy,
      );

      state = state.copyWith(
        complaints: results,
        isLoading: false,
        hasMore: results.length >= 10,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Şikayetler yüklenirken bir sorun oluştu: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;

    try {
      final repo = ref.read(complaintRepositoryProvider);
      final newResults = await repo.getFeed(
        page: nextPage,
        limit: 10,
        categoryId: state.selectedCategory,
        status: state.selectedStatus,
        searchQuery: state.searchQuery,
        sortBy: state.sortBy,
      );

      state = state.copyWith(
        complaints: [...state.complaints, ...newResults],
        isLoadingMore: false,
        hasMore: newResults.length >= 10,
        page: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> setSortBy(String sortBy) async {
    if (state.sortBy == sortBy) return;
    state = state.copyWith(sortBy: sortBy);
    await loadInitial();
  }

  Future<void> setCategory(String? categoryId) async {

    if (state.selectedCategory == categoryId) return;
    state = state.copyWith(selectedCategory: categoryId);
    await loadInitial();
  }

  Future<void> setStatus(String? status) async {
    if (state.selectedStatus == status) return;
    state = state.copyWith(selectedStatus: status);
    await loadInitial();
  }

  Future<void> setSearchQuery(String? query) async {
    state = state.copyWith(searchQuery: query);
    await loadInitial();
  }

  Future<void> toggleLike(String complaintId) async {
    try {
      final currentUser = await ref.read(currentUserProvider.future);
      final repo = ref.read(complaintRepositoryProvider);
      final updated = await repo.toggleLike(complaintId, currentUser.id);

      final index = state.complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        final list = List<Complaint>.from(state.complaints);
        list[index] = updated;
        state = state.copyWith(complaints: list);
      }
    } catch (_) {}
  }

  Future<void> toggleConfirm(String complaintId) async {
    try {
      final currentUser = await ref.read(currentUserProvider.future);
      final repo = ref.read(complaintRepositoryProvider);
      final updated = await repo.toggleConfirm(complaintId, currentUser.id);

      final index = state.complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        final list = List<Complaint>.from(state.complaints);
        list[index] = updated;
        state = state.copyWith(complaints: list);
      }
    } catch (_) {}
  }

  Future<void> deleteComplaint(String complaintId, String userId) async {
    final repo = ref.read(complaintRepositoryProvider);
    await repo.deleteComplaint(complaintId, userId);

    final updated =
        state.complaints.where((c) => c.id != complaintId).toList();
    state = state.copyWith(complaints: updated);
  }
}

final feedControllerProvider =
    NotifierProvider<FeedController, FeedState>(FeedController.new);
