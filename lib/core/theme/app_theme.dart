// lib/core/theme/app_theme.dart
// Gereksinim: Flutter 3.27+  |  pubspec.yaml -> google_fonts: ^6.2.1
//
// Kullanım (main.dart):
//   MaterialApp(
//     theme: AppTheme.light(),
//     darkTheme: AppTheme.dark(),
//     themeMode: ThemeMode.system, // veya kullanıcı ayarı
//   )
//
// Durum / kategori / skor renkleri için:
//   final s = Theme.of(context).extension<SeffafColors>()!;
//   s.resolved.bg, s.resolved.fg, s.scoreColor(78) ...

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Şikayet durumu için arka plan + yazı rengi çifti.
@immutable
class StatusColor {
  const StatusColor(this.bg, this.fg);
  final Color bg;
  final Color fg;

  static StatusColor lerp(StatusColor a, StatusColor b, double t) =>
      StatusColor(Color.lerp(a.bg, b.bg, t)!, Color.lerp(a.fg, b.fg, t)!);
}

/// Tema'ya bağlı anlamsal renkler (durum, kategori, skor).
@immutable
class SeffafColors extends ThemeExtension<SeffafColors> {
  const SeffafColors({
    required this.pending,
    required this.reviewing,
    required this.resolved,
    required this.rejected,
    required this.categories,
    required this.scoreHigh,
    required this.scoreMid,
    required this.scoreLow,
    required this.medalGold,
    required this.medalSilver,
    required this.medalBronze,
  });

  final StatusColor pending; // Bekliyor
  final StatusColor reviewing; // İnceleniyor
  final StatusColor resolved; // Çözüldü
  final StatusColor rejected; // Reddedildi

  /// 8 kategori için sabit sıralı renkler (index = kategori sırası).
  final List<Color> categories;

  final Color scoreHigh; // 70-100
  final Color scoreMid; // 40-69
  final Color scoreLow; // 0-39

  final Color medalGold;
  final Color medalSilver;
  final Color medalBronze;

  Color scoreColor(num score) =>
      score >= 70 ? scoreHigh : (score >= 40 ? scoreMid : scoreLow);

  static const light = SeffafColors(
    pending: StatusColor(Color(0xFFFCF0D2), Color(0xFF7A5200)),
    reviewing: StatusColor(Color(0xFFDDE9FB), Color(0xFF1B4DA0)),
    resolved: StatusColor(Color(0xFFD9F0E1), Color(0xFF1B6B3C)),
    rejected: StatusColor(Color(0xFFF9DEDA), Color(0xFF9E2A1F)),
    categories: [
      Color(0xFF8A5A44), // yol / çukur
      Color(0xFFB7791F), // aydınlatma
      Color(0xFF3F7D58), // temizlik
      Color(0xFF2F855A), // park / yeşil alan
      Color(0xFF2B6CB0), // su / kanalizasyon
      Color(0xFF6B46C1), // trafik / işaret
      Color(0xFFC05621), // kaldırım
      Color(0xFF4A5568), // diğer
    ],
    scoreHigh: Color(0xFF1F7A45),
    scoreMid: Color(0xFFB7791F),
    scoreLow: Color(0xFFB3261E),
    medalGold: Color(0xFFC9971C),
    medalSilver: Color(0xFF8E99A6),
    medalBronze: Color(0xFFA9683A),
  );

  static const dark = SeffafColors(
    pending: StatusColor(Color(0xFF3A2E12), Color(0xFFF2C766)),
    reviewing: StatusColor(Color(0xFF14284A), Color(0xFF8DB4F5)),
    resolved: StatusColor(Color(0xFF123222), Color(0xFF7BD3A0)),
    rejected: StatusColor(Color(0xFF3B1916), Color(0xFFF2A59C)),
    categories: [
      Color(0xFFD09A80),
      Color(0xFFE5B85C),
      Color(0xFF7CC59A),
      Color(0xFF6FD09B),
      Color(0xFF7FB2EB),
      Color(0xFFB69CF0),
      Color(0xFFF0A070),
      Color(0xFFA0AEC0),
    ],
    scoreHigh: Color(0xFF6FD39A),
    scoreMid: Color(0xFFEBBE5C),
    scoreLow: Color(0xFFF2A59C),
    medalGold: Color(0xFFE6BC4A),
    medalSilver: Color(0xFFB4BEC9),
    medalBronze: Color(0xFFD08E5E),
  );

  @override
  SeffafColors copyWith() => this;

