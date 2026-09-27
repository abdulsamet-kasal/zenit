import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/features/profile/presentation/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ProfileScreen renders properly', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profil & Ayarlar'), findsOneWidget);
    expect(find.text('Uygulama Ayarları'), findsOneWidget);
    expect(find.text('Hesaptan Çıkış Yap'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsWidgets);
  });
}
