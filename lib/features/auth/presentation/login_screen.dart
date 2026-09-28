import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/providers.dart';
import '../../../shared/widgets/seffaf_logo.dart';
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
    int step = 1; // 1: Send link & code, 2: Reset form with OTP code
    bool isSubmitting = false;
    String? dialogError;
    bool obscureNew = true;
    bool obscureConfirm = true;

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
                    step == 1
                        ? Icons.lock_reset_rounded
                        : Icons.verified_user_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step == 1 ? 'Şifre Sıfırlama' : 'Yeni Şifre Belirle',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
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
                          child: Text(
                            dialogError!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (step == 1) ...[
                        const Text(
                          'Kayıtlı e-posta adresinizi girin. Size hem tıklayabileceğiniz bir web bağlantısı hem de uygulama içinde kullanabileceğiniz doğrulama kodu gönderilecektir.',
                          style: TextStyle(fontSize: 13.5, height: 1.4),
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
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            icon: const Icon(Icons.pin_outlined, size: 16),
                            label: const Text(
                              'Elimde zaten doğrulama kodu var',
                              style: TextStyle(fontSize: 12.5),
                            ),
                            onPressed: () {
                              final email = emailCtrl.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                setDialogState(() => dialogError =
                                    'Lütfen önce kayıtlı e-posta adresinizi girin.');
                                return;
                              }
                              setDialogState(() {
                                dialogError = null;
                                step = 2;
                              });
                            },
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.mark_email_read_outlined,
                                      size: 18, color: AppColors.accent),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      emailCtrl.text.trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'adresine gelen kodu ve yeni şifrenizi girin:',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: codeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Doğrulama Kodu',
                            hintText: 'E-postadaki 6-8 haneli kod',
                            prefixIcon: Icon(Icons.pin_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: newPasswordCtrl,
                          obscureText: obscureNew,
                          decoration: InputDecoration(
                            labelText: 'Yeni Şifre',
                            hintText: 'En az 6 karakter',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNew
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () => setDialogState(
                                  () => obscureNew = !obscureNew),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: confirmPasswordCtrl,
                          obscureText: obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Yeni Şifre (Tekrar)',
                            prefixIcon: const Icon(Icons.lock_clock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () => setDialogState(
                                  () => obscureConfirm = !obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '💡 Not: Dilerseniz e-postanızdaki web bağlantısına tıklayarak tarayıcınızdan da şifrenizi yenileyebilirsiniz.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondaryLight,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          if (step == 2) {
                            setDialogState(() {
                              dialogError = null;
                              step = 1;
                            });
                          } else {
                            Navigator.of(ctx).pop();
                          }
                        },
                  child: Text(step == 2 ? 'Geri' : 'İptal'),
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
                                step = 2;
                              });
                            } catch (e) {
                              setDialogState(() {
                                isSubmitting = false;
                                final errStr = e.toString();
                                if (errStr.contains('429') ||
                                    errStr.contains('rate limit') ||
                                    errStr.contains('security purposes')) {
                                  dialogError =
                                      'Çok sık talep yapıldı. Lütfen 60 saniye bekleyin veya daha önce gönderilen e-postayı kontrol edin.';
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
                        : const Text('Kod ve Bağlantı Gönder'),
                  )
                else
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final email = emailCtrl.text.trim();
                            final token = codeCtrl.text.trim();
                            final newPass = newPasswordCtrl.text.trim();
                            final confirmPass =
                                confirmPasswordCtrl.text.trim();

                            if (token.isEmpty) {
                              setDialogState(() => dialogError =
                                  'Lütfen e-postanıza gelen kodu girin.');
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
                                    email,
                                    token,
                                    newPass,
                                  );

                              if (ctx.mounted) Navigator.of(ctx).pop();

                              if (mounted) {
                                _emailController.text = email;
                                _passwordController.text = newPass;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppColors.accent,
                                    content: Text(
                                      'Tebrikler! Şifreniz başarıyla güncellendi. Giriş yapabilirsiniz.',
                                    ),
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
                                    errStr.contains('expired') ||
                                    errStr.contains('otp')) {
                                  dialogError =
                                      'Girdiğiniz kod hatalı veya süresi dolmuş.';
                                } else {
                                  dialogError =
                                      'Şifre güncellenemedi: $e';
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
                        : const Text('Şifremi Güncelle'),
                  ),
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Center(
                      child: SeffafLogo(
                        size: 76,
                        showText: false,
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
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
    ),
  ),
);
}
}
