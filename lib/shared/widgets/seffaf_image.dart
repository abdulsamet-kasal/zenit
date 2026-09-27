import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Tüm ağ, yerel dosya ve asset görsellerini kesintisiz, çökmeyen ve
/// dark-mode uyumlu biçimde gösteren evrensel görsel bileşeni.
class SeffafImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SeffafImage({
    super.key,
    String? imageUrl,
    String? imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : imageUrl = imageUrl ?? imagePath ?? '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trimmed = imageUrl.trim();

    Widget imageWidget;

    // Bellek tasarrufu için dinamik boyutlandırma (OOM önleme, sonsuz genişlik kontrolü)
    final cacheW = (width != null && width!.isFinite)
        ? (width! * 2).toInt().clamp(200, 1080)
        : 720;

    if (trimmed.isEmpty) {
      imageWidget = _buildFallback(isDark);
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      imageWidget = CachedNetworkImage(
        imageUrl: trimmed,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheW,
        maxWidthDiskCache: 1080,
        maxHeightDiskCache: 1080,
        placeholder: (context, url) =>
            placeholder ?? _buildPlaceholder(isDark),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildFallback(isDark),
      );
    } else if (trimmed.startsWith('assets/')) {
      imageWidget = Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheW,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildFallback(isDark),
      );
    } else {
      // Yerel dosya yolu (örn: Kamera veya Galeri /data/user/0/... veya file://...)
      final cleanPath = trimmed.replaceFirst('file://', '');
      final file = File(cleanPath);

      imageWidget = Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheW,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildFallback(isDark),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? AppColors.accentLight : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColors.surfaceDark : const Color(0xFFE2E8F0),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 36,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
