import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/providers.dart';
import '../../main_navigation/main_nav_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool isModal;
  const LoginScreen({super.key, this.isModal = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Provider'ı yenile
      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı! Hoş geldiniz.'),
            backgroundColor: AppColors.primary,
          ),
        );

        if (widget.isModal) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Invalid login credentials')
              ? 'E-posta veya şifre hatalı.'
              : 'Giriş yapılamadı: Lütfen bilgilerinizi kontrol edin.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text);
    final codeCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    int step = 1; // 1: Send OTP, 2: Enter OTP & New Password
    bool isSubmitting = false;
    String? dialogError;
    bool obscureNew = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    step == 1 ? Icons.lock_reset : Icons.mark_email_read_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step == 1 ? 'Şifre Sıfırlama' : 'Yeni Şifre Belirle',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dialogError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dialogError!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (step == 1 && dialogError!.contains('429')) ...[
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.pin, size: 16),
                                label: const Text(
                                  'Gelen Kodu Girerek Devam Et',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    dialogError = null;
                                    step = 2;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (step == 1) ...[
                      const Text(
                        'Kayıtlı e-posta adresinizi girin. Yeni şifrenizi belirleyebileceğiniz güvenli bir sıfırlama bağlantısı gönderilecektir.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta Adresi',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.pin, size: 16),
                          label: const Text(
                            'Elimde 6 haneli kod var',
                            style: TextStyle(fontSize: 12.5),
                          ),
                          onPressed: () {
                            final email = emailCtrl.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              setDialogState(() => dialogError =
                                  'Lütfen önce e-posta adresinizi girin.');
                              return;
                            }
                            setDialogState(() {
                              dialogError = null;
                              step = 3;
                            });
                          },
                        ),
                      ),
                    ] else if (step == 2) ...[
                      // Bağlantı Gönderildi Başarı Durumu
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mark_email_read_outlined,
                                color: AppColors.accent,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              emailCtrl.text.trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'adresine şifre sıfırlama bağlantısı başarıyla gönderildi.\n\nLütfen e-postanızı açıp bağlantıya tıklayarak yeni şifrenizi belirleyin. Ardından uygulamadan yeni şifrenizle giriş yapabilirsiniz.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Step 3: Kod ile Sıfırlama
                      Text(
                        '${emailCtrl.text.trim()} adresine gelen 6 haneli kodu ve yeni şifrenizi girin:',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: codeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: '6 Haneli Doğrulama Kodu',
                          prefixIcon: Icon(Icons.pin_outlined),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: newPasswordCtrl,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Yeni Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setDialogState(() => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordCtrl,
                        obscureText: obscureNew,
                        decoration: const InputDecoration(
                          labelText: 'Yeni Şifre Tekrar',
                          prefixIcon: Icon(Icons.lock_clock_outlined),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (step == 2)
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tamam, Anladım'),
                  )
                else ...[
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (step == 3) {
                              setDialogState(() => step = 1);
                            } else {
                              Navigator.of(ctx).pop();
                            }
                          },
                    child: Text(step == 3 ? 'Geri' : 'İptal'),
                  ),
                  if (step == 1)
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final email = emailCtrl.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                setDialogState(() => dialogError =
                                    'Geçerli bir e-posta adresi girin.');
                                return;
                              }
                              setDialogState(() {
                                isSubmitting = true;
                                dialogError = null;
                              });
                              try {
                                await ref
                                    .read(authRepositoryProvider)
                                    .resetPassword(email);
                                setDialogState(() {
                                  isSubmitting = false;
                                  step = 2; // Gönderildi onay ekranı
                                });
                              } catch (e) {
                                setDialogState(() {
                                  isSubmitting = false;
                                  final errStr = e.toString();
                                  if (errStr.contains('429') ||
                                      errStr.contains('rate limit') ||
                                      errStr.contains('security purposes')) {
                                    dialogError =
                                        'Çok sık talep yapıldı (Limit: 429). Güvenlik amacıyla lütfen 60 saniye bekleyin veya daha önce gönderilen e-postayı kontrol edin.';
                                  } else {
                                    dialogError =
                                        'Sıfırlama bağlantısı gönderilemedi: $e';
                                  }
                                });
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Bağlantı Gönder'),
                    )
                  else if (step == 3)
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final token = codeCtrl.text.trim();
                              final newPass = newPasswordCtrl.text.trim();
                              final confirmPass =
                                  confirmPasswordCtrl.text.trim();

                              if (token.length != 6) {
                                setDialogState(() => dialogError =
                                    'Lütfen 6 haneli kodu eksiksiz girin.');
                                return;
                              }
                              if (newPass.length < 6) {
                                setDialogState(() => dialogError =
                                    'Şifre en az 6 karakter olmalıdır.');
                                return;
                              }
                              if (newPass != confirmPass) {
                                setDialogState(() => dialogError =
                                    'Girdiğiniz şifreler uyuşmuyor.');
                                return;
                              }

                              setDialogState(() {
                                isSubmitting = true;
                                dialogError = null;
                              });

                              try {
                                await ref
                                    .read(authRepositoryProvider)
                                    .verifyOtpAndResetPassword(
                                      emailCtrl.text.trim(),
                                      token,
                                      newPass,
                                    );
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                                if (mounted) {
                                  _passwordController.text = newPass;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Şifreniz başarıyla güncellendi! Yeni şifrenizle giriş yapabilirsiniz.',
                                      ),
                                      backgroundColor: AppColors.accent,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setDialogState(() {
                                  isSubmitting = false;
                                  final errStr = e.toString();
                                  if (errStr.contains('429')) {
                                    dialogError =
                                        'Çok fazla deneme yapıldı. Lütfen biraz bekleyin.';
                                  } else if (errStr.contains('Token') ||
                                      errStr.contains('invalid') ||
                                      errStr.contains('expired')) {
                                    dialogError =
                                        'Girdiğiniz 6 haneli kod hatalı veya süresi dolmuş.';
                                  } else {
                                    dialogError =
                                        'Şifre sıfırlanamadı: $e';
                                  }
                                });
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Şifreyi Güncelle'),
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ŞEFFAF\'a Hoş Geldiniz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Şikayetlerinizi takip etmek ve belediyenizi puanlamak için giriş yapın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // E-posta
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta Adresi',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'ornek@belediye.gov.tr',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lütfen e-posta adresinizi girin';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Lütfen şifrenizi girin';
                    }
                    if (val.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),

                // Şifremi Unuttum
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text(
                      'Şifremi Unuttum',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Giriş Yap Butonu
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 28),

                // Kayıt Ol Yönlendirmesi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabınız yok mu?',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterScreen(isModal: widget.isModal),
                          ),
                        );
                      },
                      child: Text(
                        'Hemen Kayıt Ol',
                        style: TextStyle(
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
