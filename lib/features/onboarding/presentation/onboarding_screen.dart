import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/seffaf_logo.dart';
import '../../auth/presentation/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isFromProfile;

  const OnboardingScreen({
    super.key,
    this.isFromProfile = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      isLogo: true,
      title: 'Seffaf\'a Hoş Geldiniz',
      subtitle: 'Vatandaşın Gücü, Şeffaf Belediyecilik',
      description:
          'Seffaf, şehirlerimizdeki tüm aksaklıkları şeffafça paylaştığınız ve belediyelerin çözüm hızını tarafsız algoritmalarla puanladığınız bağımsız denetim platformudur.',
      icon: Icons.shield_outlined,
      color: AppColors.primary,
    ),
    OnboardingSlide(
      isLogo: false,
      title: 'Sorunu Fotoğrafla & Konumlandır',
      subtitle: 'Tek Tuşla Bildirim',
      description:
          'Kaldırımdaki çukur, arızalı sokak lambası veya toplanmayan çöp... Fotoğrafını çekin; GPS teknolojimizle il ve ilçe belediyeniz otomatik tespit edilsin.',
      icon: Icons.camera_enhance_rounded,
      color: Color(0xFF2563EB),
    ),
    OnboardingSlide(
      isLogo: false,
      title: 'Yasal Süre (SLA) & Canlı Karne',
      subtitle: 'Objektif 0-100 Şeffaflık Puanı',
      description:
          'Her sorunun yasal bir çözüm süresi vardır. Belediyeler zamanında çözdükçe puanları yükselir, geciktikçe düşer. Tüm Türkiye liderlik sıralamasını canlı takip eder.',
      icon: Icons.insights_rounded,
      color: Color(0xFF0D9488),
    ),
    OnboardingSlide(
      isLogo: false,
      title: 'Topluluk Desteği & Çözüm Kanıtı',
      subtitle: 'Birlikte Denetleyin',
      description:
          'Komşularınızın bildirimlerini beğenin, "Ben de Gördüm" diyerek sorunun önceliğini artırın. Belediye çözdüğünde öncesi ve sonrası fotoğraflarını doğrulayın.',
      icon: Icons.verified_user_rounded,
      color: Color(0xFF10B981),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);

    if (!mounted) return;

    if (widget.isFromProfile) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen(isModal: false)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isFromProfile
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          if (!widget.isFromProfile)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Atla',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (slide.isLogo)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const SeffafLogo(size: 96),
                            )
                          else
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: slide.color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: slide.color.withValues(alpha: 0.25),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                slide.icon,
                                size: 50,
                                color: slide.color,
                              ),
                            ),
                          const SizedBox(height: 24),
                          Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: slide.color,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentIndex < _slides.length - 1
                            ? 'Devam Et'
                            : (widget.isFromProfile
                                ? 'Anladım'
                                : 'Hemen Başla (Kayıt Ol / Giriş Yap)'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

class OnboardingSlide {
  final bool isLogo;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingSlide({
    this.isLogo = false,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
