import 'package:flutter_test/flutter_test.dart';

import 'package:snaply_example/main.dart';

void main() {
  testWidgets('the button adds one item', (tester) async {
    await tester.pumpWidget(const SnaplyExampleApp());
    expect(find.text('Order #8412 · Margherita pizza · 2'), findsOneWidget);

    await tester.tap(find.text('Add one more'));
    await tester.pump();

    expect(find.text('Order #8412 · Margherita pizza · 3'), findsOneWidget);
  });
}
