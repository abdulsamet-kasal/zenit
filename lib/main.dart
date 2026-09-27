import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/providers.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/main_navigation/main_nav_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

// Theme Mode Riverpod Provider (Modern Riverpod Notifier)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(AppConstants.keyThemeMode);
    if (savedMode == 'light') {
      state = ThemeMode.light;
    } else if (savedMode == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyThemeMode,
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await SupabaseConfig.initialize();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted =
      prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;

  runApp(
    ProviderScope(
      child: SeffafApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class SeffafApp extends ConsumerWidget {
  final bool onboardingCompleted;

  const SeffafApp({
    super.key,
    required this.onboardingCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final userAsync = ref.watch(currentUserProvider);

    return MaterialApp(
      title: 'Şeffaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: !onboardingCompleted
          ? const OnboardingScreen()
          : userAsync.when(
              data: (user) {
                if (user.isGuest) {
                  return const LoginScreen(isModal: false);
                }
                return const MainNavScreen();
              },
              loading: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => const LoginScreen(isModal: false),
            ),
    );
  }
}
