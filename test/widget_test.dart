import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:faustina/main.dart';  // adjust if your main.dart file path differs
import 'package:faustina/screens/home_page.dart';

void main() {
  testWidgets('MyApp loads HomePage', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(MyApp());

    // Check that MaterialApp title exists
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Sales & Expenses Tracker');

    // Ensure HomePage is displayed
    expect(find.byType(HomePage), findsOneWidget);

    // Optional: check if something from HomePage is visible
    // Example: if HomePage has a title text "Dashboard"
    // expect(find.text('Dashboard'), findsOneWidget);
  });
}
