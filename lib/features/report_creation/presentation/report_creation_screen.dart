import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_defaults.dart';
import '../../../core/network/offline_manager.dart';
import '../../../core/network/offline_sync_controller.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../data/models/complaint.dart';
import '../../../data/models/complaint_status.dart';
import '../../../data/repositories/providers.dart';
import '../../feed/application/feed_controller.dart';

class ReportCreationScreen extends ConsumerStatefulWidget {
  const ReportCreationScreen({super.key});

  @override
  ConsumerState<ReportCreationScreen> createState() =>
      _ReportCreationScreenState();
}

class _ReportCreationScreenState extends ConsumerState<ReportCreationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form State
  final List<String> _selectedImagePaths = [];
  String _selectedCategoryId = 'road_pavement';
  double _latitude = AppConstants.defaultLatitude;
  double _longitude = AppConstants.defaultLongitude;
  String _address = 'Sabuni Mah., Saraçlar Cad., Edirne Merkez';
  String _detectedMunicipalityName = 'Edirne Belediyesi';
  String _detectedMunicipalityId = 'muni_edirne_merkez';
  bool _isLocating = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    ref.read(municipalityRepositoryProvider).getMunicipalities();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImagePaths.length >= AppConstants.maxPhotosCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En fazla 3 fotoğraf ekleyebilirsiniz')),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _selectedImagePaths.add(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf seçilemedi: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Konum izni verilmedi. Varsayılan konum (Edirne Merkez) kullanılacak.'),
            ),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final detected =
          GeoUtils.detectMunicipality(position.latitude, position.longitude);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _detectedMunicipalityId = detected.municipalityId;
        _detectedMunicipalityName =
            '${detected.provinceName} ${detected.districtName} Belediyesi';
        _address =
            '${detected.districtName} İlçesi, Koordinat: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}';
        _isLocating = false;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum alınırken bir hata oluştu.'),
          ),
        );
      }
      setState(() => _isLocating = false);
    }
  }

  Future<void> _submitComplaint() async {
    final desc = _descriptionController.text.trim();
    if (desc.length < AppConstants.minDescriptionLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Açıklama en az 10 karakter olmalıdır')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final currentUser = await ref.read(currentUserProvider.future);
    final category = CategoryDefaults.getById(_selectedCategoryId);
    final now = DateTime.now();
    final slaDeadline = now.add(Duration(days: category.slaDays));

    // Fallback Unsplash image if camera was not available or empty in simulator
    final photoList = _selectedImagePaths.isNotEmpty
        ? _selectedImagePaths
        : [
            'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800&auto=format&fit=crop&q=80'
          ];

    final newComplaint = Complaint(
      id: 'c-${now.millisecondsSinceEpoch}',
      anonymousUserId: currentUser.id,
      anonymousUserName: currentUser.displayName,
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : null,
      description: desc,
      categoryId: _selectedCategoryId,
      photoUrls: photoList,
      latitude: _latitude,
      longitude: _longitude,
      address: _address,
      municipalityId: _detectedMunicipalityId,
      status: ComplaintStatus.pending,
      createdAt: now,
      slaDeadline: slaDeadline,
    );

    final isOnline = await OfflineManager.isConnected();
    if (!isOnline) {
      await OfflineManager.saveDraftComplaint(newComplaint);
      await ref.read(offlineSyncProvider.notifier).refreshDraftCount();
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessDialog(
          title: 'Çevrimdışı Taslak Kaydedildi',
          message:
              'İnternet bağlantısı bulunamadı. Bildiriminiz cihazınıza kaydedildi ve bağlantı sağlandığında otomatik iletilecektir.',
        );
      }
      return;
    }

    final repo = ref.read(complaintRepositoryProvider);
    await repo.createComplaint(newComplaint);

    // Track user's created complaint
    await ref
        .read(authRepositoryProvider)
        .addCreatedComplaintId(newComplaint.id);
    ref.invalidate(currentUserProvider);

    // Refresh feed
    ref.read(feedControllerProvider.notifier).loadInitial();

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessDialog(
        title: 'Bildiriminiz Alındı!',
        message:
            'Sorun başarıyla kaydedildi ve kamuya açık akışta paylaşıldı. $_detectedMunicipalityName için çözüm süresi takibi başlatıldı.',
      );
    }
  }

  void _showSuccessDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.accent, size: 28),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      _submitComplaint();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ),
        title: const Text('Sorun Bildir'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Adım İlerleme Çubuğu (Step Indicator)
            _buildStepIndicator(),
            const Divider(height: 1),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (step) => setState(() => _currentStep = step),
                children: [
                  _buildStep1PhotosAndCategory(isDark),
                  _buildStep2LocationAndMunicipality(isDark),
                  _buildStep3Details(isDark),
                  _buildStep4PreviewAndSubmit(isDark),
                ],
              ),
            ),

            // Alt Butonlar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        child: const Text('Geri'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _nextStep,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentStep == 3 ? 'Şikayeti Gönder' : 'İleri',
                            ),
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

  Widget _buildStepIndicator() {
    final steps = ['Fotoğraf & Kategori', 'Konum', 'Detay', 'Önizleme'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = _currentStep > index;
          final isCurrent = _currentStep == index;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.primary
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < steps.length - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ADIM 1: Fotoğraf & Kategori
  Widget _buildStep1PhotosAndCategory(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Fotoğraf Ekleyin (En fazla 3)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sorunun net görülebileceği 1 ila 3 fotoğraf seçin.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 14),

          // Fotoğraf Listesi / Ekleme Kutusu
          Row(
            children: [
              ..._selectedImagePaths.map(
                (path) => Stack(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImagePaths.remove(path);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedImagePaths.length < AppConstants.maxPhotosCount)
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Kamerayı Kullan'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Galeriden Seç'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            color: AppColors.primary, size: 28),
                        SizedBox(height: 4),
                        Text('Fotoğraf',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            '2. Sorun Kategorisini Seçin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sorumlu belediye birimi ve SLA süresi kategoriye göre belirlenir.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 14),

          // Kategori Grid Seçimi
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CategoryDefaults.categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final cat = CategoryDefaults.categories[index];
              final isSelected = _selectedCategoryId == cat.id;

              return InkWell(
                onTap: () => setState(() => _selectedCategoryId = cat.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cat.color.withValues(alpha: 0.15)
                        : (isDark ? AppColors.surfaceDark : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? cat.color : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.icon, color: cat.color, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            Text(
                              'SLA: ${cat.slaDays} gün',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ADIM 2: Konum & Otomatik Belediye Tespiti
  Widget _buildStep2LocationAndMunicipality(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konum ve Belediye Tespiti',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'GPS konumunuzdan ilgili belediye ve mahalle otomatik olarak tespit edilir.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 20),

          // Otomatik Tespit Edilen Belediye Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance,
                    color: AppColors.accent, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İlgili Belediye (Otomatik Tespit)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _detectedMunicipalityName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Bu bildirim doğrudan belediyenin şeffaflık puanına etki edecektir.',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Adres ve GPS Koordinat Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pin_drop,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tespit Edilen Adres',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _address,
                  style: const TextStyle(fontSize: 13.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Koordinat: ${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _isLocating ? null : _getCurrentLocation,
            icon: _isLocating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _isLocating ? 'GPS Konumu Alınıyor...' : 'Mevcut GPS Konumumu Al',
            ),
          ),
        ],
      ),
    );
  }

  // ADIM 3: Detaylar & Açıklama
  Widget _buildStep3Details(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sorun Detayları',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ekiplerin sorunu daha hızlı tespit edebilmesi için net bir açıklama girin.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 20),

          // Başlık (Opsiyonel)
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Başlık (İsteğe bağlı)',
              hintText: 'Örn: Kaldırımda derin çukur',
            ),
          ),
          const SizedBox(height: 16),

          // Açıklama (Zorunlu)
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: AppConstants.maxDescriptionLength,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Sorun Açıklaması *',
              hintText:
                  'Sorunun tam yerini, büyüklüğünü veya oluşturduğu tehlikeyi belirtin (en az 10 karakter)...',
              counterText:
                  '${_descriptionController.text.length} / ${AppConstants.maxDescriptionLength} (Min 10)',
            ),
          ),
        ],
      ),
    );
  }

  // ADIM 4: Önizleme & Gönder
  Widget _buildStep4PreviewAndSubmit(bool isDark) {
    final category = CategoryDefaults.getById(_selectedCategoryId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bildirim Özeti',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bilgileri kontrol edip onayladıktan sonra bildiriminiz kamuya açık olarak yayınlanacaktır.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(category.icon, color: category.color, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Hedef: ${category.slaDays} Gün',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  if (_titleController.text.trim().isNotEmpty) ...[
                    Text(
                      _titleController.text.trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  Text(
                    _descriptionController.text.trim().isNotEmpty
                        ? _descriptionController.text.trim()
                        : 'Açıklama girilmedi.',
                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.apartment,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        _detectedMunicipalityName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
