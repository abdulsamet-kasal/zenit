import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SeffafApp shows LoginScreen when user is guest', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: SeffafApp(onboardingCompleted: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.text("ŞEFFAF'a Hoş Geldiniz"), findsOneWidget);
  });

  testWidgets('SeffafApp shows OnboardingScreen when not completed', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: SeffafApp(onboardingCompleted: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Seffaf'a Hoş Geldiniz"), findsOneWidget);
  });
}
