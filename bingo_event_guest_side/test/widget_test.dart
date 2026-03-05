// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_event_guest_side/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GuestApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Welcome page displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const GuestApp());

    // Verify the welcome text is displayed
    expect(find.text('Welcome to the Bingo Game!'), findsOneWidget);

    // Verify the Continue button is displayed
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Navigates to Bingo Board on Continue', (WidgetTester tester) async {
    await tester.pumpWidget(const GuestApp());

    // Tap the Continue button
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify the Bingo Board page is displayed
    expect(find.text('Bingo Board'), findsOneWidget);
  });

  testWidgets('Bingo Board displays 25 boxes', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BingoBoardPage()));

    // Verify 25 boxes are displayed
    expect(find.byType(GestureDetector), findsNWidgets(25));
  });
}
