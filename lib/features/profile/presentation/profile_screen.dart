import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/offline_sync_controller.dart';
import '../../../data/models/anonymous_user.dart';
import '../../../data/models/complaint.dart';
import '../../../data/models/municipality.dart';
import '../../../data/repositories/providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../complaint_detail/presentation/complaint_detail_screen.dart';
import '../../feed/presentation/widgets/complaint_card.dart';
import '../../municipality/presentation/municipality_profile_screen.dart';
import '../../../main.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<Complaint> _myComplaints = [];
  bool _isLoadingComplaints = true;
  bool _notificationsEnabled = true;
  List<Municipality> _followedMunicipalities = [];

  @override
  void initState() {
    super.initState();
    _loadMyComplaints();
    _loadFollowedMunicipalities();
  }

  Future<void> _loadMyComplaints() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      final repo = ref.read(complaintRepositoryProvider);
      final list = await repo.getComplaintsByUser(user.id);
      if (mounted) {
        setState(() {
          _myComplaints = list;
          _isLoadingComplaints = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingComplaints = false);
      }
    }
  }

  Future<void> _loadFollowedMunicipalities() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      final muniRepo = ref.read(municipalityRepositoryProvider);
      final all = await muniRepo.getMunicipalities();
      final followed = all
          .where((m) => user.followedMunicipalityIds.contains(m.id))
          .toList();
      if (mounted) {
        setState(() {
          _followedMunicipalities = followed;
        });
      }
    } catch (_) {}
  }

  void _showSmsVerificationModal() {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    int currentStep = 0;
    String simulatedCode = '849201';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user,
                              color: AppColors.accent, size: 26),
                          SizedBox(width: 8),
                          Text(
                            'Vatandaş Kimlik Doğrulama',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStep == 0
                        ? 'Telefon numaranızı girerek doğrulanmış vatandaş rozeti alabilir, bildirim ve itirazlarınızda öncelik kazanabilirsiniz.'
                        : 'Telefonunuza SMS ile gönderilen 6 haneli güvenlik kodunu girin.',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 18),

                  if (currentStep == 0) ...[
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Cep Telefonu',
                        hintText: '05XX XXX XX XX',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        final phone = phoneController.text.trim();
                        if (phone.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Lütfen geçerli bir telefon numarası girin.'),
                            ),
                          );
                          return;
                        }

                        // Simulate SMS transmission
                        final randomCode =
                            (100000 + (phone.hashCode.abs() % 900000))
                                .toString();
                        simulatedCode = randomCode;

                        setModalState(() {
                          currentStep = 1;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1E293B),
                            duration: const Duration(seconds: 8),
                            content: Row(
                              children: [
                                const Icon(Icons.sms,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '💬 SMS Doğrulama Kodunuz: $simulatedCode',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text('Doğrulama Kodu Gönder'),
                    ),
                  ] else ...[
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: '6 Haneli SMS Kodu',
                        hintText: simulatedCode,
                        prefixIcon: const Icon(Icons.security),
                        suffixIcon: TextButton(
                          onPressed: () {
                            otpController.text = simulatedCode;
                          },
                          child: const Text('Doldur'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final code = otpController.text.trim();
                        if (code != simulatedCode) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hatalı kod! Lütfen SMS kodunu kontrol edin.'),
                            ),
                          );
                          return;
                        }

                        final authRepo = ref.read(authRepositoryProvider);
                        await authRepo.verifyUser(phoneController.text.trim());
                        ref.invalidate(currentUserProvider);

                        if (ctx.mounted) Navigator.of(ctx).pop();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.accent,
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tebrikler! Doğrulanmış Vatandaş Rozetiniz Aktif Edildi.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Kodu Doğrula ve Tamamla'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('KVKK ve Gizlilik Politikası'),
        content: const SingleChildScrollView(
          child: Text(
            'Şeffaf platformunda anonimlik esastır. Doğrulama yapıldığında dahi telefon numaranız şifreli olarak cihazınızda ve güvenli veritabanında saklanır; kamuya açık akışta adınız veya numaranız asla üçüncü şahıslara veya belediye personeline ifşa edilmez.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verileri Sıfırla'),
        content: const Text(
          'Cihazınızda saklanan misafir kullanıcı kimliğiniz, beğenileriniz ve yerel taslaklarınız silinecektir. Devam etmek istiyor musunuz?',
          style: TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              final authRepo = ref.read(authRepositoryProvider);
              await authRepo.clearUserData();
              navigator.pop();
              ref.invalidate(currentUserProvider);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Kullanıcı verileri sıfırlandı.')),
              );
              if (mounted) {
                setState(() {
                  _myComplaints = [];
                  _followedMunicipalities = [];
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final offlineSync = ref.watch(offlineSyncProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Ayarlar'),
      ),
      body: Builder(
        builder: (context) {
          final user = userAsync.asData?.value ??
              AnonymousUser(
                id: 'misafir-vatandas',
                displayName: 'Misafir Vatandaş',
                createdComplaintIds: const [],
                isGuest: true,
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Kartı
                _buildUserCard(user, isDark),
                const SizedBox(height: 14),

              // Çevrimdışı Taslak Uyarısı (Varsa)
              if (offlineSync.pendingDraftCount > 0) ...[
                _buildOfflineDraftsCard(offlineSync, isDark),
                const SizedBox(height: 14),
              ],

              // Doğrulama CTA Banner (Yalnızca doğrulanmamışsa)
              if (!user.isVerified) ...[
                _buildAuthBanner(isDark),
                const SizedBox(height: 20),
              ],

              // Takip Ettiğim Belediyeler (Varsa)
              if (_followedMunicipalities.isNotEmpty) ...[
                _buildFollowedMunicipalitiesSection(isDark),
                const SizedBox(height: 20),
              ],

              // Bildirdiğim Şikayetler Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bildirdiğim Sorunlar (${_myComplaints.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isLoadingComplaints)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoadingComplaints)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_myComplaints.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Henüz bir şikayet bildirmediniz. Ortadaki (+) butonu ile ilk bildiriminizi yapabilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                )
              else
                ..._myComplaints.map(
                  (complaint) => ComplaintCard(
                    complaint: complaint,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ComplaintDetailScreen(complaint: complaint),
                        ),
                      );
                    },
                    onLike: () {},
                    onConfirm: () {},
                  ),
                ),

              const SizedBox(height: 28),

              // Ayarlar Bölümü
              const Text(
                'Uygulama Ayarları',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Tema Seçimi
                    ListTile(
                      leading: const Icon(Icons.brightness_6_outlined),
                      title: const Text('Uygulama Teması'),
                      subtitle: Text(
                        themeMode == ThemeMode.system
                            ? 'Sistem Temasını Takip Et'
                            : (themeMode == ThemeMode.dark
                                ? 'Karanlık Tema'
                                : 'Aydınlık Tema'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: DropdownButton<ThemeMode>(
                        value: themeMode,
                        underline: const SizedBox(),
                        onChanged: (mode) {
                          if (mode != null) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setTheme(mode);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Sistem'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Açık'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Koyu'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Bildirimler
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Bildirimler'),
                      subtitle: const Text(
                        'Şikayet çözüm durumu güncellemeleri',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                      },
                    ),
                    const Divider(height: 1),

                    // Gizlilik Politikası
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('KVKK & Gizlilik Politikası'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showPrivacyDialog,
                    ),
                    const Divider(height: 1),

                    // Hakkında
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Şeffaf Hakkında'),
                      subtitle: const Text('Sürüm 1.0.0 (Açık Kaynak Platform)',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Şeffaf',
                          applicationVersion: '1.0.0',
                          applicationLegalese:
                              '© 2026 Şeffaf Belediye Şeffaflık Platformu',
                          children: const [
                            SizedBox(height: 12),
                            Text(
                              'Vatandaşların sorun bildirebildiği ve belediyelerin çözüm hızına göre şeffafça puanlandığı açık platform.',
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // Verileri Temizle
                      ListTile(
                      leading: const Icon(Icons.delete_outline,
                          color: AppColors.statusRejected),
                      title: const Text(
                        'Cihaz Verilerimi Sıfırla',
                        style: TextStyle(color: AppColors.statusRejected),
                      ),
                      onTap: _showResetDataDialog,
                    ),

                    if (!user.isGuest) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout,
                            color: AppColors.danger),
                        title: const Text(
                          'Hesaptan Çıkış Yap',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Çıkış Yap'),
                              content: const Text(
                                  'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Çıkış Yap'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(authRepositoryProvider).signOut();
                            ref.invalidate(currentUserProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Başarıyla çıkış yapıldı.')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildUserCard(AnonymousUser user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isVerified
              ? AppColors.accent.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: user.isVerified
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  user.isVerified ? Icons.verified : Icons.person,
                  size: 32,
                  color: user.isVerified ? AppColors.accent : AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle,
                              color: AppColors.accent, size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.isVerified
                            ? AppColors.accent.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        !user.isGuest
                            ? '🛡️ Kayıtlı Vatandaş (${user.email ?? user.phoneNumber ?? 'Aktif'})'
                            : (user.isVerified
                                ? '🛡️ Doğrulanmış Vatandaş (${user.phoneNumber ?? ''})'
                                : 'Anonim Misafir ID: ${user.id.substring(0, 8)}...'),
                        style: TextStyle(
                          fontSize: 11,
                          color: user.isVerified
                              ? AppColors.accent
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user.isGuest) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Şikayetlerinizi cihazlar arası senkronize etmek için hesabınıza giriş yapın.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(isModal: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Giriş / Kayıt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined,
              color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hesabını Doğrula (SMS ile)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Doğrulanmış vatandaş rozeti al ve itirazlarının ağırlığını artır.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showSmsVerificationModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Doğrula',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineDraftsCard(OfflineSyncState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_upload_outlined,
              color: Color(0xFFD97706), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.pendingDraftCount} Çevrimdışı Taslak Bekliyor',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Bağlantı kurulduğunda otomatik olarak sisteme yüklenecektir.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: state.isSyncing
                ? null
                : () async {
                    final count = await ref
                        .read(offlineSyncProvider.notifier)
                        .syncNow();
                    if (mounted) {
                      _loadMyComplaints();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(count > 0
                              ? '$count adet şikayet başarıyla senkronize edildi!'
                              : 'İnternet bağlantısı bekleniyor...'),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(70, 34),
            ),
            child: state.isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Şimdi Eşitle', style: TextStyle(fontSize: 11.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowedMunicipalitiesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Takip Ettiğim Belediyeler (${_followedMunicipalities.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _followedMunicipalities.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final muni = _followedMunicipalities[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MunicipalityProfileScreen(
                        municipality: muni,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            muni.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Puan: ${muni.transparencyScore.toStringAsFixed(1)} / 100',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors.scoreColor(muni.transparencyScore),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
