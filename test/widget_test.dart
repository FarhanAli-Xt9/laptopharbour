// Laptop Harbour – Smoke Test
//
// Verifies the app starts successfully, the SplashScreen renders,
// and the MaterialApp widget tree is valid.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laptopharbour/main.dart';
import 'package:laptopharbour/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen widget is present on startup',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // App must render without throwing on first frame.
    expect(tester.takeException(), isNull);

    // SplashScreen widget must be in the tree.
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('MyApp widget tree contains MaterialApp',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('SplashScreen branding is rendered as RichText after animation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Pump past the 2-second splash animation so widgets are fully rendered.
    await tester.pump(const Duration(seconds: 3));

    // The brand name uses RichText (LAPTOPHARBOUR with two TextSpans).
    expect(find.byType(RichText), findsWidgets);

    // The tagline uses a plain Text widget.
    expect(find.text('Explore • Compare • Configure'), findsOneWidget);
  });
}

