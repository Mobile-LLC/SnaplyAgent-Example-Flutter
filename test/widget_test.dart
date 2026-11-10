import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snaply_example/main.dart';

void main() {
  testWidgets('the button adds one item', (tester) async {
    // No native side in a widget test: the plugin's channel answers nothing.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('snaply_agent'),
      (call) async => null,
    );
    await tester.pumpWidget(const SnaplyExampleApp());
    expect(find.text('Order #8412 · Margherita pizza · 2'), findsOneWidget);

    await tester.tap(find.text('Add one more'));
    await tester.pump();

    expect(find.text('Order #8412 · Margherita pizza · 3'), findsOneWidget);
  });
}
