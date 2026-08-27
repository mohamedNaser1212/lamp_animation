import 'package:flutter_test/flutter_test.dart';

import 'package:animate_training/main.dart';

void main() {
  testWidgets('Lamp screen loads with pull-cord hint', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('شد الفتلة'), findsWidgets);
  });
}
