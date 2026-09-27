import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seffaf/core/constants/app_colors.dart';
import 'package:seffaf/core/constants/category_defaults.dart';
import 'package:seffaf/data/models/complaint.dart';
import 'package:seffaf/data/models/municipality.dart';
import 'package:seffaf/data/repositories/providers.dart';
import 'package:seffaf/features/complaint_detail/presentation/complaint_detail_screen.dart';
import 'package:seffaf/features/feed/presentation/widgets/complaint_card.dart';

class MunicipalityProfileScreen extends ConsumerStatefulWidget {
  final Municipality municipality;

  const MunicipalityProfileScreen({super.key, required this.municipality});

  @override
  ConsumerState<MunicipalityProfileScreen> createState() =>
      _MunicipalityProfileScreenState();
}

class _MunicipalityProfileScreenState
    extends ConsumerState<MunicipalityProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Complaint> _municipalityComplaints = [];
  bool _isLoadingComplaints = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadComplaints();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    try {
      final repo = ref.read(complaintRepositoryProvider);
      final list =
          await repo.getComplaintsByMunicipality(widget.municipality.id);
      if (mounted) {
        setState(() {
          _municipalityComplaints = list;
          _isLoadingComplaints = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingComplaints = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final muni = widget.municipality;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = AppColors.scoreColor(muni.transparencyScore);

    return Scaffold(
      appBar: AppBar(
        title: Text(muni.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFollowing ? Icons.notifications_active : Icons.notifications_none,
              color: _isFollowing ? AppColors.accent : null,
            ),
            tooltip: _isFollowing ? 'Takibi Bırak' : 'Belediyeyi Takip Et',
            onPressed: () {
              setState(() => _isFollowing = !_isFollowing);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFollowing
                        ? '${muni.name} bildirimleri takip listenize eklendi.'
                        : '${muni.name} takipten çıkarıldı.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Üst Başlık & Puan Kartı
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                              : [Colors.white, const Color(0xFFF1F5F9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Şeffaflık Puanı Dairesel Gösterge
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 84,
                                height: 84,
                                child: CircularProgressIndicator(
                                  value: muni.transparencyScore / 100,
                                  strokeWidth: 8,
                                  backgroundColor:
                                      scoreColor.withValues(alpha: 0.15),
                                  color: scoreColor,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    muni.transparencyScore.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor,
                                    ),
                                  ),
                                  const Text(
                                    '/ 100',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  muni.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${muni.province} / ${muni.district}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: scoreColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    muni.transparencyScore >= 80
                                        ? 'Yüksek Şeffaflık Derecesi'
                                        : (muni.transparencyScore >= 60
                                            ? 'Orta Şeffaflık Derecesi'
                                            : 'Düşük Şeffaflık Derecesi'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4'lü İstatistik Izgarası
                    Row(
                      children: [
                        _buildStatBox(
                          label: 'Toplam Şikayet',
                          value: '${muni.totalComplaints}',
                          icon: Icons.assignment_outlined,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          label: 'Çözülen',
                          value: '${muni.resolvedComplaints}',
                          icon: Icons.check_circle_outline,
                          color: AppColors.accent,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatBox(
                          label: 'Çözüm Oranı',
                          value: '%${muni.resolutionRate.toStringAsFixed(1)}',
                          icon: Icons.pie_chart_outline,
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          label: 'Ort. Çözüm Süresi',
                          value: '${muni.avgResolutionDays} Gün',
                          icon: Icons.timer_outlined,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeaderDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Grafikler & Performans'),
                    Tab(text: 'Şikayetler'),
                  ],
                ),
                isDark: isDark,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // SEKME 1: Grafikler
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şeffaflık Puanı Trendi (Son 90 Gün)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Belediyenin zamanında ve geç çözümlerine göre anlık puan değişimi.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 16),

                  // Line Chart
                  Container(
                    height: 200,
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 8, right: 16, left: 0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 50,
                        maxY: 100,
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (val, meta) => Text(
                                val.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx >= 0 &&
                                    idx < muni.scoreHistory.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      DateFormat('MMM')
                                          .format(muni.scoreHistory[idx].date),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: muni.scoreHistory
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                    e.key.toDouble(), e.value.score))
                                .toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Kategori Bazlı Çözüm Başarısı',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kategorilere göre çözülme yüzdesi (%)',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 16),

                  // Kategori Listesi
                  ...muni.categoryPerformance.map((catPerf) {
                    final cat = CategoryDefaults.getById(catPerf.categoryId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(cat.icon, color: cat.color, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    catPerf.categoryName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              Text(
                                '%${catPerf.successRate.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.scoreColor(catPerf.successRate),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: catPerf.successRate / 100,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              color: AppColors.scoreColor(catPerf.successRate),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${catPerf.resolved} / ${catPerf.total} şikayet çözüldü',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // SEKME 2: Belediyeye Ait Şikayetler
            _isLoadingComplaints
                ? const Center(child: CircularProgressIndicator())
                : _municipalityComplaints.isEmpty
                    ? const Center(
                        child: Text(
                          'Bu belediyeye ait henüz şikayet kaydı bulunmuyor.',
                          style: TextStyle(color: AppColors.textSecondaryLight),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: _municipalityComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = _municipalityComplaints[index];
                          return ComplaintCard(
                            complaint: complaint,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ComplaintDetailScreen(
                                      complaint: complaint),
                                ),
                              );
                            },
                            onLike: () {},
                            onConfirm: () {},
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _TabBarHeaderDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarHeaderDelegate oldDelegate) {
    return false;
  }
}