  @override
  SeffafColors lerp(ThemeExtension<SeffafColors>? other, double t) {
    if (other is! SeffafColors) return this;
    return SeffafColors(
      pending: StatusColor.lerp(pending, other.pending, t),
      reviewing: StatusColor.lerp(reviewing, other.reviewing, t),
      resolved: StatusColor.lerp(resolved, other.resolved, t),
      rejected: StatusColor.lerp(rejected, other.rejected, t),
      categories: [
        for (var i = 0; i < categories.length; i++)
          Color.lerp(categories[i], other.categories[i], t)!,
      ],
      scoreHigh: Color.lerp(scoreHigh, other.scoreHigh, t)!,
      scoreMid: Color.lerp(scoreMid, other.scoreMid, t)!,
      scoreLow: Color.lerp(scoreLow, other.scoreLow, t)!,
      medalGold: Color.lerp(medalGold, other.medalGold, t)!,
      medalSilver: Color.lerp(medalSilver, other.medalSilver, t)!,
      medalBronze: Color.lerp(medalBronze, other.medalBronze, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  // ---- Renk şemaları -------------------------------------------------

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1C4E80), // çini mavisi
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD8E5F4),
    onPrimaryContainer: Color(0xFF0B2A47),
    secondary: Color(0xFF0F8B8D), // firuze
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCFEDEE),
    onSecondaryContainer: Color(0xFF053B3C),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F7F9),
    onSurface: Color(0xFF141B22),
    onSurfaceVariant: Color(0xFF56636F),
    outline: Color(0xFF8A96A2),
    outlineVariant: Color(0xFFDCE2E8),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFEDF1F4),
    surfaceContainerHigh: Color(0xFFE6EBEF),
    surfaceContainerHighest: Color(0xFFDFE5EA),
    inverseSurface: Color(0xFF1E2731),
    onInverseSurface: Color(0xFFEAEFF3),
    inversePrimary: Color(0xFF8FB8E8),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8FB8E8),
    onPrimary: Color(0xFF0A2540),
    primaryContainer: Color(0xFF1F3F63),
    onPrimaryContainer: Color(0xFFD8E5F4),
    secondary: Color(0xFF5CC4C6),
    onSecondary: Color(0xFF032B2C),
    secondaryContainer: Color(0xFF12494B),
    onSecondaryContainer: Color(0xFFCFEDEE),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF4A0E0A),
    surface: Color(0xFF0E141B),
    onSurface: Color(0xFFE6EBF0),
    onSurfaceVariant: Color(0xFF9AA7B4),
    outline: Color(0xFF66737F),
    outlineVariant: Color(0xFF26313C),
    surfaceContainerLowest: Color(0xFF0A1016),
    surfaceContainerLow: Color(0xFF131A22),
    surfaceContainer: Color(0xFF171F28),
    surfaceContainerHigh: Color(0xFF1D2731),
    surfaceContainerHighest: Color(0xFF25303B),
    inverseSurface: Color(0xFFE6EBF0),
    onInverseSurface: Color(0xFF1E2731),
    inversePrimary: Color(0xFF1C4E80),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData light() => _build(_lightScheme, SeffafColors.light);
  static ThemeData dark() => _build(_darkScheme, SeffafColors.dark);

  // Geriye dönük uyumluluk için getter'lar:
  static ThemeData get lightTheme => light();
  static ThemeData get darkTheme => dark();

  // ---- Tipografi -----------------------------------------------------

  static TextTheme _text(ColorScheme cs) {
    final base = ThemeData(brightness: cs.brightness).textTheme;
    final t = GoogleFonts.manropeTextTheme(base)
        .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface);
    return t.copyWith(
      // Karne skoru gibi büyük rakamlar için
      displayLarge: t.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -3,
          fontFeatures: const [FontFeature.tabularFigures()]),
      displayMedium: t.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
          fontFeatures: const [FontFeature.tabularFigures()]),
      headlineMedium: t.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
      headlineSmall: t.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleLarge: t.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: t.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.1),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.45),
      bodyMedium:
          t.bodyMedium?.copyWith(fontWeight: FontWeight.w500, height: 1.45),
      bodySmall: t.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: cs.onSurfaceVariant),
      labelLarge: t.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
      labelMedium: t.labelMedium
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
      labelSmall: t.labelSmall
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
    );
  }

  // ---- ThemeData -----------------------------------------------------

  static ThemeData _build(ColorScheme cs, SeffafColors semantic) {
    final text = _text(cs);
    final isDark = cs.brightness == Brightness.dark;

    OutlineInputBorder inputBorder(Color c, [double w = 0]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: w == 0
              ? BorderSide.none
              : BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: cs.brightness,
      colorScheme: cs,
      textTheme: text,
      scaffoldBackgroundColor: cs.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: [semantic],
      dividerTheme: DividerThemeData(
          color: cs.outlineVariant, thickness: 1, space: 1),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: cs.surface)
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: cs.surface),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              size: 24,
              color: s.contains(WidgetState.selected)
                  ? cs.onPrimaryContainer
                  : cs.onSurfaceVariant,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
            text.labelMedium!.copyWith(
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: s.contains(WidgetState.selected)
                  ? cs.onSurface
                  : cs.onSurfaceVariant,
            )),
      ),

      // Gölgesiz, ince çerçeveli kartlar: akış ve listeler sakin kalır.
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:
            text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        border: inputBorder(cs.outline),
        enabledBorder: inputBorder(cs.outline),
        focusedBorder: inputBorder(cs.primary, 1.5),
        errorBorder: inputBorder(cs.error, 1.2),
        focusedErrorBorder: inputBorder(cs.error, 1.5),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: cs.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: text.labelLarge,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 3,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Durum rozetleri / filtre çipleri: yuvarlak değil, hafif köşeli.
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainer,
        selectedColor: cs.primaryContainer,
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: text.labelMedium,
        secondaryLabelStyle:
            text.labelMedium?.copyWith(color: cs.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      tabBarTheme: TabBarThemeData(
        dividerColor: cs.outlineVariant,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: cs.primary,
        labelColor: cs.onSurface,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: text.labelLarge,
        unselectedLabelStyle:
            text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: cs.surfaceContainerLowest,
        dragHandleColor: cs.outlineVariant,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: text.titleLarge,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        iconColor: cs.onSurfaceVariant,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHigh,
        circularTrackColor: cs.surfaceContainerHigh,
        linearMinHeight: 8,
      ),

      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
