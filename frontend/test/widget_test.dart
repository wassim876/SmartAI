// Widget tests for SmartAI.
//
// The app root (SmartAIApp) bootstraps Supabase and Provider state, so it
// can't be pumped directly in a unit test. These tests cover self-contained
// widgets instead.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smartai/widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton renders its label and fires onPressed',
      (WidgetTester tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Continue',
            onPressed: () => tapped++,
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('PrimaryButton is disabled when onPressed is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Disabled'),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
