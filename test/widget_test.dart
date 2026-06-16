// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:jackson_fan_app/main.dart';

void main() {
  testWidgets('App shows the home page', (WidgetTester tester) async {
    await tester.pumpWidget(const JacksonFanApp());

    expect(find.text('Jackson Wang'), findsOneWidget);
    expect(find.text('快速入口'), findsOneWidget);
  });
}
