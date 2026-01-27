// Basic test for RRT App
//
// This test verifies that the app loads with the correct splash screen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rrt_sos/main.dart';

void main() {
  testWidgets('RRT App splash screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RRTApp());

    // Verify that splash screen is displayed
    expect(find.text('RRT SOS Alert'), findsOneWidget);
    expect(find.text('Rapid Response Team'), findsOneWidget);
    expect(find.text('Initializing...'), findsOneWidget);
    expect(find.byIcon(Icons.emergency), findsOneWidget);
  });
}
