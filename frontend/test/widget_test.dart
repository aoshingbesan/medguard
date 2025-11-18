// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:medguard/main.dart';
import 'package:medguard/simple_language_service.dart';

void main() {
  testWidgets('MedGuard app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => SimpleLanguageService(),
        child: const MedGuardApp(),
      ),
    );

    // Wait for the app to initialize (with timeout to avoid hanging)
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that the app loads (splash screen or home screen should be visible)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
