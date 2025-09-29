// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skuupay/main.dart';
import 'package:skuupay/core/theme/theme_provider.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Setup mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Create theme provider
    final themeProvider = ThemeProvider();
    await themeProvider.initialize(await SharedPreferences.getInstance());

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(themeProvider: themeProvider));

    // Verify that the app loads (look for login page or dashboard)
    expect(find.text('Skuupay'), findsOneWidget);
  });
}
