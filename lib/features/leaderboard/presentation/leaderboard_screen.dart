import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seffaf/core/constants/app_colors.dart';
import 'package:seffaf/data/models/municipality.dart';
import 'package:seffaf/data/repositories/providers.dart';
import 'package:seffaf/features/municipality/presentation/municipality_profile_screen.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<Municipality> _municipalities = [];
  bool _isLoading = true;
  String _selectedProvince = 'Tümü';
  String _sortBy = 'score';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _provinces = ['Tümü', 'Edirne', 'Tekirdağ', 'Kırklareli'];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final repo = ref.read(municipalityRepositoryProvider);
      final list = await repo.getLeaderboard(
        province: _selectedProvince == 'Tümü' ? null : _selectedProvince,
      );
      if (mounted) {
        setState(() {
          _municipalities = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter by search query
    final query = _searchController.text.trim().toLowerCase();
    final displayedList = _municipalities.where((m) {
      if (query.isEmpty) return true;
      return m.name.toLowerCase().contains(query) ||
          m.district.toLowerCase().contains(query) ||
          m.province.toLowerCase().contains(query);
    }).toList();

    // Sort according to _sortBy
    displayedList.sort((a, b) {
      if (_sortBy == 'resolution_rate') {
        return b.resolutionRate.compareTo(a.resolutionRate);
      } else if (_sortBy == 'fastest') {
        return a.avgResolutionDays.compareTo(b.avgResolutionDays);
      } else {
        return b.transparencyScore.compareTo(a.transparencyScore);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Şeffaflık Sıralaması'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sıralama Ölçütü',
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'score',
                child: Text('🏆 Şeffaflık Puanı'),
              ),
              const PopupMenuItem(
                value: 'resolution_rate',
                child: Text('📈 Çözüm Oranı'),
              ),
              const PopupMenuItem(
                value: 'fastest',
                child: Text('⚡ En Hızlı Çözenler'),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Belediye veya ilçe ara...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // İl Filtre Çipleri
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _provinces.length,
              itemBuilder: (context, index) {
                final prov = _provinces[index];
                final isSelected = _selectedProvince == prov;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(prov),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedProvince = prov;
                        _isLoading = true;
                      });
                      _loadLeaderboard();
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 12),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedList.isEmpty
                    ? const Center(
                        child: Text(
                          'Aramanıza uygun belediye bulunamadı.',
                          style: TextStyle(color: AppColors.textSecondaryLight),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: displayedList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final muni = displayedList[index];
                          final rank = index + 1;
                          final scoreColor =
                              AppColors.scoreColor(muni.transparencyScore);

                          return Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MunicipalityProfileScreen(
                                      municipality: muni,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 14.0),
                                child: Row(
                                  children: [
                                    // Sıralama Rozeti
                                    _buildRankBadge(rank),
                                    const SizedBox(width: 14),

                                    // Belediye Bilgisi
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            muni.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${muni.province} / ${muni.district} • %${muni.resolutionRate.toStringAsFixed(0)} Çözüm',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Şeffaflık Puanı & Trend
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: scoreColor
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: scoreColor
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                            muni.transparencyScore
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: scoreColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_upward,
                                              size: 12,
                                              color: AppColors.accent,
                                            ),
                                            Text(
                                              '+${(rank * 1.2).toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return const Text('🥇', style: TextStyle(fontSize: 24));
    } else if (rank == 2) {
      return const Text('🥈', style: TextStyle(fontSize: 24));
    } else if (rank == 3) {
      return const Text('🥉', style: TextStyle(fontSize: 24));
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.borderLight.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
