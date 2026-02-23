import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/di/service_locator.dart';
import 'package:client/features/home/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home page renders header and city selector', (
    WidgetTester tester,
  ) async {
    ServiceLocator().init();

    await tester.pumpWidget(const MaterialApp(home: HomePageContent()));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Привет, Nurtugan!'), findsOneWidget);
    expect(find.textContaining('Казахстан'), findsOneWidget);
  });
}
