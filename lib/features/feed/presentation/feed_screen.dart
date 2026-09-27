import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_defaults.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_card.dart';
import '../../complaint_detail/presentation/complaint_detail_screen.dart';
import '../application/feed_controller.dart';
import 'widgets/complaint_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Şikayet veya adres ara...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (value) {
                  ref
                      .read(feedControllerProvider.notifier)
                      .setSearchQuery(value);
                },
              )
            : const Row(
                children: [
                  Icon(Icons.visibility_outlined, color: AppColors.accent),
                  SizedBox(width: 8),
                  Text('Şeffaf Akış'),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearchVisible) {
                  _searchController.clear();
                  ref
                      .read(feedControllerProvider.notifier)
                      .setSearchQuery(null);
                }
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sırala',
            onSelected: (sortBy) {
              ref.read(feedControllerProvider.notifier).setSortBy(sortBy);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('🕒 En Yeni'),
              ),
              const PopupMenuItem(
                value: 'most_supported',
                child: Text('👍 En Çok Desteklenen'),
              ),
              const PopupMenuItem(
                value: 'sla_urgent',
                child: Text('⏳ SLA Acil Olanlar'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Duruma göre filtrele',
            onSelected: (status) {
              ref.read(feedControllerProvider.notifier).setStatus(
                    status == 'all' ? null : status,
                  );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Tüm Durumlar'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('🟡 Bekleyenler'),
              ),
              const PopupMenuItem(
                value: 'inReview',
                child: Text('🔵 İncelenenler'),
              ),
              const PopupMenuItem(
                value: 'resolved',
                child: Text('🟢 Çözülenler'),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Yatay Kategori Filtre Çipleri
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(
                  label: 'Tümü',
                  isSelected: state.selectedCategory == null,
                  onTap: () => ref
                      .read(feedControllerProvider.notifier)
                      .setCategory(null),
                ),
                ...CategoryDefaults.categories.map((cat) {
                  final isSelected = state.selectedCategory == cat.id;
                  return _buildFilterChip(
                    label: cat.name,
                    isSelected: isSelected,
                    icon: cat.icon,
                    iconColor: cat.color,
                    onTap: () => ref
                        .read(feedControllerProvider.notifier)
                        .setCategory(cat.id),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Akış Listesi
          Expanded(
            child: _buildFeedContent(state, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    IconData? icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        avatar: icon != null
            ? Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : (iconColor ?? AppColors.primary),
              )
            : null,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimaryLight,
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildFeedContent(FeedState state, bool isDark) {
    if (state.isLoading) {
      return ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    if (state.errorMessage != null) {
      return ErrorStateWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(feedControllerProvider.notifier).loadInitial(),
      );
    }

    if (state.complaints.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(feedControllerProvider.notifier).loadInitial(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: EmptyStateWidget(
              title: 'Şikayet Bulunamadı',
              description:
                  'Seçtiğiniz filtreye uygun henüz bir bildirim bulunmuyor. Yeni bir sorun bildirebilir veya filtreleri sıfırlayabilirsiniz.',
              icon: Icons.filter_list_off_outlined,
              buttonText: 'Filtreleri Sıfırla',
              onButtonPressed: () {
                ref.read(feedControllerProvider.notifier).setCategory(null);
                ref.read(feedControllerProvider.notifier).setStatus(null);
                ref.read(feedControllerProvider.notifier).setSearchQuery(null);
              },
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedControllerProvider.notifier).loadInitial(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.complaints.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.complaints.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            );
          }

          final complaint = state.complaints[index];
          return ComplaintCard(
            complaint: complaint,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ComplaintDetailScreen(complaint: complaint),
                ),
              );
            },
            onLike: () {
              ref
                  .read(feedControllerProvider.notifier)
                  .toggleLike(complaint.id);
            },
            onConfirm: () {
              ref
                  .read(feedControllerProvider.notifier)
                  .toggleConfirm(complaint.id);
            },
          );
        },
      ),
    );
  }
}
