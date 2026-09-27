import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seffaf/core/constants/app_colors.dart';
import 'package:seffaf/data/models/anonymous_user.dart';
import 'package:seffaf/data/models/complaint.dart';
import 'package:seffaf/data/repositories/providers.dart';
import 'package:seffaf/features/complaint_detail/presentation/complaint_detail_screen.dart';
import 'package:seffaf/features/feed/presentation/widgets/complaint_card.dart';
import 'package:seffaf/main.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<Complaint> _myComplaints = [];
  bool _isLoadingComplaints = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadMyComplaints();
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

  void _showAuthPlaceholderDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Giriş / Kayıt Ol'),
          ],
        ),
        content: const Text(
          'Şeffaf şu an tamamen anonim misafir kullanıcı modeli ile çalışmaktadır. Gerçek kimlik doğrulama (e-Devlet / SMS doğrulama) Faz 9 kapsamında eklenecektir.',
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('KVKK ve Gizlilik Politikası'),
        content: const SingleChildScrollView(
          child: Text(
            'Şeffaf uygulamasında hiçbir kişisel veri zorunlu olarak toplanmamaktadır. Bildirimleriniz anonim cihaz kimliği (UUID) üzerinden saklanır. Yüklediğiniz fotoğraflarda üçüncü şahısların yüz veya araç plakası gibi kişisel verilerinin yer almaması kullanıcının sorumluluğundadır.',
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
          'Cihazınızda saklanan misafir kullanıcı kimliğiniz ve yerel taslaklarınız silinecektir. Devam etmek istiyor musunuz?',
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
                setState(() => _myComplaints = []);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Ayarlar'),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Misafir Kullanıcı Kartı
              _buildUserCard(user, isDark),
              const SizedBox(height: 16),

              // Auth CTA Banner
              _buildAuthBanner(isDark),
              const SizedBox(height: 24),

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

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
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
                      subtitle: const Text('Sürüm 1.0.0 (Açık Kaynak Prototip)',
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
                        'Misafir Verilerimi Sıfırla',
                        style: TextStyle(color: AppColors.statusRejected),
                      ),
                      onTap: _showResetDataDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Anonim Kullanıcı ID: ${user.id.substring(0, 8)}...',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                  'Hesabını Doğrula (Yakında)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'e-Devlet ile doğrulanmış vatandaş rozeti al ve itiraz ağırlığını artır.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showAuthPlaceholderDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Giriş',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
