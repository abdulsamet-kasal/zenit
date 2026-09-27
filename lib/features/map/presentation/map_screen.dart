import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:seffaf/core/constants/app_colors.dart';
import 'package:seffaf/core/constants/app_constants.dart';
import 'package:seffaf/core/constants/category_defaults.dart';
import 'package:seffaf/data/models/complaint.dart';
import 'package:seffaf/data/repositories/providers.dart';
import 'package:seffaf/features/complaint_detail/presentation/complaint_detail_screen.dart';
import 'package:seffaf/shared/widgets/category_badge.dart';
import 'package:seffaf/shared/widgets/seffaf_image.dart';
import 'package:seffaf/shared/widgets/status_badge.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  List<Complaint> _allComplaints = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      final repo = ref.read(complaintRepositoryProvider);
      final list = await repo.getFeed(limit: 100);
      if (mounted) {
        setState(() {
          _allComplaints = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _moveToUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _mapController.move(
          const LatLng(
            AppConstants.defaultLatitude,
            AppConstants.defaultLongitude,
          ),
          14,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15,
      );
    } catch (_) {
      _mapController.move(
        const LatLng(
          AppConstants.defaultLatitude,
          AppConstants.defaultLongitude,
        ),
        14,
      );
    }
  }

  void _showComplaintBottomSheet(Complaint complaint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CategoryBadge(categoryId: complaint.categoryId),
                  StatusBadge(status: complaint.status, isCompact: true),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (complaint.photoUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SeffafImage(
                        imagePath: complaint.photoUrls.first,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (complaint.title != null)
                          Text(
                            complaint.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                complaint.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ComplaintDetailScreen(complaint: complaint),
                    ),
                  );
                },
                child: const Text('Şikayet Detayını İncele'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter complaints
    Iterable<Complaint> filtered = _allComplaints;
    if (_selectedCategory != null) {
      filtered = filtered.where((c) => c.categoryId == _selectedCategory);
    }
    if (_selectedStatus != null) {
      filtered = filtered.where((c) => c.status.name == _selectedStatus);
    }
    final activeComplaints = filtered.toList();

    // Generate Map Markers
    final markers = activeComplaints.map((c) {
      final category = CategoryDefaults.getById(c.categoryId);
      return Marker(
        point: LatLng(c.latitude, c.longitude),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () => _showComplaintBottomSheet(c),
          child: Container(
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              category.icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şeffaf Harita'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Duruma göre filtrele',
            onSelected: (status) {
              setState(() {
                _selectedStatus = status == 'all' ? null : status;
              });
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
      body: Stack(
        children: [
          // OpenStreetMap Tile Layer + Cluster Layer
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(
                AppConstants.defaultLatitude,
                AppConstants.defaultLongitude,
              ),
              initialZoom: AppConstants.defaultZoom,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.osmTileUrl,
                userAgentPackageName: AppConstants.osmUserAgent,
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 50,
                  size: const Size(42, 42),
                  markers: markers,
                  builder: (context, clusterMarkers) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          clusterMarkers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Üst Kategori Filtre Çipleri
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMapFilterChip(
                    label: 'Tümü (${_allComplaints.length})',
                    isSelected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...CategoryDefaults.categories.map((cat) {
                    final isSelected = _selectedCategory == cat.id;
                    return _buildMapFilterChip(
                      label: cat.name,
                      isSelected: isSelected,
                      icon: cat.icon,
                      iconColor: cat.color,
                      onTap: () => setState(() => _selectedCategory = cat.id),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Yükleniyor İndikatörü
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Sağ Alt: Konumuma Git FAB
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my_location_btn',
              onPressed: _moveToUserLocation,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFilterChip({
    required String label,
    required bool isSelected,
    IconData? icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        avatar: icon != null
            ? Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : (iconColor ?? AppColors.primary),
              )
            : null,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 2,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
