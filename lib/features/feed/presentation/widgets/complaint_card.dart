import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:seffaf/core/constants/app_colors.dart';
import 'package:seffaf/core/utils/date_formatter.dart';
import 'package:seffaf/data/models/complaint.dart';
import 'package:seffaf/shared/widgets/category_badge.dart';
import 'package:seffaf/shared/widgets/status_badge.dart';

class ComplaintCard extends StatefulWidget {
  final Complaint complaint;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onConfirm;
  final VoidCallback? onLocationTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
    required this.onLike,
    required this.onConfirm,
    this.onLocationTap,
  });

  @override
  State<ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<ComplaintCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Avatar, İsim, Zaman ve Kategori Rozeti
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      complaint.anonymousUserName.isNotEmpty
                          ? complaint.anonymousUserName[0]
                          : 'V',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.anonymousUserName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatRelative(complaint.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CategoryBadge(categoryId: complaint.categoryId),
                ],
              ),
            ),

            // Fotoğraf Alanı (4:3 Oran, Tam Genişlik)
            if (complaint.photoUrls.isNotEmpty)
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: complaint.photoUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    // Çoklu Fotoğraf İndikatörü
                    if (complaint.photoUrls.length > 1)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${complaint.photoUrls.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Durum Rozeti (Fotoğraf Üzerinde Sol Üst)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: StatusBadge(status: complaint.status),
                    ),
                  ],
                ),
              ),

            // Konum Çubuğu
            InkWell(
              onTap: widget.onLocationTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.backgroundLight,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        complaint.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
            ),

            // Başlık & Açıklama
            Padding(
              padding:
                  const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (complaint.title != null && complaint.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        complaint.title!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  Text(
                    complaint.description,
                    maxLines: _isExpanded ? 100 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (complaint.description.length > 80)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _isExpanded ? 'daha az göster' : '...devamını gör',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.accentLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 16, thickness: 0.5),

            // Alt Buton Satırı: Beğen, Yorum, Paylaş, "Ben de gördüm"
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Beğeni
                      _ActionButton(
                        icon: complaint.isLikedByMe
                            ? Icons.favorite
                            : Icons.favorite_border,
                        iconColor: complaint.isLikedByMe
                            ? Colors.red
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        label: '${complaint.likeCount}',
                        onTap: widget.onLike,
                      ),
                      const SizedBox(width: 4),
                      // Yorum
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        iconColor: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        label: '${complaint.commentCount}',
                        onTap: widget.onTap,
                      ),
                      const SizedBox(width: 4),
                      // Paylaş
                      _ActionButton(
                        icon: Icons.share_outlined,
                        iconColor: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        label: '',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Şikayet bağlantısı kopyalandı'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // "Ben de gördüm" butonu
                  InkWell(
                    onTap: widget.onConfirm,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: complaint.isConfirmedByMe
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.borderLight.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: complaint.isConfirmedByMe
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            complaint.isConfirmedByMe
                                ? Icons.visibility
                                : Icons.visibility_outlined,
                            size: 16,
                            color: complaint.isConfirmedByMe
                                ? AppColors.accent
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Gördüm (${complaint.confirmCount})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: complaint.isConfirmedByMe
                                  ? AppColors.accent
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                          ),
                        ],
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
