import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_defaults.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/comment.dart';
import '../../../data/models/complaint.dart';
import '../../../data/models/complaint_status.dart';
import '../../../data/repositories/providers.dart';
import '../../../shared/widgets/category_badge.dart';
import '../../../shared/widgets/status_badge.dart';

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
      _complaint = _complaint.copyWith(commentCount: _complaint.commentCount + 1);
    });
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = CategoryDefaults.getById(_complaint.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şikayet Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bağlantı kopyalandı')),
              );
            },
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
                              return CachedNetworkImage(
                                imageUrl: _complaint.photoUrls[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
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
                                    width: _activePhotoIndex == index ? 18 : 6,
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
                                    const Text(
                                      'Bildirilen Konum',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondaryLight,
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

                        const SizedBox(height: 24),
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
                  : AppColors.borderLight),
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
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: _complaint.status != ComplaintStatus.pending
                      ? AppColors.primary
                      : AppColors.borderLight,
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
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: _complaint.status == ComplaintStatus.resolved
                      ? AppColors.statusResolved
                      : AppColors.borderLight,
                ),
              ),
              _buildTimelineStep(
                title: 'Çözüldü',
                date: _complaint.resolvedAt != null
                    ? DateFormatter.formatDate(_complaint.resolvedAt!)
                    : 'Hedef: $slaDays gün',
                isDone: _complaint.status == ComplaintStatus.resolved,
                isCurrent: _complaint.status == ComplaintStatus.resolved,
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
  }) {
    Color iconColor = AppColors.borderLight;
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
            color: isDone ? Colors.white : AppColors.borderLight,
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
          style: const TextStyle(
            fontSize: 9.5,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
