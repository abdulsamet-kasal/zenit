import 'package:flutter/material.dart';
import 'package:seffaf/core/constants/app_colors.dart';

/// ŞEFFAF kurumsal marka logosu ve amblemi.
///
/// Responsive boyutlandırma, zarif degrade arka plan,
/// kalkan ve şeffaflık/adalet sembolü barındırır.
class SeffafLogo extends StatelessWidget {
  /// Logo ikonu boyutu (Genişlik ve yükseklik)
  final double size;

  /// Logo altında veya yanında marka ismini göster
  final bool showText;

  /// Alt sloganı ("Vatandaş Odaklı...") göster
  final bool showSubtitle;

  /// Metinlerin yerleşimi: dikey (altında) veya yatay (yanında)
  final Axis orientation;

  const SeffafLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.showSubtitle = false,
    this.orientation = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2563EB), // Parlak Mavi
            Color(0xFF0D9488), // Teal
            Color(0xFF10B981), // Zümrüt Yeşili
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.04),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan zarif halka
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
          // Ana Kalkan İkonu
          Icon(
            Icons.shield_rounded,
            size: size * 0.54,
            color: Colors.white,
          ),
          // Kalkan içindeki şeffaflık / onay pırıltısı
          Positioned(
            top: size * 0.32,
            child: Icon(
              Icons.check_rounded,
              size: size * 0.30,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );

    if (!showText) return logoIcon;

    final textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: orientation == Axis.vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'ŞEFFAF',
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 2),
          Text(
            'Vatandaş Odaklı Şeffaf Belediyecilik',
            style: TextStyle(
              fontSize: (size * 0.18).clamp(11.0, 14.0),
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );

    if (orientation == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoIcon,
          SizedBox(width: size * 0.22),
          textWidget,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoIcon,
        SizedBox(height: size * 0.18),
        textWidget,
      ],
    );
  }
}
