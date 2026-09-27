import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seffaf/main.dart';

void main() {
  testWidgets('SeffafApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SeffafApp(onboardingCompleted: true),
      ),
    );
    expect(find.text('Şeffaf Akış'), findsOneWidget);
  });
}
