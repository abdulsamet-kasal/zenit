import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/features/auth/presentation/login_screen.dart';
import 'package:seffaf/features/auth/presentation/register_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Ekranları Widget Testleri', () {
    testWidgets('LoginScreen form alanları ve butonları doğru render edilmeli',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Başlık ve açıklamalar
      expect(find.text("ŞEFFAF'a Hoş Geldiniz"), findsOneWidget);
      expect(find.text('Giriş Yap'), findsWidgets);

      // Form elemanları
      expect(find.byType(TextFormField), findsNWidgets(2)); // E-posta ve şifre
      expect(find.text('Misafir Vatandaş Olarak Devam Et'), findsOneWidget);
      expect(find.text('Hemen Kayıt Ol'), findsOneWidget);

      // Boş giriş doğrulama testi
      final loginBtn = find.widgetWithText(ElevatedButton, 'Giriş Yap');
      expect(loginBtn, findsOneWidget);
      await tester.tap(loginBtn);
      await tester.pump();

      expect(find.text('Lütfen e-posta adresinizi girin'), findsOneWidget);
      expect(find.text('Lütfen şifrenizi girin'), findsOneWidget);
    });

    testWidgets('RegisterScreen form alanları ve doğrulama doğru çalışmalı',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      expect(find.text('Vatandaş Hesabı Oluştur'), findsOneWidget);
      expect(find.text('Hesap Oluştur'), findsOneWidget);

      // 5 form alanı: Ad Soyad, E-posta, Telefon, Şifre, Şifre Tekrar
      expect(find.byType(TextFormField), findsNWidgets(5));

      // Boş form submit denemesi
      final registerBtn = find.widgetWithText(ElevatedButton, 'Hesap Oluştur');
      expect(registerBtn, findsOneWidget);
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(find.text('Lütfen adınızı ve soyadınızı girin'), findsOneWidget);
      expect(find.text('Lütfen e-posta adresinizi girin'), findsOneWidget);
    });
  });
}
