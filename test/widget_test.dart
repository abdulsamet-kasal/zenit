import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SeffafApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: SeffafApp(onboardingCompleted: true),
      ),
    );
    await tester.pump();
    expect(find.text('Şeffaf Akış'), findsOneWidget);
  });
}
