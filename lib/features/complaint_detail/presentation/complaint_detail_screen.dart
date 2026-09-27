import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_defaults.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/comment.dart';
import '../../../data/models/complaint.dart';
import '../../../data/models/complaint_status.dart';
import '../../../data/repositories/providers.dart';
import '../../../shared/widgets/category_badge.dart';
import '../../../shared/widgets/full_screen_image_viewer.dart';
import '../../../shared/widgets/seffaf_image.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../feed/application/feed_controller.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final Complaint complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  ConsumerState<ComplaintDetailScreen> createState() =>
      _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  late Complaint _complaint;
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  int _activePhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final repo = ref.read(complaintRepositoryProvider);
      final comments = await repo.getComments(_complaint.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = await ref.read(currentUserProvider.future);
    final repo = ref.read(complaintRepositoryProvider);

    final newComment = Comment(
      id: 'comm-${DateTime.now().millisecondsSinceEpoch}',
      complaintId: _complaint.id,
      anonymousUserId: user.id,
      anonymousUserName: user.displayName,
      text: text,
      createdAt: DateTime.now(),
    );

    await repo.addComment(newComment);
    _commentController.clear();

    setState(() {
      _comments.insert(0, newComment);
      _complaint =
          _complaint.copyWith(commentCount: _complaint.commentCount + 1);
    });
  }

  Future<void> _toggleLike() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      final repo = ref.read(complaintRepositoryProvider);
      final updated = await repo.toggleLike(_complaint.id, user.id);
      if (mounted) {
        setState(() => _complaint = updated);
      }
      ref.read(feedControllerProvider.notifier).loadInitial();
    } catch (_) {}
  }

  Future<void> _toggleConfirm() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      final repo = ref.read(complaintRepositoryProvider);
      final updated = await repo.toggleConfirm(_complaint.id, user.id);
      if (mounted) {
        setState(() => _complaint = updated);
      }
      ref.read(feedControllerProvider.notifier).loadInitial();
    } catch (_) {}
  }

  Future<void> _rateComplaint(int rating) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      final repo = ref.read(complaintRepositoryProvider);
      final updated =
          await repo.rateComplaint(_complaint.id, user.id, rating);
      if (mounted) {
        setState(() => _complaint = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Değerlendirmeniz kaydedildi: $rating Yıldız ⭐'),
          ),
        );
      }
      ref.read(feedControllerProvider.notifier).loadInitial();
    } catch (_) {}
  }

  void _shareComplaint() {
    final title = _complaint.title ?? 'Şikayet Detayı';
    final shareText =
        '📢 $title\n📍 ${_complaint.address}\n📊 Durum: ${_complaint.status.displayName}\nŞeffaf Platformu üzerinden inceleyin: https://seffaf.gov.tr/sikayet/${_complaint.id}';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şikayet bilgileri panoya kopyalandı! Paylaşabilirsiniz.'),
      ),
    );
  }

  void _openImageViewer(List<String> urls, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imageUrls: urls,
          initialIndex: index,
        ),
      ),
    );
  }

  void _showDisputeDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Topluluk Doğrulaması / İtiraz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu sorun çözülmediği halde "Çözüldü" olarak mı işaretlendi? İtirazınızı ileterek belediye şeffaflık puanının doğrulanmasına katkıda bulunun.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'İtiraz gerekçenizi yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              final reason = textController.text.trim();
              final user = await ref.read(currentUserProvider.future);
              final repo = ref.read(complaintRepositoryProvider);
              await repo.submitDispute(
                _complaint.id,
                user.id,
                reason,
              );
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('İtirazınız topluluk incelemesine iletildi.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            child: const Text('İtirazı Gönder'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Şikayeti Sil'),
          ],
        ),
        content: const Text(
          'Bu şikayeti ve ilişkili tüm verileri kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final scaffoldMsg = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              try {
                final user = await ref.read(currentUserProvider.future);
                await ref
                    .read(feedControllerProvider.notifier)
                    .deleteComplaint(_complaint.id, user.id);

                if (mounted) {
                  scaffoldMsg.showSnackBar(
                    const SnackBar(
                      content: Text('Şikayetiniz başarıyla silindi.'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                  nav.pop(); // Akış ekranına geri dön
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMsg.showSnackBar(
                    SnackBar(
                      content: Text('Şikayet silinirken hata oluştu: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = CategoryDefaults.getById(_complaint.categoryId);
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.asData?.value;
    final isAuthor = currentUser != null &&
        (currentUser.id == _complaint.anonymousUserId ||
            (currentUser.email != null &&
                currentUser.email == _complaint.anonymousUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şikayet Detayı'),
        actions: [
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              tooltip: 'Şikayeti Sil',
              onPressed: _showDeleteConfirmationDialog,
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Paylaş',
            onPressed: _shareComplaint,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fotoğraf Galerisi
                  if (_complaint.photoUrls.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: _complaint.photoUrls.length,
                            onPageChanged: (i) =>
                                setState(() => _activePhotoIndex = i),
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () => _openImageViewer(
                                    _complaint.photoUrls, i),
                                child: Hero(
                                  tag: 'photo_${_complaint.id}_$i',
                                  child: SeffafImage(
                                    imageUrl: _complaint.photoUrls[i],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Büyütme ikonu ipucu
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          if (_complaint.photoUrls.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _complaint.photoUrls.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width:
                                        _activePhotoIndex == index ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _activePhotoIndex == index
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori ve Durum Rozeti
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CategoryBadge(categoryId: _complaint.categoryId),
                            StatusBadge(status: _complaint.status),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Başlık ve Açıklama
                        if (_complaint.title != null)
                          Text(
                            _complaint.title!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          _complaint.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Destek ve Doğrulama Butonları (Aksiyon Barı)
                        _buildActionBar(isDark),
                        const SizedBox(height: 16),

                        // Konum Kartı
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bildirilen Konum',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    Text(
                                      _complaint.address,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // SLA Çözüm Durumu Zaman Çizelgesi (Timeline)
                        _buildSlaTimeline(isDark, category.slaDays),
                        const SizedBox(height: 20),

                        // ÖNCE / SONRA Çözüm Kanıtı (Varsa)
                        if (_complaint.resolvedPhotoUrl != null) ...[
                          _buildBeforeAfterComparison(isDark),
                          const SizedBox(height: 20),
                        ],

                        // Resmi Belediye Yanıtı (Varsa)
                        if (_complaint.municipalityResponseNote != null) ...[
                          _buildMunicipalityResponse(isDark),
                          const SizedBox(height: 20),
                        ],

                        // Vatandaş Memnuniyet Anketi (Çözülmüşse)
                        if (_complaint.status == ComplaintStatus.resolved) ...[
                          _buildSatisfactionRating(isDark),
                          const SizedBox(height: 20),
                        ],

                        const Divider(),

                        // İtiraz / Topluluk Doğrulaması Butonu
                        if (_complaint.status == ComplaintStatus.resolved)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: OutlinedButton.icon(
                              onPressed: _showDisputeDialog,
                              icon: const Icon(Icons.report_problem_outlined,
                                  color: AppColors.statusRejected),
                              label: const Text(
                                'Bu Sorun Çözülmedi mi? İtiraz Et',
                                style:
                                    TextStyle(color: AppColors.statusRejected),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.statusRejected),
                              ),
                            ),
                          ),

                        // Yorumlar Başlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Yorumlar (${_comments.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Yorum Listesi
                        if (_isLoadingComments)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_comments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: Text(
                                'Henüz yorum yapılmamış. İlk yorumu siz yazın!',
                                style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.anonymousUserName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        DateFormatter.formatRelative(
                                            comment.createdAt),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Alt Yorum Yazma Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Anonim yorum ekle...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendComment,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Destek Ol (Like)
          InkWell(
            onTap: _toggleLike,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    _complaint.isLikedByMe
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    size: 18,
                    color: _complaint.isLikedByMe
                        ? AppColors.primary
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Destek (${_complaint.likeCount})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: _complaint.isLikedByMe
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: _complaint.isLikedByMe
                          ? AppColors.primary
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ben de Gördüm (Doğrula)
          InkWell(
            onTap: _toggleConfirm,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    _complaint.isConfirmedByMe
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 18,
                    color: _complaint.isConfirmedByMe
                        ? AppColors.accent
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Doğrula (${_complaint.confirmCount})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: _complaint.isConfirmedByMe
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: _complaint.isConfirmedByMe
                          ? AppColors.accent
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterComparison(bool isDark) {
    final beforeUrl = _complaint.photoUrls.isNotEmpty
        ? _complaint.photoUrls.first
        : null;
    final afterUrl = _complaint.resolvedPhotoUrl;

    if (afterUrl == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusResolved.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare, color: AppColors.statusResolved, size: 20),
              SizedBox(width: 8),
              Text(
                'Çözüm Kanıtı: Önce / Sonra Karşılaştırması',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // ÖNCE (Bildirilen Durum)
              if (beforeUrl != null)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusRejected.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ÖNCE (Sorun)',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusRejected,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _openImageViewer([beforeUrl], 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: SeffafImage(
                              imageUrl: beforeUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              // SONRA (Belediyenin Çözümü)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.statusResolved.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SONRA (Çözüm)',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusResolved,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _openImageViewer([afterUrl], 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SeffafImage(
                            imageUrl: afterUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalityResponse(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Resmi Belediye Yanıtı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (_complaint.municipalityResponseDate != null)
                Text(
                  DateFormatter.formatDate(_complaint.municipalityResponseDate!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _complaint.municipalityResponseNote!,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionRating(bool isDark) {
    final myRating = _complaint.myRating ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vatandaş Memnuniyeti',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              if (_complaint.ratingCount > 0)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 3),
                    Text(
                      '${_complaint.averageRating.toStringAsFixed(1)} / 5 (${_complaint.ratingCount} oy)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bu çözüm sizi tatmin etti mi? Puanınız doğrudan belediye şeffaflık karnesine yansır.',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              final isFilled = star <= myRating;
              return IconButton(
                onPressed: () => _rateComplaint(star),
                icon: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFilled ? Colors.amber : Colors.grey[400],
                  size: 32,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaTimeline(bool isDark, int slaDays) {
    final isResolved = _complaint.status == ComplaintStatus.resolved;
    final isExceeded = _complaint.isSlaExceeded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExceeded
              ? AppColors.statusRejected.withValues(alpha: 0.3)
              : (isResolved
                  ? AppColors.statusResolved.withValues(alpha: 0.3)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SLA Çözüm Takvimi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExceeded
                      ? AppColors.statusRejected.withValues(alpha: 0.1)
                      : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isResolved
                      ? 'Tamamlandı'
                      : (isExceeded
                          ? 'SLA Aşıldı!'
                          : '${_complaint.remainingDays} gün kaldı'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isExceeded
                        ? AppColors.statusRejected
                        : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Steps: Bildirildi -> İnceleniyor -> Çözüldü
          Row(
            children: [
              _buildTimelineStep(
                title: 'Bildirildi',
                date: DateFormatter.formatDate(_complaint.createdAt),
                isDone: true,
                isCurrent: _complaint.status == ComplaintStatus.pending,
                isDark: isDark,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: _complaint.status != ComplaintStatus.pending
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              _buildTimelineStep(
                title: 'İnceleniyor',
                date: _complaint.status != ComplaintStatus.pending
                    ? 'İşleme alındı'
                    : 'Bekleniyor',
                isDone: _complaint.status == ComplaintStatus.inReview ||
                    _complaint.status == ComplaintStatus.resolved,
                isCurrent: _complaint.status == ComplaintStatus.inReview,
                isDark: isDark,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: _complaint.status == ComplaintStatus.resolved
                      ? AppColors.statusResolved
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              _buildTimelineStep(
                title: 'Çözüldü',
                date: _complaint.resolvedAt != null
                    ? DateFormatter.formatDate(_complaint.resolvedAt!)
                    : 'Hedef: $slaDays gün',
                isDone: _complaint.status == ComplaintStatus.resolved,
                isCurrent: _complaint.status == ComplaintStatus.resolved,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String date,
    required bool isDone,
    required bool isCurrent,
    required bool isDark,
  }) {
    Color iconColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    if (isDone) iconColor = AppColors.primary;
    if (title == 'Çözüldü' && isDone) iconColor = AppColors.statusResolved;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? iconColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor,
              width: 2,
            ),
          ),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: 14,
            color: isDone
                ? Colors.white
                : (isDark ? AppColors.textSecondaryDark : AppColors.borderLight),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          date,
          style: TextStyle(
            fontSize: 9.5,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
